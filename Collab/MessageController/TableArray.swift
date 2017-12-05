//
//  MessageArray.swift
//  Whatsapp
//
//  Created by Rafael Castro on 6/18/15. / Swift Version by Breno Oliveira on 02/18/16.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

import UIKit

class TableArray {
    
    var mapTitleToMessages:[String:[Message]] = [String:[Message]]()
    var orderedTitles:[String] = [String]()
    var numberOfSections = 0
    var numberOfMessages = 0
    var formatter:DateFormatter!
    
    init() {
        self.formatter = DateFormatter()
        self.formatter.timeStyle = .none
        self.formatter.dateStyle = .short
        self.formatter.doesRelativeDateFormatting = false
    }

    func addObject(message:Message) {
        return self.addMessage(message: message)
    }
    
    func addObjectsFromArray(messages:[Message]) {
        for message in messages {
            self.addMessage(message: message)
        }
    }
    func removeObject(message:Message) {
        self.removeMessage(message: message)
    }
    func removeObjectsInArray(messages:[Message]) {
        for message in messages {
            self.removeMessage(message: message)
        }
    }
    func removeAllObjects() {
        self.mapTitleToMessages.removeAll()
        self.orderedTitles.removeAll()
    }

    func numberOfMessagesInSection(section:Int) -> Int {
        if self.orderedTitles.count == 0 {
            return 0
        }
        let key = self.orderedTitles[section]
        let array = self.mapTitleToMessages[key]
            
        return array!.count
    }
    
    func titleForSection(section:Int) -> String {
        let formatter = self.formatter.copy() as! DateFormatter
        if self.orderedTitles.count != 0 {
            let key = self.orderedTitles[section]
            let date = formatter.date(from: key)
            
            formatter.doesRelativeDateFormatting = true
            return formatter.string(from: date!)
        }
        else{
            return ""
        }
    }
    
    func objectAtIndexPath(indexPath:NSIndexPath) -> Message {
        
        let key = self.orderedTitles[indexPath.section]
        let array = self.mapTitleToMessages[key]
        
        return array![indexPath.row]
    }
    
    func lastObject() -> Message {
        let indexPath = self.indexPathForLastMessage()
        return self.objectAtIndexPath(indexPath: indexPath)
    }
    
    func indexPathForLastMessage() -> NSIndexPath {
        let lastSection = self.numberOfSections-1
        let numberOfMessages = self.numberOfMessagesInSection(section: lastSection)
        
        return IndexPath(row:numberOfMessages-1, section:lastSection) as NSIndexPath
    }
    
    func indexPathForMessage(message:Message) -> NSIndexPath {
        let key = self.keyForMessage(message: message)
        let section = self.orderedTitles.index(of: key)
        let row = self.mapTitleToMessages[key]!.index(where: { (el) -> Bool in
            return el == message
        })
        
        return IndexPath(row:row!, section:section!) as NSIndexPath
    }

    // MARK: - Helpers

    func addMessage(message:Message) {
        let key = self.keyForMessage(message: message)
        var array = self.mapTitleToMessages[key]
        
        if array == nil {
            self.numberOfSections += 1;
            array = [Message]()
        }
        
        array?.append(message)
        
        let sortedArray = array?.sorted(by: { (m1, m2) -> Bool in
           return m1.date.compare(m2.date as Date) == .orderedAscending
        })
        self.mapTitleToMessages[key] = sortedArray
        self.cacheTitles()
        self.numberOfMessages += 1
    }
    func removeMessage(message:Message) {
        let key = self.keyForMessage(message: message)
        var array = self.mapTitleToMessages[key]
        if array != nil {
            
            for (index, msg) in array!.enumerated() {
                if msg == message {
                    array!.remove(at: index)
                    return
                }
            }
            
            if array!.count == 0 {
                self.numberOfSections -= 1
                self.mapTitleToMessages.removeValue(forKey: key)
                self.cacheTitles()
            }
            else {
                self.mapTitleToMessages[key] = array
            }
            
            self.numberOfMessages -= 1
        }
    }

    func cacheTitles() {
        let array = self.mapTitleToMessages.keys
        
        let orderedArray = array.sorted { (dateString1, dateString2) -> Bool in
            let d1 = self.formatter.date(from: dateString1)
            let d2 = self.formatter.date(from: dateString2)
            
            return d1! < d2!
        }
        self.orderedTitles = orderedArray
        
        print("%@",self.orderedTitles);
    }
    
    func keyForMessage(message:Message) -> String {
        return self.formatter.string(from: message.date as Date)
    }
}
