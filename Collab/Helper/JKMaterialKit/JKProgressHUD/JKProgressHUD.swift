//
//  JKLoader.swift
// JKMaterialKit
//
//  Created by Jitendra Kumar on 27/12/16.
//  Copyright © 2016 Jitendra. All rights reserved
//

import UIKit
import QuartzCore
import CoreGraphics
import Foundation
let mpi :CGFloat = CGFloat(M_PI)
enum JKProgressHUDMode:Int {
    /** Progress is shown using an JKIndicatorView. This is the default. */
    case Indeterminate = 0
    /** Progress is shown using a round, pie-chart like, progress view. */
    case Determinate
    /** Progress is shown using a horizontal progress bar */
    case HorizontalBar
    /** Progress is shown using a ring-shaped progress view. */
    case AnnularDeterminate
    case DefaultHorizontalBar
    case GIF
    
}

enum JKProgressHUDBackgroundStyle:Int {
    /// Solid color background
    case  StyleSolidColor = 0
    case  StyleClear
    case  darkBlur
    
}
enum JKProgressHUDPosition:Int {
    
    case  center = 40
    case  top
    case  bottom
    
}

//MARK:-JKProgressHUD-
public class JKProgressHUD:UIView{
    
     public var lineColor: UIColor = JKColor.Blue{
        didSet{
            
            setNeedsDisplay()
        }
    }
     public var lineWidth: CGFloat = 3{
        didSet{
            setNeedsDisplay()
        }
    }
     public var showBarline: Bool = false{
        didSet{
            
            setNeedsDisplay()
        }
    }
     public var textColor: UIColor = UIColor.darkGray{
        didSet{
            setNeedsDisplay()
        }
    }
     public var progressColor: UIColor = JKColor.Blue{
        didSet{
            setNeedsDisplay()
        }
    }
     public var progress: Float = 0.0{
        didSet{
            if progress >= 1.0 {
                progress = 1
            }
            else if progress <= 0{
                
                progress = 0
                
            }
            self.setprogress(value: progress, animated: true)
            self.setNeedsDisplay()
            
        }
    }
     public var messageString: String = ""{
        didSet{
            
            self.setNeedsDisplay()
        }
    }
     public var GIFname: String = ""{
        didSet{
            
            self.setNeedsDisplay()
        }
    }
    var hudPosition : JKProgressHUDPosition! = .center
    var backgroundStyle:JKProgressHUDBackgroundStyle! = .StyleSolidColor
    var hudMode :JKProgressHUDMode! = .Indeterminate
    
