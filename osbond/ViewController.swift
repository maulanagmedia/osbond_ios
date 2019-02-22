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

class ViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate, GIDSignInDelegate{

    let TAG = "MAINVIEW "
    let session = SessionManager()
    var currentUser: User? = nil
    var typeLogin: String = "GOOGLE"
    var pbLoading: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var btnLoginGoogle: GIDSignInButton!
    @IBOutlet weak var btnLoginFb: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        btnLoginFb.isHidden = true
        btnLoginGoogle.isHidden = true
        btnLoginFb.delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        // check session
        if session.isLogin() {
            print("sudah")
        }else{
            print("belum")
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
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error == nil{
            
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
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
                self.currentUser = authResult?.user
                self.doLogin()
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
            self.currentUser = authResult?.user
            self.doLogin()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User logout")
    }
    
    func doLogin(){
        
        //self.showLoading()
        let url = URL(string: ServerURL.login)
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.setValue("gmedia_osbondgym", forHTTPHeaderField: "Auth-Key")
        
        let data : [String: Any] =
            ["uid": currentUser?.uid ?? ""]
        
        do{
            
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            
            let jsonStr = String(data:jsonData, encoding: .ascii)
            
            request.httpBody = jsonStr?.data(using: .utf8)
            
            request.httpMethod = "POST"
            
        }catch{
            
        }
        
        let proses = URLSession.shared.dataTask(with: request){
            data, response, error in
            
            //self.hideLoading()
            
            if let jsonValue = String(data: data!, encoding: .ascii){
                if let jsonData = jsonValue.data(using: .utf8) {
                 
                    do {
                        
                        let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! NSDictionary
                        
                        let metadata = json.value(forKey: "metadata") as? NSDictionary
                        let responseApi = json.value(forKey: "response") as? [String : String]
                        
                        let status = metadata?.value(forKey: "status") as? Int64
                        let message = metadata?.value(forKey: "message") as? String
                        
                        if status == 200 { // existing user
                         
                            CustomToast.show(message: message ?? "", controller: self)
                           
                        }else if status == 404 { // new User
                            
                            CustomToast.show(message: message ?? "", controller: self)
                        }
                        else{
                            CustomToast.show(message: "Terjadi kesalalahan saat memuat data, harap ulangi kembali", controller: self)
                        }
                        
                    }catch let parsingError{
                        
                        print("Error", parsingError)
                    }
                }
            }
//            DispatchQueue.main.async {
//                self.navigationController?.popViewController(animated: true)
//            }
        }
        
        proses.resume()
    }
    
    
    func showLoading(){
        
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        pbLoading = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        pbLoading.hidesWhenStopped = true
        pbLoading.style = UIActivityIndicatorView.Style.gray
        pbLoading.startAnimating();
        
        alert.view.addSubview(pbLoading)
        present(alert, animated: true, completion: nil)
        
    }
    
    func hideLoading(){
        
        dismiss(animated: false, completion: nil)
        pbLoading.stopAnimating()
    }
    
}

