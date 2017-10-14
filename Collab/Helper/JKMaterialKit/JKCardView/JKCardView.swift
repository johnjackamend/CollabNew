//
//  JKCardView.swift
//
//  Created by Jitendra Kumar on 27/12/16.
//  Copyright © 2016 Jitendra. All rights reserved
//

import Foundation
import UIKit
import QuartzCore
@IBDesignable
public class JKCardView: UIView {
 
    @IBInspectable public var rippleAniDuration: Float = 0.75
    @IBInspectable public var backgroundAniDuration: Float = 1.0
    @IBInspectable public var rippleAniTimingFunction: JKTimingFunction = .Linear
    @IBInspectable public var backgroundAniTimingFunction: JKTimingFunction = .Linear
    @IBInspectable public var backgroundAniEnabled: Bool = true {
        didSet {
            if !backgroundAniEnabled {
                mkLayer.enableOnlyCircleLayer()
               
                self.setNeedsDisplay()
            }
        }
    }
    
     /// The color of the drop-shadow, defaults to black.
    @IBInspectable public var shadowColor: UIColor = UIColor.black {
        didSet {
            //mkLayer.enableMask(maskEnabled)
               if isShadow == true {
            layer.shadowColor = shadowColor.cgColor
            }
            self.setNeedsDisplay()
        }
    }
    /// Whether to display the shadow, defaults to false.
    @IBInspectable public var isShadow: Bool = false{
        didSet{
            self.setNeedsDisplay()
        }
    }
     /// The opacity of the drop-shadow, defaults to 0.5.
    @IBInspectable public var shadowOpacity: Float = 0.5 {
        didSet {
            if isShadow == true {
                layer.shadowOpacity = shadowOpacity
            }
           
            self.setNeedsDisplay()
        }
    }
     /// The x,y offset of the drop-shadow from being cast straight down.
    @IBInspectable public var shadowOffset: CGSize = CGSize(width:0,height:3) {
        didSet {
               if isShadow == true {
                    layer.shadowOffset = shadowOffset
            }
            self.setNeedsDisplay()
        }
    }
     /// The blur radius of the drop-shadow, defaults to 3.
    @IBInspectable public var shadowRadius : CGFloat = 3.0
        {
        didSet
        {   if isShadow == true {
            layer.shadowRadius = shadowRadius
            }
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 2.5 {
        didSet {
            layer.cornerRadius = cornerRadius
            mkLayer.setMaskLayerCornerRadius(cornerRadius: cornerRadius)
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
             if isShadow == true {
                layer.masksToBounds = false
            }
             else{
                layer.masksToBounds = masksToBounds
            }
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
    
    @IBInspectable public var maskEnabled: Bool = true {
        didSet {
            mkLayer.enableMask(enable: maskEnabled)
            self.setNeedsDisplay()
        }
    }
    @IBInspectable public var rippleLocation: JKRippleLocation = .TapLocation {
        didSet {
            mkLayer.rippleLocation = rippleLocation
            self.setNeedsDisplay()
        }
    }
    @IBInspectable public var ripplePercent: Float = 0.9 {
        didSet {
            mkLayer.ripplePercent = ripplePercent
        }
    }
    @IBInspectable public var backgroundLayerCornerRadius: CGFloat = 0.0 {
        didSet {
            mkLayer.setBackgroundLayerCornerRadius(cornerRadius: backgroundLayerCornerRadius)
        }
    }
   
   
    
    // color
    @IBInspectable public var rippleLayerColor: UIColor = UIColor(white: 0.45, alpha: 0.5) {
        didSet {
            mkLayer.setCircleLayerColor(color: rippleLayerColor)
        }
    }
    @IBInspectable public var backgroundLayerColor: UIColor = UIColor(white: 0.75, alpha: 0.25) {
        didSet {
            mkLayer.setBackgroundLayerColor(color: backgroundLayerColor)
        }
    }
    override public var bounds: CGRect {
        didSet {
            mkLayer.superLayerDidResize()
        }
    }
    private lazy var mkLayer: JKLayer = JKLayer(superLayer: self.layer)
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        mkLayer.setCircleLayerColor(color: rippleLayerColor)
        mkLayer.setBackgroundLayerColor(color: backgroundLayerColor)
        mkLayer.setMaskLayerCornerRadius(cornerRadius: cornerRadius)
       
    }
    
    public func animateRipple(location: CGPoint? = nil) {
        if let point = location {
            mkLayer.didChangeTapLocation(location: point)
        } else if rippleLocation == .TapLocation {
            rippleLocation = .Center
        }
        
        mkLayer.animateScaleForCircleLayer(fromScale: 0.65, toScale: 1.0, timingFunction: rippleAniTimingFunction, duration: CFTimeInterval(self.rippleAniDuration))
        mkLayer.animateAlphaForBackgroundLayer(timingFunction: backgroundAniTimingFunction, duration: CFTimeInterval(self.backgroundAniDuration))
    }
    
   public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
            super.touchesBegan(touches, with: event)
        if let firstTouch = touches.first as UITouch! {
            let location = firstTouch.location(in: self)
            animateRipple(location: location)
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        if isShadow == true
        {
          
            let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
            layer.masksToBounds = masksToBounds
            layer.shadowColor = shadowColor.cgColor
            layer.shadowOffset = shadowOffset
            layer.shadowOpacity = shadowOpacity
            layer.shadowPath = shadowPath.cgPath
        }
        else{
            // Disable the shadow.
            layer.shadowRadius = 0
            layer.shadowOpacity = 0
        }
        self.setNeedsDisplay()
    }
    
}
//MARK:-JKDashedView-
public class JKDashedView: UIView
{
    var shapeLayer:CAShapeLayer = CAShapeLayer()
  
    @IBInspectable public var rippleAniDuration: Float = 0.75
    @IBInspectable public var backgroundAniDuration: Float = 1.0
    @IBInspectable public var rippleAniTimingFunction: JKTimingFunction = .Linear
    @IBInspectable public var backgroundAniTimingFunction: JKTimingFunction = .Linear
    @IBInspectable public var backgroundAniEnabled: Bool = true {
        didSet {
            if !backgroundAniEnabled {
                mkLayer.enableOnlyCircleLayer()
            }
        }
    }
    @IBInspectable public var dashedLineColor: UIColor = UIColor.black {
        didSet {
            
            
            self.setNeedsDisplay()
        }
    }
    @IBInspectable public var dashedLineWidth: CGFloat = 1.0 {
        didSet {
        
           
            self.setNeedsDisplay()
        }
    }
    /// The color of the drop-shadow, defaults to black.
    @IBInspectable public var shadowColor: UIColor = UIColor.black {
        didSet {
            //mkLayer.enableMask(maskEnabled)
            if isShadow == true {
                layer.shadowColor = shadowColor.cgColor
            }
            self.setNeedsDisplay()
        }
    }
    /// Whether to display the shadow, defaults to false.
    @IBInspectable public var isShadow: Bool = false{
        didSet{
            self.setNeedsDisplay()
        }
    }
    /// The opacity of the drop-shadow, defaults to 0.5.
    @IBInspectable public var shadowOpacity: Float = 0.5 {
        didSet {
            if isShadow == true {
                layer.shadowOpacity = shadowOpacity
            }
            
            self.setNeedsDisplay()
        }
    }
    /// The x,y offset of the drop-shadow from being cast straight down.
    @IBInspectable public var shadowOffset: CGSize = CGSize(width:0,height:3) {
        didSet {
            if isShadow == true {
                layer.shadowOffset = shadowOffset
            }
            self.setNeedsDisplay()
        }
    }
    /// The blur radius of the drop-shadow, defaults to 3.
    @IBInspectable public var shadowRadius : CGFloat = 3.0
        {
        didSet
        {   if isShadow == true {
            layer.shadowRadius = shadowRadius
            }
            self.setNeedsDisplay()
        }
    }

    
    @IBInspectable public var strokeColor: UIColor = JKColor.Blue {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable public var cornerRadius: CGFloat = 2.5 {
        didSet {
            layer.cornerRadius = cornerRadius
            mkLayer.setMaskLayerCornerRadius(cornerRadius: cornerRadius)
        }
    }
    @IBInspectable public var masksToBounds : Bool = false
        {
        didSet
        {
            if isShadow == true {
                layer.masksToBounds = false
            }
            else{
                layer.masksToBounds = masksToBounds
            }
            self.setNeedsDisplay()
        }
        
    }
    @IBInspectable public var clipsToBound : Bool = false
        {
        didSet
        {
            self.clipsToBounds = clipsToBound
        }
    }
    
    @IBInspectable public var maskEnabled: Bool = true {
        didSet {
            mkLayer.enableMask(enable: maskEnabled)
        }
    }
    @IBInspectable public var rippleLocation: JKRippleLocation = .TapLocation {
        didSet {
            mkLayer.rippleLocation = rippleLocation
        }
    }
    @IBInspectable public var ripplePercent: Float = 0.9 {
        didSet {
            mkLayer.ripplePercent = ripplePercent
        }
    }
    @IBInspectable public var backgroundLayerCornerRadius: CGFloat = 0.0 {
        didSet {
            mkLayer.setBackgroundLayerCornerRadius(cornerRadius: backgroundLayerCornerRadius)
        }
    }
    
    
    
    // color
    @IBInspectable public var rippleLayerColor: UIColor = UIColor(white: 0.45, alpha: 0.5) {
        didSet {
            mkLayer.setCircleLayerColor(color: rippleLayerColor)
        }
    }
    @IBInspectable public var backgroundLayerColor: UIColor = UIColor(white: 0.75, alpha: 0.25) {
        didSet {
            mkLayer.setBackgroundLayerColor(color: backgroundLayerColor)
        }
    }
    override public var bounds: CGRect {
        didSet {
            mkLayer.superLayerDidResize()
        }
    }
    private lazy var mkLayer: JKLayer = JKLayer(superLayer: self.layer)
    
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    func setup() {
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = dashedLineWidth
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [6,2,6,2]
        //shapeLayer.lineDashPattern = [4, 4]
        self.layer.addSublayer(shapeLayer)
        mkLayer.setCircleLayerColor(color: rippleLayerColor)
        mkLayer.setBackgroundLayerColor(color: backgroundLayerColor)
        mkLayer.setMaskLayerCornerRadius(cornerRadius: cornerRadius)
        
    }
    public func animateRipple(location: CGPoint? = nil) {
        if let point = location {
            mkLayer.didChangeTapLocation(location: point)
        } else if rippleLocation == .TapLocation {
            rippleLocation = .Center
        }
        
        mkLayer.animateScaleForCircleLayer(fromScale: 0.65, toScale: 1.0, timingFunction: rippleAniTimingFunction, duration: CFTimeInterval(self.rippleAniDuration))
        mkLayer.animateAlphaForBackgroundLayer(timingFunction: backgroundAniTimingFunction, duration: CFTimeInterval(self.backgroundAniDuration))
    }
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        if let firstTouch = touches.first as UITouch! {
            let location = firstTouch.location(in: self)
            animateRipple(location: location)
        }
    }
    
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        if isShadow == true
        {
            let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
            layer.masksToBounds = masksToBounds
            layer.shadowColor = shadowColor.cgColor
            layer.shadowOffset = shadowOffset
            layer.shadowOpacity = shadowOpacity
            layer.shadowPath = shadowPath.cgPath
        }
        
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius:cornerRadius).cgPath
        shapeLayer.frame = self.bounds
    }
    
}

