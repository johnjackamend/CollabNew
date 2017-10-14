//
//  CollabVC.swift
//  Collab
//
//  Created by Apple01 on 4/13/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit

class CollabVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var sideMenuView: UIView!
    @IBOutlet weak var tblSideMenu: UITableView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var closeMenuBtn: UIButton!
    @IBOutlet weak var ivUserImage: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!



    var arrayMenu = ["Home","Me","My Chat","Collab with","Settings","Invite Friends"]
    var arrayIconUnselected = ["Home","Me","My Chat","Collab with","Settings","Invite Friends"]
    var arrayIconSelected = ["Home1","Me1","My Chat1","Collab with1","Settings1","Invite Friends1"]
    
    var userData = UserDefaults.SFSDefault(valueForKey: "userInfo") as! Dictionary<String , Any>


    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if UserDefaults.standard.bool(forKey: "friends_count"){
            arrayMenu = ["Home","Me","My Chat","Collab with","Settings","Invite Friends"]
            arrayIconUnselected = ["Home","Me","My Chat","Collab with","Settings","Invite Friends"]
            arrayIconSelected = ["Home1","Me1","My Chat1","Collab with1","Settings1","Invite Friends1"]
        }else{
            arrayMenu = ["Home","Me","Collab with","Settings","Invite Friends"]
            arrayIconUnselected = ["Home","Me","Collab with","Settings","Invite Friends"]
            arrayIconSelected = ["Home1","Me1","Collab with1","Settings1","Invite Friends1"]
        }
        
        self.tblSideMenu.reloadData()


//        print(userData)
//        sideMenuView.frame = self.view.frame
//        sideMenuView.isHidden = true
//        self.lblUserName.text = userData["full_name"] as! String?
//       // self.ivUserImage.sd_setImage(with:  URL(string: userData["profile_pic"] as! String), placeholderImage: UIImage.init(named: "single-women-voting"))
//        self.ivUserImage.layer.borderWidth = 2.0
//        self.ivUserImage.layer.borderColor = UIColor.init(ColorRGB: 74.0/255.0, Grean: 73.0/255.0, Blue: 73.0/255.0).cgColor
//        self.sideMenuView.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
//
//        self.view .addSubview(sideMenuView)
//        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.bool(forKey: "friends_count"){
             arrayMenu = ["Home","Me","My Chat","Collab with","Settings","Invite Friends"]
             arrayIconUnselected = ["Home","Me","My Chat","Collab with","Settings","Invite Friends"]
             arrayIconSelected = ["Home1","Me1","My Chat1","Collab with1","Settings1","Invite Friends1"]
        }else{
             arrayMenu = ["Home","Me","Collab with","Settings","Invite Friends"]
             arrayIconUnselected = ["Home","Me","Collab with","Settings","Invite Friends"]
             arrayIconSelected = ["Home1","Me1","Collab with1","Settings1","Invite Friends1"]
        }
        
        self.tblSideMenu.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        ivUserImage.layer.cornerRadius = ivUserImage.frame.size.height/2.0
        ivUserImage.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: ButtonActions
    @IBAction func openSideMenuAction(_ sender: Any) {
        sideMenuView.isHidden = false

        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.baseView.frame = CGRect(x: UIScreen.main.bounds.size.width-self.closeMenuBtn.frame.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
            self.sideMenuView.frame = CGRect(x:0, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
            self.sideMenuView.layoutIfNeeded()
            self.baseView.layoutIfNeeded()
        }, completion: { (finished) -> Void in

        })
    }

    @IBAction func closeSideMenu(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.baseView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
            self.baseView.layoutIfNeeded()
            self.sideMenuView.frame = CGRect(x: -UIScreen.main.bounds.size.width-self.closeMenuBtn.frame.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
            self.sideMenuView.layoutIfNeeded()
            // self.baseView.backgroundColor = UIColor.clear
        }, completion: { (finished) -> Void in
            self.sideMenuView.isHidden = true

        })
    }
    //MARK:
    //MARK: UITableView Datasource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMenu.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as! SideMenuCell

        cell.lblMenu.text = arrayMenu[indexPath.row ] as String
        cell.lblMenu.textColor = UIColor.white
        cell.ivIcon.image = UIImage.init(named: arrayIconUnselected[indexPath.row])
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = backgroundView
        return cell
    }

    //MARK:
    //MARK: UITableView Delegate Methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tblSideMenu.cellForRow(at: indexPath) as! SideMenuCell
        cell.lblMenu.textColor = GOLDEN_COLOR
        cell.ivIcon.image = UIImage.init(named: arrayIconSelected[indexPath.row])

    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        let cell = tblSideMenu.cellForRow(at: indexPath) as! SideMenuCell

        cell.lblMenu.textColor = UIColor.white
        cell.ivIcon.image = UIImage.init(named: arrayIconUnselected[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0;
    }
    
}
 
