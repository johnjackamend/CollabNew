//
//  JKNotificationView.swift
//  youtube
//
//  Created by Jitendra Kumar on 02/12/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
extension JKNotificationView{
    
}
class JKNotificationUtility: NSObject
{
    
    override init() {
        super.init()
    }
    
   class func getNotificationViewFrameHeight()->CGFloat
    {
        return  64.0
    }
   class func getTitleLabelFontSize()->Float {
        return  14.0
    }
   class func getMessageLabelFontSize()->Float {
        return  13.0
    }
   class func getImageViewIconCornerRadius()->Float {
        return  3.0
    }
   class func getImageViewIconFrame()->CGRect {
        return  CGRect(x:15.0,y: 8.0,width: 20.0,height: 20.0)
    }
    
   class func getDragHandlerFrame()->CGRect {
        return  CGRect(x:  UIScreen.main.bounds.size.width/2 - 30.0 ,y: self.getNotificationViewFrameHeight()-5.0,width: 60.0,height: 3.0)
    }
    
    class func getTitleLabelFrame()->CGRect {
        return  CGRect(x:45.0,y: 3.0,width: UIScreen.main.bounds.size.width-45.0,height: 26.0)
    }
    class func getTitleLabelFrameWithOutImage()->CGRect {
        return  CGRect(x:5.0,y: 3.0,width: UIScreen.main.bounds.size.width-5.0,height: 26.0)
    }
    class func getTitleLabelColor()->UIColor {
        return  UIColor.darkGray
    }
    class func getMessageLabelFrameHeight()->CGFloat {
        return  35.0
    }
    class func getMessageLabelFrame()->CGRect {
        return CGRect(x:45.0,y: 25.0,width: UIScreen.main.bounds.size.width-45.0,height: getMessageLabelFrameHeight())
    }
    
    class func getMessageLabelFrameWithOutImage()->CGRect {
        return  CGRect(x:5.0,y: 25.0,width: UIScreen.main.bounds.size.width-5.0,height: getMessageLabelFrameHeight())
    }
    class func getMessageLabelColor()->UIColor {
        return  UIColor.darkGray
    }
    class func notificationShowingDuration()->TimeInterval {
        return  7.0 /// second(s)
    }
    class func notificationShowingAnimationTime()->TimeInterval {
        return  0.5 /// second(s)
    }
    
}

typealias JKNotificationOnComplition = (_ animated:Bool)->Void
class JKNotificationView: UIToolbar , UIGestureRecognizerDelegate
{
 
    var _isDragging : Bool! = false
    var isVerticalPan : Bool! = false
    var _timerHideAuto : Timer?
    
    var onTouchHandler : JKNotificationOnComplition? = nil
    class var sharedInstance: JKNotificationView {
        struct Static {
            static let instance: JKNotificationView = JKNotificationView()
        }
        return Static.instance
    }
    
    
    lazy var imgIcon :UIImageView = {
        let launcher = UIImageView()
        return launcher
    }()
    lazy var _lblTitle :UILabel = {
        let launcher = UILabel()
        return launcher
    }()
    lazy var _lblMessage :UILabel = {
        let launcher = UILabel()
        return launcher
    }()
    lazy var _dragHandler :UIView = {
        let launcher = UIView()
        
        return launcher
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(){
        let rect:CGRect = CGRect(x: 0.0, y: 0.0, width:UIScreen.main.bounds.size.width, height: JKNotificationUtility.getNotificationViewFrameHeight())
        super.init(frame: rect)
        if UIDevice.current.isGeneratingDeviceOrientationNotifications == false{
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(JKNotificationView.orientationStatusDidChange), name:NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        setUpUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI(){
        
        self.barTintColor = UIColor.white
        self.isTranslucent = true
        self.barStyle = .default
        self.layer.zPosition = CGFloat(MAXFLOAT)
        self.backgroundColor = UIColor.clear
        self.isMultipleTouchEnabled = false
        self.isExclusiveTouch = true
        self.frame = CGRect(x: 0.0, y: 0.0, width:UIScreen.main.bounds.size.width, height: JKNotificationUtility.getNotificationViewFrameHeight())
        /// Icon
        imgIcon.frame = JKNotificationUtility.getImageViewIconFrame()//IMAGE_VIEW_ICON_FRAME
        imgIcon.contentMode = .scaleAspectFill
        imgIcon.layer.cornerRadius = CGFloat(JKNotificationUtility.getImageViewIconCornerRadius())
        imgIcon.clipsToBounds = true
        
        if (imgIcon.superview == nil) {
            self.addSubview(imgIcon)
        }
        /// Title
        _lblTitle.frame = JKNotificationUtility.getTitleLabelFrame()//LABEL_TITLE_FRAME
        _lblTitle.textColor = JKNotificationUtility.getTitleLabelColor()//LABEL_TITLE_COLOR
        _lblTitle.font = UIFont(name: "HelveticaNeue-Bold", size: CGFloat(JKNotificationUtility.getTitleLabelFontSize()))
        _lblTitle.numberOfLines = 1
        if (_lblTitle.superview == nil) {
            self.addSubview(_lblTitle)
        }
        
        /// Message
        _lblMessage.frame = JKNotificationUtility.getMessageLabelFrame()//LABEL_MESSAGE_FRAME
        _lblMessage.textColor = JKNotificationUtility.getMessageLabelColor()///LABEL_MESSAGE_COLOR
        _lblMessage.font = UIFont(name: "HelveticaNeue", size: CGFloat(JKNotificationUtility.getMessageLabelFontSize()))
        _lblMessage.numberOfLines = 2
        _lblMessage.lineBreakMode = .byTruncatingTail
        if (_lblMessage.superview == nil) {
            self.addSubview(_lblMessage)
        }
        fixLabelMessageSize()
        //Drag Handler

        _dragHandler.frame = JKNotificationUtility.getDragHandlerFrame() //DRAG_HANDLER_FRAME
        _dragHandler.layer.cornerRadius = 2
        _dragHandler.backgroundColor = UIColor.white
        if (_dragHandler.superview == nil) {
            self.addSubview(_dragHandler)
        }
        
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(JKNotificationView.notificationViewDidTap))
        self.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        let panGesture : UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action:#selector(JKNotificationView.notificationViewDidPan))
        panGesture.delegate = self
        
        self.addGestureRecognizer(panGesture)
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let shadowPath : UIBezierPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 4.0)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width:0, height:3);
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 8
        self.layer.shadowPath = shadowPath.cgPath;

    }
    
