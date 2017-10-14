//
//  UILabelExtenstion.swift
//  Collab
//
//  Created by SFS04 on 4/28/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import Foundation
import UIKit

extension UILabel{
    
    func calculateFontSizeAccordingToWidth(labelFrame : CGRect)  {
        
//        
//       // let baseRatio = ScreenSize.SCREEN_WIDTH / ScreenSize.SCREEN_HEIGHT
//        
//        let labelRatio = labelFrame.size.width / labelFrame.size.height
//        
//         let ratioDiffence = baseRatio - labelRatio
//        
//         let fontCalculatedSize = self.font.pointSize * ratioDiffence + self.font.pointSize
//        
//        self.font = UIFont.systemFont(ofSize: fontCalculatedSize)
//
        if DeviceType.IS_IPHONE_5 != true {
            let fontCalculatedSize = labelFrame.size.height * 0.8
            
            self.font = UIFont.systemFont(ofSize: fontCalculatedSize)
        }
     
    }
}
