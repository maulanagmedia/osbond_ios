//
//  HomeOTPFreeCupon.swift
//  osbond
//
//  Created by gmedia ios dev 2 on 08/03/19.
//  Copyright © 2019 gmedia ios dev 2. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn

class HomeOTPFreeCupon: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tvTimer: UILabel!
    
    @IBOutlet weak var tf1: UITextField!
    @IBOutlet weak var tf2: UITextField!
    @IBOutlet weak var tf3: UITextField!
    @IBOutlet weak var tf4: UITextField!
    @IBOutlet weak var btnKirimUlangOTP: UIButton!
    let session = SessionManager.getObject()
    let maxLength = 1
    
    static var timerCount = 0
    static var nomor = ""
    var timer = Timer()
    var pbLoading: progressLoading = progressLoading()
    
    public static func setTimerCount(count: String, nomor: String){
        
        timerCount = (Int(count) ?? 0) * 60
        HomeOTPFreeCupon.nomor = nomor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tf4.delegate = self
        self.runTimer()
        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(sender:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(sender:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        
        DispatchQueue.main.async {
            self.view.frame.origin.y = -150 // Move view 150 points upward
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        
        DispatchQueue.main.async {
            self.view.frame.origin.y = 0 // Move view to original position
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func updateTimer() {
        
        if(HomeOTPFreeCupon.timerCount <= 0) {
            
            if self.timer != nil {
                
                self.timer.invalidate()
                //self.timer = nil
            }
            
            tvTimer.text = "OTP is expired"
            btnKirimUlangOTP.isHidden = false
        }else{
         
            HomeOTPFreeCupon.timerCount -= 1     //This will decrement(count down)the seconds.
            tvTimer.text = timeString(time: TimeInterval(HomeOTPFreeCupon.timerCount))
            btnKirimUlangOTP.isHidden = true
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    func runTimer() {
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(HomeOTPFreeCupon.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @IBAction func onTF1Changed(_ sender: Any) {
        
        if (self.tf1.text!.characters.count > maxLength) {
            self.tf1.deleteBackward()
        }
        
        if self.tf1.text?.count ?? 0 > 0 {
            
            self.tf2.becomeFirstResponder()
        }
    }
    
    @IBAction func onFT2Changed(_ sender: Any) {
        
        if (self.tf2.text!.characters.count > maxLength) {
            self.tf2.deleteBackward()
        }
        
        if self.tf2.text?.count ?? 0 > 0 {
            
            self.tf3.becomeFirstResponder()
        }else{
            
            self.tf1.becomeFirstResponder()
        }
    }
    
    
    @IBAction func onFT3Changed(_ sender: Any) {
    
        if (self.tf3.text!.characters.count > maxLength) {
            self.tf3.deleteBackward()
        }
        
        if self.tf3.text?.count ?? 0 > 0 {
            
            self.tf4.becomeFirstResponder()
        }else{
            
            self.tf2.becomeFirstResponder()
        }
    }
    
    
    @IBAction func onFT4Changed(_ sender: Any) {
        
        if (self.tf4.text!.characters.count > maxLength) {
            self.tf4.deleteBackward()
        }
        
        if self.tf4.text?.count ?? 0 > 0 {
            
        }else{
            
            self.tf3.becomeFirstResponder()
        }
    }
    
    @IBAction func onUpdateOTPClicked(_ sender: Any) {
        
        // Kirim otp
        self.showLoading()
        let url = URL(string: ServerURL.getOTP)
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.setValue("gmedia_osbondgym", forHTTPHeaderField: "Auth-Key")
        request.setValue(session.getUID(), forHTTPHeaderField: "Uid")
        request.setValue(session.getToken(), forHTTPHeaderField: "Token")
        
        let data : [String: Any] =
            ["nomor": HomeOTPFreeCupon.nomor ?? ""]
        
        do{
            
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            
            let jsonStr = String(data:jsonData, encoding: .ascii)
            
            request.httpBody = jsonStr?.data(using: .utf8)
            
            request.httpMethod = "POST"
            
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
                            
                            CustomToast.show(message: message ?? "", controller: self)
                            
                            if status == 200 {
                                
                                let expired = responseApi?["expired"];
                                DispatchQueue.main.async {
                                    
                                    HomeOTPFreeCupon.setTimerCount(count: (expired ?? "0"), nomor: HomeOTPFreeCupon.nomor)
                                    
                                    self.runTimer()
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
    
    
    @IBAction func setOnVerifikasiClicked(_ sender: Any) {
    
        let alert = UIAlertController(title: "Konfirmasi", message: "Anda yakin ingin memverifikasi nomor anda?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
                self.saveOTP()
            }))
        
        alert.addAction(UIAlertAction(title: "Batal", style: .default, handler: { action in


        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveOTP(){
        
        self.showLoading()
        let url = URL(string: ServerURL.checkOTP)
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.setValue("gmedia_osbondgym", forHTTPHeaderField: "Auth-Key")
        request.setValue(session.getUID(), forHTTPHeaderField: "Uid")
        request.setValue(session.getToken(), forHTTPHeaderField: "Token")
        
        let data : [String: Any] =
            ["otp": (String.init(format: "%@%@%@%@", tf1.text ?? "",tf2.text ?? "",tf3.text ?? "",tf4.text ?? ""))]
        
        do{
            
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            
            let jsonStr = String(data:jsonData, encoding: .ascii)
            
            request.httpBody = jsonStr?.data(using: .utf8)
            
            request.httpMethod = "POST"
            
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
                            
                            DispatchQueue.main.async {
                                CustomToast.show(message: message ?? "", controller: self)
                                
                            }
                            
                            if status == 200 {
                                
                                DispatchQueue.main.async {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }else if status == 401 {
                                
                                self.redirectToLogin()
                            }
                            
                        }catch let parsingError{
                            
                            self.hideLoading()
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
    
}
