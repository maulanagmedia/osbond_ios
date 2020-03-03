//
//  TokenQRController.swift
//  osbond
//
//  Created by gmedia ios dev 2 on 22/03/19.
//  Copyright © 2019 gmedia ios dev 2. All rights reserved.
//

import UIKit
import AVFoundation
import FBSDKLoginKit
import Firebase
import GoogleSignIn

class TokenQRController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    let videoSession = AVCaptureSession()
    var video = AVCaptureVideoPreviewLayer()
    public static var idToken = ""
    let session = SessionManager.getObject()
    @IBOutlet weak var ivQR: UIImageView!
    var pbLoading: progressLoading = progressLoading()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.getQR()
    }
    
    func getQR(){
        
        self.showLoading()
        let url = URL(string: ServerURL.getBarcode)
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.setValue("gmedia_osbondgym", forHTTPHeaderField: "Auth-Key")
        request.setValue(session.getUID(), forHTTPHeaderField: "Uid")
        request.setValue(session.getToken(), forHTTPHeaderField: "Token")
        
        request.httpMethod = "POST"
        let data : [String: Any] =
            ["id_kupon": TokenQRController.idToken]
        
        do{
            
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            
            let jsonStr = String(data:jsonData, encoding: .ascii)
            
            request.httpBody = jsonStr?.data(using: .utf8)
            
        }catch{
            
        }
        
        let proses = URLSession.shared.dataTask(with: request){
            data, response, error in
            
            self.hideLoading()
            if data != nil {
                
                if let jsonValue = String(data: data!, encoding: .ascii){
                    if let jsonData = jsonValue.data(using: .utf8) {
                        
                        do {
                            
                            let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! NSDictionary
                            
                            let metadata = json.value(forKey: "metadata") as? NSDictionary
                            let responseApi = json.value(forKey: "response") as? [String: String]
                            
                            let status = metadata?.value(forKey: "status") as? Int64
                            let message = metadata?.value(forKey: "message") as? String
                            
                            //CustomToast.show(message: message ?? "", controller: self)
                            
                            if status == 200 {
                                
                                DispatchQueue.main.async {
                                    
                                    let urlImage = URL(string: ((responseApi!["url"]))!.replacingOccurrences(of: " ", with: "%20"))
                                    
                                    if urlImage != nil {
                                        
                                        let data = try? Data(contentsOf: urlImage!)
                                        
                                        if let imageData = data {
                                            let image = UIImage(data: imageData)
                                            self.ivQR.image = image
                                        }
                                    }
                                }
                            }else if status == 401 {
                                
                                self.redirectToLogin()
                            }
                            
                        }catch let parsingError{
                            
                            print("Error", parsingError)
                            CustomToast.show(message: parsingError.localizedDescription, controller: self)
                        }
                    }
                }
            }else{
                
                CustomToast.show(message: "Please check your internet connection", controller: self)
            }
        }
        
        proses.resume()
    }
    
    
    @IBAction func onKirimTokenClicked(_ sender: Any) {
    
        // for barcode
        
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            videoSession.addInput(input)
        }catch{
            
            print("Error load camera")
        }
        
        let output = AVCaptureMetadataOutput()
        videoSession.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        video = AVCaptureVideoPreviewLayer(session: videoSession)
        video.frame = view.layer.bounds
        DispatchQueue.main.async {
            
            self.view.layer.addSublayer(self.video)
            self.videoSession.startRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects != nil && metadataObjects.count != 0 {
            
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                
                if object.type == AVMetadataObject.ObjectType.qr {
                    
                    DispatchQueue.main.async {
                        
                        self.shareToken(uidUser: object.stringValue!)
                        self.video.removeFromSuperlayer()
                        self.videoSession.stopRunning()
                    }
                    
                    /*let alert = UIAlertController(title: "QRCode", message: object.stringValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Copy", style: .default, handler: { (nil) in
                        UIPasteboard.general.string = object.stringValue
                        
                        DispatchQueue.main.async {
                            
                        self.video.removeFromSuperlayer()
                            self.videoSession.stopRunning()
                        }
                    }))
                    
                    present(alert, animated: true, completion: nil)*/
                }
            }
        }
    }
    
    func shareToken(uidUser : String){
        
        self.showLoading()
        let url = URL(string: ServerURL.shareToken)
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.setValue("gmedia_osbondgym", forHTTPHeaderField: "Auth-Key")
        request.setValue(session.getUID(), forHTTPHeaderField: "Uid")
        request.setValue(session.getToken(), forHTTPHeaderField: "Token")
        
        request.httpMethod = "POST"
        let data : [String: Any] =
            ["id_kupon": TokenQRController.idToken
                , "uid_user": uidUser
        ]
        
        do{
            
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            
            let jsonStr = String(data:jsonData, encoding: .ascii)
            
            request.httpBody = jsonStr?.data(using: .utf8)
            
        }catch{
            
        }
        
        let proses = URLSession.shared.dataTask(with: request){
            data, response, error in
            
            self.hideLoading()
            if data != nil {
                
                if let jsonValue = String(data: data!, encoding: .ascii){
                    if let jsonData = jsonValue.data(using: .utf8) {
                        
                        do {
                            
                            let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! NSDictionary
                            
                            let metadata = json.value(forKey: "metadata") as? NSDictionary
                            let responseApi = json.value(forKey: "response") as? [String: String]
                            
                            let status = metadata?.value(forKey: "status") as? Int64
                            let message = metadata?.value(forKey: "message") as? String
                            
                            //CustomToast.show(message: message ?? "", controller: self)
                            
                            DispatchQueue.main.async {
                                
                                CustomToast.show(message: message!, controller: self)
                            }
                            
                            if status == 200 {
                                
                            }else if status == 401 {
                                
                                self.redirectToLogin()
                            }
                            
                        }catch let parsingError{
                            
                            print("Error", parsingError)
                            CustomToast.show(message: parsingError.localizedDescription, controller: self)
                        }
                    }
                }
            }else{
                
                CustomToast.show(message: "Please check your internet connection", controller: self)
            }
        }
        
        proses.resume()
    }
    
    func redirectToLogin(){
        
        DispatchQueue.main.async {
            
            ViewController.specialState = 1
            let firebaseAuth = Auth.auth()
            
            // logout FB
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func showLoading(){
        
        DispatchQueue.main.async {
            
            self.pbLoading.showActivityIndicator(uiView: self.view)
        }
    }
    
    func hideLoading(){
        
        DispatchQueue.main.async {
            
            self.pbLoading.hideActivityIndicator(uiView: self.view)
        }
    }
}