    func showNotificationView(image : UIImage? , withTitle title: String?,withMessage message:String?,AutoHide isAutoHide:Bool!,onTouchHandler onTouch:JKNotificationOnComplition? ){
        /// Invalidate _timerHideAuto
        if ((_timerHideAuto) != nil) {
           _timerHideAuto?.invalidate()
            _timerHideAuto = nil;
        }
        
        /// onTouch
        onTouchHandler = onTouch
        //Image
        if (image != nil) {
            
            imgIcon.image = image
            
        }
        else{
            imgIcon.image = nil
            _lblTitle.frame = JKNotificationUtility.getTitleLabelFrameWithOutImage()//LABEL_TITLE_FRAME_WITHOUT_IMAGE
            _lblMessage.frame = JKNotificationUtility.getMessageLabelFrameWithOutImage()//LABEL_MESSAGE_FRAME_WITHOUT_IMAGE
        }
        
        //Title
        
        if (title != nil)
        {
            _lblTitle.text = title!
        }
        else{
            _lblTitle.text = ""
        }
        
        //Message
        
        if (message != nil)
        {
            _lblMessage.text = message!
        }
        else{
            _lblMessage.text = ""
        }

        fixLabelMessageSize()
        /// Prepare frame
        var frame : CGRect = self.frame
        frame.origin.y = -frame.size.height
        
        self.frame = frame
        
        //Add to window
        UIApplication.shared.delegate?.window??.windowLevel = UIWindowLevelStatusBar
        UIApplication.shared.delegate?.window??.addSubview(self)
        
        // show animation
        
        UIView.animate( withDuration: JKNotificationUtility.notificationShowingAnimationTime(), delay: 0.0, options: .curveEaseOut, animations: {
            var frame : CGRect = self.frame
            frame.origin.y = frame.origin.y+frame.size.height
            self.frame = frame
        }) { (finished:Bool) in
            
        }
 // Schedule to hide
        if isAutoHide  == true
        {
            
            _timerHideAuto = Timer.scheduledTimer(timeInterval: JKNotificationUtility.notificationShowingDuration(), target: self, selector: #selector(JKNotificationView.hideNotificationView), userInfo: nil, repeats: false)
            
        }
    }
    
    func hideNotificationView(){
        self.hideNotificationViewOnComplete(onComplete: nil)
    }
    func hideNotificationViewOnComplete(onComplete : JKNotificationOnComplition?){
        if _isDragging == false
        {
            
            UIView.animate( withDuration: JKNotificationUtility.notificationShowingAnimationTime(), delay: 0.0, options: .curveEaseOut, animations: {
                var frame : CGRect = self.frame
                frame.origin.y = frame.origin.y-frame.size.height
                self.frame = frame
            }) { (finished:Bool) in
                self.removeFromSuperview()
                UIApplication.shared.delegate?.window??.windowLevel = UIWindowLevelNormal
                /// Invalidate _timerHideAuto
                if ((self._timerHideAuto) != nil) {
                    self._timerHideAuto?.invalidate()
                    self._timerHideAuto = nil;
                }
                if (onComplete != nil){
                    onComplete!(true)
                }
            }
        }
        else{
            /// Invalidate _timerHideAuto
            if ((self._timerHideAuto) != nil) {
                self._timerHideAuto?.invalidate()
                self._timerHideAuto = nil;
            }
        }
    }
    //MARK:-notificationViewDidTap
    @objc func notificationViewDidTap(gesture : UIGestureRecognizer){
        
        if (onTouchHandler != nil) {
            onTouchHandler!(true)
        }
    }
    //MARK:-notificationViewDidPan
   @objc  func notificationViewDidPan(gesture : UIPanGestureRecognizer){
        
        if gesture.state == .ended {
            _isDragging = false
            if self.frame.origin.y < 0 || _timerHideAuto == nil
            {
                hideNotificationView()
            }
        }
        else if gesture.state == .began{
             _isDragging = true
        }
        else if gesture.state == .changed{
            let translation : CGPoint = gesture.translation(in: self.superview)
            // Figure out where the user is trying to drag the view.
            let newCenter : CGPoint = CGPoint(x: self.superview!.bounds.size.width / 2, y: gesture.view!.center.y + translation.y)
            // See if the new position is in bounds.
            if newCenter.y >= (-1*JKNotificationUtility.getNotificationViewFrameHeight()/2) && newCenter.y <= JKNotificationUtility.getNotificationViewFrameHeight()/2 {
                gesture.view?.center = newCenter
                
                gesture.setTranslation(.zero, in: self.superview)
            }
        }

    }
    
    //MARK:-GESTURE DELEGATE
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer.isKind(of:UIPanGestureRecognizer.self) {
            let panGestureRecognizer : UIPanGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
            let translation : CGPoint = panGestureRecognizer.translation(in: self)
            isVerticalPan = fabs(translation.y) > fabs(translation.x) // BOOL property
            return true
        }
        else if gestureRecognizer.isKind(of: UITapGestureRecognizer.self){
            let tapGestureRecognizer : UITapGestureRecognizer = gestureRecognizer as! UITapGestureRecognizer
            notificationViewDidTap(gesture: tapGestureRecognizer)
            return false
        }
        else{
            return false
        }
    }
    
