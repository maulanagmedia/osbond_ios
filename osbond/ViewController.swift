//
//  ViewController.swift
//  osbond
//
//  Created by gmedia ios dev 2 on 18/02/19.
//  Copyright © 2019 gmedia ios dev 2. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn

class ViewController: UIViewController, LoginButtonDelegate, GIDSignInUIDelegate, GIDSignInDelegate{

    let TAG = "MAINVIEW "
    let session = SessionManager.getObject()
    var currentUser: User? = nil
    var typeLogin: String = "GOOGLE"
    var pbLoading: progressLoading = progressLoading()
    
    @IBOutlet weak var btnToMain: UIButton!
    @IBOutlet weak var btnLoginGoogle: GIDSignInButton!
    @IBOutlet weak var btnLoginFb: FBLoginButton!
    public static var specialState = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        btnLoginFb.isHidden = true
        btnLoginGoogle.isHidden = true
        btnLoginFb.delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // check session
        if session.isLogin() {
            print("sudah login")
        }else{
            print("belum login")
        }
        
        if ViewController.specialState == 1 {
           
            ViewController.specialState = 0
            CustomToast.show(message: "Your session has timed out. Please login again", controller: self)
            
        }
        
        // Check is already login with sosmed
        if Auth.auth().currentUser != nil {
            
            print(TAG+"Dari View")
            currentUser = Auth.auth().currentUser
            doLogin()
        } else {
            print(TAG+"belum")
        }
    }
    
    @IBAction func onLoginGoogle(_ sender: Any) {
        
        //GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func btnUIFB(_ sender: Any) {
        
        btnLoginFb.sendActions(for: .touchUpInside)
    }
    
    @IBAction func btnUIGoogle(_ sender: Any) {
        
        btnLoginGoogle.sendActions(for: .touchUpInside)
    }
    
    // FB feedback authentication
    func loginButton(_ loginButton: FBLoginButton!, didCompleteWith result: LoginManagerLoginResult!, error: Error!) {
        if error == nil{
            
            if AccessToken.current?.tokenString != nil {
                
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                
                Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                    if let error = error {
                        
                        print(error.localizedDescription)
                        print("----------gagal fb--------------")
                        return
                    }
                    
                    print("email :" + (authResult?.user.email ?? ""))
                    print("nama  :" + (authResult?.user.displayName ?? ""))
                    print("foto  :" + (authResult?.user.photoURL?.absoluteString ?? ""))
                    
                    print(self.TAG+"Dari FB")
                    self.typeLogin = "FACEBOOK"
                    self.currentUser = authResult!.user
                    self.doLogin()
                    
                }
            }
            
        }else{
            
            print((error.localizedDescription))
            print("----------gagal login fb--------------")
        }
    }
    
    // Feedback Authentication from google
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if error != nil {
            
            print(error?.localizedDescription ?? "")
            print("----------gagal login google--------------")
            return
        }
        
        guard let authentication = user.authentication else { return }
        
        if authentication.idToken != nil && authentication.accessToken != nil {
            
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if error != nil {
                    print("----------gagal login google--------------")
                    return
                }
                
                print("email :" + (authResult?.user.email ?? ""))
                print("nama  :" + (authResult?.user.displayName ?? ""))
                print("foto  :" + (authResult?.user.photoURL?.absoluteString ?? ""))
                
                print(self.TAG+"Dari G")
                self.typeLogin = "GOOGLE"
                self.currentUser = authResult!.user
                self.doLogin()
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton!) {
        print("User logout")
    }
    
    func doLogin(){
        
        self.showLoading()
        let url = URL(string: ServerURL.login)
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.setValue("gmedia_osbondgym", forHTTPHeaderField: "Auth-Key")
        
        if currentUser != nil && currentUser?.uid != nil {
            
            //let photoUrl =  String(describing: currentUser!.photoURL)
            
            var tempPhotoURL : String!
            
            tempPhotoURL = String.init(format: "%@", currentUser!.photoURL! as CVarArg)
            
            var fcmToken = Messaging.messaging().fcmToken!
            
            InstanceID.instanceID().instanceID { (result, error) in
                if let error = error {
                    
                    print("Error fetching remote instance ID: \(error)")
                } else if let result = result {
                    
                    print("Remote instance ID token: \(result.token)")
                    fcmToken = result.token
                }
            }
            
            Messaging.messaging().subscribe(toTopic: "osbond") { error in
                print("Subscribed to osbond topic")
            }
            
            let data : [String: Any] =
                ["uid": currentUser!.uid
                    ,"foto": tempPhotoURL
                    ,"fcm_id": fcmToken
            ]
            
            //print("Token :" + fcmToken!)
            
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
                                let responseApi = json.value(forKey: "response") as? [String : String]
                                
                                let status = metadata!.value(forKey: "status") as! Int64
                                let message = metadata!.value(forKey: "message") as! String
                                
                                if status == 200 { // existing user
                                    
                                    CustomToast.show(message: message, controller: self)
                                    let token = responseApi!["token"]!
                                    
                                    let uid = self.currentUser!.uid
                                    
                                    if uid != "" {
                                        
                                        self.session.saveSession(uid: self.currentUser!.uid, email: self.currentUser!.email ?? "", displayName: self.currentUser!.displayName ?? "", token: token)
                                        self.redirectToMain()
                                    }else{
                                        
                                        CustomToast.show(message: "Terjadi kesahalan, harap login kembali", controller: self)
                                    }
                                    
                                }else if status == 404 { // new User
                                    
                                    self.doRegister()
                                }
                                else{
                                    CustomToast.show(message: "Terjadi kesalalahan saat memuat data, harap ulangi kembali", controller: self)
                                }
                                
                            }catch let parsingError{
                                
                                print("Error", parsingError)
                            }
                        }
                    }
                }else{
                    
                    CustomToast.show(message: "Please check your internet connection", controller: self)
                }
                
                //            DispatchQueue.main.async {
                //                self.navigationController?.popViewController(animated: true)
                //            }
            }
            
            proses.resume()
        }
    }
    
    
    func doRegister(){
        
        self.showLoading()
        let url = URL(string: ServerURL.register)
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.setValue("gmedia_osbondgym", forHTTPHeaderField: "Auth-Key")
        
        var fcmToken = ""
        if Messaging.messaging().fcmToken != nil {
            fcmToken = Messaging.messaging().fcmToken ?? ""
        }
        
        var photoUrl : String!
        
        photoUrl = String.init(format: "%@", currentUser!.photoURL! as CVarArg)
        
        let data : [String: Any] =
            ["uid": (currentUser!.uid)
                ,"email": currentUser!.email ?? ""
                ,"profile_name": currentUser!.displayName ?? ""
                ,"foto": photoUrl
                ,"type": typeLogin
                ,"fcm_id": fcmToken
                ,"insert_at": ""
                ,"user_insert": currentUser!.uid
        ]
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
                            let responseApi = json.value(forKey: "response") as? [String : String]
                            
                            let status = metadata!.value(forKey: "status") as? Int64
                            let message = metadata!.value(forKey: "message") as! String
                            
                            if status == 200 { // berhasil register
                                
                                let token = responseApi?["token"] ?? ""
                                
                                let uid = self.currentUser?.uid ?? ""
                                
                                if uid != "" {
                                    
                                    self.session.saveSession(uid: self.currentUser!.uid, email: self.currentUser!.email ?? "", displayName: self.currentUser!.displayName ?? "", token: token)
                                    CustomToast.show(message: message, controller: self)
                                    self.redirectToMain()
                                }else{
                                    
                                    CustomToast.show(message: "Terjadi kesahalan, harap login kembali", controller: self)
                                }
                                
                                
                            }else{
                                CustomToast.show(message: message, controller: self)
                            }
                            
                        }catch let parsingError{
                            
                            print("Error", parsingError)
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
    
    func redirectToMain(){
        //btnToMain.sendActions(for: .touchUpInside)
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "segToMain", sender: self)
        }
    }
    
}

