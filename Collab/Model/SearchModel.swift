//
//  SearchModel.swift
//  Collab
//
//  Created by Apple01 on 4/17/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit

class SearchModel: NSObject {
    public var songName: String?
    public var songUrl: String?
    public var songAlbumName: String?
    public var songImageUrl: String?


    convenience init(_ dictionary: Dictionary<String, AnyObject>) {
        self.init()
        songName = dictionary["title"] as? String
        songUrl = dictionary["stream_url"] as? String
        songImageUrl = dictionary["artwork_url"] as? String
    }

}
