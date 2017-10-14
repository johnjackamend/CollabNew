//
//  MessageController.swift
//  Whatsapp
//
//  Created by Rafael Castro on 7/23/15. / Swift Version by Breno Oliveira on 02/18/16.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

import Photos
import Firebase
import FirebaseStorage
import UIKit
import OneSignal

class MessageController:UIViewController, InputbarDelegate, MessageGatewayDelegate, UITableViewDataSource, UITableViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var ivUser: UIImageView!
    @IBOutlet weak var tapView: UIView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var inputbar:Inputbar!
    let deviceToken:String = ""
    var frndUnreadMsg = String()
    var image = UIImage()
    let imagePicker = UIImagePickerController()
    
    var frndName = String()
    var frndImage = String()
    var frndPlayerId = String()

    @IBOutlet var toolbarBottomConstant: NSLayoutConstraint!
    @IBOutlet var toolbarHeight: NSLayoutConstraint!


    var chat:Chat! {
        didSet {
            //lblUserName.text = self.chat?.contact.name
        }
    }

    private var tableArray:TableArray!
    private var gateway:MessageGateway!

    override func viewDidLoad() {
        super.viewDidLoad()
         self.imagePicker.delegate = self
        lblUserName.text = self.chat?.friendName.capitalized

      ivUser.sd_setImage(with: URL.init(string: self.chat.friendImage as String), placeholderImage: #imageLiteral(resourceName: "placeholder_user"))

        ivUser.layer.cornerRadius = ivUser.frame.size.height / 2.0
        ivUser.clipsToBounds = true
        self.navigationController?.isNavigationBarHidden = true
        frndUnreadMsg = "0"
        self.getChatHistory()
        self.getFirendInfo()
        self.setInputbar()
        self.setTableView()
        self.setGateway()
        AppDelegate.sharedDelegate.storeCurrntClass.append("Message")
    // delayed code, by default run in main thread
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
           
        })
        self.view.keyboardTriggerOffset = inputbar.frame.size.height
        self.view.addKeyboardPanning() {[unowned self](keyboardFrameInView:CGRect, opening:Bool, closing:Bool) in
            /*
             self.view.removeKeyboardControl()
             */

            var toolBarFrame = self.inputbar.frame
            toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height
            self.inputbar.frame = toolBarFrame

            var tableViewFrame = self.tableView.frame
            tableViewFrame.size.height = toolBarFrame.origin.y - 64
            self.tableView.frame = tableViewFrame

            self.tableViewScrollToBottomAnimated(animated: false)

        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false

    }

    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)

        self.view.keyboardTriggerOffset = inputbar.frame.size.height
        self.view.addKeyboardPanning() {[unowned self](keyboardFrameInView:CGRect, opening:Bool, closing:Bool) in
            /*
             self.view.removeKeyboardControl()
             */

            var toolBarFrame = self.inputbar.frame
            toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height
            self.inputbar.frame = toolBarFrame

            var tableViewFrame = self.tableView.frame
            tableViewFrame.size.height = toolBarFrame.origin.y - 64
            self.tableView.frame = tableViewFrame

            self.tableViewScrollToBottomAnimated(animated: false)
        }
    }

    override func viewDidDisappear(_ animated:Bool) {
        super.viewDidDisappear(animated)
        self.view.endEditing(true)
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = true

        self.gateway.dismiss()
    }

    override func viewWillDisappear(_ animated:Bool) {
//        userID = (UserDefaults.standard.object(forKey: User_Id) as? String)!
//        self.updateUnreadCount(userId: userID, unreadCount: "0")

    }

    func getFirendInfo()  {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let refChild = ref.child("users")
        let users = refChild.child(self.chat.friendID as String)
       
        users.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if snapshot.value != nil{
                print(snapshot.value!)
                let user = snapshot.value as? [String : Any] ?? [:]
                self.frndName = user["name"] as! String
                self.frndImage = user["profile_pic"] as! String
                self.frndPlayerId = user["player_id"] as! String
                print(user["name"] ?? "")
            }
        })
    }

    // MARK :
    // MARK : Chat Methods
    func sendMessgaeToChat(chatID : String , toUser recieverID : NSInteger, andMessage messgae: String) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let refChild = ref.child("Messages")
        let refChatID = refChild.child(chatID)
        let refMessageID = refChatID.childByAutoId()

        let senderId = UserDefaults.SFSDefault(valueForKey: "user_id") as! String
        let receiverStr = String(format:"%d",recieverID)
        var chatId = String()
        if Int(senderId)!  > Int(receiverStr)!{
            chatId = senderId + receiverStr
        }else{
            chatId =  receiverStr + senderId
        }

        let dataDict = ["sender":senderId,
                        "receiver": recieverID,
                        "message": messgae,
                        "timestamp": Int(NSDate().timeIntervalSince1970)] as [String : Any]

        refMessageID.setValue(dataDict) { (error, ref) in

            if error == nil{
               self.fireOneSignalNotification(textMsg: messgae)
                
                //insertion completed in database
            }
        }
    }

    func sendMessageToHistory(chatID : String , toUser reciverID: NSInteger , andMessage message:String)  {
        let ref : DatabaseReference!
        ref = Database.database().reference()
        let refChild = ref.child("ChatHistory")
        let refChatID = refChild.child(chatID)
        var unread_message = [Any]()
        for i in 0 ... 1 {
            var strUser = String()
            var strUnreadCount = String()
            let myId = UserDefaults.SFSDefault(valueForKey: "user_id") as! String;

            let frndId = self.chat.friendID as String;
            if myId < frndId {
                if i == 0{
                    strUser = myId
                    strUnreadCount = "0"
                }else{
                    strUser = frndId
                    strUnreadCount = frndUnreadMsg
                }
                unread_message.append(["unreadMsg":strUnreadCount,"userId":strUser])
            }
            else{
                if i == 0{
                    strUser = frndId
                    strUnreadCount = frndUnreadMsg
                }else{
                    strUser = myId
                    strUnreadCount = "0"

                }
                unread_message.append(["unreadMsg":strUnreadCount,"userId":strUser])
            }
        }

        let dataDict = ["timestamp":Int(NSDate().timeIntervalSince1970),
                        "last_message": message,"unread_message":unread_message] as [String : Any]
        refChatID.updateChildValues(dataDict){ (error, ref) in
       
        if error == nil{
            self.sendMessgaeToChat(chatID: chatID , toUser: reciverID ,andMessage: message)
            //insertion completed in database
        }
        }
    }
    // MARK: Firebase Notification Method
    
    func fireOneSignalNotification(textMsg:String)  {
     let frndId = self.chat.friendID as String
        let message = "\(UserDefaults.SFSDefault(valueForKey: "full_name")) has sent you message:\(textMsg)"

     let content = ["reciever":frndId,"player_id":frndPlayerId,"senderId":UserDefaults.SFSDefault(valueForKey: "user_id"),"senderName":UserDefaults.SFSDefault(valueForKey: "full_name"),"senderPic":UserDefaults.SFSDefault(valueForKey: "profile_pic"),"chatId":self.chat.chatID,"messsage":message]
        
        let parameter = ["contents": ["en": message], "include_player_ids":[frndPlayerId],"ios_badgeType":"Increase","ios_badgeCount":"1","data":content] as [String : Any];
        OneSignal.postNotification(parameter, onSuccess: { result in
            print("result = \(result!)")
        }, onFailure: {error in
            print("error = \(error!)")
        })
    }

    func setInputbar() {
        self.inputbar.placeholder = "Type your message"
        self.inputbar.tintColor = UIColor.lightGray
        self.inputbar.inputDelegate = self
        self.inputbar.leftButtonImage = UIImage(named:"photos")
        self.inputbar.rightButtonText = "Send"
        self.inputbar.rightButtonTextColor = UIColor(red:0, green:124/255, blue:1, alpha:1)
    }

    func setTableView() {
        self.tableArray = TableArray()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRect(x:0, y:0,width:self.view.frame.size.width,height:10))
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor.clear

        self.tableView.register(MessageCell.self, forCellReuseIdentifier:"MessageCell")
    }

    func setGateway() {
        self.gateway = MessageGateway.sharedInstance
        self.gateway.delegate = self
        self.gateway.chat = self.chat
        self.gateway.loadOldMessages()
    }

    // MARK - Actions

    @IBAction func userDidTapScreen(_ sender: Any) {
        self.inputbar.inputResignFirstResponder()
    }

    // MARK: - TableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableArray.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableArray.numberOfMessagesInSection(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCell
        cell.message = self.tableArray.objectAtIndexPath(indexPath: indexPath as NSIndexPath)
        return cell;
    }

    // MARK - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = self.tableArray.objectAtIndexPath(indexPath: indexPath as NSIndexPath)
        return message.height
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableArray.titleForSection(section: section)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect(x:0,y: 0,width: tableView.frame.size.width,height: 40)

        let view = UIView(frame:frame)
        view.backgroundColor = UIColor.clear
        view.autoresizingMask = .flexibleWidth

        let label = UILabel()
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.textAlignment = .center
        label.font = UIFont(name:"Helvetica", size:20)
        label.sizeToFit()
        label.center = view.center
        label.font = UIFont(name:"Helvetica", size:13)
        label.backgroundColor = UIColor(red:207/255, green:220/255, blue:252/255, alpha:1)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.autoresizingMask = []
        view.addSubview(label)

        return view
    }

    func tableViewScrollToBottomAnimated(animated:Bool) {
        let numberOfSections = self.tableArray.numberOfSections
        let numberOfRows = self.tableArray.numberOfMessagesInSection(section: numberOfSections-1)
        if numberOfRows > 0 {
            self.tableView.scrollToRow(at: self.tableArray.indexPathForLastMessage() as IndexPath, at:.bottom, animated:animated)
        }

        self.tableView.reloadData()
    }


    // MARK - InputbarDelegate

    func inputbarDidPressRightButton(inputbar:Inputbar) {
        let message = Message()
        message.text = inputbar.text
        message.date = NSDate()
        message.chatId = self.chat.identifier

        self.sendMessageToHistory(chatID: self.chat.chatID as String, toUser: self.chat.friendID.integerValue, andMessage: message.text)
      

        // [self fireNotification:inputbar.text andSenderID:kGetValueForKey(USER_ID)];

    }
    func inputbarDidPressLeftButton(inputbar:Inputbar) {

        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .authorized || status == .notDetermined) {
            self.imagePicker.sourceType = .savedPhotosAlbum;
            self.present(self.imagePicker, animated: true, completion: nil)
        }

