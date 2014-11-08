//
//  AppDelegate.swift
//  GarbageMaster
//
//  Created by 門脇裕 on 2014/10/11.
//  Copyright (c) 2014年 yu_kadowaki. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow = UIWindow()
    var navigationController: UINavigationController = UINavigationController()
    var tabbarController: UITabBarController = UITabBarController()
    var garbageListViewController: GarbageListViewController = GarbageListViewController()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        navigationController = UINavigationController(rootViewController: garbageListViewController)
        tabbarController.setViewControllers(NSArray(object: navigationController), animated: false)
        navigationController.tabBarItem = UITabBarItem(title: "add", image: nil, selectedImage: nil)
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        self.window.rootViewController = tabbarController
        
        self.window.backgroundColor = UIColor.whiteColor()
        self.window.makeKeyAndVisible()
        
        
        // Notificationの設定
        
//        let action: UIMutableUserNotificationAction = UIMutableUserNotificationAction()
//        action.identifier = "action"
//        action.title = "Notification"
//        action.activationMode = UIUserNotificationActivationMode.Foreground
//        action.destructive = false
//        action.authenticationRequired = false
//        
//        let category: UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
//        category.identifier = "category"
//        
//        let defaultActions: NSArray = [action]
//        category.setActions(defaultActions, forContext: UIUserNotificationActionContext.Default)
//        
//        let categories: NSSet = NSSet(object: category)
        
        let notificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge
        
        let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        var alert = UIAlertView()
        alert.title = "ごみ出し通知"
        alert.message = notification.alertBody
        alert.addButtonWithTitle(notification.alertAction!)
        alert.show()
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

