//
//  ChatListCell.swift
//  Whatsapp
//
//  Created by Rafael Castro on 7/24/15. / Swift Version by Breno Oliveira on 02/18/16.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

import UIKit

class ChatCell:UITableViewCell {
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var messageLabel:UILabel!
    @IBOutlet weak var timeLabel:UILabel!
    @IBOutlet weak var picture:UIImageView!
    @IBOutlet weak var notificationLabel:UILabel!
    @IBOutlet weak var lblFilter: UILabel!
    @IBOutlet weak var ivFilter: UIImageView!
    @IBOutlet weak var lblUnreadCount: UILabel!
    
    override var imageView:UIImageView {
        set {
            
        }
        get {
            return self.picture
        }
    }
    
    var chat:Chat! {
        didSet {
            self.nameLabel.text = chat.contact.name
            self.messageLabel.text = chat.lastMessage.text
            self.updateTimeLabelWithDate(date: chat.lastMessage.date)
            self.updateUnreadMessagesIcon(numberOfUnreadMessages: chat.numberOfUnreadMessages)
        }
    }

    override func awakeFromNib () {
//        self.picture.layer.cornerRadius = self.picture.frame.size.width/2
//        self.picture.layer.masksToBounds = true
////        self.notificationLabel.layer.cornerRadius = self.notificationLabel.frame.size.width/2
////        self.notificationLabel.layer.masksToBounds = true
//        self.nameLabel.text = ""
//     self.messageLabel.text = ""
       // self.timeLabel.text = ""
    }
    
    func updateTimeLabelWithDate(date:NSDate) {
        let df = DateFormatter()
        df.timeStyle = .short
        df.dateStyle = .none
        df.doesRelativeDateFormatting = false
        self.timeLabel.text = df.string(from: date as Date)
    }
    
    func updateUnreadMessagesIcon(numberOfUnreadMessages:Int)
    {
//        self.notificationLabel.isHidden = numberOfUnreadMessages == 0
//        self.notificationLabel.text = String(numberOfUnreadMessages)
    }
}
