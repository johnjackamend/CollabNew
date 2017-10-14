//
//  Extensions.swift
//  Caveman
//
//  Created by Jitendra Kumar on 28/11/16.
//  Copyright © 2016 AsthaSachdeva. All rights reserved.
//

import UIKit
import Dispatch
import Foundation

//--------------MARK:- NSUserDefaults Extension -
extension UserDefaults
{
    class func SFSDefault(setIntegerValue integer: Int , forKey key : String)
    {
        UserDefaults.standard.set(integer, forKey: key)
        UserDefaults.standard.synchronize()
        
    }
    class func SFSDefault(setObject object: Any , forKey key : String)
    {
        UserDefaults.standard.set(object, forKey: key)
        UserDefaults.standard.synchronize()
        
    }
    class func SFSDefault(setValue object: Any , forKey key : String)
    {
        UserDefaults.standard.setValue(object, forKey: key)
        UserDefaults.standard.synchronize()
        
    }
    class func SFSDefault(setBool boolObject:Bool  , forKey key : String)
    {
        UserDefaults.standard.set(boolObject, forKey : key)
        UserDefaults.standard.synchronize()
        
    }
    
    
    class func SFSDefault(integerForKey  key: String) -> Int{
        let integerValue : Int = UserDefaults.standard.integer(forKey: key) as Int
        UserDefaults.standard.synchronize()
        
        return integerValue
    }
    class func SFSDefault(objectForKey key: String) -> Any
    {
        let object : Any = UserDefaults.standard.object(forKey: key)! as Any
        UserDefaults.standard.synchronize()
        
        return object
    }
    class func SFSDefault(valueForKey  key: String) -> Any
    {
        let value : Any = UserDefaults.standard.value(forKey: key)! as Any
        UserDefaults.standard.synchronize()
        return value
    }
    class func SFSDefault(boolForKey  key : String) -> Bool
    {
        let booleanValue : Bool = UserDefaults.standard.bool(forKey: key) as Bool
        UserDefaults.standard.synchronize()
        
        return booleanValue
    }
    
    class func SFSDefault(removeObjectForKey key: String)
    {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    //Save no-premitive data
    class func SFSDefault(setArchivedDataObject object: Any , forKey key : String)
    {
        let data : Data? = NSKeyedArchiver.archivedData(withRootObject: object)
        UserDefaults.standard.set(data, forKey: key)
        UserDefaults.standard.synchronize()
    }
    class func SFSDefault(getUnArchiveObjectforKey key: String) -> Any
    {
        var objectValue : Any?
        if  let storedData  = UserDefaults.standard.object(forKey: key) as? Data
        {
            objectValue   =  NSKeyedUnarchiver.unarchiveObject(with: storedData) as Any?
            UserDefaults.standard.synchronize()
            return objectValue!;
        }
        else
        {
            objectValue = "" as Any?
            return objectValue!
            
        }
        
        
    }
 
}
extension UIColor
{
    class  func smRedColor()->UIColor
    {
        
        
        return UIColor(red: 199.0/255.0, green: 49.0/255.0, blue: 32.0/255.0, alpha: 1.0)
        
    }
    class  func smGoldenColor()->UIColor
    {


        return UIColor(red: 192.0/255.0, green: 135.0/255.0, blue: 51.0/255.0, alpha: 1.0)

    }
    class  func smCellBackGroundColor()->UIColor
    {
        
        
        return UIColor(red: 241.0/255.0, green: 244.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        
    }
    
    
    class func smPlaceHolderColor()->UIColor
    {
        
        return UIColor(red: 161.0/255.0, green: 161.0/255.0, blue: 162.0/255.0, alpha: 1.0)
        
    }
    
    class func smRGB(smRed r:CGFloat , smGrean g: CGFloat , smBlue b: CGFloat)->UIColor
    {
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
        
    }
    class  func getRandomColor() -> UIColor{
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
        
    }
}
extension UITextField
{
  
    func textFieldPlaceholderColor(_ color:UIColor){
        let attibutedStr:NSAttributedString=NSAttributedString(string: self.placeholder!, attributes: [NSForegroundColorAttributeName: color]);
        //        self.attributedPlaceholder = NSAttributedString(string:placeholder,
        //            attributes:[NSForegroundColorAttributeName: color])
        
        self.attributedPlaceholder=attibutedStr
    }
    