//        let message = Message()
//        message.text = inputbar.text
//        message.date = NSDate()
//        message.chatId = self.chat.identifier
//
//        self.sendMessageToHistory(chatID: self.chat.chatID as String, toUser: self.chat.friendID.integerValue, andMessage: message.text)

    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
         //   self.composeMessage(type: .photo, content: pickedImage)
        } else {
            let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
           // self.composeMessage(type: .photo, content: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func inputbarDidChangeHeight(newHeight:CGFloat) {
        //Update DAKeyboardControl
        // self.view.keyboardTriggerOffset = newHeight
        toolbarHeight.constant = newHeight
    }
    //MARK: NSNotification Methods

    func keyboardWillShow(notification:NSNotification) {
        let userInfo  = notification.userInfo as! Dictionary<String, Any>
        let keyboardFrame: NSValue = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue //userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        print(keyboardHeight)
        self.toolbarBottomConstant.constant = keyboardHeight

    }

    func keyboardWillHide(notification:NSNotification) {
        self.toolbarBottomConstant.constant = 0
    }


    // MARK: - MessageGatewayDelegate

    func gatewayDidUpdateStatusForMessage(message:Message) {
        let indexPath = self.tableArray.indexPathForMessage(message: message)
        let cell = self.tableView.cellForRow(at: indexPath as IndexPath) as! MessageCell
        cell.updateMessageStatus()
    }

    func gatewayDidReceiveMessages(array:[Message]) {
        
        if self.tableArray.numberOfMessages + 1 == array.count {
            self.tableArray.addObject(message: array.last!)
        }
        else if array.count == self.tableArray.numberOfMessages{
            // dont add again
        }
        else{
            self.tableArray.addObjectsFromArray(messages: array)
        }
        self.tableView.reloadData()
        self.updateChatHistory()
        self.scrollTableViewToBottom()
           }

    func scrollTableViewToBottom(){
        self.tableViewScrollToBottomAnimated(animated: false)
    }

    @IBAction func blockBtnAction(_ sender: Any) {

        let blockVC = self.storyboard?.instantiateViewController(withIdentifier: "BlockVC") as! BlockVC
        blockVC.chatID = self.chat.chatID as String
        blockVC.userName = self.chat.friendName as String
        blockVC.image = self.ivUser.image!
        blockVC.friendID = self.chat.friendID as String
        self.navigationController?.pushViewController(blockVC, animated: true)
    }

    @IBAction func favBtnAction(_ sender: Any) {

        let chatID  = self.chat.chatID as String
        let ref : DatabaseReference!
        ref = Database.database().reference()
        let refChild = ref.child("ChatHistory")
        let refChatID = refChild.child(chatID)
        let dataDict = ["favourite":"1"]
        refChatID.updateChildValues(dataDict)
    }

    func updateChatHistory() {
        let ref : DatabaseReference!
        ref = Database.database().reference()
        let refChild = ref.child("ChatHistory")
        let refChatID = refChild.child(self.chat.chatID as String)

        var unread_message = [Any]()
        for i in 0 ... 1 {
            var strUser = String()
            let  myId = UserDefaults.SFSDefault(valueForKey: "user_id") as! String;
            let frndId = self.chat.friendID as String;
           
          let setMsgCount = String(format:"%d", Int(self.frndUnreadMsg)! - 1)
            if myId < frndId {
                if i == 0{
                    strUser = myId;
                    unread_message.append(["unreadMsg":"0","userId":strUser])
                }else{
                    strUser = frndId
                    unread_message.append(["unreadMsg":setMsgCount,"userId":strUser])
                }
            }
            else{
                if i == 0{
                    strUser = frndId;
                    unread_message.append(["unreadMsg":setMsgCount,"userId":strUser])
                }else{
                    strUser = myId
                    unread_message.append(["unreadMsg":"0","userId":strUser])
                }
            }
        }
        let dataDict : Dictionary = ["unread_message":unread_message] as [String : Any]
        refChatID.updateChildValues(dataDict)
    }

    func getChatHistory()
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

                let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.goToProfile(_:)))
                self.tapView.addGestureRecognizer(tapGesture)

                print("Value:\(String(describing: snapshot.value))")
                let allKeys = database.keys

                for key: String in allKeys {
                    print("\(String(describing: database[key]))")
                    let nodeDict = database[key] as? [String : Any] ?? [:]
                    if key == self.chat.chatID as String {
                        let unreadMsg:[Any] = nodeDict["unread_message"] as! [Any]
                        let  myId = UserDefaults.SFSDefault(valueForKey: "user_id") as! String
                        let frndId = self.chat.friendID as String
                        var frndInfo = Dictionary<String, Any>()
                        if myId < frndId {
                            frndInfo = (unreadMsg[1] as! NSDictionary) as! Dictionary<String, Any>
                        }else{
                            frndInfo = (unreadMsg[0] as! NSDictionary) as! Dictionary<String, Any>
                        }
                        var count  = frndInfo["unreadMsg"] as! String
                        count =  String(format:"%d", Int(count)! + 1)
                        self.frndUnreadMsg = count
                    }
                    else{
                    }
                }
                self.tableView.reloadData()

            }
        })
    }
    
    //MARK:
    //MARK: UIButton Actions
    @IBAction func backAction(_ sender: Any) {
         print(AppDelegate.sharedDelegate.storeCurrntClass)
        if AppDelegate.sharedDelegate.storeCurrntClass.count != 0 {
            AppDelegate.sharedDelegate.storeCurrntClass.removeLast()
             print(AppDelegate.sharedDelegate.storeCurrntClass)
        }
        self.navigationController?.popViewController(animated: true)
    }
    func goToProfile(_ sender: UITapGestureRecognizer)  {
        
        let fullProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "FullProfileVC") as! FullProfileVC
        fullProfileVC.userID = self.chat.friendID as String
        fullProfileVC.isMyProfile = "no"
        self.navigationController?.pushViewController(fullProfileVC, animated: true)
        
    }
    func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        print("Recived: \(userInfo)")
        
      //  completionHandler(.NewData)
        
    }
    
}
