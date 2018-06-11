//
//  AppDelegate.swift
//  Echowaves
//
//  Created by D on 10/18/17.
//  Copyright © 2017 EchoWaves. All rights reserved.
//

import Fabric
import Crashlytics
import Branch
import Alamofire
import UserNotifications


import UIKit
import SwiftKeychainWrapper


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var uuid: String?
    var tandc = false
    //    static let HOST = "https://testapi.wisaw.com"
    static let HOST = "https://api.wisaw.com"
    
    let themeColor = UIColor(red: 0.01, green: 0.41, blue: 0.22, alpha: 1.0)
    
    
    // Returns the difference in hours between the receiver and Greenwich Mean Time at a given date.
    static func timeZoneOffset() -> Int {
        return NSTimeZone.system.secondsFromGMT(for: Date()) / 3600
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        window?.tintColor = themeColor
        //        NetworkActivityIndicatorManager.shared.isEnabled = true
        
        // retrieve UUID, if not there generate one.
        
        uuid =  KeychainWrapper.standard.string(forKey: "WiSaw-UUID")
        
        if(uuid == nil) {
            uuid = UUID().uuidString
            KeychainWrapper.standard.set(uuid!, forKey: "WiSaw-UUID")
        }
        print("UUID:", uuid!)
        
        Fabric.with([Crashlytics.self])
        
        
        // for debug and development only
        Branch.getInstance().setDebug()
        // listener for Branch Deep Link data
        let branch: Branch = Branch.getInstance()
        
        branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: {params, error in
            
            if error == nil && params!["+clicked_branch_link"] != nil && params!["$photo_id"] != nil {
                print("clicked picture link!")
                // load the view to show the picture
                
                print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ deep linking:")
                print("photo id: \(params!["$photo_id"]!)")
                // Option 1: read deep link data
                
                
                let sharedViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SharingViewController") as! SharingViewController
                
                sharedViewController.photoId = (params!["$photo_id"]! as! NSString).integerValue
                
                self.window?.rootViewController?.dismiss(animated: true) {
                    print("going babck to home controller")
                }
                self.window?.rootViewController?.present(sharedViewController, animated: true) {
                    print("showing SharingViewController")
                }
            } else {
                // load your normal view
            }
        })
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        application.setMinimumBackgroundFetchInterval(1800) // 30 minutes
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    // branch.io stuff
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // handler for URI Schemes (depreciated in iOS 9.2+, but still used by some apps)
        Branch.getInstance().application(app, open: url, options: options)
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        // handler for Universal Links
        Branch.getInstance().continue(userActivity)
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // handler for Push Notifications
        Branch.getInstance().handlePushNotification(userInfo)
    }
    
    
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    class func photoLiked(photoId: Int) -> Void {
        FileManager.default.createFile(atPath: getDocumentsDirectory().appendingPathComponent("wisaw-liked-\(photoId)").path, contents: nil)
    }
    
    class func photoViewed(photoId: Int) -> Void {
        FileManager.default.createFile(atPath: getDocumentsDirectory().appendingPathComponent("wisaw-viewed-\(photoId)").path, contents: nil)
    }
    
    class func isPhotoLiked(photoId: Int) -> Bool {
        let liked = FileManager.default.fileExists(atPath: getDocumentsDirectory().appendingPathComponent("wisaw-liked-\(photoId)").path)
        return liked
    }
    
    class func isPhotoViewed(photoId: Int) -> Bool {
        let viewed = FileManager.default.fileExists(atPath: getDocumentsDirectory().appendingPathComponent("wisaw-viewed-\(photoId)").path)
        return viewed
    }
    
    
    class func updateNewPhotosStatus(photosJSON: [Any]) {
//        if UserDefaults.standard.object(forKey: "firstRun") == nil {
//            UserDefaults.standard.set("no", forKey: "firstRun")
//            // mark all photos as read
//            for photoJSON in photosJSON {
//                let photoId = (photoJSON as! [String:Any])["id"] as! Int
//                AppDelegate.photoViewed(photoId: photoId)
//            }
//        }
        updateAppBadge(photosJSON: photosJSON)
    }
    
    class func updateAppBadge(photosJSON: [Any]) {
//        var updates = 0
//        for photoJSON in photosJSON {
//            let photoId = (photoJSON as! [String:Any])["id"] as! Int
//            if !AppDelegate.isPhotoViewed(photoId: photoId) {
//                updates = updates + 1
//            }
//        }
//        UIApplication.shared.applicationIconBadgeNumber = updates
    }
    
    // Support for background fetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let lattitude = UserDefaults.standard.string(forKey: "lattitude")
        let longitude = UserDefaults.standard.string(forKey: "longitude")
        
        if lattitude == nil || longitude == nil {
            completionHandler(.noData)
        } else {
            // load images here, can only do it after the gps data is obtained
            let parameters: [String: Any] = [
                "location" : [
                    "type": "Point",
                    "coordinates": [ lattitude!, longitude!]
                ]
                
            ]
            Alamofire.request("\(AppDelegate.HOST)/photos/feed", method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .responseJSON { response in
                    if let statusCode = response.response?.statusCode {
                        if(statusCode == 200) {
                            if let json = response.result.value as? [String:Any] {
                                let photosJSON = json["photos"] as! [Any]
                                AppDelegate.updateAppBadge(photosJSON: photosJSON)
                                completionHandler(.newData)
                            }
                        }
                    }
            }
        }
    }
    
}

