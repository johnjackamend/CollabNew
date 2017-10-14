
//
//  SideMenuCell.swift
//  Collab
//
//  Created by Apple01 on 4/15/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit

class SideMenuCell: UITableViewCell {

    @IBOutlet weak var ivIcon: UIImageView!

    @IBOutlet weak var lblMenu: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