    func setLeftPaddingImageIcon(_ imageicon:UIImage){
        let image1: UIImage? = imageicon
        if image1 != nil {
            let view: UIView? = UIView()
            view!.frame = CGRect(x: 0, y: 0, width: self.frame.size.height, height: self.frame.size.height)
            let imageView=UIImageView()
            imageView.frame=CGRect(x: 0, y: 8, width: self.frame.size.height-16, height: self.frame.size.height-16)
            imageView.image=imageicon
            imageView.contentMode = .scaleAspectFit
            view?.addSubview(imageView)
            self.leftView=view
            self.leftViewMode=UITextFieldViewMode.always
            
        }
        self.setRightPaddingView()
    }
    
    func setLeftPaddingView(){
        let paddingView=UIView()
        paddingView.frame=CGRect(x: 0, y: 0, width: 10, height: 30)
        self.leftView=paddingView
        self.leftViewMode=UITextFieldViewMode.always
        
    }
    
    func setRightPaddingImageIcon(_ imageicon:UIImage){
        let image1: UIImage? = imageicon
        if image1 != nil {
            let view: UIView? = UIView()
            view!.frame = CGRect(x: 0, y: 0, width: self.frame.size.height, height: self.frame.size.height)
            let imageView=UIImageView()
            imageView.frame=CGRect(x: 8, y: 8, width: self.frame.size.height-16, height: self.frame.size.height-16)
            imageView.image=imageicon
            imageView.contentMode = .scaleAspectFit
            view?.addSubview(imageView)
            self.rightView=view
            self.rightViewMode=UITextFieldViewMode.always
            
        }
        self.setLeftPaddingView()
    }
    
    func setRightPaddingView(){
        let paddingView=UIView()
        paddingView.frame=CGRect(x: 0, y: 0, width: 10, height: 30)
        self.rightView=paddingView
        self.rightViewMode=UITextFieldViewMode.always
    }
    
    func setLeftAndRightPadding() {
        self.setLeftPaddingView()
        self.setRightPaddingView()
    }
    

    
    func setTextFieldRadiusCorner(_ cornerRadius:CGFloat){
        self.layer.cornerRadius=cornerRadius;
        self.layer.masksToBounds=true;
    }
    
    func setTextFieldBoader(_ borderW:CGFloat,borderC:UIColor){
        self.layer.borderWidth=borderW;
        self.layer.borderColor=borderC.cgColor;
        
    }
}
//--------------MARK:- UIAlertController Extension -
let UIAlertControllerBlocksCancelButtonIndex : Int = 0;
let UIAlertControllerBlocksDestructiveButtonIndex : Int = 1;
let UIAlertControllerBlocksFirstOtherButtonIndex : Int = 2;
typealias UIAlertControllerPopoverPresentationControllerBlock = (_ popover:UIPopoverPresentationController?)->Void
typealias UIAlertControllerCompletionBlock = (_ alertController:UIAlertController?,_ action:UIAlertAction?,_ buttonIndex:Int?)->Void
extension UIAlertController{
     //MARK:- showInViewController -
    class func showInViewController(viewController:UIViewController!,withTitle title:String?,withMessage message:String?,withpreferredStyle preferredStyle:UIAlertControllerStyle?,cancelButtonTitle cancelTitle:String?,destructiveButtonTitle destructiveTitle:String?,otherButtonTitles otherTitles:[String?]?,popoverPresentationControllerBlock:UIAlertControllerPopoverPresentationControllerBlock?,tapBlock:UIAlertControllerCompletionBlock?) -> UIAlertController!{
        
        let strongController : UIAlertController! = UIAlertController(title: title, message: message, preferredStyle: preferredStyle!)
        strongController.view.tintColor = UIColor.black
        if (cancelTitle != nil)
        {
            let cancelAction : UIAlertAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: { (action:UIAlertAction) in
                if (tapBlock != nil){
                    tapBlock!(strongController,action,UIAlertControllerBlocksCancelButtonIndex)
                }
            })
            strongController.addAction(cancelAction)
        }
        if (destructiveTitle != nil)
        {
            let destructiveAction : UIAlertAction = UIAlertAction(title: destructiveTitle, style:.destructive, handler: { (action:UIAlertAction) in
                if (tapBlock != nil){
                    tapBlock!(strongController,action,UIAlertControllerBlocksDestructiveButtonIndex)
                }
            })
            strongController.addAction(destructiveAction)
        }
        if (otherTitles != nil)
        {
            for btnx in 0..<otherTitles!.count
            {
                let otherButtonTitle:String = otherTitles![btnx]!
                
                let otherAction : UIAlertAction = UIAlertAction(title: otherButtonTitle, style: .default, handler: { (action:UIAlertAction) in
                    if (tapBlock != nil){
                        tapBlock!(strongController,action,UIAlertControllerBlocksFirstOtherButtonIndex+btnx)
                    }
                })
                strongController.addAction(otherAction)
                
            }
        }
        
