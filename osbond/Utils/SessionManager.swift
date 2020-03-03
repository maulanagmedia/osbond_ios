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

    public static let userDef = UserDefaults.standard
    /*var uid: String = ""
    var email: String = ""
    var displayName: String = ""
    var foto: String = ""
    var type: String = ""
    var fcmId: String = ""*/
    
    static let session = SessionManager()
    
    class func getObject()->SessionManager{
        
        return session;
    }
    
    let TAG_UID: String = "uid";
    let TAG_EMAIL: String = "email";
    let TAG_NAME: String = "displayname";
    let TAG_TYPE: String = "type";
    let TAG_TOKEN: String = "token";
    
    public func saveSession(uid: String, email: String, displayName: String, token: String){
        
        SessionManager.userDef.set(uid, forKey: TAG_UID)
        SessionManager.userDef.set(email, forKey: TAG_EMAIL)
        SessionManager.userDef.set(displayName, forKey: TAG_NAME)
        SessionManager.userDef.set(token, forKey: TAG_TOKEN)
    }
    
    public func saveSessionType(uid: String, email: String, displayName: String, type: String){
        
        SessionManager.userDef.set(uid, forKey: TAG_UID)
        SessionManager.userDef.set(email, forKey: TAG_EMAIL)
        SessionManager.userDef.set(displayName, forKey: TAG_NAME)
        SessionManager.userDef.set(type, forKey: TAG_TYPE)
    }
    
    public func updateUID(uid: String){
        
        SessionManager.userDef.set(uid, forKey: TAG_UID)
    }
    
    public func updateToken(token: String){
        
        SessionManager.userDef.set(token, forKey: TAG_TOKEN)
    }
    
    public func removeSession(){
        
        SessionManager.userDef.set("", forKey: TAG_UID)
        SessionManager.userDef.set("", forKey: TAG_EMAIL)
        SessionManager.userDef.set("", forKey: TAG_NAME)
        SessionManager.userDef.set("", forKey: TAG_TYPE)
    }
    
    public func getToken() -> String {
        return (SessionManager.userDef.string(forKey: TAG_TOKEN) ?? "")
    }
    
    public func getUID() -> String {
        return (SessionManager.userDef.string(forKey: TAG_UID) ?? "")
    }
    
    public func getEmail() -> String {
        return (SessionManager.userDef.string(forKey: TAG_EMAIL) ?? "")
    }
    
    public func getName() -> String {
        return (SessionManager.userDef.string(forKey: TAG_NAME) ?? "")
    }
    
    public func isLogin() -> Bool{
        
        let uid = self.getUID()
        
        if uid == "" {
            
            return false
        }else{
            
            return true
        }
    }
}
