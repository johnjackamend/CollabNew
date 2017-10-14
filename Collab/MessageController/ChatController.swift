//
//  ChatListController.swift
//  Whatsapp
//
//  Created by Rafael Castro on 7/24/15. / Swift Version by Breno Oliveira on 02/18/16.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

import UIKit
import Firebase

class ChatController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate,UITextFieldDelegate {

    @IBOutlet var tfSearch: UITextField!
    var arrayChatHistory = [Chat]()
    var searchResults = [Chat]()
    @IBOutlet weak var  tableView:UITableView!
    var filterCellArray = [String]()
    var tableData:[Chat] = []
    var friendIds:[Int] = []
    var search = String()
    var chatModel = Chat()
    var isSearchOn = Bool()


    override func viewDidLoad() {
        super.viewDidLoad()
         //filterCellArray = ["Unread","Recent","Favs"]
        tfSearch.delegate = self
        isSearchOn = false
    }

    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(true)
        AppManager.setTextfieldLeftView(image: #imageLiteral(resourceName: "search"), textField: tfSearch)

        if UserDefaults.SFSDefault(boolForKey: "isNotification") == true {

            UserDefaults.SFSDefault(setBool: false, forKey: "isNotification")
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "messageController") as! MessageController
            controller.chat = chatModel
            self.navigationController?.pushViewController(controller, animated: false)
        }
        else{
            self.navigationController?.navigationBar.isHidden = true
            self.getChatHistory(fav: "all")
        }
    }
    //MARK: Webservices Methods
    func getUserFriends()  {
        AppManager.sharedInstance.showHud(showInView: self.view, label: "")
        let para: Dictionary = ["user_id":UserDefaults.SFSDefault(valueForKey: "user_id")]
        ServerManager.sharedInstance.httpPost(String(format:"%@accept_deny_friendrequest",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
            AppManager.sharedInstance.hidHud()
            var jsonResult = response as! Dictionary<String, Any>
            print(jsonResult)
            if jsonResult["success"] as! NSNumber == 1{
                // let arrayChatData =
                //                NSArray *arrayChatData=[dic valueForKey:@"friends"];
                //                for (NSDictionary *dataDic in arrayChatData) {
                //                    Chat *objChat = [self getChatObjectBasedOnID:[dataDic objectForKey:@"friend_id"]];
                //                    if (objChat) {
                //                        NSInteger index = [arrayChatHistory indexOfObject:objChat];
                //                        Contact *objContact = objChat.contact;
                //                        objContact.name =[dataDic objectForKey:@"user_name"];
                //                        objContact.profileImage =[dataDic objectForKey:@"profile_pic"];
                //                        objChat.contact=objContact;
                //                        [arrayChatHistory replaceObjectAtIndex:index withObject:objChat];
                //                    }
                //                }

            }
            else{
                AppManager.showMessageView(view: self.view, meassage: jsonResult["error_message"] as! String)
            }
        }) { (error) in
            AppManager.sharedInstance.hidHud()
            AppManager.showMessageView(view: self.view, meassage: error.description)
        }
    }

    //MARK: FireBase Methods
    func getChatHistory(fav:String)
    {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let refChild = ref.child("ChatHistory")
        
        refChild.observe(DataEventType.value, with: { (snapshot) in
            var database = snapshot.value as? [String : AnyObject] ?? [:]
            if  snapshot.value is NSNull {
                // null
            }
            else{
                print("Value:\(String(describing: snapshot.value))")
                let allKeys = database.keys

                if self.arrayChatHistory.count != 0 {
                    self.arrayChatHistory.removeAll()
                }
                for key: String in allKeys {
                    print("\(String(describing: database[key]))")
                    let nodeDict = database[key] as? [String : Any] ?? [:]
                    let userID = UserDefaults.SFSDefault(valueForKey: "user_id") as! String
                    let senderID : String = nodeDict["sender"] as? String ?? ""
                    let receiverID : String = nodeDict["receiver"] as? String ?? ""
                    
                    if senderID == userID || receiverID == userID {
                        /// for get friend id
                        if senderID == userID{
                            self.friendIds.append(Int(receiverID)!)
                        }
                        else{
                            self.friendIds.append(Int(senderID)!)
                        }

                        let objChat = Chat()
                        objChat.chatID = key as NSString
                        let objMessage = Message()
                        objMessage.text = nodeDict["last_message"] as! String
                        objChat.lastMessage = objMessage

                        if receiverID == userID {
                            objChat.friendID = senderID as NSString
                        }
                        else {
                            objChat.friendID =  receiverID as NSString
                        }
                        
                        
                        let unreadMsg = nodeDict["unread_message"] as? Array ?? []
                        let frndInfo = unreadMsg[1] as? [String:Any] ?? [:]
                        let myInfo  = unreadMsg[0]as? [String:Any] ?? [:]
                        objChat.favourite = Int((nodeDict["favourite"] as? String)!)!
                        
                        
                        if userID < objChat.friendID as String {
                            let msgCounts = (myInfo["unreadMsg"]) as! String
                            objChat.numberOfUnreadMessages =   Int(msgCounts)!
                        }else{
                            objChat.numberOfUnreadMessages = Int((frndInfo["unreadMsg"] as? String)!)!
                        }
                        
                        
                        let time  = nodeDict["timestamp"]
                        objChat.timeFirStamp = time as! Int
                        print(objChat)
                        
                        
                        let message = Message()
                        message.text = nodeDict["last_message"] as! String
                        message.chatId = key
                        let objContact = Contact()
                        objContact.identifier = key
                        objChat.contact = objContact
                        self.arrayChatHistory.append(objChat)
                    }
                    else{

                    }
                }
                if (self.arrayChatHistory.count==0) {
                    //You have no friends"
                }
                var sortedArray  = Array<Chat>()
                if fav == "fav"{
                    sortedArray = self.arrayChatHistory.sorted(by: {$0.favourite > $1.favourite})
                }
                else if fav == "unread"{
                    sortedArray = self.arrayChatHistory.sorted(by: {$0.numberOfUnreadMessages > $1.numberOfUnreadMessages})
                }
                else{
                    sortedArray = self.arrayChatHistory.sorted(by: {$0.timeFirStamp > $1.timeFirStamp})
                }
                self.arrayChatHistory.removeAll()
                self.arrayChatHistory.append(contentsOf: sortedArray)

                    self.tableView.reloadSections(IndexSet.init(integer: 1), with: .none)
//                self.tableView.reloadData()
            }
        })
    }

    func getUsersWithKey()  {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let refChild = ref.child("users")

        refChild.observe(DataEventType.value, with: { (snapshot) in
            var database = snapshot.value as? [String : AnyObject] ?? [:]

            if  snapshot.value is NSNull {
                // null
            }
            else{
                print("Value:\(String(describing: snapshot.value))")
                let allKeys = database.keys

                print(allKeys)
                for key: String in allKeys {
                    if self.friendIds.contains(Int(key)!) == true{
                        print(self.friendIds);
                        print(key)
                    }else{

                    }
                    print("\(String(describing: database[key]))")


                    /*
                     objContact.name = user["name"] as! String
                     objContact.profileImage = user["profile_pic"] as! String
                     objChat?.contact = objContact
                     // arrayChatHistory.replaceObject(at: indexPath.row, with: objChat!)
                     cell.nameLabel.text = objContact.name
                     cell.messageLabel.text = objChat?.lastMessage.text
                     if objContact.profileImage.isEmpty == false{
                     cell.picture.sd_setImage(with: URL.init(string: objContact.profileImage))
                     }
                     else{
                     cell.picture.image = #imageLiteral(resourceName: "placeholder_user")
                     }

                     cell.picture.layer.cornerRadius = cell.picture.frame.size.height/2
                     cell.picture.clipsToBounds = true
                     */
                }
            }
        })
    }

    func getChatObjectBasedOnID(userID :String) -> Chat? {
        let predicate = NSPredicate(format: "friendID == %@", userID)
        let filteredArray: [Any] = arrayChatHistory.filter { predicate.evaluate(with: $0) }
        if filteredArray.count > 0 {
            return filteredArray.first as? Chat
        }
        else{
            return nil
        }
    }


    // MARK: - TableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView:UITableView, numberOfRowsInSection section:NSInteger) -> Int
    {
        if section == 0 {
            return filterCellArray.count
        }
        else{
            if isSearchOn == true {
                return searchResults.count
            }
            else{
            return arrayChatHistory.count
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell    {
        if indexPath.section == 0 {

            let cellIdentifier = "filterCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! ChatCell
            cell.lblFilter.text = filterCellArray[indexPath.row]
            cell.ivFilter.image = nil
            cell.selectionStyle = .none
            return cell
        }
        else{
            let cellIdentifier = "chatCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! ChatCell
            cell.picture.layer.cornerRadius = cell.picture.frame.size.width/2
            cell.picture.layer.masksToBounds = true
            cell.selectionStyle = .gray
            var objChat : Chat? = Chat()
            if isSearchOn == true {
                 objChat   = searchResults[indexPath.row] as Chat
            }
            else{
                 objChat = arrayChatHistory[indexPath.row]
            }
//            if objChat?.contact.name.isEmpty == true {
                var ref:DatabaseReference!
                ref = Database.database().reference()
                let refChild = ref.child("users")
                let users = refChild.child(objChat!.friendID as String)

                users.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in

                    if snapshot.value is NSNull {
                    }
                    else{
                        let user = snapshot.value as?  [String : Any] ?? [:]
                        let objContact: Contact = (objChat?.contact)!
                        objContact.name = user["name"] as! String
                        objContact.profileImage = user["profile_pic"] as? String ?? ""
                        objChat?.contact = objContact
                        objChat?.friendImage = user["profile_pic"] as! NSString
                        objChat?.friendName = user["name"] as! NSString
                        // arrayChatHistory.replaceObject(at: indexPath.row, with: objChat!)
                        cell.nameLabel.text = objContact.name

                        cell.picture.layer.cornerRadius = cell.picture.frame.size.height/2
                        cell.picture.clipsToBounds = true

                        if objContact.profileImage.characters.count > 0{
                            cell.picture.sd_setImage(with: URL.init(string: objContact.profileImage))
                        }
                        else{
                            cell.picture.image = #imageLiteral(resourceName: "placeholder_user")
                        }

                        cell.nameLabel.text = objContact.name
                        cell.messageLabel.text = objChat?.lastMessage.text
                        cell.lblUnreadCount.layer.cornerRadius = cell.lblUnreadCount.frame.size.height / 2.0
                        cell.lblUnreadCount.clipsToBounds = true

                        if (objChat?.numberOfUnreadMessages)! > 0 {
                            cell.lblUnreadCount.isHidden = false
                            cell.lblUnreadCount.text = String(format:"%d",(objChat?.numberOfUnreadMessages)!)
                        }
                        else{
                            cell.lblUnreadCount.isHidden = true
                        }

                    }
                })
              return cell
            }
    }
    // MARK: - UITableViewDelegate

    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath) {

        if indexPath.section == 0 {
            let cell = tableView.cellForRow(at: indexPath) as! ChatCell
            cell.ivFilter.image = #imageLiteral(resourceName: "filter")
            cell.selectionStyle = .none
            if indexPath.row == 0 {
                self.getChatHistory(fav: "unread");
            }
            else if indexPath.row == 1 {
                self.getChatHistory(fav: "recent");
            }
            else{
                self.getChatHistory(fav: "fav")
            }
        }
        else{
            if AppDelegate.sharedDelegate.storeCurrntClass.count != 0 {
                AppDelegate.sharedDelegate.storeCurrntClass.removeLast()
                print(AppDelegate.sharedDelegate.storeCurrntClass)
            }

            let controller = self.storyboard?.instantiateViewController(withIdentifier: "messageController") as! MessageController
             var chatToStart : Chat = Chat()

            if isSearchOn == true {
                chatToStart = searchResults[indexPath.row]
            }
            else{
                chatToStart = arrayChatHistory[indexPath.row]

            }
            controller.chat = chatToStart
            // controller.image = cell.picture.image!

            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        if indexPath.section == 0 {
            let cell = tableView.cellForRow(at: indexPath) as! ChatCell
            cell.ivFilter.image = nil
        }
        else{

        }
    }



    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 30.0
        }
        else{
            return 60.0
        }
    }
    // MARK: - GestureMethod

    @IBAction func backBtnAction(_ sender: Any) {
        print(AppDelegate.sharedDelegate.storeCurrntClass)
        if AppDelegate.sharedDelegate.storeCurrntClass.count != 0 {
            AppDelegate.sharedDelegate.storeCurrntClass.removeLast()
            print(AppDelegate.sharedDelegate.storeCurrntClass)
        }
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func filterChatAction(_ sender: UIButton) {
        if sender.isSelected == true {
            sender.isSelected = false
            filterCellArray.removeAll()
            tableView.beginUpdates()
            tableView.reloadSections(IndexSet.init(integer: 0), with: .none)
            tableView.endUpdates()
        }
        else{
            sender.isSelected = true
            filterCellArray = ["Unread","Recent","Favs"]
            tableView.beginUpdates()
            tableView.reloadSections(IndexSet.init(integer: 0), with: .none)
            tableView.endUpdates()
        }
    }

   // MARK: UITextFieldMethod
    //MARK: UITextField Delegate Methods

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         isSearchOn = true
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let searchStringLocal = textFieldText.replacingCharacters(in: range, with: string)

        if searchStringLocal.characters.count == 0{
            isSearchOn = false
            searchResults.removeAll()
            self.tableView.reloadSections(IndexSet.init(integer: 1), with: .none)
        }
        else{
            let predicate: NSPredicate = NSPredicate(format: "friendName CONTAINS[cd] %@ ", searchStringLocal)
            if searchResults.count > 0{
                searchResults.removeAll()
            }
            searchResults =  ((arrayChatHistory as NSArray).filtered(using: predicate) as? [Chat])!
//            if  let filter =  (arrayChatHistory as NSArray).filtered(using: predicate) as? [Chat]{
//                for obj in filter{
//                    searchResults.append(obj)
//                }
//            }
           self.tableView.reloadSections(IndexSet.init(integer: 1), with: .none)
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
//         isSearchOn = false

    }
}
