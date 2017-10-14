//
//  JKLayer.swift
// JKMaterialKit
//
//  Created by Jitendra Kumar on 27/12/16.
//  Copyright © 2016 Jitendra. All rights reserved
//

import UIKit
import QuartzCore

public enum JKTimingFunction {
    case Linear
    case EaseIn
    case EaseOut
    case Custom(Float, Float, Float, Float)

    public var function: CAMediaTimingFunction {
        switch self {
        case .Linear:
            return CAMediaTimingFunction(name: "linear")
        case .EaseIn:
            return CAMediaTimingFunction(name: "easeIn")
        case .EaseOut:
            return CAMediaTimingFunction(name: "easeOut")
        case .Custom(let cpx1, let cpy1, let cpx2, let cpy2):
            return CAMediaTimingFunction(controlPoints: cpx1, cpy1, cpx2, cpy2)
        }
    }
}

public enum JKRippleLocation {
    case Center
    case Left
    case Right
    case TapLocation
}

public class JKLayer {
    private var superLayer: CALayer!
    private let rippleLayer = CALayer()
    private let backgroundLayer = CALayer()
    private let maskLayer = CAShapeLayer()
    
    public var rippleLocation: JKRippleLocation = .TapLocation {
        didSet {
            let origin: CGPoint?
            let sw = superLayer.bounds.width
            let sh = superLayer.bounds.height
            
            switch rippleLocation {
            case .Center:
                origin = CGPoint(x: sw/2, y: sh/2)
            case .Left:
                origin = CGPoint(x: sw*0.25, y: sh/2)
            case .Right:
                origin = CGPoint(x: sw*0.75, y: sh/2)
            default:
                origin = nil
            }
            if let origin = origin {
                setCircleLayerLocationAt(center: origin)
            }
        }
    }

    public var ripplePercent: Float = 0.9 {
        didSet {
            if ripplePercent > 0 {
                let sw = superLayer.bounds.width
                let sh = superLayer.bounds.height
                let circleSize = CGFloat(max(sw, sh)) * CGFloat(ripplePercent)
                let circleCornerRadius = circleSize/2

                rippleLayer.cornerRadius = circleCornerRadius
                setCircleLayerLocationAt(center: CGPoint(x: sw/2, y: sh/2))
            }
        }
    }

    public init(superLayer: CALayer) {
        self.superLayer = superLayer

        let sw = superLayer.bounds.width
        let sh = superLayer.bounds.height

        // background layer
        backgroundLayer.frame = superLayer.bounds
        backgroundLayer.opacity = 0.0
        superLayer.addSublayer(backgroundLayer)

        // ripple layer
        let circleSize = CGFloat(max(sw, sh)) * CGFloat(ripplePercent)
        let rippleCornerRadius = circleSize/2

        rippleLayer.opacity = 0.0
        rippleLayer.cornerRadius = rippleCornerRadius
        setCircleLayerLocationAt(center: CGPoint(x: sw/2, y: sh/2))
        backgroundLayer.addSublayer(rippleLayer)

        // mask layer
        setMaskLayerCornerRadius(cornerRadius: superLayer.cornerRadius)
        backgroundLayer.mask = maskLayer
    }

