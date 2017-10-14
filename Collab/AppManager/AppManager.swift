//
//  AppManager.swift
//  SHAMEL
//
//  Created by Apple on 8/23/16.
//  Copyright © 2016 Sunfocus Solutions. All rights reserved.
//

import UIKit
import Foundation

class AppManager: NSObject  {

    var multiColorLoader : JKIndicatorView!
    var HUD:JKProgressHUD!
    class var sharedInstance:AppManager {
        struct Singleton {
            static let instance = AppManager()
        }
        return Singleton.instance
    }
    
     class func isLogin() -> Bool {
        return UserDefaults.SFSDefault(boolForKey: kLoginStatus) ? true:false
    }
    //MARK: Check permissions
    func checkCameraStatus(view : UIViewController, headerString : String , messageString : String) -> Bool{
        let cameraMediaType = AVMediaTypeVideo
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: cameraMediaType)

        switch cameraAuthorizationStatus {
        case .denied:
            print("denied")
             self.callAlert(view: view, headerString: headerString, messageString: messageString)
            return false
        case .authorized:
            print("authorized")
            return true
        case .restricted:
            print("restricted")
            self.callAlert(view: view, headerString: headerString, messageString: messageString)
            return false
        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(forMediaType: cameraMediaType) { granted in
                if granted {
                    print("Granted access to \(cameraMediaType)")
                } else {
                    print("Denied access to \(cameraMediaType)")
                    self.callAlert(view: view, headerString: headerString, messageString: messageString)
                }
            }
            return true
        }
    }
    func callAlert(view : UIViewController, headerString : String , messageString : String)  {
        let alert: SCLAlertView = SCLAlertView()
        alert.tintTopCircle = false
        alert.customViewColor = GOLDEN_COLOR
        alert.addButton("Settings", actionBlock: {
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
                else{
                    return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                } else {
                    // Fallback on earlier versions
                }
            }
        })
        alert.showSuccess(view, title: headerString, subTitle: messageString, closeButtonTitle: "No Thanks", duration:  0.0)
    }

    // MARK: showHud
    func showHud(showInView myView:UIView,label title:String){
        HUD = JKProgressHUD.showProgressHud(inView: myView, progressMode: .Indeterminate)
        HUD.lineColor = UIColor.smGoldenColor()
        HUD.messageString =  title
    }

    // MARK: hidHud
    func hidHud(){
        if (HUD != nil) {
            if !HUD.isHidden {

                HUD.hideHud(animated: true)
                HUD.removeFromSuperview()
            }
        }
        else if (multiColorLoader != nil) {
            multiColorLoader.stopAnimation()
            multiColorLoader.removeFromSuperview()
        }
        HUD.removeFromSuperview()

    }
    class func setTextfieldLeftView( image: UIImage, textField :UITextField)
    {
        let leftView = UIView.init(frame: .init(x: 0, y: 0, width: 50, height: 40))
        let leftImageView = UIImageView.init(frame: .init(x: 10, y: 10, width: 20, height: 20))
        leftImageView.image = image
        leftView.addSubview(leftImageView)
        textField.leftView = leftView
        textField.leftViewMode = UITextFieldViewMode.always
    }

    //MARK: shoHudProgressBar
    func shoHudProgressBar(showInView myView:UIView , ProgressHudMode hudeMode:JKProgressHUDMode,titleLabel title:String?){
        HUD = JKProgressHUD.showProgressHud(inView: myView, progressMode: hudeMode)
        HUD.messageString =  title ?? ""
    }
    //MARK: recieveProgressData
    func recieveProgressData( setProgress myprogress:Float ,  label : String){
        var progress:Float = HUD!.progress
        if progress < 1.0 {
            progress = progress + 0.1
            HUD.messageString =  label
            HUD.progress = progress

        }
    }
    class func setSubViewlayout(_ subView: UIView , mainView : UIView){
        subView.translatesAutoresizingMaskIntoConstraints = false
        mainView.addConstraint(NSLayoutConstraint(item: subView, attribute: .top, relatedBy: .equal, toItem: mainView, attribute: .top, multiplier: 1.0, constant: 0.0))
        
        mainView.addConstraint(NSLayoutConstraint(item: subView, attribute: .leading, relatedBy: .equal, toItem: mainView, attribute: .leading, multiplier: 1.0, constant: 0.0))
        
        mainView.addConstraint(NSLayoutConstraint(item: subView, attribute: .bottom, relatedBy: .equal, toItem: mainView, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        
        mainView.addConstraint(NSLayoutConstraint(item: subView, attribute: .trailing, relatedBy: .equal, toItem: mainView, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        
    }
    
    class  func isValidEmail(_ testStr:String) -> Bool {
        print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest=NSPredicate(format: "SELF MATCHES %@", emailRegEx);
        if  emailTest.evaluate(with: testStr){
            return true
        }
        return false
    }
    
    class  func validPhoneNumber(_ value: String) -> Bool{
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        if phoneTest.evaluate(with: value) {
            return true
        }
        return false
    }
    
    class func setShadowEffect(containerView item:UIView,shadowOffset offset:CGSize,shadowOpacity opacity: Float,shadowRadius radius:CGFloat){
        item.layer.shadowColor =  UIColor.darkGray.cgColor
        item.layer.shadowOffset =  offset
        item.layer.shadowOpacity=opacity
        item.layer.shadowRadius = radius
        item.layer.masksToBounds = true
        item.clipsToBounds = true
    }
    
    class func imageWithImage(_ image:UIImage ,scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContext( newSize )
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width,height: newSize.height))
        let newImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return newImage
    }
    
    class func calculateHeightForString(_ inString:String,newWidth:CGFloat, font : UIFont) -> CGFloat{
        let messageString = inString
        let attributes = [NSFontAttributeName:font]
        let attrString:NSAttributedString? = NSAttributedString(string: messageString, attributes: attributes )
        let rect:CGRect = attrString!.boundingRect(with: CGSize(width: newWidth,height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, context:nil )//hear u will get nearer height not the exact value
        let requredSize:CGRect = rect
        return requredSize.height  //to include button's in your tableview
        
    }
    
    class func getDateToString(datepicker currentdate :Date )->String{
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = DateFormatter.Style.medium
        dateformatter.dateFormat="dd-MMM-yyyy"
        let dateInStringFormated=dateformatter.string(from: currentdate)
        return dateInStringFormated
    }
    
//    class func showSuccessDialog(_ successMessage : String, view: Any){
//        let alert: SCLAlertView = SCLAlertView()
//        alert.showSuccess(view as! UIViewController, title:"Shamel", subTitle: successMessage as String, closeButtonTitle: NSLocalizedString("ok", comment: ""), duration: 0.0)
//    }
//    class func showFaliureDialog(_ successMessage : String, view: Any){
//        let alert: SCLAlertView = SCLAlertView()
//        alert.showError(view as! UIViewController, title: NSLocalizedString("error", comment:"" ), subTitle: successMessage as String, closeButtonTitle: NSLocalizedString("ok", comment: ""), duration: 0.0)
//    }
    class func showServerErrorDialog(_ error : NSError, view: Any){
        var errorMessage: NSString = NSString()
        switch error.code {
        case -998:
            errorMessage = "Unknow Error";
            break;
        case -1000:
            errorMessage = "Bad URL request";
            break;
        case -1002:
            errorMessage = "Unsupported URL";
            break;
        case -1003:
            errorMessage = "The host could not be found";
            break;
        case -1004:
            errorMessage = "The host could not be connect, Please try after some time";
            break;
        case -1005:
            errorMessage = "The network connection is lost, Please try again later";
            break;
        case -1009:
            errorMessage = "The internet connection appears to be  offline";
            break;
        case -1103:
            errorMessage = "Data length exceeded to maximum defined data";
            break;
        case -1100:
            errorMessage = "File does not exist";
            break;
        case -1013:
            errorMessage = "User authentication required";
        case -2102:
            errorMessage = "The request time out";
            break;
            
        default:
            errorMessage = error.localizedDescription as NSString;
            break;
        }
        
        AppManager.showMessageView(view: AppDelegate.sharedDelegate.window!, meassage:  error.localizedDescription)

    }

    class func isInternetError(_ error : NSError) -> Bool {
        if error.code == -999 || error.code == -1001 || error.code == -1005 || error.code == -1009 || error.code == -1011 || error.code == -1019 || error.code == -1020 || error.code == -1004 || error.code == -2102 {
                return true
        }
        else{
           return false
        }

    }
    /// Insta Login
    func handleLoginResponse(url:NSURL) -> Bool {
        if !(url.absoluteString?.hasPrefix("ig564509fa73fc4172825574ab686f763e://authorize"))! {
            return false
        }
        var query: String? = url.fragment
        if (query == nil) {
            query = url.query
        }

        let pairs:Array? =  query?.components(separatedBy: "&")
        let params = NSMutableDictionary ()

        for pair in pairs! {
            let key:Array? =  pair.components(separatedBy: "=")
            let value = key?[1].removingPercentEncoding

        params.setValue(value, forKey: key![0] )
        }

        let accessToken = params.value(forKey: "access_token")

        if (accessToken == nil){
           // let errorReason = params.value(forKey: "error_reason")
            return true;
        }
        else{
     UserDefaults.SFSDefault(setValue: accessToken as! String, forKey: I_ACCESS_TOKEN)
        }
        return true
    }

    /// Check Login

    func isValidLogin() -> Bool {
        let accessToken :String? = UserDefaults.SFSDefault(valueForKey: I_ACCESS_TOKEN) as? String
        if accessToken == nil{
            return false
        }
        else{
            return true
        }
    }

  class func showMessageView(view:UIView, meassage: String)  {
        let label = UILabel.init(frame:.init(x: 0, y: 64, width: view.frame.size.width, height: 30))
        label.text = meassage
        label.backgroundColor = UIColor.lightGray
        label.textColor = UIColor.black
        label.textAlignment = .center

        label.adjustsFontSizeToFitWidth = true

        view.addSubview(label)
        label.alpha = 1

    UIView.animate(withDuration: 3, delay:0, options:UIViewAnimationOptions.transitionFlipFromTop, animations: {
       label.alpha = 0
    }, completion: { finished in
        label.isHidden = true
    })

    }
    
    //MARK:
    //MARK: Shake TextField
    func shakeTextField(textField: UITextField, withText:String, currentText:String) -> Void {
        textField.text = ""
        textField.attributedPlaceholder = NSAttributedString(string: currentText,
                                                             attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        let isSecured = textField.isSecureTextEntry
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.10
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint:CGPoint.init(x: textField.center.x - 10, y: textField.center.y) )
        animation.toValue = NSValue(cgPoint: CGPoint.init(x: textField.center.x + 10, y: textField.center.y) )
        textField.layer.add(animation, forKey: "position")
        if isSecured {
            textField.isSecureTextEntry = false
        }
        textField.attributedPlaceholder = NSAttributedString(string: withText,
                                                             attributes: [NSForegroundColorAttributeName: UIColor.red])
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            textField.attributedPlaceholder = NSAttributedString(string: currentText,
                                                                 attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
            //  textField.placeholder = placeholder
            if isSecured {
                textField.isSecureTextEntry = true
            }
        }
    }
    
    //MARK:
    //MARK: Image resizing methods
    func resizeImage(image : UIImage , targetSize : CGSize) -> UIImage{
        let originalSize:CGSize =  image.size
        
        let widthRatio :CGFloat = targetSize.width/originalSize.width
        let heightRatio :CGFloat = targetSize.height/originalSize.height
        
        var newSize : CGSize!
        if widthRatio > heightRatio {
            newSize =  CGSize(width : originalSize.width*heightRatio ,  height : originalSize.height * heightRatio)
        }
        else{
            newSize = CGSize(width : originalSize.width * widthRatio , height : originalSize.height*widthRatio)
        }
        
        // preparing rect for new image
        
        let rect:CGRect =  CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        image .draw(in: rect)
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    class func convertStringToFloat(value : String) -> CGFloat {
        if let n = NumberFormatter().number(from: value) {
            let f = CGFloat(n)
            return f
        }else{
            return 0.0
        }
    }
    
    class func calculateHeight( width: CGFloat ,  height: CGFloat , _ scaleWidth: CGFloat) -> CGFloat {
        let newHeight : CGFloat = (( height  / width ) * scaleWidth)
        return newHeight
    }
    
   class func resizeImageWithImage (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth
        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}


