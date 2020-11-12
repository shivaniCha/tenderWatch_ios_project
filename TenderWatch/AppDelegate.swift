//
//  AppDelegate.swift
//  TenderWatch
//
//  Created by mac2019_17 on 27/04/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import UserNotifications
import FirebaseMessaging
import FBSDKCoreKit
import IQKeyboardManagerSwift
import Braintree


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate,MessagingDelegate {
    
    //MARK:- Variable
    var window: UIWindow?
    
    //MARK:- application life cycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //enable iqkeyboard
        IQKeyboardManager.shared.enable = true
        
        //setup brain tree
        BTAppSwitch.setReturnURLScheme("com.app.Pier21NationalHistoricSite.payments")
        
        // Initialize sign-in
        GIDSignIn.sharedInstance().clientID = GOOGLE_CLIENT_ID
        FirebaseApp.configure()
        
        //take permission for notification
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        
        //Decide root
        //if user is logged in then navigate to "Dashboard Screen"
       if utils.getLoginUserData() != nil
        {
            let dashboardClientTenderListVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "DashboardClientTenderListVC") as! DashboardClientTenderListVC
            let navigation = UINavigationController.init(rootViewController: dashboardClientTenderListVC)
           
            self.window?.rootViewController = navigation

        }
        else
        {
            let userSelectionVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "UserSelectionVC") as! UserSelectionVC
            let navigation = UINavigationController.init(rootViewController: userSelectionVC)
           
            self.window?.rootViewController = navigation
        }
        
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    //MARK:- Open url
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        
        
        //For FB
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        return GIDSignIn.sharedInstance().handle(url)  //For Google
    }
    
    
    //MARK:- firebase method
    private func application(application: UIApplication,
                             didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        //store FCM token
        utils.setFcmToken(fcmToken: fcmToken)
        
    }
    
}

