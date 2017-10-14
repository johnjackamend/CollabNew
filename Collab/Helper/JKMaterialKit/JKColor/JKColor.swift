//
//  JKColor.swift
// JKMaterialKit
//
//  Created by Jitendra Kumar on 27/12/16.
//  Copyright © 2016 Jitendra. All rights reserved
//

import UIKit

extension UIColor {
    convenience public init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
     convenience public init(hexString colorString: String!, alpha:CGFloat = 1.0) {
        // Convert hex string to an integer
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: colorString)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = NSCharacterSet(charactersIn: "#") as CharacterSet
        // Scan hex value
        scanner.scanHexInt32(&hexInt)
        let hexint = Int(hexInt)
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha
     self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    convenience public init (ColorRGB r:CGFloat ,Grean g: CGFloat ,Blue b: CGFloat,alpha:CGFloat = 1.0){
        self.init(red:r/255.0, green:g/255.0, blue:b/255.0, alpha:alpha)
    }

}
public struct JKColor {
    public static let Red = UIColor(hex: 0xF44336)
    public static let Pink = UIColor(hex: 0xE91E63)
    public static let Purple = UIColor(hex: 0x9C27B0)
    public static let DeepPurple = UIColor(hex: 0x67AB7)
    public static let Indigo = UIColor(hex: 0x3F51B5)
    public static let Blue = UIColor(hex: 0x2196F3)
    public static let LightBlue = UIColor(hex: 0x03A9F4)
    public static let Cyan = UIColor(hex: 0x00BCD4)
    public static let Teal = UIColor(hex: 0x009688)
    public static let Green = UIColor(hex: 0x4CAF50)
    public static let LightGreen = UIColor(hex: 0x8BC34A)
    public static let Lime = UIColor(hex: 0xCDDC39)
    public static let Yellow = UIColor(hex: 0xFFEB3B)
    public static let Amber = UIColor(hex: 0xFFC107)
    public static let Orange = UIColor(hex: 0xFF9800)
    public static let DeepOrange = UIColor(hex: 0xFF5722)
    public static let Brown = UIColor(hex: 0x795548)
    public static let Grey = UIColor(hex: 0x9E9E9E)
    public static let BlueGrey = UIColor(hex: 0x607D8B)
    public static let DarkBlue = UIColor(hexString: "#0279C2")
    public static let extraLightGrey  = UIColor(hexString: "#EBEBF1")
    public static let placeHolderColor = UIColor(ColorRGB: 161.0, Grean: 161.0, Blue: 162.0)
    public static let navigationBarColor = UIColor(ColorRGB: 213.0, Grean: 213.0, Blue: 197.0)
    
   
}
