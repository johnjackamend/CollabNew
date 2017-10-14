//
//  SearchCell.swift
//  Collab
//
//  Created by Apple01 on 4/17/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    @IBOutlet weak var ivSong: UIImageView!
    @IBOutlet weak var lblSongName: UILabel!
    @IBOutlet weak var lblAlbumName: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
