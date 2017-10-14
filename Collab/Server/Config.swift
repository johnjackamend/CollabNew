//
//  Congig.swift
//  SHAMEL
//
//  Created by Apple on 8/23/16.
//  Copyright © 2016 Sunfocus Solutions. All rights reserved.
//

import Foundation


#if DEBUG
    /************************************************************************************************************
    //MARK:- DEBUG MODE
    ************************************************************************************************************/
    
    let API_SERVER_URL  = "http://shameltech.com"


#else
    /************************************************************************************************************
    //MARK:- RELEASE MODE
    ************************************************************************************************************/
    let API_SERVER_URL  = "http://shameltech.com"

    
#endif

//MARK:- Api Base URL
let API_BASE_URL  =  API_SERVER_URL + "/shamelapp/apis/"

//MARK:- User Management api
let API_SIGNUP_URL = API_BASE_URL + "signup"
let API_LOGIN_URL  =  API_BASE_URL + "iph-login.php"
let API_PASSWORD_RESET_URL  =  API_BASE_URL + "passwordReset"
let API_LOGOUT_URL  =  API_BASE_URL + "logout"
let API_DISABLEACCOUNT_URL  =  API_BASE_URL + "deactivateUser"

//MARK:- Recharge
let API_GET_VOUCHER_BALANCE_URL = API_BASE_URL + "voucher-list.php"
let API_GET_PREPAID_BALANCE_URL  =  API_BASE_URL + "iph-account-balance.php"
let API_GET_POSTPAID_BALANCE_URL  =  API_BASE_URL + "iph-postpaid-balance.php"
let API_VOUCHER_RECHARGE_URL  =  API_BASE_URL + "iph-prepaid-recharge.php"
let API_PREPAID_RECHARGE_URL  =  API_BASE_URL + "iph-prepaid-topup.php"
let API_POSTPAID_RECHARGE_URL  =  API_BASE_URL + "iph-postpaid-recharge.php"
let API_INTERNATIONAL_RECHARGE_VALIDATION_URL  =  API_BASE_URL + "iph-intltopup-validate.php"
let API_INTERNATIONAL_RECHARGE_URL  =  API_BASE_URL + "iph-intltopup-recharge.php"
let API_ADD_SHAMEL_AMOUNT_URL  =  API_BASE_URL + "iph-addcredit.php"

//MARK:- Setting user
let API_ABOUT_URL  =  API_BASE_URL + "content.php"
let API_CONTACTUS_URL  =  API_BASE_URL + "contactus.php"
let API_CHANGEPASSWORD_URL  =  API_BASE_URL + "changePassword"
let API_CHANGEEMAIL_URL  =  API_BASE_URL + "changeOldEmail"
let API_CHANGEUNAME_URL  =  API_BASE_URL + "changeUserName"

//MARK: Home Services Apis 
let API_HOME_SERVICES = API_BASE_URL + "home_services.php"
let API_HOME_SERVICES_CONTACT_LIST = API_BASE_URL + "home_contacts.php"

//MARK: Number Search Apis
let API_GOVT_NUMBER_SEARCH = API_BASE_URL + "govtnum_services.php"
let API_GOVT_NUMBER_SEARCH_CONTACT_LIST = API_BASE_URL + "govtnum_contacts.php"

//MARK: Government Services Apis
let API_GOVERNMENT_SERVICES = API_BASE_URL + "govt_services.php"

//MARK: Charity Services Apis
let API_CHARITY_SERVICES = API_BASE_URL + "charity_services.php"
let API_CHARITY_SERVICES_CONTACT_LIST = API_BASE_URL + "charity_contacts.php"


//MARK: Diwaniyat Apis
let API_GET_AREA_LIST = API_BASE_URL + "diwaniya_add.php"
let API_ADD_DIWANIYAT = API_BASE_URL + "diwaniya_add.php"
let API_SEARCH_DIWANIYAT = API_BASE_URL + "diwaniya_search.php"

//MARK: Banner Apis
let API_GET_BANNER = API_BASE_URL + "adbanner.php"

//MARK: Shoping card Apis
let API_GET_CARD_CATEGORY_LIST = API_BASE_URL + "card_categories.php"
let API_GET_CARDS = API_BASE_URL + "cards.php"

//MARK: Recharge History

let API_RECHARGE_HISTORY = API_BASE_URL + "recharges_list.php"

//MARK: Notification

let API_NOTIFICATION_DETAIL = API_BASE_URL + "notification_list.php"

//MARK: Get URL for Obituaries

let API_OBITUARIES = API_BASE_URL + "ob-link.php"


//bundle id
//com.sfs.shamel //Adib accounts
//MARK: Some Common Keys

let kAlertTitle  = "Shamel"
let kOops      = "Oops!!"
let KSuccess   = "success"
let KStatus = "status"
let kDeviceTokenKey   = "DeviceToken"
let kLanguage = "language"
let kLoginStatus = "isLogin"

let kEnglish = "en"
let kArbic = "ar"
let kBannerImage = "ad_image"
let kBannerLink = "ad_link"
let kIsFirstTime = "isFirstTime"
let kPassword = "password"
let kUserID = "user_id"
let kBalance = "account_balance"







