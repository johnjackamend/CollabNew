//
//  ServerManager.swift
//  SwiftDemo
//
//  Created by Admin on 5/19/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import UIKit
import Foundation
import AFNetworking

typealias ServerSuccessCallBack=(_ response : Any, _ requestPath: String)->Void
typealias ServerFailureCallBack=(_ error:NSError)->Void
typealias ServerProgressCallBack=(_ uploadProgress:Progress)->Void
typealias ReachibilityBlock = (_ isReachble : Bool) -> Void


class ServerManager: NSObject
{
    var multiColorLoader : JKIndicatorView!
    var HUD:JKProgressHUD!
    class var sharedInstance:ServerManager {
        struct Singleton {
            static let instance = ServerManager()
        }
        return Singleton.instance
    }
    
    //MARK:-documentsDirectoryURL-
    lazy var documentsDirectoryURL : URL = {
        let documents = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return documents
    }()
    
    //MARK:- showToast-
    // MARK: showAlert
    
    func showAlert(_ title:String, message:String){
         JKNotificationView.showNotificationView(image: UIImage(named: "logo"), withTitle: title, withMessage: message)
    }
    
    
    //MARK:- showAlert-
    func showAlertControl(from ViewController:UIViewController,withTitle title:String = kAlertTitle,withMessage message:String?){
        
        let alertController:UIAlertController =  UIAlertController.showAlertInViewController(viewController: ViewController, withTitle: title, message: message, cancelButtonTitle: "Okay", destructiveButtonTitle: nil, otherButtonTitles: nil) { (alert:UIAlertController?, action:UIAlertAction?, index:Int?) in
            
        }
        alertController.view.tintColor = JKColor.Red
    }
    func CheckNetwork(_ reachableBlock :@escaping ReachibilityBlock){
     AFNetworkReachabilityManager.shared().startMonitoring()
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange({ (status:AFNetworkReachabilityStatus) in
            DispatchQueue.main.async {
                print("status \(status)")
                switch status{
                case .reachableViaWiFi,.reachableViaWWAN:
                    reachableBlock(true)
                    break
                case .notReachable,.unknown:
                    AFNetworkReachabilityManager.shared().stopMonitoring()
                    let image : UIImage = UIImage(named: "logo")!
                    JKNotificationView.showNotificationView(image: image, withTitle: "No Internet Connection!", withMessage: "Internet Connection is not available,Please check Your network Settings!", AutoHide: true, onTouchHandler: { (finished:Bool) in
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(URL(string: "prefs:root=WIFI")!, options: [:], completionHandler: nil)
                        }
                        else{
                            UIApplication.shared.openURL(URL(string: "prefs:root=WIFI")!)
                        }
                        
                        
                    })
                    
                    reachableBlock(false)
                    break
                }
        }
        })
    }
    
    func showIndeterminateLoader(showInView myView:UIView){
        HUD = JKProgressHUD.showProgressHud(inView: myView, progressMode: .Indeterminate)
        HUD.lineColor = UIColor.smRedColor()
        HUD.backgroundStyle = .StyleClear
        HUD.tag = 1
    }
   
    // MARK: showHud
    func showHud(showInView myView:UIView,label title:String){
         HUD = JKProgressHUD.showProgressHud(inView: myView, progressMode: .Indeterminate)
         HUD.lineColor = UIColor.smRedColor()
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
   
    
   
   
    
    // MARK: httpPost
    func httpPost(_ serverPath:String,postParams:[String:Any]?,SuccessHandle:@escaping (ServerSuccessCallBack) ,failier:@escaping ( ServerFailureCallBack )){
       print("Url- \(serverPath)")
       print("Input Parameter - \(postParams)")
     //let request:NSMutableURLRequest =   AFJSONRequestSerializer().requestWithMethod("POST", URLString: serverPath , parameters: postParams, error: nil)
        let request: NSMutableURLRequest = AFHTTPRequestSerializer().request(withMethod: "POST", urlString: serverPath, parameters: postParams, error: nil)
        let manager : AFURLSessionManager = AFURLSessionManager(sessionConfiguration: URLSessionConfiguration.default);

       manager.responseSerializer = AFHTTPResponseSerializer()
        
        let dataTask : URLSessionDataTask = manager.dataTask(with: request as URLRequest) { (response, responseObject, error) -> Void in
            if ((error) != nil){
                print("Error: \(error!)")
                //self.hidHud()
                failier(error! as NSError)
            }
            else{
                do   {
                    let responseObject = try JSONSerialization.jsonObject(with: responseObject as!  Data, options: JSONSerialization.ReadingOptions(rawValue: UInt(0)))
                    if let responseDict =  responseObject as? Dictionary<String, Any> {
                        print(responseDict)
                         SuccessHandle(responseDict as Any, serverPath)
                    }
                }
                catch
                {
                }
            }
        }
        manager.setTaskDidSendBodyDataBlock { ( session:URLSession!, uploadTask:URLSessionTask, bytesSent:Int64, totalBytesSent:Int64, totalBytesExpectedToSend:Int64) -> Void in
            let  progress1 : Float = Float(totalBytesSent)/Float(totalBytesExpectedToSend);
            print(progress1)
        }
        
        dataTask.resume()
    }
    // MARK: httpPost
    func httpPostInsta(_ serverPath:String,postParams:[String:Any]?,SuccessHandle:@escaping (ServerSuccessCallBack) ,failier:@escaping ( ServerFailureCallBack )){
        print("Url- \(serverPath)")
        print("Input Parameter - \(postParams)")
        //let request:NSMutableURLRequest =   AFJSONRequestSerializer().requestWithMethod("POST", URLString: serverPath , parameters: postParams, error: nil)
        let request: NSMutableURLRequest = AFHTTPRequestSerializer().request(withMethod: "POST", urlString: serverPath, parameters: postParams, error: nil)
        let manager : AFURLSessionManager = AFURLSessionManager(sessionConfiguration: URLSessionConfiguration.default);
        //manager.responseSerializer = AFHTTPResponseSerializer()

        let dataTask : URLSessionDataTask = manager.dataTask(with: request as URLRequest) { (response, responseObject, error) -> Void in
            if ((error) != nil){
                print("Error: \(error!)")
                //self.hidHud()
                failier(error! as NSError)
            }
            else{
                SuccessHandle(responseObject! as Any, serverPath)

            }
        }
        manager.setTaskDidSendBodyDataBlock { ( session:URLSession!, uploadTask:URLSessionTask, bytesSent:Int64, totalBytesSent:Int64, totalBytesExpectedToSend:Int64) -> Void in
            let  progress1 : Float = Float(totalBytesSent)/Float(totalBytesExpectedToSend);
            print(progress1)
        }

        dataTask.resume()
    }

    
    // MARK:httpGet
    func httpGet(_ serverPath:String,postParams:[String:Any]?,SuccessHandle:@escaping (ServerSuccessCallBack) ,failier:@escaping ( ServerFailureCallBack ) ){
        let request:NSMutableURLRequest =   AFJSONRequestSerializer().request(withMethod: "GET", urlString: serverPath, parameters: postParams, error: nil)
        let manager : AFURLSessionManager = AFURLSessionManager(sessionConfiguration: URLSessionConfiguration.default);
        let dataTask : URLSessionDataTask = manager.dataTask(with: request as URLRequest) { (response, responseObject, error) -> Void in
            if ((error) != nil) {
                print("Error: \(error!)")
                self.hidHud()
                failier(error! as NSError)
            } else {
                SuccessHandle(responseObject! as Any, serverPath)
            }
        }
        manager.setTaskDidSendBodyDataBlock { ( session:URLSession!, uploadTask:URLSessionTask, bytesSent:Int64, totalBytesSent:Int64, totalBytesExpectedToSend:Int64) -> Void in
            let  progress1 : Float = Float(totalBytesSent)/Float(totalBytesExpectedToSend);
            print(progress1)
        }
        
        dataTask.resume()
        
    }
    // MARK:
    // MARK: httpMultipartDataPost
    
    func httpMultipartDataPostSingle(_ serverPath:String,postParams:[String:Any]? ,meidaObject:Any, mediaKey:String , isVideo : Bool ,SuccessHandle:@escaping (ServerSuccessCallBack) ,failier:@escaping ( ServerFailureCallBack ),ProgressHandle:@escaping (ServerProgressCallBack)){
        //AFHTTPRequestSerializer
        //AFJSONRequestSerializer
        
        var err:NSError? = nil
        
        let request:NSMutableURLRequest =   AFHTTPRequestSerializer().multipartFormRequest(withMethod: "POST", urlString: serverPath, parameters: postParams, constructingBodyWith: { (formData :AFMultipartFormData) -> Void in
            print("url \(serverPath)")
            print("parameters  \(String(describing: postParams))")
            print("meidaObject  \(meidaObject) mediaKey \(mediaKey)")
            
            var  filedata : Data
            var mimetype :String
            var filename :String
            if let mediaList  = meidaObject as? [Any]{
                for media in mediaList{
                    if let image  = media as? UIImage {
                        
                        filedata = UIImageJPEGRepresentation(image, 0.8)!
                        filename = AppUtility.filename(Prefix: "image", fileExtension: "jpg")
                        mimetype = "image/jpg" ;
                        formData .appendPart(withFileData: filedata, name: mediaKey, fileName: filename, mimeType: mimetype)
                    }
                    else{
                        // let err : NSError?=nil
                        let filepath = media as! String;
                        let url=URL(fileURLWithPath: filepath)
                        filename = url.lastPathComponent
                        filedata = try! Data(contentsOf: url)
                        mimetype = AppUtility.mimeTypeForPath(filePath: url as NSURL)
                        //formData.appendPartWithFileURL(url, name: mediaKey, fileName: filename, mimeType: mimetype, error: err)
                        formData .appendPart(withFileData: filedata, name: mediaKey, fileName: filename, mimeType: mimetype)
                        
                    }
                }
            }
            else
            {
                if let image  = meidaObject as? UIImage     {
                    
                    filedata = UIImagePNGRepresentation(image)!
                    filename = AppUtility.filename(Prefix: "image", fileExtension: "jpg")
                    mimetype = "image/jpg"
                    formData .appendPart(withFileData: filedata, name: mediaKey, fileName: filename, mimeType: mimetype)
                }
                else{
                    // let err : NSError?=nil
                    let filepath = meidaObject as! String
                    let url=URL(fileURLWithPath: filepath)
                    filename = url.lastPathComponent
                    filedata = try! Data(contentsOf: url)
                    mimetype = AppUtility.mimeTypeForPath(filePath: url as NSURL)
                    //formData.appendPartWithFileURL(url, name: mediaKey, fileName: filename, mimeType: mimetype, error: err)
                    formData .appendPart(withFileData: filedata, name: mediaKey, fileName: filename, mimeType: mimetype)
                }
            }
            
            
            
        }, error: &err)
        
        let manager : AFURLSessionManager = AFURLSessionManager(sessionConfiguration: URLSessionConfiguration.default);
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let uploadTask : URLSessionUploadTask = manager.uploadTask(withStreamedRequest: request as URLRequest, progress: { (uploadProgress) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                ProgressHandle(uploadProgress)
                
                // self.recieveProgressData(setProgress: Float(uploadProgress.fractionCompleted), label: "")
            })
            
        })
        { (response, responseObject, error) -> Void in
            if ((error) != nil) {
                print("Error: \(error!)")
                failier(error! as NSError)
            } else {
                do   {
                    let responseObject = try JSONSerialization.jsonObject(with: responseObject as!  Data, options: JSONSerialization.ReadingOptions(rawValue: UInt(0)))
                    if let responseDict =  responseObject as? Dictionary<String, Any> {
                        print(responseDict)
                        SuccessHandle(responseDict as Any, serverPath)
                    }
                }
                catch
                {
                }

            }
        }
        
        manager.setTaskDidSendBodyDataBlock { ( session:URLSession!, uploadTask:URLSessionTask, bytesSent:Int64, totalBytesSent:Int64, totalBytesExpectedToSend:Int64) -> Void in
            //  let  progress1 : Float = Float(totalBytesSent)/Float(totalBytesExpectedToSend);
            
            // self.recieveProgressData(setProgress: progress1, label: "")
        }
        uploadTask.resume()
    }

    // MARK: httpMultipartDataPost (multipleImages)
    func httpMultipartDataPost(_ serverPath:String,postParams:[String:Any]? ,meidaObject:Any, mediaKey:String , isVideo : Bool ,SuccessHandle:@escaping (ServerSuccessCallBack) ,failier:@escaping ( ServerFailureCallBack ),ProgressHandle:@escaping (ServerProgressCallBack)){
        //AFHTTPRequestSerializer
        //AFJSONRequestSerializer
        
        var err:NSError? = nil
        
        
        let request:NSMutableURLRequest =   AFHTTPRequestSerializer().multipartFormRequest(withMethod: "POST", urlString: serverPath, parameters: postParams, constructingBodyWith: { (formData :AFMultipartFormData) -> Void in
            
            var  filedata : Data
            var mimetype :String
            var filename :String
            var index :NSInteger
            index = 1
            if let mediaList  = meidaObject as? [Any]
            {
                for media in mediaList
                {
                    if index == 1{
                        let keyName = "profile_pic"
                        if let image  = media as? UIImage {
                            
                            filedata = UIImagePNGRepresentation(image)!
                            filename = AppUtility.filename(Prefix: "image", fileExtension: "png")
                            mimetype = "image/png" ;
                            formData .appendPart(withFileData: filedata, name: keyName, fileName: filename, mimeType: mimetype)
                        }
                        else{
                            // let err : NSError?=nil
                            let filepath = media as! String;
                            let url=URL(fileURLWithPath: filepath)
                            filename = url.lastPathComponent
                            filedata = try! Data(contentsOf: url)
                            mimetype = AppUtility.mimeTypeForPath(filePath: url as NSURL)
                            //formData.appendPartWithFileURL(url, name: mediaKey, fileName: filename, mimeType: mimetype, error: err)
                            formData .appendPart(withFileData: filedata, name: mediaKey, fileName: filename, mimeType: mimetype)
                            
                        }
                        index += 1
                    }
                    else if index == 2{
                        let keyName = "image1"
                        
                        if let image  = media as? UIImage {
                            
                            filedata = UIImagePNGRepresentation(image)!
                            filename = AppUtility.filename(Prefix: "image", fileExtension: "png")
                            mimetype = "image/png" ;
                            formData .appendPart(withFileData: filedata, name: keyName, fileName: filename, mimeType: mimetype)
                        }
                        else{
                            // let err : NSError?=nil
                            let filepath = media as! String;
                            let url=URL(fileURLWithPath: filepath)
                            filename = url.lastPathComponent
                            filedata = try! Data(contentsOf: url)
                            mimetype = AppUtility.mimeTypeForPath(filePath: url as NSURL)
                            //formData.appendPartWithFileURL(url, name: mediaKey, fileName: filename, mimeType: mimetype, error: err)
                            formData .appendPart(withFileData: filedata, name: keyName, fileName: filename, mimeType: mimetype)
                        }
                        index += 1
                    }
                    else {
                        let keyName = "image2"
                        
                        if let image  = media as? UIImage {
                            
                            filedata = UIImagePNGRepresentation(image)!
                            filename = AppUtility.filename(Prefix: "image", fileExtension: "png")
                            mimetype = "image/png" ;
                            formData .appendPart(withFileData: filedata, name: keyName, fileName: filename, mimeType: mimetype)
                        }
                        else{
                            // let err : NSError?=nil
                            let filepath = media as! String;
                            let url=URL(fileURLWithPath: filepath)
                            filename = url.lastPathComponent
                            filedata = try! Data(contentsOf: url)
                            mimetype = AppUtility.mimeTypeForPath(filePath: url as NSURL)
                            //formData.appendPartWithFileURL(url, name: mediaKey, fileName: filename, mimeType: mimetype, error: err)
                            formData .appendPart(withFileData: filedata, name: keyName, fileName: filename, mimeType: mimetype)
                        }
                        index += 1
                    }
                }
            }
            else
            {
                
                if let image  = meidaObject as? UIImage     {
                    
                    filedata = UIImagePNGRepresentation(image)!
                    filename = AppUtility.filename(Prefix: "image", fileExtension: "png")
                    mimetype = "image/png"
                    formData .appendPart(withFileData: filedata, name: mediaKey, fileName: filename, mimeType: mimetype)
                }
                else{
                    // let err : NSError?=nil
                    let filepath = meidaObject as! String
                    let url=URL(fileURLWithPath: filepath)
                    filename = url.lastPathComponent
                    filedata = try! Data(contentsOf: url)
                    mimetype = AppUtility.mimeTypeForPath(filePath: url as NSURL)
                    //formData.appendPartWithFileURL(url, name: mediaKey, fileName: filename, mimeType: mimetype, error: err)
                    formData .appendPart(withFileData: filedata, name: mediaKey, fileName: filename, mimeType: mimetype)
                    
                }
            }
        }, error: &err)
        
        let manager : AFURLSessionManager = AFURLSessionManager(sessionConfiguration: URLSessionConfiguration.default);
        manager.responseSerializer = AFHTTPResponseSerializer()

        let uploadTask : URLSessionUploadTask = manager.uploadTask(withStreamedRequest: request as URLRequest, progress: { (uploadProgress) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                ProgressHandle(uploadProgress)
           
            })
            
        })
        { (response, responseObject, error) -> Void in
            if ((error) != nil) {
                print("Error: \(error!)")
                failier(error! as NSError)
            } else {
                do   {
                    let responseObject = try JSONSerialization.jsonObject(with: responseObject as!  Data, options: JSONSerialization.ReadingOptions(rawValue: UInt(0)))
                    if let responseDict =  responseObject as? Dictionary<String, Any> {
                        print(responseDict)
                        SuccessHandle(responseDict as Any, serverPath)
                    }
                }
                catch
                {
                }
            }
        }
        
        manager.setTaskDidSendBodyDataBlock { ( session:URLSession!, uploadTask:URLSessionTask, bytesSent:Int64, totalBytesSent:Int64, totalBytesExpectedToSend:Int64) -> Void in
        }
        uploadTask.resume()
    }
    

    // MARK: httpMultipartDataPost
    func httpMultipartDataPost(_ serverPath:String,postParams:[String:Any]? ,meidaObject:Any, mediaKey:String , isVideo : Bool ,SuccessHandle:@escaping (ServerSuccessCallBack) ,failier:@escaping ( ServerFailureCallBack )){
        
        var err:NSError? = nil
        
        
        let request:NSMutableURLRequest =   AFHTTPRequestSerializer().multipartFormRequest(withMethod: "POST", urlString: serverPath, parameters: postParams, constructingBodyWith: { (formData :AFMultipartFormData) -> Void in
            
            var  filedata : Data
            var mimetype :String
            var filename :String
            var index :NSInteger
            index = 1
            if let mediaList  = meidaObject as? [Any]
            {
                for media in mediaList
                {
                    if index == 1{
                        let keyName = "profile_pic"
                    if let image  = media as? UIImage {
                        
                        filedata = UIImagePNGRepresentation(image)!
                        filename = AppUtility.filename(Prefix: "image", fileExtension: "png")
                        mimetype = "image/png" ;
                        formData .appendPart(withFileData: filedata, name: keyName, fileName: filename, mimeType: mimetype)
                    }
                    else{
                        // let err : NSError?=nil
                        let filepath = media as! String;
                        let url=URL(fileURLWithPath: filepath)
                        filename = url.lastPathComponent
                        filedata = try! Data(contentsOf: url)
                        mimetype = AppUtility.mimeTypeForPath(filePath: url as NSURL)
                        //formData.appendPartWithFileURL(url, name: mediaKey, fileName: filename, mimeType: mimetype, error: err)
                        formData .appendPart(withFileData: filedata, name: mediaKey, fileName: filename, mimeType: mimetype)
                        
                    }
                         index += 1
                }
                 else {
                        let keyName = "images"
                        
                        if let image  = media as? UIImage {
                            
                            filedata = UIImagePNGRepresentation(image)!
                            filename = AppUtility.filename(Prefix: "image", fileExtension: "png")
                            mimetype = "image/png" ;
                            formData .appendPart(withFileData: filedata, name: keyName, fileName: filename, mimeType: mimetype)
                        }
                        else{
                            // let err : NSError?=nil
                            let filepath = media as! String;
                            let url=URL(fileURLWithPath: filepath)
                            filename = url.lastPathComponent
                            filedata = try! Data(contentsOf: url)
                            mimetype = AppUtility.mimeTypeForPath(filePath: url as NSURL)
                            //formData.appendPartWithFileURL(url, name: mediaKey, fileName: filename, mimeType: mimetype, error: err)
                            formData .appendPart(withFileData: filedata, name: keyName, fileName: filename, mimeType: mimetype)
                        }
                         index += 1
                    }
                }
            }
            else
            {
              
                if let image  = meidaObject as? UIImage     {
                    
                    filedata = UIImagePNGRepresentation(image)!
                    filename = AppUtility.filename(Prefix: "image", fileExtension: "png")
                    mimetype = "image/png"
                    formData .appendPart(withFileData: filedata, name: mediaKey, fileName: filename, mimeType: mimetype)
                }
                else{
                    // let err : NSError?=nil
                    let filepath = meidaObject as! String
                    let url=URL(fileURLWithPath: filepath)
                    filename = url.lastPathComponent
                    filedata = try! Data(contentsOf: url)
                    mimetype = AppUtility.mimeTypeForPath(filePath: url as NSURL)
                    //formData.appendPartWithFileURL(url, name: mediaKey, fileName: filename, mimeType: mimetype, error: err)
                    formData .appendPart(withFileData: filedata, name: mediaKey, fileName: filename, mimeType: mimetype)
                    
                }
            }
            
           
            
            }, error: &err)
        
        let manager : AFURLSessionManager = AFURLSessionManager(sessionConfiguration: URLSessionConfiguration.default);
        
        let uploadTask : URLSessionUploadTask = manager.uploadTask(withStreamedRequest: request as URLRequest, progress: { (uploadProgress) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                self.recieveProgressData(setProgress: Float(uploadProgress.fractionCompleted), label: "")
            })
            
            })
        { (response, responseObject, error) -> Void in
            if ((error) != nil) {
                print("Error: \(error!)")
                self.hidHud()
                failier(error! as NSError)
            } else {
                
                
                SuccessHandle(responseObject! as Any, serverPath)
            }
        }
        
        manager.setTaskDidSendBodyDataBlock { ( session:URLSession!, uploadTask:URLSessionTask, bytesSent:Int64, totalBytesSent:Int64, totalBytesExpectedToSend:Int64) -> Void in
            let  progress1 : Float = Float(totalBytesSent)/Float(totalBytesExpectedToSend);
            NSLog("progress1: %f", progress1);
            
            self.recieveProgressData(setProgress: progress1, label: "")
        }
        
        uploadTask.resume()
    }
    
    func uploadVideoOnServer(serverPath: String , parameter: [String:Any]?,mediaFile: Any , videoKey : String ,thumbnailImage: UIImage , thumbnailKey : String , SuccessHandle:@escaping (ServerSuccessCallBack) , ProgressHandle:@escaping (ServerProgressCallBack) ,failier:@escaping ( ServerFailureCallBack )) {
        var err:NSError? = nil
        let request:NSMutableURLRequest =   AFHTTPRequestSerializer().multipartFormRequest(withMethod: "POST", urlString: serverPath, parameters: parameter, constructingBodyWith: { (formData :AFMultipartFormData) -> Void in
            //For Thumbnail Image
            var  imageData : Data
            var imageMimetype :String
            var imageName :String
            imageData = UIImagePNGRepresentation(thumbnailImage)!
            imageName = AppUtility.filename(Prefix: "image", fileExtension: "png")
            imageMimetype = "image/png" ;
            formData .appendPart(withFileData: imageData, name: thumbnailKey, fileName: imageName, mimeType: imageMimetype)
            //For Video
            
            var  videoData : Data
            var  videoMimetype :String
            let videoFilePath = URL(fileURLWithPath: mediaFile as! String)
            let videoFileName = videoFilePath.lastPathComponent
            let videoFile = videoFileName.replacingOccurrences(of: "trim.", with: "+")
            videoData = try! Data(contentsOf: videoFilePath)
            videoMimetype = AppUtility.mimeTypeForPath(filePath: videoFilePath as NSURL)
            formData .appendPart(withFileData: videoData, name: videoKey, fileName: videoFile, mimeType: videoMimetype)
        }, error: &err)
        
        let manager : AFURLSessionManager = AFURLSessionManager(sessionConfiguration: URLSessionConfiguration.default);
           manager.responseSerializer = AFHTTPResponseSerializer()
     let uploadTask : URLSessionUploadTask = manager.uploadTask(withStreamedRequest: request as URLRequest, progress: { (uploadProgress) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                 ProgressHandle(uploadProgress)
                //self.recieveProgressData(setProgress: Float(uploadProgress.fractionCompleted), label: "")
            })
            
        })
        { (response, responseObject, error) -> Void in
            if ((error) != nil) {
                print("Error: \(error!)")
                //self.hidHud()
                failier(error! as NSError)
            } else {
                SuccessHandle(responseObject! as Any, serverPath)
            }
        }
        manager.setTaskDidSendBodyDataBlock { ( session:URLSession!, uploadTask:URLSessionTask, bytesSent:Int64, totalBytesSent:Int64, totalBytesExpectedToSend:Int64) -> Void in
            let  progress1 : Float = Float(totalBytesSent)/Float(totalBytesExpectedToSend);
            NSLog("progress1: %f", progress1);
            //self.recieveProgressData(setProgress: progress1, label: "")
        }
        
        uploadTask.resume()
    }
    
    // MARK: httpDownloadTask
    
    func httpDownloadTask(_ serverPath:String,SuccessHandle:@escaping (ServerSuccessCallBack) ,failier:@escaping ( ServerFailureCallBack )){
        let configuration = URLSessionConfiguration.default
        let manager=AFURLSessionManager(sessionConfiguration: configuration)
        let fileUrl  = URL(string: serverPath)
        let request = URLRequest(url: fileUrl!)
        let downloadTask  : URLSessionDownloadTask = manager.downloadTask(with: request, progress: nil, destination: { (targetPath, response) -> URL in
            /*
            let  documentsDirectoryURL = try? Foundation.FileManager.default.url(for: Foundation.FileManager.SearchPathDirectory.documentDirectory, in: Foundation.FileManager.SearchPathDomainMask(), appropriateFor: nil, create: false)
            return documentsDirectoryURL!.appendingPathComponent(response.suggestedFilename!)
            */
            let directory : NSURL = (self.documentsDirectoryURL as NSURL)
            return directory.appendingPathComponent(response.suggestedFilename!)!
            }, completionHandler: { (response, filePath, error) -> Void in
                
                print("File downloaded to:\(filePath!)")
               
                if (error==nil)
                {
                    
                    
                    SuccessHandle(filePath! as Any, serverPath)
                }
                else
                {
                     print("Error: \(error!)")
                    failier(error! as NSError)
                    
                    self.hidHud()
                }
        })
        downloadTask.resume()
        manager.setDownloadTaskDidWriteDataBlock { (session:URLSession!, downloadTask:URLSessionDownloadTask!, bytesWritten:Int64, totalBytesWritten:Int64, totalBytesExpectedToWrite:Int64) -> Void in
            
            DispatchQueue.main.async(execute: { () -> Void in
                let  progress : Float = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite);
                self.recieveProgressData(setProgress: progress, label: "")
            })
            
        }
        
        
    }
    
    // MARK: httpBackGroundTask
    func httpBackGroundTask(serverRequest serverPath: String ,WithParams params: NSDictionary ,isPostMethod posttype: Bool ,SuccessHandle:@escaping (ServerSuccessCallBack) ,failier:@escaping ( ServerFailureCallBack )){
        let manager : AFURLSessionManager = AFURLSessionManager(sessionConfiguration: URLSessionConfiguration.default);
        var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = 0
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask (expirationHandler: { () -> Void in
            manager.operationQueue.cancelAllOperations()
            UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
        })
        
        let method : String =  ((posttype == true) ?  "POST":"GET")
        
        let request:NSMutableURLRequest =   AFJSONRequestSerializer().request(withMethod: method, urlString: serverPath, parameters: params , error: nil)
        let dataTask : URLSessionDataTask = manager.dataTask(with: request as URLRequest) { (response, responseObject, error) -> Void in
            if ((error) != nil) {
                 print("Error: \(error!)")
                self.hidHud()
                failier(error! as NSError)
            } else {
                SuccessHandle(responseObject! as Any, serverPath)
            }
        }
        
        dataTask.resume()
        
    }
    
    //MARK: 
    
    func getFormDataStringWithDictParams (_ parameter: Dictionary<String, Any> ) -> Data? {
        var bodyString = [String]()
        for (name, value) in parameter {
            bodyString.append("\(name)=\(value)")
        }
         let str = bodyString.joined(separator: "&")
        return str.data(using: String.Encoding.utf8)
        
    }
    
    
}
//MARK:-AppUtility-
class AppUtility:NSObject{
    
