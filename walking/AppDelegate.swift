//
//  AppDelegate.swift
//  walking
//
//  Created by koyasu on 2021/12/22.
//

import UIKit
import YammerSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        YMLoginClient.sharedInstance().appClientID = "5KFoSJHaXkuOsDcrqQC1w"
        YMLoginClient.sharedInstance().appClientSecret = "RWyuyOJAhPHSBAk66WzgQJPGwX8DtufREiIoHHV30g"
        YMLoginClient.sharedInstance().authRedirectURI = "msauth.com.microsoft.identitysample.msalios://auth"
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

