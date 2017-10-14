//
//  MenuVC.swift
//  Collab
//
//  Created by SFS04 on 4/24/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit
import Firebase

class MenuVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var tblMenu: UITableView!
    var selectedMenuItem : Int = 0
    var arrayImages = ["Home","Me","My Chat","Collab with","Settings","Invite Friends","Logout"]
    var arraySelectedImage = ["Home1","Me1","My Chat1","Collab with1","Settings1","Invite Friends1","Logout1"]
    @IBOutlet var ivUserImage: UIImageView!
    @IBOutlet var lblUserFullName: UILabel!    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblMenu.dataSource = self
        tblMenu.delegate = self
        
        self.navigationController?.navigationBar.isHidden = true
        var name = UserDefaults.SFSDefault(valueForKey:  "full_name") as! String
        
        name = name.capitalized
        lblUserFullName.text = name

//        let url = URL.init(string: userInfo["profile_pic"] as! String)
//        ivUserImage.sd_setImage(with: url)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let imageUrl = URL.init(string: UserDefaults.SFSDefault(valueForKey:  "profile_pic") as! String)
        if imageUrl != nil {
            ivUserImage.sd_setImage(with: imageUrl!)
        }
        else{
            ivUserImage.image = #imageLiteral(resourceName: "placeholder_user")
        }

        ivUserImage.sd_setImage(with: imageUrl!)
        ivUserImage.layer.cornerRadius = ivUserImage.frame.size.height / 2.0
        ivUserImage.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.upadteImage), name: NSNotification.Name(rawValue: "updateProfilePic"), object: nil)
        
         arrayImages = ["Home","Me","My Chat","Collab with","Settings","Invite Friends","Logout"]
         arraySelectedImage = ["Home1","Me1","My Chat1","Collab with1","Settings1","Invite Friends1","Logout1"]
        
        
        self.tblMenu.reloadData()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func upadteImage() {
        let imageUrl = URL.init(string: UserDefaults.SFSDefault(valueForKey:  "profile_pic") as! String)
        if imageUrl != nil {
            ivUserImage.sd_setImage(with: imageUrl!)
        }
        else{
            ivUserImage.image = #imageLiteral(resourceName: "placeholder_user")
        }
        
        ivUserImage.sd_setImage(with: imageUrl!)
        ivUserImage.layer.cornerRadius = ivUserImage.frame.size.height / 2.0
        ivUserImage.clipsToBounds = true
    }
    // MARK:
    // MARK: - Webservices Methods
    
    func logOut()  {
        AppManager.sharedInstance.showHud(showInView: self.view, label: "")
        let para: Dictionary = ["user_id":UserDefaults.SFSDefault(valueForKey: "user_id")]
        ServerManager.sharedInstance.httpPost(String(format:"%@logout",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
            AppManager.sharedInstance.hidHud()
            var jsonResult = response as! Dictionary<String, Any>
            AppManager.sharedInstance.hidHud()
            print(jsonResult)
            if jsonResult["success"] as! NSNumber == 1{
                self.registerUserOnFirebase( )
                UserDefaults.SFSDefault(setBool: false, forKey: "isLogin")
                let loginVc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                let navigationController : UINavigationController = UINavigationController.init(rootViewController: loginVc)
                AppDelegate.sharedDelegate.window?.rootViewController = navigationController
            }
            else{
                AppManager.showMessageView(view: self.view, meassage: jsonResult["error_message"] as! String)
            }
        }) { (error) in
            AppManager.sharedInstance.hidHud()
            AppManager.showMessageView(view: self.view, meassage: error.description)
        }

    }


    func registerUserOnFirebase( ) {

        var ref: DatabaseReference!
        ref = Database.database().reference()
        let refChild = ref.child("users")
        let chatID = refChild.child(UserDefaults.SFSDefault(valueForKey: "user_id") as! String)
        var dataDict : Dictionary<String, Any>

            dataDict = ["player_id":""]
            chatID.updateChildValues(dataDict) { (error, ref) in

            if error != nil{
                print("error in insertion")
            }
            else{

            }
        }
    }

    // MARK:
    // MARK: - Table view data source
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arraySelectedImage.count
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "sideMenuCell"
        let cell = tblMenu.dequeueReusableCell(withIdentifier: identifier) as! SideMenuCell
    
        cell.selectionStyle = .none
        cell.lblMenu.text = arrayImages[indexPath.row]
        cell.ivIcon.image = UIImage.init(named: arrayImages[indexPath.row])
        
        return cell
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50.0
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            let cell = tblMenu.cellForRow(at: indexPath) as! SideMenuCell
            cell.lblMenu.textColor = GOLDEN_COLOR
            cell.ivIcon.image = UIImage.init(named: arraySelectedImage[indexPath.row])
            switch (indexPath.row) {
            case 0:
                let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                let navigationController = UINavigationController.init(rootViewController: homeVC)
                self.menuContainerViewController.centerViewController = navigationController
                self.menuContainerViewController.menuState = MFSideMenuStateClosed;
                break
            case 1:
                let meVC = self.storyboard?.instantiateViewController(withIdentifier: "MeVC") as! MeVC
                let navigationController = UINavigationController.init(rootViewController: meVC)
                self.menuContainerViewController.centerViewController = navigationController
                meVC.outSideController = "no"
                self.menuContainerViewController.menuState = MFSideMenuStateClosed;
                break
            case 2:
                let myChatVc = self.storyboard?.instantiateViewController(withIdentifier: "ChatController") as! ChatController
                let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                let navigationController = UINavigationController.init(rootViewController: homeVC)
                self.menuContainerViewController.centerViewController = navigationController
                navigationController.pushViewController(myChatVc, animated: true)
                self.menuContainerViewController.menuState = MFSideMenuStateClosed;
                break
            case 3:
                let collabWithVC = self.storyboard?.instantiateViewController(withIdentifier: "CollabWithVC") as! CollabWithVC
                let navigationController = UINavigationController.init(rootViewController: collabWithVC)
                self.menuContainerViewController.centerViewController = navigationController
                
                self.menuContainerViewController.menuState = MFSideMenuStateClosed;
                break
            case 4:
                let catagoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CatagoryVC") as! CatagoryVC
                catagoryVC.isInternalController = "no"
                let navigationController = UINavigationController.init(rootViewController: catagoryVC)
                self.menuContainerViewController.centerViewController = navigationController
                
                
                self.menuContainerViewController.menuState = MFSideMenuStateClosed;
                break
            case 5:
                let inviteFriendsVC = self.storyboard?.instantiateViewController(withIdentifier: "InviteFriendsVC") as! InviteFriendsVC
                inviteFriendsVC.isPopUp = "no"
                let navigationController = UINavigationController.init(rootViewController: inviteFriendsVC)
                self.menuContainerViewController.centerViewController = navigationController
                self.menuContainerViewController.menuState = MFSideMenuStateClosed;
                break
                
            case 6:
                self.menuContainerViewController.menuState = MFSideMenuStateClosed;
                let alert = UIAlertController(title: "Collab", message: "Are you sure you want to log out?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Logout", style: .default) { action in
                    self.logOut()
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                })
                
                self.present(alert, animated: true, completion: nil)
                
                break
            default:
                let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                let navigationController = UINavigationController.init(rootViewController: homeVC)
                self.menuContainerViewController.centerViewController = navigationController
                self.menuContainerViewController.menuState = MFSideMenuStateClosed;
                break
            }
        
}
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        let cell = tblMenu.cellForRow(at: indexPath) as! SideMenuCell
        
        cell.lblMenu.textColor = UIColor.white
        cell.ivIcon.image = UIImage.init(named: arrayImages[indexPath.row])
    }
}