    //MARK:-generateBoundaryString-
    class func generateBoundaryString() -> String
    {
        return  "Boundary-\(NSUUID().uuidString)"
    }
    //MARK:-mimeTypeForPath-
    class func mimeTypeForPath(filePath:NSURL)->String
    {
        var  mimeType:String;
        
        let fileExtension:CFString = (filePath.pathExtension as NSString?)!
        let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, nil);
        let str = UTTypeCopyPreferredTagWithClass(UTI!.takeUnretainedValue(), kUTTagClassMIMEType);
        if (str == nil) {
            mimeType = "application/octet-stream";
        } else {
            mimeType = str!.takeUnretainedValue() as String
        }
        return mimeType
    }
    //MARK:-filename-
    class func filename(Prefix:String , fileExtension:String)-> String
    {
        let dateformatter=DateFormatter()
        dateformatter.dateFormat="MddyyHHmmss"
        let dateInStringFormated=dateformatter.string(from: NSDate() as Date )
        return  NSString(format: "%@_%@.%@", Prefix,dateInStringFormated,fileExtension) as String
    }
    //MARK:-getJsonObjectDict-
    class func getJsonObjectDict(responseObject:Any)->[String:Any]
    {
        var anyObj :[String:Any]!
        do
        {
            anyObj = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: []) as! [String:Any]
            // use anyObj here
            return anyObj!
            
        } catch  {
            print("json error: \(error)")
        }
        return anyObj!
    }
    //MARK:-getJsonObjectArray-
    class func getJsonObjectArray(responseObject:Any)->[Any]
    {
        
        var anyObj :[Any] = [Any]()
        do
        {
            anyObj = try JSONSerialization.jsonObject(with: (responseObject as! NSData) as Data, options: []) as! [Any]
            // use anyObj here
            return anyObj
            
        } catch  {
            print("json error: \(error)")
        }
        return anyObj
    }
    //MARK:-JSONStringify-
    class func JSONStringify(value: Any, prettyPrinted: Bool = false) -> String
    {
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        
        if JSONSerialization.isValidJSONObject(value)
        {
            if let data = try? JSONSerialization.data(withJSONObject: value, options: options)
            {
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                {
                    return string as String
                }
            }
        }
        return ""
    }
    //MARK:-getJsonData-
    class func getJsonData(responseObject:Any)->NSData
    {
        
        var data :NSData!
        do
        {
            data = try JSONSerialization.data(withJSONObject: responseObject, options: []) as NSData!
            // use anyObj here
            return data!
            
        } catch  {
            print("json error: \(error)")
        }
        return data!
    }
    //MARK:-isValidPassword-
    class func isValidPassword(password: String) -> Bool
    {
        if (password.isEmpty)
        {
            return false
        }
        
        let passRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{10,}"
        let passwordTest=NSPredicate(format: "SELF MATCHES %@", passRegEx);
        return passwordTest.evaluate(with: password)
        
        
    }
    //MARK:-isValidEmail-
    class  func isValidEmail(testStr:String) -> Bool {
        print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest=NSPredicate(format: "SELF MATCHES %@", emailRegEx);
        return emailTest.evaluate(with: testStr)
    }
    
    //MARK:-validPhoneNumber-
    class func validPhoneNumber(value: String) -> Bool
    {
        let phone_regex = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phone_regex)
        return phoneTest.evaluate(with: value)
    }
    class func checkToDateStrGreaterThanFromDateStr(fromdatestring:String, andDate todatestring:String,setDateFormat dateFormat:String!)->ComparisonResult{
        
        let dformate :DateFormatter = DateFormatter()
        dformate.timeZone = NSTimeZone.local
        dformate.dateFormat  = dateFormat
        let fromdate : Date! = dformate.date(from: fromdatestring)!
        let todate : Date! = dformate.date(from: todatestring)!
        let result : ComparisonResult = fromdate.compare(todate)
        
        return result
        
    }
    
}

