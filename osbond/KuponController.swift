//
//  KuponController.swift
//  osbond
//
//  Created by gmedia ios dev 2 on 21/03/19.
//  Copyright © 2019 gmedia ios dev 2. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn

class KuponController: UIViewController, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listToken.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tbToken.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TokenViewCell
        
        let customItem = listToken[indexPath.row]
        
        cell.l_cabang.text = customItem.item3
        if customItem.item5 == "1" { // jenis tiket tanpa keterangan
            
            cell.iv_logoright.isHidden = false
            cell.l_token.isHidden = false
            
            cell.l_token.text = customItem.item4
            if customItem.item2 == "0" { 
            
                cell.iv_bgtoken.image = UIImage(named: "token_gold")!
            }else{
                
                cell.iv_bgtoken.image = UIImage(named: "token_silver")!
            }
            
        }else if customItem.item5 == "2" {
            
            cell.iv_bgtoken.image = UIImage(named: "token_silver")!
            cell.iv_logocenter.isHidden = false
            cell.l_package.isHidden = false
            cell.v_description.isHidden = false
            cell.l_timeleft.isHidden = false
            
            //cell.l_package.text = customItem.item4
            cell.l_duedate.text = ItemValidation().ChangeFormatDate(date: customItem.item7, from: FormatDate.timestamp, to: FormatDate.dateDisplay)
            cell.l_used.text = customItem.item6
            
        }else if customItem.item5 == "7" { //event
            
            cell.iv_bgtoken.image = UIImage(named: "token_event")!
            cell.l_package.isHidden = false
            cell.l_package.textAlignment = NSTextAlignment.right
            cell.l_package.text = customItem.item4
        }
        
        let lastElement = listToken.count - 1
        if !isLoading && indexPath.row == lastElement {
            
            isLoading = true
            self.start = self.start + self.count
            self.getTokenList()
        }
        
        return cell
    }
    
    @IBOutlet weak var tbToken: UITableView!
    let session = SessionManager.getObject()
    let count = 10
    var start = 0
    var listToken = [CustomItem]()
    var isLoading = false
    var pbLoading: progressLoading = progressLoading()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        start = 0
        self.getTokenList()
    }
    
    func getTokenList(){
        
        self.isLoading = true
        if self.start == 0 {
            self.showLoading()
        }
        let url = URL(string: ServerURL.getToken)
        var request = URLRequest(url: url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("frontend-client", forHTTPHeaderField: "Client-Service")
        request.setValue("gmedia_osbondgym", forHTTPHeaderField: "Auth-Key")
        request.setValue(session.getUID(), forHTTPHeaderField: "Uid")
        request.setValue(session.getToken(), forHTTPHeaderField: "Token")
        request.httpMethod = "POST"
        
        let data : [String: Any] =
            ["start": start,
             "count": count]
        
        do{
            
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            
            let jsonStr = String(data:jsonData, encoding: .ascii)
            
            request.httpBody = jsonStr?.data(using: .utf8)
            
        }catch{
            
        }
        
        let proses = URLSession.shared.dataTask(with: request){
            data, response, error in
            
            self.isLoading = false
            
            if self.start == 0 {
                self.hideLoading()
            }
            
            if data != nil {
                
                if let jsonValue = String(data: data!, encoding: .ascii){
                    if let jsonData = jsonValue.data(using: .utf8) {
                        
                        do {
                            
                            if self.start == 0 {
                                
                                self.listToken.removeAll()
                            }
                            
                            let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! NSDictionary
                            
                            let metadata = json.value(forKey: "metadata") as? NSDictionary
                            let responseApi = json.value(forKey: "response") as? NSArray
                            
                            let status = metadata?.value(forKey: "status") as? Int64
                            let message = metadata?.value(forKey: "message") as? String
                            
                            if status == 200 {
                                
                                for jo in responseApi! {
                                    
                                    let dataRow = jo as? [String: String]
                                    self.listToken.append(CustomItem(item1: (dataRow?["id"])!
                                        ,item2: (dataRow?["id_cabang"])!
                                        ,item3: (dataRow?["cabang"])!
                                        ,item4: (dataRow?["paket"])!
                                        ,item5: (dataRow?["jenis"])!
                                        ,item6: (dataRow?["jumlah_scan"])!
                                        ,item7: (dataRow?["end"])!
                                    ))
                                }
                                
                                DispatchQueue.main.async {
                                    
                                    self.tbToken.reloadData()
                                }
                                
                            }else if status == 401 {
                                
                                self.redirectToLogin()
                            }else if status == 404 && self.start != 0 {
                                
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
                
                CustomToast.show(message: "Please check your internet connection", controller: self)
            }
        }
        
        proses.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segDetail" {
        
            let index = self.tbToken.indexPathForSelectedRow
            let item = listToken[(index?.row)!]
            
            TokenQRController.idToken = item.item1
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