        if (popoverPresentationControllerBlock != nil)
        {
            popoverPresentationControllerBlock!(strongController.popoverPresentationController!)
        }
        
        DispatchQueue.main.async {
            viewController.present(strongController, animated: true, completion:{})
        }
        
        return strongController
    }
    //MARK:- showAlertInViewController -
    class func showAlertInViewController(viewController:UIViewController!,withTitle title:String?,message:String?,cancelButtonTitle cancelTitle:String?,destructiveButtonTitle destructiveTitle:String?,otherButtonTitles otherTitles:[String?]?,tapBlock:UIAlertControllerCompletionBlock?) -> UIAlertController!{
        
        return self.showInViewController(viewController: viewController, withTitle: title, withMessage: message, withpreferredStyle:.alert, cancelButtonTitle: cancelTitle, destructiveButtonTitle: destructiveTitle, otherButtonTitles: otherTitles, popoverPresentationControllerBlock: nil, tapBlock: tapBlock)
    }
    //MARK:- showActionSheetInViewController -
    class func showActionSheetInViewController(viewController:UIViewController!,withTitle title:String?,message:String?,cancelButtonTitle cancelTitle:String?,destructiveButtonTitle destructiveTitle:String?,otherButtonTitles otherTitles:[String?]?,tapBlock:UIAlertControllerCompletionBlock?) -> UIAlertController!{
        
        return self.showInViewController(viewController: viewController, withTitle: title, withMessage: message, withpreferredStyle:.actionSheet, cancelButtonTitle: cancelTitle, destructiveButtonTitle: destructiveTitle, otherButtonTitles: otherTitles, popoverPresentationControllerBlock: nil, tapBlock: tapBlock)
    }
    class func showActionSheetInViewController(viewController:UIViewController!,withTitle title:String?,message:String?,cancelButtonTitle cancelTitle:String?,destructiveButtonTitle destructiveTitle:String?,otherButtonTitles otherTitles:[String?]?,popoverPresentationControllerBlock:UIAlertControllerPopoverPresentationControllerBlock?,tapBlock:UIAlertControllerCompletionBlock?) -> UIAlertController!{
        
        return self.showInViewController(viewController: viewController, withTitle: title, withMessage: message, withpreferredStyle:.actionSheet, cancelButtonTitle: cancelTitle, destructiveButtonTitle: destructiveTitle, otherButtonTitles: otherTitles, popoverPresentationControllerBlock: popoverPresentationControllerBlock, tapBlock: tapBlock)
    }
    
}

extension String{
    func insert(seperator: String, afterEveryXChars: Int, intoString: String) -> String
    {
        var output = ""
        intoString.characters.enumerated().forEach { index, c in
            if index % afterEveryXChars == 0 && index > 0
            {
                output += seperator
            }
            output.append(c)
        }
        //        insert(":", afterEveryXChars: 2, intoString: "11231245")
        print(output)
        return output
    }
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension UIView {
    
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    func addCenterConstraintsOf(item:UIView ,itemSize size:CGSize!){
        item.translatesAutoresizingMaskIntoConstraints = false
        let width : NSLayoutConstraint = NSLayoutConstraint(item: item, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: size.width)
        let height : NSLayoutConstraint = NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: size.height)
        let xConstraint : NSLayoutConstraint = NSLayoutConstraint(item: item, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint : NSLayoutConstraint = NSLayoutConstraint(item: item, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([width,height,xConstraint,yConstraint])
        item.setNeedsDisplay()
    }
}


extension DispatchQueue {
    
    static var userInteractive: DispatchQueue { return DispatchQueue.global(qos: .userInteractive) }
    static var userInitiated: DispatchQueue { return DispatchQueue.global(qos: .userInitiated) }
    static var utility: DispatchQueue { return DispatchQueue.global(qos: .utility) }
    static var background: DispatchQueue { return DispatchQueue.global(qos: .background) }
    
    func after(_ delay: TimeInterval, execute closure: @escaping () -> Void) {
        asyncAfter(deadline: .now() + delay, execute: closure)
    }
    
    func syncResult<T>(_ closure: () -> T) -> T {
        var result: T!
        sync { result = closure() }
        return result
    }
}

