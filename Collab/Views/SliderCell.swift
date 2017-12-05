//
//  SliderCell.swift
//  Collab
//
//  Created by Apple on 28/09/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit

class SliderCell: UITableViewCell {

    @IBOutlet var sliderAge: MARKRangeSlider!
    @IBOutlet var sliderDistance: UISlider!
    @IBOutlet var lblAge: UILabel!
    @IBOutlet var lblCollab: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
