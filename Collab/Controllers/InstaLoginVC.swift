//
//  InstaLoginVC.swift
//  Collab
//
//  Created by Apple01 on 4/12/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class InstaLoginVC: UIViewController,UIWebViewDelegate {
    @IBOutlet weak var instaWebView: UIWebView!

    var parametrs = NSMutableDictionary()


    // MARK:
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.instaWebView.delegate = self
        AppManager.sharedInstance.showHud(showInView: self.view, label: "Logging you in....")
        let urlStr =  String(format: "%@client_id=%@&redirect_uri=%@&response_type=code",INSTA_URL,I_CLIENT_ID,I_REDIRECT_URI)
        self.instaWebView.loadRequest(NSURLRequest(url: NSURL(string: urlStr)! as URL) as URLRequest)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    // MARK:
    //MARK: - UIWebViewDelegate
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return self.checkRequest(forCallbackURL: request)
    }

    func webViewDidStartLoad(_ webView: UIWebView) {

    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        AppManager.sharedInstance.hidHud()
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.webViewDidFinishLoad(webView)
        AppManager.sharedInstance.hidHud()

    }


    // MARK:
    //MARK: - checkRequest
    func checkRequest(forCallbackURL request: URLRequest) -> Bool {

        let urlString: String = request.url!.absoluteString
        if urlString.hasPrefix(I_REDIRECT_URI) {
            // extract and handle code
            var theFileName = (urlString as NSString).lastPathComponent
            print(theFileName)
            theFileName = theFileName.replacingOccurrences(of: "?code=", with: "")
            print(theFileName)
            self.makePostRequest(theFileName)
            return false
        }
        return true
    }


    func makePostRequest(_ code: String) {
        AppManager.sharedInstance.showHud(showInView: self.view, label: "Logging you in....")
        let param: NSDictionary = ["client_id"      : I_CLIENT_ID,
                                   "client_secret"   : I_CLIENT_SECRET,
                                   "grant_type"      :"authorization_code",
                                   "redirect_uri"    : "https://com.sfs.collab",
                                   "code"             : code,
                                   "scope":"basic+public_content+follower_list+comments+relationships+likes"]

        ServerManager.sharedInstance.httpPostInsta("https://www.instagram.com/oauth/access_token/?", postParams: param as? [String : Any], SuccessHandle: { (response, url) in
            AppManager.sharedInstance.hidHud()
            print("OOOOOOOOOO%@",response)

            let JSON: NSDictionary = response as! NSDictionary
            print(JSON)

            print(JSON["access_token"]!)

            for  (key ,value) in JSON  {
                if key as! String == "access_token" {
                    UserDefaults.SFSDefault(setValue: value, forKey: I_ACCESS_TOKEN)
                    UserDefaults.SFSDefault(setValue: JSON["user"]!, forKey: I_USER_DATA)
                    self.loginWithInsta(dataDict: JSON["user"] as! NSDictionary )

                }
            }
        }) { (error) in
            AppManager.sharedInstance.hidHud()

        }
    }

    // MARK:
    // MARK:- Add userToFirebase Methods

    func registerUserOnFirebase(userData : Dictionary<String, Any> ) {

        var ref: DatabaseReference!
        ref = Database.database().reference()
        let refChild = ref.child("users")
        let chatID = refChild.child(userData["id"] as! String)
        var dataDict : Dictionary<String, Any>

        if Platform.isSimulator {
            print("Running on Simulator")
            dataDict = ["name" : userData["full_name"]!,"profile_pic":userData["profile_pic"]!,"player_id":""]
        }
        else{
            let playerID: String = UserDefaults.SFSDefault(valueForKey: "player_id") as? String ?? ""
            dataDict = ["name" : userData["full_name"]!,"profile_pic":userData["profile_pic"]!,"player_id":playerID]
        }
        chatID.setValue(dataDict) { (error, ref) in

            if error != nil{
                print("error in insertion")
            }
            else{
                //                let catagoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CatagoryVC") as! CatagoryVC
                //                catagoryVC.isInternalController = "yes"
                //                self.navigationController?.pushViewController(catagoryVC, animated: true)
            }
        }
    }

    // MARK:
    // MARK:- Webservices Methods
    func loginWithInsta(dataDict : NSDictionary)  {
        AppManager.sharedInstance.showHud(showInView: self.view, label: "Logging you in....")
        let instaLink = String(format:"https://www.instagram.com/%@",String(describing: dataDict["username"]!))
        let urlImage  = dataDict["profile_picture"] as! String
        let stringToBeRemoved = "s150x150"
        let imageURl = urlImage.replacingOccurrences(of: stringToBeRemoved, with: "")
        var lat = String()
        var long = String()

        let myLocation = CLLocation(latitude: AppDelegate.sharedDelegate.userlocation.coordinate.latitude, longitude: AppDelegate.sharedDelegate.userlocation.coordinate.longitude)

        if AppDelegate.sharedDelegate.userlocation.coordinate.latitude == 0.0 && AppDelegate.sharedDelegate.userlocation.coordinate.longitude == 0.0 {
            lat = ""
            long = ""
        } else {
            lat = "\(AppDelegate.sharedDelegate.userlocation.coordinate.latitude )"
            long = "\(AppDelegate.sharedDelegate.userlocation.coordinate.longitude )"
        }
        let para  = ["signup_type":"instagram",
                     "instagram_id": dataDict["id"]!,
                     "full_name":dataDict["full_name"]!,
                     "email":"",
                     "instagram_profile_link":instaLink,
                     "username" : dataDict["username"]!,
                     "lat":lat,
                     "lng":long,
                     "device_token":"123",
                     "device_type":"iOS",
                     "profile_pic":imageURl
        ]

        let url = "\(BASE_URL)signup"

        ServerManager.sharedInstance.httpPost(url, postParams: para, SuccessHandle: { (response, requestPath) in

            AppManager.sharedInstance.hidHud()
            var jsonResult = response as! Dictionary<String, Any>

            if jsonResult["success"] as! NSNumber == 1{
                let userInfo: Dictionary = jsonResult["user_data"] as! Dictionary<String, Any>
               
                self.logOutFromInsta()
            
                if Int(userInfo["account_status"] as! String) == 0{
                    
                    UserDefaults.SFSDefault(setBool: false, forKey: "isLogin")
                    
                    let loginVc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    let navigationController : UINavigationController = UINavigationController.init(rootViewController: loginVc)
                    
                      AppManager.showMessageView(view: loginVc.view, meassage: "Your account is de-activated.")
                    
                    AppDelegate.sharedDelegate.window?.rootViewController = navigationController
                    
                }else
                {
                    UserDefaults.SFSDefault(setValue: userInfo["id"]!, forKey: USER_ID)
                    UserDefaults.SFSDefault(setValue: userInfo["full_name"]!, forKey:  "full_name")
                    UserDefaults.SFSDefault(setValue: userInfo["profile_pic"]!, forKey:  "profile_pic")
                    
                    UserDefaults.SFSDefault(setValue: userInfo, forKey: "userInfo")
                    UserDefaults.SFSDefault(setBool: true, forKey: "isLogin")
                    
                    self.registerUserOnFirebase(userData: userInfo);
                    
                    if jsonResult["new_user"] as! NSNumber == 0{
                        AppDelegate.sharedDelegate.moveToFeedVC(index: 0)
                        UserDefaults.SFSDefault(setBool: false, forKey: kIsFirstTime)
                    }
                    else{
                        UserDefaults.SFSDefault(setBool: true, forKey: kIsFirstTime)
                        let catagoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CatagoryVC") as! CatagoryVC
                        catagoryVC.isInternalController = "yes"
                        self.navigationController?.pushViewController(catagoryVC, animated: true)
                        
                    }
                    
                    
                }
                
                
            }

        }) { (error) in
            AppManager.sharedInstance.hidHud()
            AppManager.showMessageView(view: self.view, meassage: error.localizedDescription)

        }
    }

    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    func logOutFromInsta() {

        let storage : HTTPCookieStorage = HTTPCookieStorage.shared
        for cookie in storage.cookies! {
            //        let domainName = cookie.domain
            //        let domainRange: NSRange = (domainName as NSString).range(of: "instagram.com")
            //        if domainRange.length > 0 {
            storage.deleteCookie(cookie)
            // }
        }


        //        if let cookies = HTTPCookieStorage.shared.cookies {
        //            for cookie in storage.cookies! {
        //                let domainName = cookie.domain
        //                let domainRange: NSRange = (domainName as NSString).range(of: "instagram.com")
        //                if domainRange.length > 0 {
        //                    storage.deleteCookie(cookie)
        //                }
        //            }
        //        }
    }
}