    fileprivate  var hudContentView:JKCardView!
    fileprivate  var barIndicator : JKBarProgressView!
    fileprivate var systemBarIndicator : JKSystemProgressBar!
    fileprivate var circularProgress:JKCircularProgressView!
    fileprivate var indicatorView :JKIndicatorView!
    fileprivate var gifIndicatorView : UIImageView!
    fileprivate var label : UILabel!
    override init(frame: CGRect) {
     super.init(frame: CGRect.init(x: 0, y: frame.origin.y - 64, width: frame.size.width, height: frame.size.height))
        self.backgroundColor = UIColor.clear
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK:-showProgressHud inWindow-
    class func showGifProgressHud(inView view:UIView!,GIFfileName filename:String,backgroundStyle style:JKProgressHUDBackgroundStyle = .StyleSolidColor,hudPosition position:JKProgressHUDPosition = .center)->JKProgressHUD!{
        let hud : JKProgressHUD = JKProgressHUD()
        hud.hudMode = .GIF
        hud.GIFname = filename
        hud.hudPosition = position
        hud.backgroundStyle = style
        hud.messageString = ""
        view.addSubview(hud)
        hud.updatehudContraints(item: hud, toItem: view)
        hud.showHud(animated: true)
        return hud
    }
   
    //MARK:-showProgressHud inView-
    class func showProgressHud(inView view:UIView!,progressMode mode:JKProgressHUDMode = .Indeterminate,backgroundStyle style:JKProgressHUDBackgroundStyle = .StyleSolidColor,hudPosition position:JKProgressHUDPosition = .center,titleLabel title:String = "")->JKProgressHUD!{
        let hud : JKProgressHUD = JKProgressHUD()
        hud.hudMode = mode
        hud.hudPosition = position
        hud.backgroundStyle = style
        hud.messageString =   title.isEmpty ? "" : title
        view.addSubview(hud)
        hud.updatehudContraints(item: hud, toItem: view)
        hud.showHud(animated: true)
        return hud
    }
  
   
    
    //MARK:-updatehudContraints-
    fileprivate  func updatehudContraints(item:UIView, toItem:UIView){
        item.translatesAutoresizingMaskIntoConstraints = false
        let top : NSLayoutConstraint = NSLayoutConstraint(item: item, attribute: .top, relatedBy: .equal, toItem: toItem, attribute: .top, multiplier: 1, constant: 64)
        let leading : NSLayoutConstraint = NSLayoutConstraint(item: item, attribute: .leading, relatedBy: .equal, toItem: toItem, attribute: .leading, multiplier: 1, constant: 0)
        let botttom : NSLayoutConstraint = NSLayoutConstraint(item: item, attribute: .bottom, relatedBy: .equal, toItem: toItem, attribute: .bottom, multiplier: 1, constant: 0)
        let trailing : NSLayoutConstraint = NSLayoutConstraint(item: item, attribute: .trailing, relatedBy: .equal, toItem: toItem, attribute: .trailing, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([top,leading,botttom,trailing])
        self.setNeedsDisplay()
    }
    //MARK:-initilaize-
    fileprivate func initilaize(){
        if self.backgroundStyle == .StyleClear {
            self.backgroundColor = UIColor.clear
        }
        else{
          
            self.backgroundColor = UIColor.clear
        }
        self.alpha = 0.0
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.alpha = 1.0
            self.addContentView()
        })
    }
    fileprivate func addBlurView(style:UIBlurEffectStyle = .light){
        let blurEffect = UIBlurEffect(style:style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        self.addSubview(blurEffectView)
        self.updatehudContraints(item: blurEffectView, toItem: self)
    }
    //MARK:-addContentView-
    fileprivate func addContentView(){
        hudContentView = JKCardView()
        self.addSubview(hudContentView)
        
        hudContentView.translatesAutoresizingMaskIntoConstraints = false
        var topConstraint : NSLayoutConstraint
        var bottomConstraint : NSLayoutConstraint
        var widthRelation: NSLayoutRelation =  .equal
        if messageString.isEmpty == false {
            if hudMode == .HorizontalBar || hudMode == .DefaultHorizontalBar{
                widthRelation = .equal
            }
            else{
                widthRelation = .lessThanOrEqual
            }
            
        }
        
        let width : NSLayoutConstraint = NSLayoutConstraint(item: hudContentView, attribute: .width, relatedBy: widthRelation, toItem: nil, attribute: .width, multiplier: 1, constant: 200)
        let height : NSLayoutConstraint = NSLayoutConstraint(item: hudContentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
        
        
        
        if hudMode == .HorizontalBar || hudMode == .DefaultHorizontalBar
        {
            
            if messageString.isEmpty == false {
                
                height.constant = 55
                
            }
            else{
                
                height.constant = 45
            }
            hudContentView.cornerRadius = 5
            
        }
        else if hudMode == .Determinate || hudMode == .AnnularDeterminate
        {
            if messageString.isEmpty == false {
                height.constant = 50
                hudContentView.cornerRadius = 5
                
            }
            else{
                width.constant = 45
                height.constant = 45
                
                hudContentView.cornerRadius = max(width.constant, height.constant)/2
            }
            
        }
        else if hudMode == .GIF
        {
            
            height.constant = 45
            width.constant = 45
             hudContentView.cornerRadius = 5
            
            
        }
        else{
            if messageString.isEmpty == false {
                height.constant = 50
                hudContentView.cornerRadius = 5
            }
            else{
                width.constant = 45
                height.constant = 45
                hudContentView.cornerRadius = max(width.constant, height.constant)/2
            }
            
            
        }
  
        if hudPosition == .top
        {
            
            let xConstraint : NSLayoutConstraint = NSLayoutConstraint(item: hudContentView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
            topConstraint = NSLayoutConstraint(item: hudContentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 80)
            NSLayoutConstraint.activate([width,height,xConstraint,topConstraint])
            
        }
        else if hudPosition == .bottom
        {
            
            let xConstraint : NSLayoutConstraint = NSLayoutConstraint(item: hudContentView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
            bottomConstraint = NSLayoutConstraint(item: hudContentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -40)
            NSLayoutConstraint.activate([width,height,xConstraint,bottomConstraint])
        }
        else
        {
            let xConstraint : NSLayoutConstraint = NSLayoutConstraint(item: hudContentView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
            let yConstraint : NSLayoutConstraint = NSLayoutConstraint(item: hudContentView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: -32)
            NSLayoutConstraint.activate([width,height,xConstraint,yConstraint])
            
        }
        hudContentView.shadowOffset = CGSize(width: 0, height: 0)
        hudContentView.shadowRadius = 7
        hudContentView.maskEnabled = true
        hudContentView.isShadow = true
        hudContentView.masksToBounds = false
        hudContentView.clipsToBound = true
        hudContentView.shadowColor = UIColor.black
        hudContentView.backgroundColor = UIColor.white
        hudContentView.setNeedsDisplay()
        addHudView()
    }
    //MARK:-addHudView-
    fileprivate func addHudView(){
        
        if hudMode == .HorizontalBar
        {
            barIndicator  = JKBarProgressView()
            if showBarline {
                
                barIndicator.lineColor = lineColor
                barIndicator.lineWidth =  lineWidth
            }
            else{
                barIndicator.lineColor = UIColor.clear
                barIndicator.lineWidth =  0
            }
            
            barIndicator.progressColor = progressColor
            barIndicator.trackTintColor = JKColor.extraLightGrey
            barIndicator.progress = 0
            hudContentView.addSubview(barIndicator!)
            barIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            let leading : NSLayoutConstraint = NSLayoutConstraint(item: barIndicator, attribute: .leading, relatedBy: .equal, toItem: hudContentView, attribute: .leading, multiplier: 1, constant: 10)
            let trailing : NSLayoutConstraint = NSLayoutConstraint(item: barIndicator, attribute: .trailing, relatedBy: .equal, toItem: hudContentView, attribute: .trailing, multiplier: 1, constant: -10)
            
            let height : NSLayoutConstraint = NSLayoutConstraint(item: barIndicator!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 15)
            if messageString.isEmpty == false {
                let top : NSLayoutConstraint = NSLayoutConstraint(item: barIndicator, attribute: .top, relatedBy: .equal, toItem: hudContentView, attribute: .top, multiplier: 1, constant: 10)
                NSLayoutConstraint.activate([top,height,leading,trailing])
            }
            else{
                
                let yConstraint : NSLayoutConstraint = NSLayoutConstraint(item: barIndicator, attribute: .centerY, relatedBy: .equal, toItem: hudContentView, attribute: .centerY, multiplier: 1, constant: 0)
                NSLayoutConstraint.activate([yConstraint,height,leading,trailing])
            }
            
            barIndicator.setNeedsDisplay()
            
        }
        if hudMode == .DefaultHorizontalBar
        {
            systemBarIndicator  = JKSystemProgressBar()
            systemBarIndicator.progressViewStyle = .bar
            systemBarIndicator.progressTintColor = progressColor
            systemBarIndicator.trackTintColor =  JKColor.extraLightGrey
            systemBarIndicator.progress = 0
            systemBarIndicator.cornerRadius = 5
            systemBarIndicator.clipsToBound = true
            systemBarIndicator.masksToBounds = true
            if showBarline {
                systemBarIndicator.borderWidth =  lineWidth
                systemBarIndicator.borderColor = lineColor
            }
            
            
            hudContentView.addSubview(systemBarIndicator!)
            systemBarIndicator.translatesAutoresizingMaskIntoConstraints = false
            let leading : NSLayoutConstraint = NSLayoutConstraint(item: systemBarIndicator, attribute: .leading, relatedBy: .equal, toItem: hudContentView, attribute: .leading, multiplier: 1, constant: 10)
            let trailing : NSLayoutConstraint = NSLayoutConstraint(item: systemBarIndicator, attribute: .trailing, relatedBy: .equal, toItem: hudContentView, attribute: .trailing, multiplier: 1, constant: -10)
            
            let height : NSLayoutConstraint = NSLayoutConstraint(item: systemBarIndicator!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 8)
            if messageString.isEmpty == false {
                let top : NSLayoutConstraint = NSLayoutConstraint(item: systemBarIndicator, attribute: .top, relatedBy: .equal, toItem: hudContentView, attribute: .top, multiplier: 1, constant: 10)
                NSLayoutConstraint.activate([top,height,leading,trailing])
            }
            else{
                
                let yConstraint : NSLayoutConstraint = NSLayoutConstraint(item: systemBarIndicator, attribute: .centerY, relatedBy: .equal, toItem: hudContentView, attribute: .centerY, multiplier: 1, constant: 0)
                NSLayoutConstraint.activate([yConstraint,height,leading,trailing])
            }
            
            systemBarIndicator.setNeedsDisplay()
            
        }
        else if hudMode == .Determinate || hudMode == .AnnularDeterminate
        {
            circularProgress = JKCircularProgressView()
            if hudMode == .AnnularDeterminate
            {
                circularProgress.annular = true
            }
            circularProgress.backgroundColor = UIColor.clear
            circularProgress.progressTintColor = progressColor
            circularProgress.trackTintColor  =  JKColor.extraLightGrey
            circularProgress.progress = progress
            circularProgress.lineWidth =  lineWidth
            hudContentView.addSubview(circularProgress)
            circularProgress.translatesAutoresizingMaskIntoConstraints = false
            let width : NSLayoutConstraint = NSLayoutConstraint(item: circularProgress, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 0)
            let height : NSLayoutConstraint = NSLayoutConstraint(item: circularProgress, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
            
            
            if messageString.isEmpty == false {
                width.constant = 35
                height.constant = 35
                
                var leading : NSLayoutConstraint
                leading = NSLayoutConstraint(item: circularProgress, attribute: .leading, relatedBy: .equal, toItem: hudContentView, attribute: .leading, multiplier: 1, constant: 5)
                let yConstraint : NSLayoutConstraint = NSLayoutConstraint(item: circularProgress, attribute: .centerY, relatedBy: .equal, toItem: hudContentView, attribute: .centerY, multiplier: 1, constant: 0)
                NSLayoutConstraint.activate([width,height,yConstraint,leading])
                
            }
            else{
                width.constant = 40
                height.constant = 40
                let xConstraint : NSLayoutConstraint = NSLayoutConstraint(item: circularProgress, attribute: .centerX, relatedBy: .equal, toItem: hudContentView, attribute: .centerX, multiplier: 1, constant: 0)
                let yConstraint : NSLayoutConstraint = NSLayoutConstraint(item: circularProgress, attribute: .centerY, relatedBy: .equal, toItem: hudContentView, attribute: .centerY, multiplier: 1, constant: 0)
                NSLayoutConstraint.activate([width,height,xConstraint,yConstraint])
            }
            
            circularProgress.setNeedsDisplay()
        }
        else if hudMode == .GIF
        {
          
            messageString  = ""
            gifIndicatorView = UIImageView()
            gifIndicatorView.contentMode = .scaleAspectFit
            gifIndicatorView.clipsToBounds = true
            hudContentView.addSubview(gifIndicatorView!)
            gifIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            let width : NSLayoutConstraint = NSLayoutConstraint(item: gifIndicatorView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 40)
            let height : NSLayoutConstraint = NSLayoutConstraint(item: gifIndicatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 40)
            let xConstraint = NSLayoutConstraint(item: gifIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: hudContentView, attribute: .centerX, multiplier: 1, constant: 0)
           let yConstraint = NSLayoutConstraint(item: gifIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: hudContentView, attribute: .centerY, multiplier: 1, constant: 0)
           
            NSLayoutConstraint.activate([width,height,xConstraint,yConstraint])
            
        }
        else
        {
            //Indeterminate
            indicatorView  = JKIndicatorView()
            indicatorView.lineColor = lineColor
            indicatorView.lineWidth = (lineWidth > 3) ? lineWidth : 3
            hudContentView.addSubview(indicatorView!)
            var width : NSLayoutConstraint
            var height : NSLayoutConstraint
            var xConstraint : NSLayoutConstraint
            var yConstraint : NSLayoutConstraint
            //Indeterminate
            indicatorView.translatesAutoresizingMaskIntoConstraints = false
            width = NSLayoutConstraint(item: indicatorView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 0)
            height = NSLayoutConstraint(item: indicatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
            
            if messageString.isEmpty == false {
                
                
                width.constant = 32
                height.constant = 32
              
                let leading : NSLayoutConstraint
                leading = NSLayoutConstraint(item: indicatorView, attribute: .leading, relatedBy: .equal, toItem: hudContentView, attribute: .leading, multiplier: 1, constant: 5)
                  yConstraint = NSLayoutConstraint(item: indicatorView, attribute: .centerY, relatedBy: .equal, toItem: hudContentView, attribute: .centerY, multiplier: 1, constant: 0)
                NSLayoutConstraint.activate([width,height,yConstraint,leading])
                
            }
            else{
                width.constant = 35
                height.constant = 35
                xConstraint = NSLayoutConstraint(item: indicatorView, attribute: .centerX, relatedBy: .equal, toItem: hudContentView, attribute: .centerX, multiplier: 1, constant: 0)
                yConstraint = NSLayoutConstraint(item: indicatorView, attribute: .centerY, relatedBy: .equal, toItem: hudContentView, attribute: .centerY, multiplier: 1, constant: 0)
                NSLayoutConstraint.activate([width,height,xConstraint,yConstraint])
            }
            indicatorView.setNeedsDisplay()
        }
        
        if messageString.isEmpty == false && hudMode != .GIF{
            addLabel()
        }
    }
    
    fileprivate func addLabel()
    {
        label = UILabel()
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        label.textColor = textColor
        label.text = messageString
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        hudContentView.addSubview(label!)
        label.translatesAutoresizingMaskIntoConstraints = false
        if hudMode == .HorizontalBar || hudMode == .DefaultHorizontalBar
        {
            let leading : NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: hudContentView, attribute: .leading, multiplier: 1, constant: 10)
            let trailing : NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: hudContentView, attribute: .trailing, multiplier: 1, constant: -10)
            let height : NSLayoutConstraint = NSLayoutConstraint(item: label!, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1, constant: 30)
            
            var top : NSLayoutConstraint
            
            if hudMode == .HorizontalBar {
                top  = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: barIndicator, attribute: .bottom, multiplier: 1, constant: 0)
            }
            else  {
                top  = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: systemBarIndicator, attribute: .bottom, multiplier: 1, constant: 0)
            }
            
            
            let bottom : NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: hudContentView, attribute: .bottom, multiplier: 1, constant: 0)
            NSLayoutConstraint.activate([top,height,leading,trailing,bottom])
            
        }
        else if hudMode == .Determinate || hudMode == .AnnularDeterminate
        {
            let leading : NSLayoutConstraint = NSLayoutConstraint(item: label, attribute:.left, relatedBy: .equal, toItem: circularProgress, attribute: .right, multiplier: 1, constant: 10)
            let trailing : NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: hudContentView, attribute: .trailing, multiplier: 1, constant: -10)
            let height : NSLayoutConstraint = NSLayoutConstraint(item: label!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 30)
            
             let yConstraint : NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: hudContentView, attribute: .centerY, multiplier: 1, constant: 0)
           
            NSLayoutConstraint.activate([yConstraint,height,leading,trailing])
        }
        else
        {
            let leading : NSLayoutConstraint = NSLayoutConstraint(item: label, attribute:.left, relatedBy: .equal, toItem: indicatorView, attribute: .right, multiplier: 1, constant: 10)
            let trailing : NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: hudContentView, attribute: .trailing, multiplier: 1, constant: -10)
            let height : NSLayoutConstraint = NSLayoutConstraint(item: label!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 30)
             let yConstraint : NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: hudContentView, attribute: .centerY, multiplier: 1, constant: 0)
            NSLayoutConstraint.activate([yConstraint,height,leading,trailing])
        }
    }
    //MARK:-hideHudafterDelay-
    public func hideHud(animated animate:Bool, afterDelay delay:Int,completion:@escaping (_ complete: Bool) -> Void){
        DispatchQueue.main.after(TimeInterval(delay)) {
            self.hideHud(animated: animate, completion: completion)
        }
    }
    public  func hideHud(animated animate:Bool, afterDelay delay:Int){
        let completion = { (complete: Bool) -> Void in}
        self.hideHud(animated: true, afterDelay: delay, completion: completion)
    }
    //MARK:-hideHud-
    public  func hideHud(animated animate:Bool,completion:@escaping(_ complete: Bool) -> Void){
        let completion = { (complete: Bool) -> Void in
            if complete {
                let mode : JKProgressHUDMode = self.hudMode
                if mode == .HorizontalBar
                {
                    self.barIndicator?.removeFromSuperview()
                }
                else if mode == .DefaultHorizontalBar{
                    self.systemBarIndicator.removeFromSuperview()
                }
                else if mode == .Determinate
                {
                    self.circularProgress?.removeFromSuperview()
                }
               else if mode == .Indeterminate
                {
                    //Indeterminate
                    self.indicatorView?.stopAnimation()
                    self.indicatorView?.removeFromSuperview()
                }
                else if mode == .GIF {
                    if (self.gifIndicatorView != nil) {
                         self.gifIndicatorView.removeFromSuperview()
                    }
                   
                }
                if (self.label != nil)
                {
                    self.label.removeFromSuperview()
                }
                self.removeFromSuperview()
                completion(complete)
            }
        }
        self.alpha = 1.0
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
        }, completion: completion)
        
    }
    public func hideHud(animated animate:Bool){
        
        let completion = { (complete: Bool) -> Void in}
        self.hideHud(animated: true, completion: completion)
    }
    //MARK:-showHud-
    fileprivate func showHud(animated animate:Bool){
        DispatchQueue.main.async {
            self.initilaize()
            let mode : JKProgressHUDMode = self.hudMode
            if mode == .Indeterminate
            {
                //Indeterminate
                self.indicatorView?.startAnimation()
            }
            else if mode == .GIF{
                if self.GIFname.isEmpty == false
                {
                    //let gifImage = UIImage.gif(name: self.GIFname)
                    
                   // self.gifIndicatorView.image = gifImage
                }
                
            }
            
        }
        
    }
    //MARK:-setprogress-
    fileprivate func setprogress(value:Float , animated:Bool)
    {
        DispatchQueue.main.async {
            
            if self.hudMode == .HorizontalBar
            {
                if (self.barIndicator != nil){
                    self.barIndicator.progress = value
                    self.barIndicator.setNeedsLayout()
                    if self.messageString.isEmpty == false {
                        if (self.label != nil)
                        {
                            self.label.text = self.messageString
                        }
                        
                        self.setNeedsDisplay()
                        
                    }
                    
                    
                }
                
            }
            else if self.hudMode == .DefaultHorizontalBar{
                if (self.systemBarIndicator != nil){
                    self.systemBarIndicator.progress = value
                    self.systemBarIndicator.setNeedsLayout()
                    if self.messageString.isEmpty == false {
                        if (self.label != nil)
                        {
                            self.label.text = self.messageString
                        }
                        
                        self.setNeedsDisplay()
                        
                    }
                    
                    
                }
                
            }
            else if self.hudMode == .Determinate || self.hudMode == .AnnularDeterminate
            {
                if (self.circularProgress != nil){
                    self.circularProgress.progress = value
                    self.circularProgress.setNeedsLayout()
                    if self.messageString.isEmpty == false {
                        if (self.label != nil)
                        {
                            self.label.text = self.messageString
                        }
                        self.setNeedsDisplay()
                        
                    }
                }
                
            }
        }
        
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
    }
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if backgroundStyle == .darkBlur {
            let context : CGContext = UIGraphicsGetCurrentContext()!
            UIGraphicsPushContext(context)
            //Gradient colours
            let gradLocationsNum : size_t = 2
            let gradLocations:[CGFloat] = [0.0, 1.0]
            let gradColors:[CGFloat] = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.45]
            let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient : CGGradient = CGGradient(colorSpace: colorSpace, colorComponents: gradColors, locations: gradLocations, count: gradLocationsNum)!
            //Gradient center
            let gradCenter:CGPoint = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
            //Gradient radius
            let gradRadius:CGFloat = min(self.bounds.size.width , self.bounds.size.height)
            //Gradient draw
            context.drawRadialGradient(gradient, startCenter: gradCenter, startRadius: 0, endCenter: gradCenter, endRadius: gradRadius, options: .drawsAfterEndLocation)
        }
        self.setNeedsDisplay()
        
    }
    
}

