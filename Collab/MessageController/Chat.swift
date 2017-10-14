//
//  Chat.swift
//  Whatsapp
//
//  Created by Rafael Castro on 7/24/15. / Swift Version by Breno Oliveira on 02/18/16.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

import UIKit
import Foundation

class Chat: NSObject {
    var contact:Contact!
    var numberOfUnreadMessages:Int = 0
    var chatID = NSString()
    var friendID = NSString()
    var friendName = NSString()
    var friendImage = NSString()
    var timeFirStamp : Int = 0
    var favourite : Int = 0
    var lastMessage:Message! {
        willSet (val) {
            if self.lastMessage != nil {
                if self.lastMessage.date.earlierDate(val.date as Date) != self.lastMessage.date as Date {
                    self.lastMessage = val
                }
            }
        }
    }

    var identifier:String {
        get {
            return self.chatID as String
        }
    }

    func save() {
        LocalStorage.sharedInstance.storeChat(chat: self)
    }
}