    public func superLayerDidResize() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundLayer.frame = superLayer.bounds
        setMaskLayerCornerRadius(cornerRadius: superLayer.cornerRadius)
        CATransaction.commit()
        setCircleLayerLocationAt(center: CGPoint(x: superLayer.bounds.width/2, y: superLayer.bounds.height/2))
    }

    public func enableOnlyCircleLayer() {
        backgroundLayer.removeFromSuperlayer()
        superLayer.addSublayer(rippleLayer)
    }

    public func setBackgroundLayerColor(color: UIColor) {
        backgroundLayer.backgroundColor = color.cgColor
    }

    public func setCircleLayerColor(color: UIColor) {
        rippleLayer.backgroundColor = color.cgColor
    }

    public func didChangeTapLocation(location: CGPoint) {
        if rippleLocation == .TapLocation {
            setCircleLayerLocationAt(center: location)
        }
    }

    public func setMaskLayerCornerRadius(cornerRadius: CGFloat) {
        maskLayer.path = UIBezierPath(roundedRect: backgroundLayer.bounds, cornerRadius: cornerRadius).cgPath
    }

    public func enableMask(enable: Bool = true) {
        backgroundLayer.mask = enable ? maskLayer : nil
    }

    public func setBackgroundLayerCornerRadius(cornerRadius: CGFloat) {
        backgroundLayer.cornerRadius = cornerRadius
    }

    private func setCircleLayerLocationAt(center: CGPoint) {
        let bounds = superLayer.bounds
        let width = bounds.width
        let height = bounds.height
        let subSize = CGFloat(max(width, height)) * CGFloat(ripplePercent)
        let subX = center.x - subSize/2
        let subY = center.y - subSize/2

        // disable animation when changing layer frame
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        rippleLayer.cornerRadius = subSize / 2
        rippleLayer.frame = CGRect(x: subX, y: subY, width: subSize, height: subSize)
        CATransaction.commit()
    }

    // MARK - Animation
    public func animateScaleForCircleLayer(fromScale: Float, toScale: Float, timingFunction: JKTimingFunction, duration: CFTimeInterval) {
        let rippleLayerAnim = CABasicAnimation(keyPath: "transform.scale")
        rippleLayerAnim.fromValue = fromScale
        rippleLayerAnim.toValue = toScale

        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 1.0
        opacityAnim.toValue = 0.0

        let groupAnim = CAAnimationGroup()
        groupAnim.duration = duration
        groupAnim.timingFunction = timingFunction.function
        groupAnim.isRemovedOnCompletion = false
        groupAnim.fillMode = kCAFillModeForwards

        groupAnim.animations = [rippleLayerAnim, opacityAnim]

        rippleLayer.add(groupAnim, forKey: nil)
    }

    public func animateAlphaForBackgroundLayer(timingFunction: JKTimingFunction, duration: CFTimeInterval) {
        let backgroundLayerAnim = CABasicAnimation(keyPath: "opacity")
        backgroundLayerAnim.fromValue = 1.0
        backgroundLayerAnim.toValue = 0.0
        backgroundLayerAnim.duration = duration
        backgroundLayerAnim.timingFunction = timingFunction.function
        backgroundLayer.add(backgroundLayerAnim, forKey: nil)
    }

    public func animateSuperLayerShadow(fromRadius: CGFloat, toRadius: CGFloat, fromOpacity: Float, toOpacity: Float, timingFunction: JKTimingFunction, duration: CFTimeInterval) {
        animateShadowForLayer(layer: superLayer, fromRadius: fromRadius, toRadius: toRadius, fromOpacity: fromOpacity, toOpacity: toOpacity, timingFunction: timingFunction, duration: duration)
    }

    public func animateMaskLayerShadow() {

    }

    private func animateShadowForLayer(layer: CALayer, fromRadius: CGFloat, toRadius: CGFloat, fromOpacity: Float, toOpacity: Float, timingFunction: JKTimingFunction, duration: CFTimeInterval) {
        let radiusAnimation = CABasicAnimation(keyPath: "shadowRadius")
        radiusAnimation.fromValue = fromRadius
        radiusAnimation.toValue = toRadius

        let opacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        opacityAnimation.fromValue = fromOpacity
        opacityAnimation.toValue = toOpacity

        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = duration
        groupAnimation.timingFunction = timingFunction.function
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = kCAFillModeForwards
        groupAnimation.animations = [radiusAnimation, opacityAnimation]

        layer.add(groupAnimation, forKey: nil)
    }
    
    public func removeAllAnimations() {
        self.backgroundLayer.removeAllAnimations()
        self.rippleLayer.removeAllAnimations()
    }
    
}