@IBDesignable
public class JKSystemProgressBar:UIProgressView{
    
    @IBInspectable public var cornerRadius: CGFloat = 2.5 {
        didSet {
            layer.cornerRadius = cornerRadius
            self.setNeedsDisplay()
        }
    }
    @IBInspectable public var borderColor: UIColor =  UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
            self.setNeedsDisplay()
            
        }
    }
    @IBInspectable public var borderWidth: CGFloat =  0 {
        didSet {
            layer.borderWidth = borderWidth
            self.setNeedsDisplay()
            
        }
    }
    @IBInspectable public var masksToBounds : Bool = false
        {
        didSet
        {
            layer.masksToBounds = masksToBounds
            self.setNeedsDisplay()
        }
        
    }
    @IBInspectable public var clipsToBound : Bool = false
        {
        didSet
        {
            self.clipsToBounds = clipsToBound
            self.setNeedsDisplay()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y - 64, width: frame.size.width, height: frame.size.height))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

//MARK:-JKBarProgressView-
@IBDesignable
public class JKBarProgressView:UIView{
    @IBInspectable public var progress: Float = 0.0{
        didSet{
            if progress >= 1.0 {
                progress = 1
            }
            else if progress <= 0{
                
                progress = 0
                
            }
            setNeedsDisplay()
        }
    }
    @IBInspectable public var lineColor: UIColor = UIColor.blue{
        didSet{
            
            setNeedsDisplay()
            
        }
        
    }
    @IBInspectable public var lineWidth: CGFloat = 2{
        didSet{
            setNeedsDisplay()
        }
        
    }
    @IBInspectable public var trackTintColor: UIColor = JKColor.extraLightGrey{
        
        didSet{
            setNeedsDisplay()
        }
        
    }
    @IBInspectable public var progressColor: UIColor = JKColor.Blue{
        didSet{
            setNeedsDisplay()
        }
        
    }
    
    
    override init(frame: CGRect) {
      super.init(frame: CGRect.init(x: 0, y: frame.origin.y - 64, width: frame.size.width, height: frame.size.height))
        progress = 0.0
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK:-- Drawing
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context : CGContext = UIGraphicsGetCurrentContext()!
        context.setLineWidth(lineWidth);
        context.setStrokeColor(lineColor.cgColor);
        context.setFillColor(trackTintColor.cgColor)
        
        // Draw background
        var radius : CGFloat = (rect.size.height / 2) - 2
        context.move(to: CGPoint(x: 2, y: rect.size.height/2))
        context.addArc(tangent1End: CGPoint(x: 2, y: 2), tangent2End: CGPoint(x: radius + 2, y: 2), radius: radius)
        context.addLine(to: CGPoint(x: rect.size.width - radius - 2, y: 2))
        context.addArc(tangent1End: CGPoint(x: rect.size.width - 2, y: 2), tangent2End: CGPoint(x: rect.size.width - 2, y: rect.size.height / 2), radius: radius)
        context.addArc(tangent1End: CGPoint(x: rect.size.width - 2, y: rect.size.height - 2), tangent2End: CGPoint(x: rect.size.width - radius - 2, y: rect.size.height - 2), radius: radius)
        context.addLine(to: CGPoint(x: radius + 2, y: rect.size.height - 2))
        context.addArc(tangent1End: CGPoint(x:  2, y: rect.size.height - 2), tangent2End: CGPoint(x:  2, y: rect.size.height / 2), radius: radius)
        
        context.fillPath()
        
        // Draw border
        context.move(to: CGPoint(x: 2, y: rect.size.height/2))
        context.addArc(tangent1End: CGPoint(x: 2, y: 2), tangent2End: CGPoint(x: radius + 2, y: 2), radius: radius)
        context.addLine(to: CGPoint(x: rect.size.width - radius - 2, y: 2))
        context.addArc(tangent1End: CGPoint(x: rect.size.width - 2, y: 2), tangent2End: CGPoint(x: rect.size.width - 2, y: rect.size.height / 2), radius: radius)
        context.addArc(tangent1End: CGPoint(x: rect.size.width - 2, y: rect.size.height - 2), tangent2End: CGPoint(x: rect.size.width - radius - 2, y: rect.size.height - 2), radius: radius)
        context.addLine(to: CGPoint(x: radius + 2, y: rect.size.height - 2))
        context.addArc(tangent1End: CGPoint(x:  2, y: rect.size.height - 2), tangent2End: CGPoint(x:  2, y: rect.size.height / 2), radius: radius)
        
        context.strokePath();
        
        context.setFillColor(progressColor.cgColor);
        radius = radius - 2;
        let amount : CGFloat = CGFloat(self.progress) * rect.size.width;
        
        // Progress in the middle area
        if (amount >= radius + 4 && amount <= (rect.size.width - radius - 4)) {
            
            context.move(to: CGPoint(x: 4, y: rect.size.height/2))
            context.addArc(tangent1End: CGPoint(x: 4, y: 4), tangent2End: CGPoint(x: radius + 4, y: 4), radius: radius)
            context.addLine(to: CGPoint(x: amount, y: 4))
            context.addLine(to: CGPoint(x: amount, y:radius + 4))
            context.move(to: CGPoint(x: 4, y: rect.size.height/2))
            context.addArc(tangent1End: CGPoint(x: 4, y: rect.size.height - 4), tangent2End: CGPoint(x: radius + 4, y: rect.size.height - 4), radius: radius)
            context.addLine(to: CGPoint(x: amount, y:rect.size.height - 4))
            context.addLine(to: CGPoint(x: amount, y:radius + 4))
            
            context.fillPath();
        }
            
            // Progress in the right arc
        else if (amount > radius + 4) {
            let x : CGFloat = amount - (rect.size.width - radius - 4);
            context.move(to: CGPoint(x: 4, y: rect.size.height/2))
            context.addArc(tangent1End: CGPoint(x: 4, y: 4), tangent2End: CGPoint(x: radius + 4, y: 4), radius: radius)
            context.addLine(to: CGPoint(x: rect.size.width - radius - 4, y: 4))
            
            var angle :CGFloat = -acos(x/radius)
            
            if angle.isNaN
            {
                angle = 0
            }
            context.addArc(center: CGPoint(x: rect.size.width - radius - 4, y: rect.size.height/2), radius: radius, startAngle: mpi, endAngle: 0, clockwise: false)
            context.addLine(to: CGPoint(x: amount, y: rect.size.height/2))
            context.move(to: CGPoint(x: 4, y: rect.size.height/2))
            context.addArc(tangent1End: CGPoint(x: 4, y: rect.size.height - 4), tangent2End: CGPoint(x: radius + 4, y: rect.size.height - 4), radius: radius)
            context.addLine(to: CGPoint(x:  rect.size.width - radius - 4, y: rect.size.height - 4))
            
            angle = acos(x/radius)
            //let d = Double.nan
            
            if angle.isNaN
            {
                angle = 0
            }
            
            context.addArc(center: CGPoint(x: rect.size.width - radius - 4, y: rect.size.height/2), radius: radius, startAngle: -mpi, endAngle: 0, clockwise: true)
            context.addLine(to: CGPoint(x: amount, y: rect.size.height/2))
            context.fillPath();
        }
            
            // Progress is in the left arc
        else if (amount < radius + 4 && amount > 0) {
            
            context.move(to: CGPoint(x: 4, y: rect.size.height/2))
            context.addArc(tangent1End: CGPoint(x: 4, y: 4), tangent2End: CGPoint(x: radius+4, y: 4), radius: radius)
            context.addLine(to: CGPoint(x: radius + 4, y: rect.size.height/2))
            context.move(to: CGPoint(x: 4, y: rect.size.height/2))
            context.addArc(tangent1End: CGPoint(x: 4, y: rect.size.height - 4), tangent2End: CGPoint(x: radius+4, y: rect.size.height - 4), radius: radius)
            context.addLine(to: CGPoint(x: radius + 4, y: rect.size.height/2))
            
            context.fillPath();
        }
        self.setNeedsDisplay()
    }
    
}
//MARK:-JKCircularProgressView-
@IBDesignable
public class JKCircularProgressView:UIView{
    
