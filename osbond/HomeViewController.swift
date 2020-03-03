//
//  HomeViewController.swift
//  osbond
//
//  Created by gmedia ios dev 2 on 04/03/19.
//  Copyright © 2019 gmedia ios dev 2. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UITextFieldDelegate{

    @IBOutlet weak var btnLogin: BtnLogin!
    
    @IBOutlet weak var btnToken: BtnLogin!
   
    @IBOutlet weak var btnUser: BtnLogin!
    
    @IBOutlet weak var btnBeliToken: BtnLogin!
    
    @IBOutlet weak var collectionHeaderView: UICollectionView!
    @IBOutlet weak var headerPageControl: UIPageControl!
    let session = SessionManager.getObject()
    let TAG = "HOMEVIEW "
    @IBOutlet weak var FreeCuponDialog: UIView!
    @IBOutlet weak var edtNomor: UITextField!
    public static var stateController = 0
    var pbLoading: progressLoading = progressLoading()
    
    /*var imgArr:[String] = [
        "image1.jpg"
        ,"image2.jpg"
        ,"image3.jpg"
        ,"image4.jpg"
        ,"image5.jpg"
        ,"image6.jpg"
    ]*/
    
    var listHeader = [CustomItem]()
    
    var timer = Timer()
    var counter = 0
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let newHight = collectionView.bounds.size.height
        return CGSize(width: collectionView.bounds.size.width, height: CGFloat(newHight))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return listHeader.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HeaderViewCell
        
        let customItem = listHeader[indexPath.row]
        let urlImage = URL(string: (customItem.item1).replacingOccurrences(of: " ", with: "%20"))
        
        if urlImage != nil {
         
            let data = try? Data(contentsOf: urlImage!)
            
            if let imageData = data {
                let image = UIImage(data: imageData)
                cell.ivHeader.image = image
            }
        }else{
            
            print(TAG+customItem.item1)
        }
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Customise textfield
        let myColor = UIColor.white
        edtNomor.layer.borderColor = myColor.cgColor
        edtNomor.layer.borderWidth = 1.0
        
        edtNomor.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(sender:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(sender:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.btnLogin.titleLabel?.minimumScaleFactor = 0.5;
        self.btnLogin.titleLabel?.adjustsFontSizeToFitWidth = true;
        
        self.btnToken.titleLabel?.minimumScaleFactor = 0.5;
        self.btnToken.titleLabel?.adjustsFontSizeToFitWidth = true;
        
        self.btnUser.titleLabel?.minimumScaleFactor = 0.5;
        self.btnUser.titleLabel?.adjustsFontSizeToFitWidth = true;
        
        self.btnBeliToken.titleLabel?.minimumScaleFactor = 0.5;
        self.btnBeliToken.titleLabel?.adjustsFontSizeToFitWidth = true;

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
    
    override func viewWillAppear(_ animated: Bool) {
        
        if HomeViewController.stateController != 0 {
            
            if HomeViewController.stateController == 2 {
                
                DispatchQueue.main.async {
                    
                    self.performSegue(withIdentifier: "segToken", sender: self)
                }
            }
            HomeViewController.stateController = 0
        }
        headerPageControl.numberOfPages = listHeader.count
        if listHeader.count > 0
        {
            headerPageControl.currentPage = 0
        }
        
        self.FreeCuponDialog.isHidden = true
        
        if !session.isLogin() {
            
            self.redirectToLogin()
            
        }else{
            self.getHeaderImages()
        }
    }
    
    @objc func changeImage() {
        
        if listHeader.count > 0 {
        
            if counter < listHeader.count {
                let index = IndexPath.init(item: counter, section: 0)
                self.collectionHeaderView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
                //headerPageControl.currentPage = counter
                counter += 1
            } else {
                counter = 0
                let index = IndexPath.init(item: counter, section: 0)
                self.collectionHeaderView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
                //headerPageControl.currentPage = counter
                counter = 1
            }
        }
        
    }
    
    func getHeaderImages(){
        
        self.showLoading()
        let url = URL(string: ServerURL.getImageSlider)
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.setValue("gmedia_osbondgym", forHTTPHeaderField: "Auth-Key")
        request.setValue(session.getUID(), forHTTPHeaderField: "Uid")
        request.setValue(session.getToken(), forHTTPHeaderField: "Token")
        request.httpMethod = "GET"
        
        let proses = URLSession.shared.dataTask(with: request){
            data, response, error in
            
            self.hideLoading()
            if data != nil {
                
                if let jsonValue = String(data: data!, encoding: .ascii){
                    if let jsonData = jsonValue.data(using: .utf8) {
                        
                        do {
                            
                            self.listHeader.removeAll()
                            let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! NSDictionary
                            
                            let metadata = json.value(forKey: "metadata") as? NSDictionary
                            let responseApi = json.value(forKey: "response") as? NSArray
                            
                            let status = metadata?.value(forKey: "status") as? Int64
                            let message = metadata?.value(forKey: "message") as? String
                            
                            if status == 200 {
                                
                                for jo in responseApi! {
                                    
                                    let dataRow = jo as? [String: String]
                                    self.listHeader.append(CustomItem(item1: (dataRow?["picture"])!))
                                }
                                
                                
                                
                                DispatchQueue.main.async {
                                    
                                    self.collectionHeaderView.reloadData()
                                    self.headerPageControl.numberOfPages = self.listHeader.count
                                    
                                    if self.timer != nil {
                                        self.timer.invalidate()
                                        self.timer = Timer()
                                    }
                                    self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
                                }
                                
                            }else if status == 401{
                                
                                self.redirectToLogin()
                            }else{
                                CustomToast.show(message: message ?? "", controller: self)
                            }
                            
                        }catch let parsingError{
                            
                            print("Error", parsingError)
                            CustomToast.show(message: parsingError.localizedDescription, controller: self)
                        }
                    }
                }
            }else{
                
                self.hideLoading()
                CustomToast.show(message: "Please check your internet connection", controller: self)
            }
            
            self.getKuponGratis()
        }
        
        proses.resume()
    }
    
    func getKuponGratis(){
        
        self.showLoading()
        let url = URL(string: ServerURL.getFreeCupon)
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.setValue("gmedia_osbondgym", forHTTPHeaderField: "Auth-Key")
        request.setValue(session.getUID(), forHTTPHeaderField: "Uid")
        request.setValue(session.getToken(), forHTTPHeaderField: "Token")
        request.httpMethod = "GET"
        
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
                            
                            if status == 200 {
                                
                                let settingFreeToken = responseApi?["setting"];
                                let isGetToken = responseApi?["verify"];
                                
                                if settingFreeToken == "1" {
                                    
                                    if isGetToken == "0" {
                                        
                                        DispatchQueue.main.async {
                                            self.FreeCuponDialog.isHidden = false
                                        }
                                    }
                                }
                                
                            }else{
                                CustomToast.show(message: message ?? "", controller: self)
                            }
                            
                        }catch let parsingError{
                            
                            print("Error", parsingError)
                            CustomToast.show(message: parsingError.localizedDescription, controller: self)
                        }
                    }
                }
            }else{
                
                self.hideLoading()
                CustomToast.show(message: "Please check your internet connection", controller: self)
            }
        }
        
        proses.resume()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerPageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    
    @IBAction func onTokenClicked(_ sender: Any) {
        
        
        
    }
    
    @IBAction func OnSkipClicked(_ sender: Any) {
        
        self.FreeCuponDialog.isHidden = true
    }
    
    @IBAction func onOkFreeCuponClicked(_ sender: Any) {
        
        
        if (self.edtNomor.text?.isEmpty)! {
            
            CustomToast.show(message: "Harap isi nomor anda", controller: self)
            return
        }
        
        // Kirim otp
        let url = URL(string: ServerURL.getOTP)
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.setValue("gmedia_osbondgym", forHTTPHeaderField: "Auth-Key")
        request.setValue(session.getUID(), forHTTPHeaderField: "Uid")
        request.setValue(session.getToken(), forHTTPHeaderField: "Token")
        
        let data : [String: Any] =
            ["nomor": edtNomor.text ?? ""]
        
        do{
            
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            
            let jsonStr = String(data:jsonData, encoding: .ascii)
            
            request.httpBody = jsonStr?.data(using: .utf8)
            
            request.httpMethod = "POST"
            
        }catch{
            
        }
        
        let proses = URLSession.shared.dataTask(with: request){
            data, response, error in
            
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
                                    
                                    HomeOTPFreeCupon.setTimerCount(count: (expired ?? "0"), nomor: (self.edtNomor.text ?? ""))
                                    self.FreeCuponDialog.isHidden = true
                                    self.performSegue(withIdentifier: "segOTP", sender: self)
                                }
                            }else if status == 401{
                                
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

    @IBAction func setOnBeliTokenClicked(_ sender: Any) {
        
        let popUp = BuyTokenController.create()
        let sbPopup = SBCardPopupViewController(contentViewController: popUp)
        sbPopup.show(onViewController: self)
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
