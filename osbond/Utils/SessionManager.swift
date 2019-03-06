//
//  SessionManager.swift
//  osbond
//
//  Created by gmedia ios dev 2 on 21/02/19.
//  Copyright © 2019 gmedia ios dev 2. All rights reserved.
//

import UIKit
import CoreData

class SessionManager: NSObject {

    let userDef = UserDefaults.standard
    /*var uid: String = ""
    var email: String = ""
    var displayName: String = ""
    var foto: String = ""
    var type: String = ""
    var fcmId: String = ""*/
    
    let TAG_UID: String = "uid";
    let TAG_EMAIL: String = "email";
    let TAG_NAME: String = "displayname";
    let TAG_TYPE: String = "type";
    let TAG_TOKEN: String = "token";
    
    public func saveSession(uid: String, email: String, displayName: String, token: String){
        
        self.userDef.set(uid, forKey: TAG_UID)
        self.userDef.set(email, forKey: TAG_EMAIL)
        self.userDef.set(displayName, forKey: TAG_NAME)
        self.userDef.set(token, forKey: TAG_TOKEN)
    }
    
    public func saveSession(uid: String, email: String, displayName: String, type: String){
        
        self.userDef.set(uid, forKey: TAG_UID)
        self.userDef.set(email, forKey: TAG_EMAIL)
        self.userDef.set(displayName, forKey: TAG_NAME)
        self.userDef.set(type, forKey: TAG_TYPE)
    }
    
    public func updateUID(uid: String){
        
        self.userDef.set(uid, forKey: TAG_UID)
    }
    
    public func updateToken(token: String){
        
        self.userDef.set(token, forKey: TAG_TOKEN)
    }
    
    public func removeSession(){
        
        self.userDef.set("", forKey: TAG_UID)
        self.userDef.set("", forKey: TAG_EMAIL)
        self.userDef.set("", forKey: TAG_NAME)
        self.userDef.set("", forKey: TAG_TYPE)
    }
    
    func getToken() -> String {
        return (userDef.string(forKey: TAG_TOKEN) ?? "")
    }
    
    func getUID() -> String {
        return (userDef.string(forKey: TAG_UID) ?? "")
    }
    
    func getEmail() -> String {
        return (userDef.string(forKey: TAG_EMAIL) ?? "")
    }
    
    func getName() -> String {
        return (userDef.string(forKey: TAG_NAME) ?? "")
    }
    
    func isLogin() -> Bool{
        
        let uid = self.getUID()
        
        if uid == "" {
            
            return false
        }else{
            
            return true
        }
    }
}