    /**
     * Progress (0.0 to 1.0)
     */
    
    @IBInspectable public var progress: Float = 0.0{
        didSet{
            if progress >= 1.0 {
                progress = 1
            }
            else if progress <= 0{
                
                progress = 0
                
            }
            setNeedsDisplay()
        }
    }
    /**
     * Indicator progress color.
     * Defaults to white [UIColor whiteColor].
     */
    @IBInspectable public var progressTintColor: UIColor = JKColor.DarkBlue{
        didSet{
            self.setNeedsDisplay()
        }
    }
    /**
     * Indicator background (non-progress) color.
     * Defaults to translucent white (alpha 0.1)
     */
    
    @IBInspectable public var trackTintColor: UIColor = JKColor.extraLightGrey{
        didSet{
            self.setNeedsDisplay()
        }
    }
    @IBInspectable public var annular: Bool = false{
        didSet{
            self.setNeedsDisplay()
        }
    }
    @IBInspectable public var lineWidth: CGFloat = 2{
        didSet{
            self.setNeedsDisplay()
        }
        
    }
    override init(frame: CGRect) {
       super.init(frame: CGRect.init(x: 0, y: frame.origin.y - 64, width: frame.size.width, height: frame.size.height))
        self.initialSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialSetup()
    }
    
