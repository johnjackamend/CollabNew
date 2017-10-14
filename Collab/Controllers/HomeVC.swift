//
//  HomeVC.swift
//  Collab
//
//  Created by SFS04 on 4/24/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit
import Pulsator
import MediaPlayer
import Firebase
import OneSignal
import CMPageControl
import CoreLocation

class HomeVC: UIViewController, YSLDraggableCardContainerDelegate, YSLDraggableCardContainerDataSource,NPAudioStreamDelegate,reloadPageDelegate {

    //MARK:
    //MARK: Outlet Connections


    var distance = Int()
    var isLastProfile = Bool()

    @IBOutlet weak var btnChat: UIButton!

    var infoView = InfoView()
    var filteredData = NSArray()
    let urlarray = NSMutableArray()
    let pulsator = Pulsator()
    var isPlaying = Bool()
    var audioStream : NPAudioStream = NPAudioStream()
    
    @IBOutlet weak var container : YSLDraggableCardContainer! // = YSLDraggableCardContainer()
    
    var userImage = String()
    var userName = String()
    var chatModel = Chat()
    var noInternetView = NoInternetView()
    var isFakeProfiles = Bool()


    @IBOutlet var viewCanAgain: UIView!
    @IBOutlet var viewStartChat: UIView!

    //MARK:
    //MARK: Outlet Connections viewStartChat

    var docController:UIActivityViewController!
    @IBOutlet var lblShouldCollab: UILabel!
    @IBOutlet var ivMe: UIImageView!
    @IBOutlet var ivFriend: UIImageView!
    @IBOutlet weak var cltnSharedFollowers: UICollectionView!
    var userChatID = String()

    let heightCalculated: CGFloat = UIScreen.main.bounds.size.width
    

    //MARK:
    //MARK: Outlet Connections PopUp View
    @IBOutlet var popUpView: UIView!
    @IBOutlet weak var lblAboutUser: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var lblSharedFollowers: UILabel!
    @IBOutlet weak var btnInstaView: UIButton!
    @IBOutlet weak var btnPlaySongPopUpView: UIButton!
    //MARK:
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnChat.isHidden = false
        distance = 8000
        isFakeProfiles = false
        isLastProfile = false
        noInternetView = Bundle.main.loadNibNamed("NoInternetView", owner: self, options: nil)?[0] as! NoInternetView
        noInternetView.delegate = self
        
