//
//  BlockVC.swift
//  Collab
//
//  Created by Apple01 on 5/11/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit
import Firebase

class BlockVC: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var ivUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var btnUnMatch: UIButton!
    @IBOutlet weak var btnBlock: UIButton!

    var chatID = String()
    var friendID = String()

    var userName = String()
    var image = UIImage()


    // MARK: - UiView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true
        ivUser.image = image
        ivUser.layer.cornerRadius = ivUser.frame.size.height / 2.0
        ivUser.clipsToBounds = true
        btnUnMatch.setTitle("Unmatch with \(userName)", for: .normal)
        btnBlock.setTitle("Block & Report \(userName)", for: .normal)
        lblUserName.text = userName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

     // MARK: - Custom Button Actions
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func unMatchBtnAction(_ sender: Any) {
        AppManager.sharedInstance.showHud(showInView: self.view, label: "")
        let para = ["user_id": UserDefaults.SFSDefault(valueForKey: USER_ID),"unfriend_user_id":friendID]
        ServerManager.sharedInstance.httpPost(String(format:"%@unfriend_user",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
            AppManager.sharedInstance.hidHud()
            var jsonResult = response as! Dictionary<String, Any>
            print(jsonResult)
            if jsonResult["success"] as! NSNumber == 1{
                var ref: DatabaseReference!
                ref = Database.database().reference()
                let refChild = ref.child("ChatHistory")
                let chatId = refChild.child(self.chatID)
                chatId.removeValue()
                AppManager.showMessageView(view: self.view, meassage: "User Unmatched" )

                }
                else{
                    AppManager.showMessageView(view: self.view, meassage: jsonResult["error_message"] as! String)
                }
        }) { (error) in
            AppManager.sharedInstance.hidHud()
            AppManager.showMessageView(view: self.view, meassage: error.description)
        }
    }

    @IBAction func btnReportAction(_ sender: Any) {

        AppManager.sharedInstance.showHud(showInView: self.view, label: "")
        let para = ["user_id": UserDefaults.SFSDefault(valueForKey: "user_id"),
                    "friend_id":friendID,
                    "request_status":"0"]
        ServerManager.sharedInstance.httpPost(String(format:"%@accept_deny_friendrequest",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
            AppManager.sharedInstance.hidHud()
            var jsonResult = response as! Dictionary<String, Any>
            print(jsonResult)
            if jsonResult["success"] as! NSNumber == 1{
                var ref: DatabaseReference!
                ref = Database.database().reference()
                let refChild = ref.child("ChatHistory")
                let chatId = refChild.child(self.chatID)
                chatId.removeValue()
                AppManager.showMessageView(view: self.view, meassage: "User Reported!")

            }
            else{
                AppManager.showMessageView(view: self.view, meassage: jsonResult["error_message"] as! String)
            }
        }) { (error) in
            AppManager.sharedInstance.hidHud()
            AppManager.showMessageView(view: self.view, meassage: error.description )
        }

    }

}
