//
//  InviteFriendsVC.swift
//  Collab
//
//  Created by SFS04 on 4/24/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import MessageUI

class InviteFriendsVC: UIViewController,FBSDKAppInviteDialogDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate {
    @IBOutlet weak var sideMenuBtn: UIButton!
    var isPopUp = String()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        if isPopUp == "yes" {
            sideMenuBtn.setImage(#imageLiteral(resourceName: "left-arrow"), for: .normal)
            sideMenuBtn.addTarget(self, action: #selector(self.backBtn(_ :)), for: .touchUpInside)
        }
        else{
            sideMenuBtn.setImage(#imageLiteral(resourceName: "side_menu"), for: .normal)
            sideMenuBtn.addTarget(self, action: #selector(self.sideMenuBtn(_ :)), for: .touchUpInside)

        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:
    //MARK: Custom Button Actions

    func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }

    func sideMenuBtn(_ sender: Any) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion {
        }
    }
    @IBAction func inviteFbAction(_ sender: Any) {
        print("Invite button tapped")

        let inviteDialog:FBSDKAppInviteDialog = FBSDKAppInviteDialog()
        if(inviteDialog.canShow()){

            let appLinkUrl:NSURL = NSURL(string: "https://itunes.apple.com/app/id1227430521")!
            let previewImageUrl:NSURL = NSURL(string: "http://sunfocussolutions.com/collab/assets/uploads/Icon-App.png")!

            let inviteContent:FBSDKAppInviteContent = FBSDKAppInviteContent()
            inviteContent.appLinkURL = appLinkUrl as URL!
            inviteContent.appInvitePreviewImageURL = previewImageUrl as URL!
            //            inviteContent.promotionText = "I would like to invite you on collab."

            inviteDialog.content = inviteContent
            inviteDialog.delegate = self
            inviteDialog.show()
        }
    }
    @IBAction func inviteWhatsAppAction(_ sender: Any) {
        let urlString : String = "I would like to invite you on collab. Link :https://itunes.apple.com/app/id1227430521"
        let urlStringEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let url  = NSURL(string: "whatsapp://send?text=\(urlStringEncoded!)")

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url! as URL, options: [:])
        } else {
            UIApplication.shared.openURL(url! as URL)
        }
    }
    @IBAction func inviteEmailAction(_ sender: Any) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail()
        {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
        else
        {
            self.showSendMailErrorAlert()
        }
    }
    @IBAction func inviteMessageAction(_ sender: Any) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "I would like to invite you on collab. Link :https://itunes.apple.com/app/id1227430521"
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    //MARK:
    //MARK: Mail Invites Delegates
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setSubject("Join me on Collab!")
        mailComposerVC.setMessageBody("I would like to invite you on collab. Link :https://itunes.apple.com/app/id1227430521", isHTML: false)
        return mailComposerVC
    }
    func showSendMailErrorAlert(){
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }

    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    //MARK:
    //MARK: FBApp Invites Delegates

    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!){
        if results != nil {
            let resultObject = results as Dictionary

            if let didCancel = resultObject["completionGesture"]
            {
                if (didCancel as AnyObject).caseInsensitiveCompare("Cancel") == ComparisonResult.orderedSame
                {
                    print("User Canceled invitation dialog")
                }
            }
        }
    }

    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        print("Error tool place in appInviteDialog \(error)")
    }
    
}
