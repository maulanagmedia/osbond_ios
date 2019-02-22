//
//  AppDelegate.swift
//  osbond
//
//  Created by gmedia ios dev 2 on 18/02/19.
//  Copyright © 2019 gmedia ios dev 2. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn

// notification
/*import FirebaseCore
import FirebaseMessaging
import FirebaseInstanceID
import UserNotifications*/

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , GIDSignInDelegate/*, MessagingDelegate, UNUserNotificationCenterDelegate*/{
    
    let tag = "APPDEL : "

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        // ...
        if error != nil {
            print(tag + error.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // ...
    }

    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
        print(tag + "User disconnect from google")
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    var window: UIWindow?

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        // Firebase Notification
        /*UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound, .badge]) { (isGranted, err) in
            if err != nil {
                
            }else{
                UNUserNotificationCenter.current().delegate = self
                Messaging.messaging().delegate = self
                application.registerForRemoteNotifications()
                FirebaseApp.configure()
            }
        }*/
        return true
    }
    
    /*func connectToFCM(){
        
        Messaging.messaging().shouldEstablishDirectChannel = true
    }*/

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        /*Messaging.messaging().shouldEstablishDirectChannel = false*/
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        /*connectToFCM()*/
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    /*func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let newToken = InstanceID.instanceID().token()
        connectToFCM()
    }*/
}

