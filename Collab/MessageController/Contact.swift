//
//  Contact.swift
//  Whatsapp
//
//  Created by Magneto on 2/12/16. / Swift Version by Breno Oliveira on 02/18/16.
//  Copyright © 2016 HummingBird. All rights reserved.
//

import UIKit

class Contact {
    var identifier:String = ""
    var name:String = ""
    var imageId:String = ""
    var profileImage:String = ""
    

    func contactFromDictionary(dict:NSDictionary) -> Contact {
        let contact = Contact()
        contact.name = dict["name"] as! String
        contact.identifier = dict["id"] as! String
        contact.imageId = dict["imageId"] as! String
        //contact.profileImage = dict["profile_pic"] as! String
        return contact
    }
    
    func hasImage() -> Bool {
        return self.imageId.characters.count > 0
    }
    
    func save() {
        LocalStorage.sharedInstance.storeContact(contact: self)
    }
}
