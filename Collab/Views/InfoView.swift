//
//  InfoView.swift
//  Collab
//
//  Created by SFS04 on 5/2/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit

class InfoView: UIView {
    @IBOutlet var btnReject: UIButton!
    @IBOutlet var btnPlayPause: UIButton!
    @IBOutlet var btnAccept: UIButton!
    @IBOutlet var lblUserName: UILabel!

    @IBOutlet var lblCategory: UILabel!
    @IBOutlet var subInfoView: UIView!
   
    @IBOutlet var lblDistance: UILabel!
    @IBOutlet var btnInstaName: UIButton!
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //self.layer.frame = self.bounds
    }
    
    
    
}
