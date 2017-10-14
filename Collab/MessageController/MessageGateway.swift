//
//  MessageGateway.swift
//  Whatsapp
//
//  Created by Rafael Castro on 7/4/15. / Swift Version by Breno Oliveira on 02/18/16.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//
import Firebase
@objc protocol MessageGatewayDelegate:NSObjectProtocol {
    func gatewayDidUpdateStatusForMessage(message:Message)
    func gatewayDidReceiveMessages(array:[Message])
}


class MessageGateway:NSObject {
    var delegate:MessageGatewayDelegate!
    var chat:Chat!
    var messagesToSend:NSMutableArray = NSMutableArray()
    var query:DatabaseQuery? = DatabaseQuery()
    

    func loadOldMessages() {
        
        var firbaseRef: DatabaseReference!
        firbaseRef = Database.database().reference()
        let firbaseRefChild = firbaseRef.child("Messages")
        let firbaseRefChatID = firbaseRefChild.child(self.chat.chatID as String)
        self.query = firbaseRefChatID.queryOrdered(byChild: "timestamp")
        
        self.query?.observe(DataEventType.value, with: { (snapshot) in
            
            if snapshot.value == nil {
                
            }
            else{
                print(snapshot.value ?? "")
                let messageDic = snapshot.value as? [String: Any] ?? [:]
                let keys = messageDic.keys
                var msgArray  = Array <Message> ()
                for key : String in keys{
                    let messageDictionary = messageDic[key] as! [String:Any]
                    let messageObject = Message()
                    let currentUserID = UserDefaults.SFSDefault(valueForKey: "user_id") as? String
                    let senderID : String = messageDictionary["sender"] as? String ?? ""
                    if senderID == currentUserID  {
                    messageObject.sender = .Myself
                        messageObject.status = .Sent
                    }
                    else{
                        messageObject.sender = .Someone
                        messageObject.status = .Received
                    }
                    
                    messageObject.chatId = self.chat.chatID as String
                    messageObject.text = messageDictionary["message"] as! String

                   
                    let timeInterval : TimeInterval  =  TimeInterval.init(messageDictionary["timestamp"] as! NSNumber)
                    messageObject.date = NSDate.init(timeIntervalSince1970: timeInterval)
                    msgArray.append(messageObject)
                }
                
                //sort array
                
               let sortedArray = msgArray.sorted(by: {$0.date.compare($1.date as Date) == .orderedAscending})
                if ((self.delegate) != nil)
                {
                    self.delegate.gatewayDidReceiveMessages(array: sortedArray )
                }
            }
            }
        )
    }
    
    func updateStatusToReadInArray(unreadMessages:[Message]) {
        var readIds = [String]()
        for message in unreadMessages {
            message.status = .Read
            readIds.append(message.identifier)
        }
        self.chat.numberOfUnreadMessages = 0
        self.sendReadStatusToMessages(messageIds: readIds)
    }
    
    func queryUnreadMessagesInArray(array:[Message]) -> [Message] {
        return array.filter({(message:Message) -> Bool in
            return message.status == .Received
        })
    }
    
    func news() {
        
    }
    func dismiss() {
        self.delegate = nil
        self.query?.removeAllObservers()
        self.query = nil
        
    }

    func fakeMessageUpdate(message:Message) {
        self.perform(#selector(MessageGateway.updateMessageStatus(message:)), with:message, afterDelay:2)
    }
    
    func updateMessageStatus(message:Message) {
        
        switch message.status {
        case .Sending:
            message.status = .Failed
        case .Failed:
            message.status = .Sent
        case .Sent:
            message.status = .Received
        case .Received:
            message.status = .Read
        default: break
        }
        
        if self.delegate != nil && self.delegate.responds(to: #selector(MessageGatewayDelegate.gatewayDidUpdateStatusForMessage(message:))) {
            self.delegate!.gatewayDidUpdateStatusForMessage(message: message)
        }
        
        //
        // Remove this when connect to your server
        // fake update message
        //
        if message.status != .Read {
            self.fakeMessageUpdate(message: message)
        }
    }

    // MARK: - Exchange data with API

    func sendMessage(message:Message) {
        //
        // Add here your code to send message to your server
        // When you receive the response, you should update message status
        // Now I'm just faking update message
        //
        LocalStorage.sharedInstance.storeMessage(message: message)
        self.fakeMessageUpdate(message: message)
        //TODO
    }
    func sendReadStatusToMessages(messageIds:[String]) {
        if messageIds.count == 0 {
            return
        }
        //TODO
    }
    func sendReceivedStatusToMessages(messageIds:[String]) {
        if messageIds.count == 0 {
            return
        }
        //TODO
    }
    
    static let sharedInstance = MessageGateway()
    private override init() {}
}
