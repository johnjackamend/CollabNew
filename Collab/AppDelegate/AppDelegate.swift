
//
//  AppDelegate.swift
//  Collab
//
//  Created by Apple01 on 4/11/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import OneSignal
import FBSDKCoreKit
import FBSDKShareKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate,OSSubscriptionObserver{

    //MARK: Properties
    var window: UIWindow?
    var locationManager = CLLocationManager()
    var userlocation = CLLocation()

    var locationStatus : NSString = "Not Started"
    var storeCurrntClass = [String]()
 


    //MARK: AppDelegate Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        //Bar Style white
        UIApplication.shared.statusBarStyle = .lightContent

        //Keyboard settings
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true

        //Register for push notifications
        self.setDeviceForPushNotification(application)

        //Get Location
        self.getLatLng()

        // Firebase Methods
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true

        //Register devive for One Signal Push Notification
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "940be648-d47e-454c-a57e-fd9350bb158a",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })

        //For facebook share
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        //Navigate app
        if UserDefaults.SFSDefault(boolForKey: "isLogin") == true {
            AppDelegate.sharedDelegate.moveToFeedVC(index: 0)
        }
        if UserDefaults.SFSDefault(boolForKey: "isFirstTime") == true{
        }
        return true
    }

    class var sharedDelegate:AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool{
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url as URL!, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userlocation = manager.location!
        print("locations = \(userlocation.coordinate.latitude) \(userlocation.coordinate.longitude)")
        if UserDefaults.SFSDefault(boolForKey: kLocationIsOff) == true {
            if let _ : String? = UserDefaults.SFSDefault(valueForKey: "user_id") as! String
            {
               self.updateLocation()
            }
        }
        else{
           self.locationManager.stopUpdatingLocation()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
        // Restart any tasks that                                                                                                                                                                                                                                            were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }



    //MARK:
    //MARK:Push Notification Delegate Methods

    func setDeviceForPushNotification(_ application : UIApplication){
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
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let characterSet = CharacterSet(charactersIn: "<>")
        let deviceTokenString = deviceToken.description.trimmingCharacters(in: characterSet).replacingOccurrences(of: " ", with: "");
        print(deviceTokenString)

        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        let userID = status.subscriptionStatus.userId
        UserDefaults.SFSDefault(setValue: userID ?? "", forKey: "player_id")
    }

    func didReceiveNotificationResponse(userInfo : Dictionary<String, Any> , isBackground: Bool){
        if userInfo.keys.count != 0
        {
            let custom = userInfo["custom"] as? NSDictionary
            let  chatInfo = custom?["a"] as? NSDictionary
            let objChat = Chat()
            objChat.chatID = chatInfo?["chatId"] as! NSString
            objChat.friendID = chatInfo?["senderId"] as! NSString
            objChat.friendName = chatInfo?["senderName"] as! NSString
            objChat.friendImage = chatInfo?["senderPic"] as! NSString
//            let messgaeStr = "\(objChat.friendName) sent you message"
            if UserDefaults.SFSDefault(boolForKey: "isLogin") == false {
                return
            }
            else{
                UserDefaults.SFSDefault(setBool: true, forKey: "isNotification")
//                HDNotificationView.hide(onComplete: nil)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let objSideMenu = storyboard.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
                let home = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                home.chatModel = objChat
                let navigationController = UINavigationController.init(rootViewController: home)
                let objLeftMenu = MFSideMenuContainerViewController.container(withCenter: navigationController , leftMenuViewController: objSideMenu, rightMenuViewController: nil)
                objLeftMenu?.panMode = MFSideMenuPanModeNone
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                appdelegate.window?.rootViewController = objLeftMenu
            }
        }
    }

    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
            let userID = status.subscriptionStatus.userId
            print("userID = \(String(describing: userID))")
            let pushToken = status.subscriptionStatus.pushToken
            print("pushToken = \(String(describing: pushToken))")
            UserDefaults.SFSDefault(setValue: userID ?? "", forKey: "player_id")
            print("Subscribed for OneSignal push notifications!")
        }
        print("SubscriptionStateChange: \n\(stateChanges)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        let info : Dictionary! = userInfo as Dictionary
        print(userInfo)
        if info != nil
        {
            let custom = info["custom"] as? NSDictionary
            let  chatInfo = custom?["a"] as? NSDictionary
            let objChat = Chat()
            objChat.chatID = chatInfo?["chatId"] as! NSString
            objChat.friendID = chatInfo?["senderId"] as! NSString
            objChat.friendName = chatInfo?["senderName"] as! NSString
            objChat.friendImage = chatInfo?["senderPic"] as! NSString
            let messgaeStr = "\(objChat.friendName) sent you message"
            if UserDefaults.SFSDefault(boolForKey: "isLogin") == false {
                return
            }
            else{
                let state : UIApplicationState = UIApplication.shared.applicationState
                if state == .active {
                    let lastObject = storeCurrntClass.last
                    if lastObject == "Chat" || lastObject == "Message" {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    }
                    else{
                        HDNotificationView.show(with: #imageLiteral(resourceName: "appIcon"), title: "Collab", message:messgaeStr, isAutoHide: true, onTouch: {
                            UserDefaults.SFSDefault(setBool: true, forKey: "isNotification")
                            HDNotificationView.hide(onComplete: nil)
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let objSideMenu = storyboard.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
                            let home = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                            home.chatModel = objChat
                            let navigationController = UINavigationController.init(rootViewController: home)
                            let objLeftMenu = MFSideMenuContainerViewController.container(withCenter: navigationController , leftMenuViewController: objSideMenu, rightMenuViewController: nil)
                            objLeftMenu?.panMode = MFSideMenuPanModeNone
                            let appdelegate = UIApplication.shared.delegate as! AppDelegate
                            appdelegate.window?.rootViewController = objLeftMenu
                        })
                    }
                }
                else  if state == .inactive {
                    let lastObject = storeCurrntClass.last
                    print(storeCurrntClass)
                    if lastObject == "Chat" || lastObject == "Message" {
                    }
                    else{
                        UserDefaults.SFSDefault(setBool: true, forKey: "isNotification")
                        HDNotificationView.hide(onComplete: nil)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let objSideMenu = storyboard.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
                        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                        homeVC.chatModel = objChat
                        let navigationController = UINavigationController.init(rootViewController: homeVC)
                        let objLeftMenu = MFSideMenuContainerViewController.container(withCenter: navigationController , leftMenuViewController: objSideMenu, rightMenuViewController: nil)
                        objLeftMenu?.panMode = MFSideMenuPanModeNone
                        let appdelegate = UIApplication.shared.delegate as! AppDelegate
                        appdelegate.window?.rootViewController = objLeftMenu

                    }
                }
                else  if state == .background {
                    HDNotificationView.show(with: #imageLiteral(resourceName: "appIcon"), title: "Collab", message:messgaeStr, isAutoHide: true, onTouch: {
                        UserDefaults.SFSDefault(setBool: true, forKey: "isNotification")
                        HDNotificationView.hide(onComplete: nil)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let objSideMenu = storyboard.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
                        let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatController") as! ChatController
                        chatVC.chatModel = objChat
                        let navigationController = UINavigationController.init(rootViewController: chatVC)
                        let objLeftMenu = MFSideMenuContainerViewController.container(withCenter: navigationController , leftMenuViewController: objSideMenu, rightMenuViewController: nil)
                        objLeftMenu?.panMode = MFSideMenuPanModeNone
                        let appdelegate = UIApplication.shared.delegate as! AppDelegate
                        appdelegate.window?.rootViewController = objLeftMenu
                    })
                }
                else{
                    HDNotificationView.show(with: #imageLiteral(resourceName: "appIcon"), title: "Collab", message: messgaeStr, isAutoHide: true)
                }
            }
        }
    }

    func moveToFeedVC(index : Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let objSideMenu = storyboard.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        let navigationController = UINavigationController.init(rootViewController: homeVC)

        let objLeftMenu = MFSideMenuContainerViewController.container(withCenter: navigationController , leftMenuViewController: objSideMenu, rightMenuViewController: nil)
        objLeftMenu?.panMode = MFSideMenuPanModeNone
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.window?.rootViewController = objLeftMenu
    }
    // MARK: location delegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        default: break
        }
    }
    //MARK: Get Lat - Long

    func getLatLng() -> Void {

        locationManager =  CLLocationManager()
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation() // start location manager
            if Version.IS_OS_8_OR_LATER{
                if locationManager.responds(to:#selector(CLLocationManager.requestWhenInUseAuthorization)){
                    locationManager.requestWhenInUseAuthorization()
                }else
                {
                    //when below iso 8.0 version
                    locationManager.startUpdatingLocation()
                }
            }
        }
    }
}
extension AppDelegate:UNUserNotificationCenterDelegate{
    @available(iOS 10.0, *)

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let userInfo = response.notification.request.content.userInfo as? Dictionary<String, Any> {
            print(userInfo)
            self.didReceiveNotificationResponse(userInfo: userInfo, isBackground: false)
        }
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

     let userInfo = notification.request.content.userInfo as! Dictionary<String, Any>
        let custom = userInfo["custom"] as? NSDictionary
        let  chatInfo = custom?["a"] as? NSDictionary


        let userID : String = UserDefaults.SFSDefault(valueForKey: "user_id") as! String

        print(userID)
        print(chatInfo?["reciever"] ?? "")
        if userID == chatInfo?["reciever"] as! String{
            completionHandler([.alert])
        }
        else{
             completionHandler([])

        }

    }
    func updateLocation() {
        let para: Dictionary = ["user_id":UserDefaults.SFSDefault(valueForKey: "user_id"),
                                "lat" :userlocation.coordinate.latitude,
                                "lng" : userlocation.coordinate.longitude]
        ServerManager.sharedInstance.httpPost(String(format:"%@update_user_lat_lng",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
            
            self.locationManager.stopUpdatingLocation()
            
            var jsonResult = response as! Dictionary<String, Any>
            print(jsonResult)
            if jsonResult["success"] as! NSNumber == 1{
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let home = mainStoryboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                home.getFilteredData(distanceInt: 0)
            }
            else{
            }
        }) { (error) in

            self.locationManager.stopUpdatingLocation()
        }
    }

}
