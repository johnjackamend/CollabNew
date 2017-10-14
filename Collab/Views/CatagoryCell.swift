//
//  CatagoryCell.swift
//  Collab
//
//  Created by Apple01 on 4/13/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit

class CatagoryCell: UITableViewCell {

    @IBOutlet weak var btnCat1: UIButton!
    @IBOutlet weak var btnCat2: UIButton!
    @IBOutlet weak var lblCat1: UILabel!
    @IBOutlet weak var lblCat2: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