        //MARK:-HELPER
        func fixLabelMessageSize(){
            let size : CGSize = _lblMessage.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width - 45.0, height: CGFloat(MAXFLOAT)))
            var frame : CGRect  = _lblMessage.frame
            
            frame.size.height = (size.height > JKNotificationUtility.getMessageLabelFrameHeight() ? JKNotificationUtility.getMessageLabelFrameHeight() : size.height)
            _lblMessage.frame = frame
            
            
        }
        //MARK:- - ORIENTATION NOTIFICATION
        
        func orientationStatusDidChange(notification:NSNotification){
            
            setUpUI()
        }
    
    //MARK:- UTILITY FUNCS
    class func showNotificationView(image : UIImage? , withTitle title: String?,withMessage message:String?){
        JKNotificationView.sharedInstance.showNotificationView(image: image, withTitle: title, withMessage: message, AutoHide: true, onTouchHandler: nil)
    }

   class func showNotificationView(image : UIImage? , withTitle title: String?,withMessage message:String?,AutoHide isAutoHide:Bool!){
    
    JKNotificationView.sharedInstance.showNotificationView(image: image, withTitle: title, withMessage: message, AutoHide: isAutoHide, onTouchHandler: nil)
    }
    class func showNotificationView(image : UIImage? , withTitle title: String?,withMessage message:String?,AutoHide isAutoHide:Bool!,onTouchHandler onTouch:JKNotificationOnComplition? ){
        JKNotificationView.sharedInstance.showNotificationView(image: image, withTitle: title, withMessage: message, AutoHide: isAutoHide, onTouchHandler: onTouch)
    }
    class func hideNotificationView(){
        JKNotificationView.hideNotificationViewOnComplete(onComplete: nil)
    }
   class func hideNotificationViewOnComplete(onComplete : JKNotificationOnComplition?){
     JKNotificationView.sharedInstance.hideNotificationViewOnComplete(onComplete: onComplete)
    }
    
}
        