        //Thread.detachNewThreadSelector(#selector(HomeVC.getFriends), toTarget: self, with: nil)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if UserDefaults.SFSDefault(boolForKey: "isNotification") == true {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ChatController") as! ChatController
            controller.chatModel = chatModel
            self.navigationController?.pushViewController(controller, animated: false)
        }
        else{

            self.navigationController?.navigationBar.isHidden = true
            self.view.backgroundColor = UIColor.cyan

//            container.frame = CGRect.init(x: 0, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height-64)
            
            
            //container.frame = CGRect.init(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height:heightCalculated)
            
            container.backgroundColor = UIColor.clear

            container.dataSource = self
            container.delegate = self

            self.view.layer.addSublayer(pulsator)
            pulsator.position = self.view.center
            pulsator.numPulse = 3
            pulsator.backgroundColor =  UIColor(red: 192.0/255.0, green: 135.0/255.0, blue: 51.0/255.0, alpha: 1.0).cgColor
            pulsator.radius = ScreenSize.SCREEN_WIDTH/2
            //self.view.addSubview(container)
            container.isHidden = true

            isPlaying = false

            viewCanAgain.frame = CGRect.init(x: 0, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height - 64)
            
            
            self.view.addSubview(viewCanAgain)
            viewCanAgain.isHidden = true

            viewStartChat.frame = CGRect.init(x: 0, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height - 64)
            
            
            self.view.addSubview(viewStartChat)
            viewStartChat.isHidden = true
            
            popUpView.frame = CGRect.init(x: 0, y: ScreenSize.SCREEN_HEIGHT, width: self.view.frame.size.width, height: popUpView.frame.size.height - 64)
            
            
            self.view.addSubview(popUpView)
            
            popUpView.isHidden = true

            if UserDefaults.SFSDefault(boolForKey: kIsFirstTime) == true {
                self.getTopEightData()
            }
            else{
                self.getFilteredData(distanceInt: distance)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:
    //MARK:Webservices Methods
  
    func getFilteredData(distanceInt : Int) {
        
        if pulsator.isPulsating == false {
            pulsator.start()
        }
        
        
        AppManager.sharedInstance.showHud(showInView: self.view, label: "")
        let para: Dictionary = ["user_id":UserDefaults.SFSDefault(valueForKey: "user_id"),
                                "distance" :distanceInt ]
        ServerManager.sharedInstance.httpPost(String(format:"%@homepage",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
            AppManager.sharedInstance.hidHud()
            var jsonResult = response as! Dictionary<String, Any>
            AppManager.sharedInstance.hidHud()
            print(jsonResult)
            if jsonResult["success"] as! NSNumber == 1{
                self.pulsator.stop()
                let dataArray = NSArray.init(object: jsonResult["user_data"]!)
                self.filteredData = dataArray[0] as! NSArray
                self.pulsator.stop()
                self.container.isHidden = false
                self.container.reload()
            }
            else if jsonResult["success"] as! NSNumber == 101{
              self.pulsator.stop()
                UserDefaults.SFSDefault(setBool: true, forKey: kLocationIsOff)
                AppManager.sharedInstance.callAlert(view: self, headerString: DENIED_LOCATION_HEADER, messageString: DENIED_LOCATION_MESSAGE)
            }
            else{
                self.distance = distanceInt
                if self.distance < 10000{
                    self.distance = self.distance + 300
                    self.getFilteredData(distanceInt: self.distance)
                }
                else{
                    self.pulsator.stop()
                    self.viewCanAgain.isHidden = false
                }
            }
        }) { (error) in
            AppManager.sharedInstance.hidHud()
            if AppManager.isInternetError(error) == true  {
                self.noInternetView.frame = CGRect.init(x: self.view.frame.origin.x, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height - 64 )


                //self.noInternetView.frame = self.viewCanAgain.frame
                self.view.addSubview(self.noInternetView)

            }
            else{
                AppManager.sharedInstance.hidHud()
                AppManager.showMessageView(view: self.view, meassage: error.description as String)
            }
        }
    }

    func getTopEightData() {
        pulsator.start()

        AppManager.sharedInstance.showHud(showInView: self.view, label: "")
        let para: Dictionary = ["user_id":UserDefaults.SFSDefault(valueForKey: "user_id")]

        ServerManager.sharedInstance.httpPost(String(format:"%@get_fake_users",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
            AppManager.sharedInstance.hidHud()
            var jsonResult = response as! Dictionary<String, Any>
            AppManager.sharedInstance.hidHud()
            print(jsonResult)
            if jsonResult["success"] as! NSNumber == 1{
                self.isFakeProfiles = true
                UserDefaults.SFSDefault(setBool: false, forKey: kIsFirstTime)
                let dataArray = NSArray.init(object: jsonResult["user_data"]!)
                self.filteredData = dataArray[0] as! NSArray
                self.pulsator.stop()
                self.container.isHidden = false
                self.container.reload()
                //self.getFilteredData(distanceInt: self.distance)
            }
            else{
                self.pulsator.stop()
                self.viewCanAgain.isHidden = false
            }
        }) { (error) in
            AppManager.sharedInstance.hidHud()
            if AppManager.isInternetError(error) == true  {
                self.noInternetView.frame = CGRect.init(x: self.view.frame.origin.x, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height - 64 )


                //self.noInternetView.frame = self.viewCanAgain.frame
                self.view.addSubview(self.noInternetView)

            }
            else{
                AppManager.sharedInstance.hidHud()
                AppManager.showMessageView(view: self.view, meassage: error.description as String)
            }
        }
    }

    //MARK:
    //MARK: Initiate Chat With User

    func initateChatWithUser(dict :Dictionary <String, Any>)  {
        var ref: DatabaseReference!
        ref = Database.database().reference()

        let refChild = ref.child("ChatHistory")

        var senderId = String()
        var receiverStr =  String()

        senderId = UserDefaults.SFSDefault(valueForKey: "user_id") as! String

        receiverStr = dict["id"] as! String
        var chatId = String()
        if Int(senderId)!  > Int(receiverStr)!{
            chatId = senderId + receiverStr
        }else{
            chatId =  receiverStr +  senderId
        }
        let chatID = refChild.child(chatId)

        var unread_message = [Any]()
        for i in 0 ... 1 {
            var strUser = String()
            //   var strUnreadCount = String()

            if senderId < receiverStr {
                if i == 0{
                    strUser = senderId;
                }else{
                    strUser = receiverStr
                }
            }
            else{
                if i == 0{
                    strUser = receiverStr;
                }else{
                    strUser = senderId
                }
            }

            unread_message.append(["unreadMsg":"0","userId":strUser])

        }

        let dataDict : Dictionary = ["sender":senderId,
                                     "receiver":dict["id"],
                                     "receiver_name" : dict["full_name"],
                                     "timestamp":Int(NSDate().timeIntervalSince1970),
                                     "last_message" : "",
                                     "chatId":chatId,
                                     "favourite":"0",
                                     "unread_message":unread_message]

        chatID.setValue(dataDict) { (error, ref) in
            if error != nil{
                print("error")
            }
            else{
                self.viewStartChat.isHidden = false
                self.userChatID = chatId
                //                self.getChatHistory(chatID: chatId)
                print("addded")

                self.getFirendInfo(chatId, friendID: dict["id"] as! String)
            }
        }
    }

    //MARK:
    //MARK: Button Actions
    @IBAction func openSideMenu(_ sender: Any) {
        self.btnPauseSongAction()
        self.menuContainerViewController.toggleLeftSideMenuCompletion {
        }
    }

    func slideRight(tag : NSInteger)  {
        audioStream.pause()
        // infoView.btnPlayPause.setImage(UIImage.init(named: "play"), for: .normal)
        infoView.btnPlayPause.isSelected = false
        infoView.btnPlayPause.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        audioStream.seekToTime(inSeconds: 0)
        isPlaying = false

        let dataDict = self.filteredData[tag] as! Dictionary<String, Any>
        AppManager.sharedInstance.showHud(showInView: self.view, label: "")

        let para: Dictionary = ["user_id":UserDefaults.SFSDefault(valueForKey: "user_id"),
                                "friend_id" : dataDict["id"]!,
                                "request_status": "1"]

        ServerManager.sharedInstance.httpPost(String(format:"%@accept_deny_friendrequest",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
            AppManager.sharedInstance.hidHud()
            var jsonResult = response as! Dictionary<String, Any>
            AppManager.sharedInstance.hidHud()
            print(jsonResult)
            if jsonResult["success"] as! NSNumber == 1{
                let data = jsonResult["data_type"] as? [String : Any] ?? [:]
                self.setStartChatView()
                self.initateChatWithUser(dict: data)
            }
            else{
                AppManager.showMessageView(view: self.view, meassage: jsonResult["error_message"] as! String)
            }
        }) { (error) in
            AppManager.sharedInstance.hidHud()
            AppManager.showMessageView(view: self.view, meassage: error.description)
        }
    }
    func slideleft(tag : NSInteger)  {
        audioStream.pause()
        // infoView.btnPlayPause.setImage(UIImage.init(named: "play"), for: .normal)
        infoView.btnPlayPause.isSelected = false
        infoView.btnPlayPause.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        audioStream.seekToTime(inSeconds: 0)
        isPlaying = false

        let dataDict = self.filteredData[tag] as! Dictionary<String, Any>

        AppManager.sharedInstance.showHud(showInView: self.view, label: "")

        let para: Dictionary = ["user_id":UserDefaults.SFSDefault(valueForKey: "user_id"),
                                "friend_id" : dataDict["id"]!,
                                "request_status": "0"]

        ServerManager.sharedInstance.httpPost(String(format:"%@accept_deny_friendrequest",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
            AppManager.sharedInstance.hidHud()
            var jsonResult = response as! Dictionary<String, Any>
            AppManager.sharedInstance.hidHud()
            print(jsonResult)
            if jsonResult["success"] as! NSNumber == 1{
                AppManager.showMessageView(view: self.view, meassage: jsonResult["success_message"] as! String)
                //self.getFilteredData()
            }
            else{
                AppManager.showMessageView(view: self.view, meassage: jsonResult["error_message"] as! String)
                //self.getFilteredData()
            }
        }) { (error) in
            AppManager.sharedInstance.hidHud()
            //self.getFilteredData()
            AppManager.showMessageView(view: self.view, meassage: error.description)
        }
    }


    func rejectRequest(_ sender: UIButton)  {
        audioStream.pause()
        // infoView.btnPlayPause.setImage(UIImage.init(named: "play"), for: .normal)
        infoView.btnPlayPause.isSelected = false
        infoView.btnPlayPause.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        audioStream.seekToTime(inSeconds: 0)
        isPlaying = false

        if isFakeProfiles == false {
            container.movePosition(with: .left, isAutomatic: false)
            self.slideleft(tag: sender.tag)
        }
        else{
            container.movePosition(with: .left, isAutomatic: false)
            if sender.tag == self.filteredData.count - 1 {
                self.getFilteredData(distanceInt: distance)
                isFakeProfiles = false
            }
        }

//        let dataDict = self.filteredData[_sender.tag] as! Dictionary<String, Any>
//
//        AppManager.sharedInstance.showHud(showInView: self.view, label: "")
//
//        let para: Dictionary = ["user_id":UserDefaults.SFSDefault(valueForKey: "user_id"),
//                                "friend_id" : dataDict["id"]!,
//                                "request_status": "0"]
//
//        ServerManager.sharedInstance.httpPost(String(format:"%@accept_deny_friendrequest",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
//            AppManager.sharedInstance.hidHud()
//            var jsonResult = response as! Dictionary<String, Any>
//            AppManager.sharedInstance.hidHud()
//            print(jsonResult)
//            if jsonResult["success"] as! NSNumber == 1{
//                AppManager.showMessageView(view: self.view, meassage: jsonResult["success_message"] as! String)
//                //self.getFilteredData()
//            }
//            else{
//                AppManager.showMessageView(view: self.view, meassage: jsonResult["error_message"] as! String)
//                // self.getFilteredData()
//            }
//        }) { (error) in
//            AppManager.sharedInstance.hidHud()
//            //self.getFilteredData()
//            AppManager.showMessageView(view: self.view, meassage: error.description)
//        }


    }
    func acceptRequest(_ sender: UIButton)  {
        audioStream.pause()
        // infoView.btnPlayPause.setImage(UIImage.init(named: "play"), for: .normal)
        infoView.btnPlayPause.isSelected = false
        infoView.btnPlayPause.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        audioStream.seekToTime(inSeconds: 0)
        isPlaying = false

        if isFakeProfiles == false {
            let dataDict = self.filteredData[sender.tag] as! Dictionary<String, Any>
            userImage = dataDict["profile_pic"] as! String
            userName = dataDict["full_name"] as! String
            container.movePosition(with: .right, isAutomatic: false)
            self.slideRight(tag: sender.tag)
        }
        else{
            container.movePosition(with: .right, isAutomatic: false)
            if sender.tag == self.filteredData.count - 1 {
                self.getFilteredData(distanceInt: distance)
                isFakeProfiles = false
            }
        }

//        let dataDict = self.filteredData[_sender.tag] as! Dictionary<String, Any>
//
//        AppManager.sharedInstance.showHud(showInView: self.view, label: "")
//
//        let para: Dictionary = ["user_id":UserDefaults.SFSDefault(valueForKey: "user_id"),
//                                "friend_id" : dataDict["id"]!,
//                                "request_status": "1"]
//
//        ServerManager.sharedInstance.httpPost(String(format:"%@accept_deny_friendrequest",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
//            AppManager.sharedInstance.hidHud()
//            var jsonResult = response as! Dictionary<String, Any>
//            AppManager.sharedInstance.hidHud()
//            print(jsonResult)
//            if jsonResult["success"] as! NSNumber == 1{
//
//                let data = jsonResult["data_type"] as? [String : Any] ?? [:]
//                self.setStartChatView()
//                self.initateChatWithUser(dict: data)
//            }
//            else{
//                AppManager.showMessageView(view: self.view, meassage: jsonResult["error_message"] as! String)
//            }
//        }) { (error) in
//            AppManager.sharedInstance.hidHud()
//            AppManager.showMessageView(view: self.view, meassage: error.description)
//        }
    }
    func btnPlayPauseSong( btn: UIButton) {
        infoView.btnPlayPause = btn
        audioStream.delegate = self
        let dataDict = self.filteredData[btn.tag] as! Dictionary<String, Any>

        let getURL : String = dataDict["music_file_url"] as! String
        
//        let sUrl = "http://api.soundcloud.com/resolve.json?url=" + getURL + "?client_id=" + SOUND_CLOUD_CLIENT_ID
        
//        let sUrl = getURL + "?client_id=" + SOUND_CLOUD_CLIENT_ID
        
        let sUrl = getURL
        
        let songUrl  = URL.init(string: sUrl  )
        

        if urlarray.count != 0 {
            urlarray.removeAllObjects()
        }
        urlarray.add(songUrl!)

        if isPlaying == false {
            btn.isSelected = true
            self.perform(#selector(self.btnPlaySongAction), on: .main, with: nil, waitUntilDone: true)
        }
        else{
            btn.isSelected = false
            self.perform(#selector(self.btnPauseSongAction), on: .main, with: nil, waitUntilDone: true)
        }
    }


    func btnPlaySongAction()  {
        audioStream.callMethod(urlarray)
        audioStream.selectIndex(forPlayback: 0)
        audioStream.play()
        isPlaying = true
    }

    func btnPauseSongAction()  {
        if audioStream.status == .playing {
            audioStream.pause()
            isPlaying = false
        }
    }

    func viewInstaProfile(_sender: UIButton) {
        let dataDict = self.filteredData[_sender.tag] as! Dictionary<String, Any>
        if let url = URL(string: dataDict["instagram_profile_link"] as! String) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                // Fallback on earlier versions
            }
        }
    }
    //MARK:
    //MARK: scan again view actions

    @IBAction func scanAgainAction(_ sender: Any) {
        viewCanAgain.isHidden = true
        self.getTopEightData()
    }
    @IBAction func inviteYourFriendsAction(_ sender: Any) {

        let Controller = (self.storyboard?.instantiateViewController(withIdentifier: "InviteFriendsVC"))! as! InviteFriendsVC
        Controller.isPopUp = "yes"
        definesPresentationContext = true
        Controller.modalPresentationStyle = .overCurrentContext
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.subtype = kCATransitionFromRight
        navigationController?.view?.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(Controller, animated: false)

    }

    //MARK:
    //MARK: YSLDraggableCardContainer DataSource

    func cardContainerViewNextView(with index: Int) -> UIView! {
        let dataDict = self.filteredData[index] as! Dictionary<String, Any>

        let view = CardView.init(frame: .init(x: 0, y: 0, width: heightCalculated , height: heightCalculated))

        view.backgroundColor = UIColor.lightGray

        var imagesArray = [String]()
//        imagesArray.append("https://scontent-dft4-2.cdninstagram.com/t51.2885-19//14156345_1097002337022043_11763453_a.jpg")
//        imagesArray.append("https://scontent-dft4-2.cdninstagram.com/t51.2885-19//14156345_1097002337022043_11763453_a.jpg")
//        imagesArray.append("https://scontent-dft4-2.cdninstagram.com/t51.2885-19//14156345_1097002337022043_11763453_a.jpg")
        
        imagesArray.append(dataDict["image1"] as! String)
        imagesArray.append(dataDict["image2"] as! String)
        imagesArray.append(dataDict["profile_pic"] as! String)
        
        view.scrollImages(imagesArray)

        infoView = Bundle.main.loadNibNamed("InfoView", owner: self, options: nil)?[0] as! InfoView

        infoView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.showPopUpView))
        infoView.addGestureRecognizer(tapGesture)
        infoView.tag = index
        
        let heightValue = UIScreen.main.bounds.size.height - (heightCalculated+64) ;
        
//        infoView.frame = CGRect.init(x: 0, y: self.view.frame.size.height - (64 + (self.view.frame.size.height/3.0)), width: self.view.frame.size.width, height: self.view.frame.size.height/3.0)
        
         infoView.frame = CGRect.init(x: 0, y: (UIScreen.main.bounds.size.width) , width: heightCalculated, height: heightValue)

        let distanceFloat = Float(dataDict["distance"] as! String)


        let distance : String = String(format:"%.0f miles away",distanceFloat!)

        infoView.lblDistance.text = dataDict["bio"] as! String
        infoView.lblDistance.textAlignment = .left
        infoView.lblUserName.text = "\(dataDict["full_name"]!)".capitalized
        print(dataDict)

        infoView.btnReject.addTarget(self, action: #selector(self.rejectRequest), for: .touchUpInside)
        infoView.btnReject.tag = index

        infoView.btnAccept.addTarget(self, action: #selector(self.acceptRequest), for: .touchUpInside)
        infoView.btnAccept.tag = index

        infoView.btnPlayPause.addTarget(self, action: #selector(self.btnPlayPauseSong(btn:)), for: .touchUpInside)
        infoView.btnPlayPause.tag = index
        infoView.btnPlayPause.isSelected = false

        let instaName  = String(format:" @%@",dataDict["full_name"] as! String )


        let category1 = dataDict["collab_with"] as! String
        let category2:[String] = category1.components(separatedBy: ",")

        if category2.count >= 2 {
            infoView.lblCategory.text = String(format : "%@ | %@",category2[0] as CVarArg,category2[1] as CVarArg)
        }
        else if category2.count == 1 {
            infoView.lblCategory.text = String(format : "%@",category2[0] as CVarArg)
        }
        else{
            infoView.lblCategory.text = ""
        }

        infoView.btnInstaName.setTitle(instaName, for: .normal)
        infoView.btnInstaName.addTarget(self, action: #selector(self.viewInstaProfile(_sender:)), for: .touchUpInside)
        view.addSubview(infoView)

        return view

    }
    func cardContainerViewNumberOfView(in index: Int) -> Int {

        return filteredData.count
    }

    func showImageOneAction(_ sender: UIButton)  {
        let dataDict = self.filteredData[sender.tag] as! Dictionary<String, Any>
        let view = container.getCurrentView() as! CardView


        view.btnImage1.backgroundColor = UIColor.black

        view.btnImage2.layer.borderWidth = 1.0
        view.btnImage2.layer.borderColor = UIColor.black.cgColor
        view.btnImage2.backgroundColor = UIColor.white

        view.btnImage3.layer.borderWidth = 1.0
        view.btnImage3.layer.borderColor = UIColor.black.cgColor
        view.btnImage3.backgroundColor = UIColor.white

        view.backgroundColor = UIColor.lightGray
        let imageUrl1 = URL.init(string: dataDict["image1"] as! String)
        view.imageView.sd_setImage(with: imageUrl1)
    }

    func showImageTwoAction(_ sender : UIButton)  {
        let dataDict = self.filteredData[sender.tag] as! Dictionary<String, Any>
        print(index)
        let view = container.getCurrentView() as! CardView
        view.backgroundColor = UIColor.lightGray

        view.btnImage2.backgroundColor = UIColor.black

        view.btnImage1.layer.borderWidth = 1.0
        view.btnImage1.layer.borderColor = UIColor.black.cgColor
        view.btnImage1.backgroundColor = UIColor.white

        view.btnImage3.layer.borderWidth = 1.0
        view.btnImage3.layer.borderColor = UIColor.black.cgColor
        view.btnImage3.backgroundColor = UIColor.white

        let imageUrl1 = URL.init(string: dataDict["image2"] as! String)
        view.imageView.sd_setImage(with: imageUrl1)
    }

    func showImageThreeAction(_ sender : UIButton)  {
        let dataDict = self.filteredData[sender.tag] as! Dictionary<String, Any>
        let view = container.getCurrentView() as! CardView
        view.backgroundColor = UIColor.lightGray

        view.btnImage1.layer.borderWidth = 1.0
        view.btnImage1.layer.backgroundColor = UIColor.black.cgColor
        view.btnImage1.backgroundColor = UIColor.white

        view.btnImage3.backgroundColor = UIColor.black

        view.btnImage2.layer.borderWidth = 1.0
        view.btnImage2.layer.backgroundColor = UIColor.black.cgColor
        view.btnImage2.backgroundColor = UIColor.white

        let imageUrl1 = URL.init(string: dataDict["profile_pic"] as! String)
        view.imageView.sd_setImage(with: imageUrl1)
    }

    //MARK:
    //MARK: YSLDraggableCardContainer Delegate

    func cardContainerView(_ cardContainerView: YSLDraggableCardContainer!, didEndDraggingAt index: Int, draggableView: UIView!, draggableDirection: YSLDraggableDirection) {

        self.btnPauseSongAction()
        
        if draggableDirection == .left {

            if isFakeProfiles == false {
                container.movePosition(with: draggableDirection, isAutomatic: false)
                self.slideleft(tag: index)
            }
            else{
                container.movePosition(with: draggableDirection, isAutomatic: false)
                if index == self.filteredData.count - 1 {
                    self.getFilteredData(distanceInt: distance)
                    isFakeProfiles = false
                }
            }

        }
        if draggableDirection == .right {
            if isFakeProfiles == false {
                let dataDict = self.filteredData[index] as! Dictionary<String, Any>
                userImage = dataDict["profile_pic"] as! String
                userName = dataDict["full_name"] as! String
                container.movePosition(with: draggableDirection, isAutomatic: false)
                self.slideRight(tag: index)
            }
            else{
                container.movePosition(with: draggableDirection, isAutomatic: false)
                if index == self.filteredData.count - 1 {
                    self.getFilteredData(distanceInt: distance)
                    isFakeProfiles = false
                }
            }
}
        if draggableDirection == .up {

        }
    }

    func cardContainderView(_ cardContainderView: YSLDraggableCardContainer!, updatePositionWithDraggableView draggableView: UIView!, draggableDirection: YSLDraggableDirection, widthRatio: CGFloat, heightRatio: CGFloat) {


    }

    func cardContainerViewDidCompleteAll(_ container: YSLDraggableCardContainer!) {
        isLastProfile = true
    }


    func programaticallyConstraints(view : UIView)  {

        view.backgroundColor = UIColor.yellow
        view.translatesAutoresizingMaskIntoConstraints = false

        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0))

        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0))

        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0))

        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant:self.view.frame.size.height - self.view.frame.size.height/3.0 - 64))

        self.view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 1.0, constant: self.view.frame.size.height/3.0))

    }
    //MARK:
    //MARK: Player Delegate methods

    func audioStream(_ audioStream :NPAudioStream , didUpdateTrackCurrentTime currentTime :CMTime)  {
        // let time =  CMTimeGetSeconds(currentTime)
        // lblDuration.text = String(format:"%.0f Seconds",time)
        // if time >= 15 {
        //audioStream.pause()
        // infoView.btnPlayPause.setImage(UIImage.init(named: "play"), for: .normal)
//        infoView.btnPlayPause.isSelected = false
//        infoView.btnPlayPause.setImage(#imageLiteral(resourceName: "play"), for: .normal)
//        audioStream.seekToTime(inSeconds: 0)
//        isPlaying = false
        print("Stop Player:\(currentTime.seconds)")
        //}
    }
    //MARK:
    //MARK: Tap gesture Action
    func showPopUpView(sender : UITapGestureRecognizer) {
        if isPlaying == true {
            audioStream.pause()
            infoView.btnPlayPause.isSelected = false
            infoView.btnPlayPause.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            audioStream.seekToTime(inSeconds: 0)
            isPlaying = false
        }
        popUpView.frame = CGRect.init(x: 0, y: ScreenSize.SCREEN_HEIGHT, width: ScreenSize.SCREEN_WIDTH, height: 176)
        let dataDict = self.filteredData[(sender.view?.tag)!] as! Dictionary<String, Any>
        lblAboutUser.text = "About \(dataDict["full_name"]!)".capitalized
        let category1 = dataDict["Industry"]
        let category2 = dataDict["Musician"]

        if category1 != nil  &&  category2 != nil{
            lblCategory.text = "\(category1!) | \(category2!)"
        }
        else if category2 != nil && category1 == nil {
            lblCategory.text = "\(category2!)"
        }
        else{
            lblCategory.text = "\(category1!)"
        }
        lblBio.text = dataDict["bio"] as! String?
        btnInstaView.tag = (sender.view?.tag)!
        btnInstaView.setTitle("@\(dataDict["full_name"]!)", for: .normal)
        btnInstaView.addTarget(self, action:#selector( self.viewInstaProfilePopUp(_sender : )), for: .touchUpInside)
        btnPlaySongPopUpView.addTarget(self, action: #selector(self.btnPlayPauseSong(btn:)), for: .touchUpInside)
        btnPlaySongPopUpView.tag = (sender.view?.tag)!
        btnPlaySongPopUpView.isSelected = false
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: {
            self.popUpView.isHidden = false
            self.popUpView.frame = CGRect.init(x: 0, y: ScreenSize.SCREEN_HEIGHT - 176, width: ScreenSize.SCREEN_WIDTH, height: 176)
        }, completion: { (finished: Bool) in
        })
    }

    //MARK:
    //MARK: popUpViewActions

    @IBAction func dismissPopUpViewAction(_ sender: Any) {
        if isPlaying == true {
            audioStream.pause()
            btnPlaySongPopUpView.isSelected = false
            btnPlaySongPopUpView.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            audioStream.seekToTime(inSeconds: 0)
            isPlaying = false
        }
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: {

            self.popUpView.frame = CGRect.init(x: 0, y: ScreenSize.SCREEN_HEIGHT, width: ScreenSize.SCREEN_WIDTH, height: self.popUpView.frame.size.height)
        }, completion: { (finished: Bool) in
            self.popUpView.isHidden = true
        })
    }

    //MARK:
    //MARK: Start Chat Methods

    @IBAction func goToChatControllerAction(_ sender: Any) {
        self.btnPauseSongAction()
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ChatController") as! ChatController
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    
    func setStartChatView()  {

        ivMe.layer.cornerRadius = ivMe.frame.size.height/2.0
        ivFriend.layer.cornerRadius = ivMe.frame.size.height/2.0

        ivMe.layer.borderWidth = 2.0
        ivFriend.layer.borderWidth = 2.0

        ivMe.layer.borderColor = UIColor.white.cgColor
        ivFriend.layer.borderColor = UIColor.white.cgColor

        ivMe.sd_setImage(with: URL.init(string: UserDefaults.SFSDefault(valueForKey: "profile_pic") as! String), placeholderImage: #imageLiteral(resourceName: "placeholder_user"))
        ivFriend.sd_setImage(with: URL.init(string: userImage), placeholderImage: #imageLiteral(resourceName: "placeholder_user"))
        lblShouldCollab.text = "You and \(userName) should collab."
        viewStartChat.isHidden = false
    }

    //MARK:
    //MARK: start chat view actions
    @IBAction func startChatAction(_ sender: Any) {
        self.getChatHistory(chatID: userChatID)
        viewStartChat.isHidden = true

    }
    @IBAction func keepSurfingAction(_ sender: Any) {
        viewStartChat.isHidden = true
        if isLastProfile == true {
            if distance < 10000 {
                distance = distance + 300
                self.getFilteredData(distanceInt: distance)
            }
            else{
                self.viewCanAgain.isHidden = false
            }

        }
        else{
            self.getFilteredData(distanceInt:distance )
        }
    }
    func viewInstaProfilePopUp(_sender :UIButton)  {
        let dataDict = self.filteredData[_sender.tag] as! Dictionary<String, Any>
        if let url = URL(string: dataDict["instagram_profile_link"] as! String) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                UIApplication.shared.openURL(url as URL)
            }
        }
    }


    //MARK :
    //MARK : get chat history
    func getChatHistory(chatID : String)  {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let refChild = ref.child("ChatHistory")
        let userid = refChild.child(chatID)

        userid.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in

            if snapshot.value is NSNull{

            }
            else{
                let userID = UserDefaults.SFSDefault(valueForKey: "user_id") as! String
                var chatData = snapshot.value as? [String : AnyObject] ?? [:]
                print(chatData)
                let senderID : String = chatData["sender"] as? String ?? ""
                let receiverID : String = chatData["receiver"] as? String ?? ""
                if senderID == userID || receiverID == userID {

                    let objChat = Chat()
                    objChat.chatID = chatID as NSString
                    let objMessage = Message()
                    objMessage.text = chatData["last_message"] as! String
                    objChat.lastMessage = objMessage

                    if receiverID == userID {
                        objChat.friendID = senderID as NSString
                    }
                    else {
                        objChat.friendID =  receiverID as NSString
                    }

                    let unreadMsg = chatData["unread_message"] as? Array ?? []
                    let frndInfo = unreadMsg[1] as? [String:Any] ?? [:]
                    let myInfo  = unreadMsg[0]as? [String:Any] ?? [:]
                    objChat.favourite = Int((chatData["favourite"] as? String)!)!
                    if userID == frndInfo["userId"] as! String {
                        let msgCounts = (myInfo["unreadMsg"]) as! String
                        objChat.numberOfUnreadMessages =   Int(msgCounts)!

                    }else{
                        objChat.numberOfUnreadMessages = Int((frndInfo["unreadMsg"] as? String)!)!
                    }
                    let time  = chatData["timestamp"]
                    let userName = chatData["receiver_name"]

                    objChat.timeFirStamp = time as! Int

                    let message = Message()
                    message.text = chatData["last_message"] as! String
                    message.chatId = chatID
                    let objContact = Contact()
                    objContact.identifier = chatID
                    objChat.contact = objContact
                    objChat.contact.name = userName as! String
                    objChat.contact.profileImage = self.userImage
                    objChat.friendName = userName as! NSString
                    objChat.friendImage = self.userImage as NSString

                    DispatchQueue.main.async {
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "messageController") as! MessageController
                        controller.chat = objChat
                        controller.image = self.ivFriend.image!
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }
        }
        )
    }

    //MARK: No Internet delegate method

    func reloadPageAction() {
        noInternetView.removeFromSuperview()
        self.getFilteredData(distanceInt: distance)
    }



    func getFirendInfo(_ chatID:String, friendID:String)  {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let refChild = ref.child("users")
        let users = refChild.child(friendID)
        users.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if snapshot.value != nil{
                print(snapshot.value!)
                let user = snapshot.value as? [String : Any] ?? [:]
                if let playerID = user["player_id"] {
                    self.fireOneSignalNotification(playerId:playerID as! String, ChatId: chatID,frndId:friendID)
                }
                
            }
        })
    }
    
    func fireOneSignalNotification(playerId:String, ChatId:String, frndId:String)  {
        
        let content = ["reciever":frndId,"player_id":playerId,"senderId":UserDefaults.SFSDefault(valueForKey: "user_id"),"senderName":UserDefaults.SFSDefault(valueForKey: "full_name"),"senderPic":UserDefaults.SFSDefault(valueForKey: "profile_pic"),"chatId":ChatId,"messsage":""]
        
        let parameter = ["contents": ["en": "Add as A friend"], "include_player_ids":[playerId],"ios_badgeType":"Increase","ios_badgeCount":"1","data":content] as [String : Any];
        OneSignal.postNotification(parameter, onSuccess: { result in
            print("result = \(result!)")
        }, onFailure: {error in
            print("error = \(error!)")
        })
    }
    
    // MARK: get friends count
    func getFriends() {
        
        let para: Dictionary = ["user_id":UserDefaults.SFSDefault(valueForKey: "user_id")]
        ServerManager.sharedInstance.httpPost(String(format:"%@get_friends",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
            
            var jsonResult = response as! Dictionary<String, Any>
            
            print(jsonResult)
            
            OperationQueue.main.addOperation {
                //
                if jsonResult["success"] as! NSNumber == 1{
                    UserDefaults.standard.set(true, forKey: "friends_count")
                    UserDefaults.standard.synchronize()
                     self.btnChat.isHidden = false
                }
                else{
                    UserDefaults.standard.set(false, forKey: "friends_count")
                    UserDefaults.standard.synchronize()
                     self.btnChat.isHidden = true
                }
                //
            }
        }) { (error) in
            AppManager.sharedInstance.hidHud()
            if AppManager.isInternetError(error) == true  {
                
                
            }
            else{
               
            }
        }
    }
    
}
