//
//  Constant.swift
//
//  Created by Apple on 8/23/16.
//  Copyright © 2016 Sunfocus Solutions. All rights reserved.
//

import Foundation
import UIKit

enum UIUserInterfaceIdiom : Int
{
    case unspecified
    case phone
    case pad
}

enum controllerType {
    
    case internalController
    case externalController
}
var TYPE_CONTROLLER = controllerType.internalController

let I_REDIRECT_URI = "https://com.sfs.collab"
let I_CLIENT_ID = "2d4763e626ae4bbca39fab094a14f2a1"
let I_CLIENT_SECRET = "f6acd2d36f8842b7a38b0513a61766a1"
let I_ACCESS_TOKEN = "access_token"
let BASE_URL = "http://sunfocussolutions.com/collab/index.php/api/"
let INSTA_URL = "https://api.instagram.com/oauth/authorize/?"
let I_USER_DATA = "instaUserData"
let I_USER_ID = "instaUserID"
let USER_ID = "user_id"
let SOUND_CLOUD_CLIENT_ID = "355503a68ddc02f17cb5d10afdf7548e"



let DENIED_LOCATION_HEADER = "You denied location permissions";
let DENIED_LOCATION_MESSAGE = "To use all the features of the application you need allow the location permission. Please turn on location from your settings."

let DENIED_GALLRY_HEADER = "You denied gallary permissions";
let DENIED_GALLRY_MESSAGE = "To use all the features of the application you need allow the camera/gallary permission. Please turn on this permission from your settings."
let kLocationIsOff = "isLocationOff"


let GOLDEN_COLOR =  UIColor(red: 192.0/255.0, green: 135.0/255.0, blue: 51.0/255.0, alpha: 1.0)

struct Platform {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
    }
}
struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}
extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
}

struct Version{
    static let SYS_VERSION_FLOAT = (UIDevice.current.systemVersion as NSString).floatValue
    static let iOS7 = (Version.SYS_VERSION_FLOAT < 8.0 && Version.SYS_VERSION_FLOAT >= 7.0)
    static let iOS8 = (Version.SYS_VERSION_FLOAT >= 8.0 && Version.SYS_VERSION_FLOAT < 9.0)
    static let iOS9 = (Version.SYS_VERSION_FLOAT >= 9.0 && Version.SYS_VERSION_FLOAT < 10.0)
    static let IS_OS_8_OR_LATER =  floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_8_0)
}
func dPrint(_ items: Any...,enable:Bool = true){
    if enable == true {
        print(items)
    }
}