    func initialSetup(){
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
        
    }
    override public var intrinsicContentSize: CGSize{
        get{
            return CGSize(width: 37.0, height: 37.0)
            
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        let allRect : CGRect = self.bounds
        let circleRect : CGRect = allRect.insetBy(dx: 2.0, dy: 2.0)
        let context : CGContext = UIGraphicsGetCurrentContext()!
        if annular
        {
            let isPreiOS7 = kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0
            // lineWidth = isPreiOS7 ? 5.0 : 2.0
            let processBackgroundPath : UIBezierPath = UIBezierPath()
            processBackgroundPath.lineWidth = lineWidth
            processBackgroundPath.lineCapStyle = .butt
            let center : CGPoint = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
            let radius : CGFloat =  (self.bounds.size.width - lineWidth)/2
            let startAngle : CGFloat = -(mpi / 2); // 90 degrees
            var endAngle : CGFloat = (2 * mpi) + startAngle
            processBackgroundPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            trackTintColor.set()
            processBackgroundPath.stroke()
            // Draw progress
            let processPath : UIBezierPath = UIBezierPath()
            processPath.lineCapStyle = isPreiOS7 ? .round : .square
            processPath.lineWidth = lineWidth
            endAngle = (CGFloat(self.progress * 2) * mpi) + startAngle
            processPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            progressTintColor.set()
            processPath.stroke()
            
        }
        else{
            // Draw background
            progressTintColor.setStroke()
            trackTintColor.setFill()
            context.setLineWidth(2.0)
            context.fillEllipse(in: circleRect)
            
            // Draw progress
            let center : CGPoint = CGPoint(x: allRect.size.width/2, y: allRect.size.height/2)
            let radius : CGFloat =  (allRect.size.width - 4)/2
            let startAngle : CGFloat = -(mpi / 2); // 90 degrees
            let endAngle : CGFloat = (CGFloat(self.progress * 2) * mpi) + startAngle
            progressTintColor.setFill()
            context.move(to: CGPoint(x: center.x, y: center.y))
            context.addArc(center: CGPoint(x: center.x, y: center.y), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            context.closePath()
            context.fillPath()
        }
        self.setNeedsDisplay()
    }
}

//MARK:-JKIndicatorView-
@IBDesignable
public class JKIndicatorView: UIView {
    
    fileprivate var strokeLineAnimation: CAAnimationGroup!
    fileprivate var rotationAnimation: CAAnimation!
    fileprivate var strokeColorAnimation: CAAnimation!
    
    /**
     * Array of UIColor
     */
    @IBInspectable public var colorArray:[UIColor] = [UIColor.blue]{
        didSet {
            if colorArray.count < 0  {
                colorArray = [UIColor.blue]
            }
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable public var roundTime = 1.5{
        didSet {
            if roundTime < 1.5 {
                roundTime = 1.5
            }
            self.setNeedsDisplay()
        }
    }
    fileprivate var animating: Bool = false
    /**
     * lineWidth of the stroke
     */
    @IBInspectable public var lineWidth:CGFloat = 3.0 {
        didSet {
            circleLayer.lineWidth = lineWidth
            self.setNeedsDisplay()
        }
        
    }
    @IBInspectable public var lineColor:UIColor = UIColor.blue {
        didSet {
            colorArray = [lineColor]
            self.updateAnimations()
        }
    }
    
 
    override init(frame: CGRect) {
       super.init(frame:frame)
        
        self.initialSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialSetup()
        
        
    }
    lazy public var circleLayer:CAShapeLayer! = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.lineWidth = self.lineWidth
        layer.lineCap = kCALineCapRound
        return layer
    }()
    
    
    // MARK: - Initial Setup
    
    fileprivate func initialSetup() {
        
        self.layer.addSublayer(self.circleLayer)
        self.backgroundColor = UIColor.clear
        
        if self.colorArray.count == 0
        {
            self.colorArray = [lineColor]
        }
        
        self.updateAnimations()
    }
    // MARK: - Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        
        let center : CGPoint = CGPoint(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
        let radius :CGFloat = min(self.bounds.size.width, self.bounds.size.height)/2.0 - self.circleLayer.lineWidth / 2.0
        let startAngle : CGFloat = 0
        let endAngle : CGFloat = 2*CGFloat(M_PI)
        let path : UIBezierPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        circleLayer.path = path.cgPath
        circleLayer.frame =  self.bounds
        
    }
    // MARK: -
    
    
    fileprivate func updateAnimations() {
        // Stroke Head
        let headAnimation = CABasicAnimation(keyPath: "strokeStart")
        headAnimation.beginTime = roundTime / 3.0
        headAnimation.fromValue = 0
        headAnimation.toValue = 1
        headAnimation.duration = 2 * roundTime / 3.0
        headAnimation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        // Stroke Tail
        let tailAnimation = CABasicAnimation(keyPath: "strokeEnd")
        tailAnimation.fromValue = 0
        tailAnimation.toValue = 1
        tailAnimation.duration = 2 * roundTime / 3.0
        tailAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)        // Stroke Line Group
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = roundTime
        animationGroup.repeatCount = .infinity
        animationGroup.animations = [headAnimation, tailAnimation]
        self.strokeLineAnimation = animationGroup
        // Rotation
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = (2 * M_PI)
        rotationAnimation.duration = roundTime
        rotationAnimation.repeatCount = .infinity
        self.rotationAnimation = rotationAnimation
        let strokeColorAnimation = CAKeyframeAnimation(keyPath: "strokeColor")
        strokeColorAnimation.values = self.prepareColorValues()
        strokeColorAnimation.keyTimes = self.prepareKeyTimes()
        strokeColorAnimation.calculationMode = kCAAnimationDiscrete
        strokeColorAnimation.duration = Double(Double(self.colorArray.count) * roundTime)
        strokeColorAnimation.repeatCount = .infinity
        self.strokeColorAnimation = strokeColorAnimation
        self.setNeedsDisplay()
    }
    // MARK: - Animation Data Preparation
    
    fileprivate func prepareColorValues() -> [Any] {
        var cgColorArray = [Any]()
        for color: UIColor in self.colorArray {
            cgColorArray.append(color.cgColor)
            
        }
        return cgColorArray
    }
    
    fileprivate func prepareKeyTimes() -> [NSNumber] {
        var keyTimesArray = [NSNumber]()
        for i in 0..<self.colorArray.count + 1
        {
            keyTimesArray.append(NSNumber(value:  (Float(i)  *  1.0) / Float(self.colorArray.count)))
        }
        return keyTimesArray
    }
    // MARK: -startAnimation
    
    public func startAnimation()
    {
        self.animating = true
        self.circleLayer.add(self.strokeLineAnimation, forKey: "strokeLineAnimation")
        self.circleLayer.add(self.rotationAnimation, forKey: "rotationAnimation")
        self.circleLayer.add(self.strokeColorAnimation, forKey: "strokeColorAnimation")
    }
    // MARK: -stopAnimation
    public func stopAnimation() {
        self.animating = false
        self.circleLayer.removeAnimation( forKey: "strokeLineAnimation")
        self.circleLayer.removeAnimation( forKey: "rotationAnimation")
        self.circleLayer.removeAnimation( forKey: "strokeColorAnimation")
    }
    
    public  func stopAnimation(after timeInterval: TimeInterval)
    {
        DispatchQueue.main.after(timeInterval) {
            self.stopAnimation()
        }
       // self.perform(#selector(JKIndicatorView.stopAnimation as (JKIndicatorView) -> () -> ()), with: nil, afterDelay: timeInterval)
        
    }
    
    fileprivate func isAnimating() -> Bool {
        return animating
    }}


