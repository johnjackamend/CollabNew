//
//  CatagoryVC.swift
//  Collab
//
//  Created by Apple01 on 4/13/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit
import Firebase

class CatagoryVC: UIViewController {

    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBOutlet weak var lblChoose: UILabel!
    @IBOutlet weak var lblWhat: UILabel!
    @IBOutlet weak var tblCat: UITableView!
    @IBOutlet weak var lblNotifications: UILabel!
    @IBOutlet weak var outletSwitch: UISwitch!
    @IBOutlet weak var outletNextBtn: UIButton!
    @IBOutlet weak var outletSideMenuBtn: UIButton!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var btnTerms: UIButton!
    @IBOutlet var outletBtnNext: UIButton!
    @IBOutlet weak var viewTopContsraint: NSLayoutConstraint!
    let arrayCatagory: [String] = ["Musician","Model","Video","Acting","Photography", "Producer", "Visual artist", "Writer","Performer","Management","Dancer","GFX desginer"]
    
    let arrayCatagoryServer = NSMutableArray()
    
    let parameters = NSMutableDictionary()
    let arrayMusician = NSMutableArray()
    let arrayIndustry = NSMutableArray()
    var index1 = NSIndexPath()
    var index2 = NSIndexPath()
    var isInternalController = NSString()
    
    var hideDeleteButton = false

    @IBOutlet var lblChooseMax: UILabel!
    @IBOutlet weak var navView: UIView!

    @IBOutlet weak var btnDelete: UIButton!

    //MARK:
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(UIDevice.current.localizedModel)
        if DeviceType.IS_IPHONE_5 {
        }
        else{
            lblWhat.adjustsFontSizeToFitWidth = true
            lblChoose.adjustsFontSizeToFitWidth = true
        }

        self.navigationController?.navigationBar.isHidden = true
        if UserDefaults.SFSDefault(boolForKey: "isNotificationOff") == true{
            outletSwitch.isOn = false
        }
        else{
            outletSwitch.isOn = true
        }
        if isInternalController == "yes" {
            TYPE_CONTROLLER = controllerType.internalController
            btnDelete.isHidden = true
        }
        else{
            btnDelete.isHidden = false
            TYPE_CONTROLLER = controllerType.externalController
        }
        
        
        
        print("height-Content:\(mainScrollView.contentSize.height)")
        print("height-Scroll:\(mainScrollView.frame.size.height)")
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if TYPE_CONTROLLER == controllerType.internalController {
            outletBtnNext.setTitle("Next", for: .normal)
            outletBtnNext.addTarget(self, action: #selector(self.nextAction(_:)), for: .touchUpInside)
            lblNotifications.isHidden = true
            outletSwitch.isHidden = true
            viewTopContsraint.constant = -25

            self.view.updateConstraints()
            outletSideMenuBtn.isHidden = true
            btnTerms.isHidden = false
            navView.isHidden = true
            mainScrollView.alwaysBounceVertical = false
            mainScrollView.contentSize = CGSize.init(width: UIScreen.main.bounds.size.width, height: 0)
            
        }
        else{
            self.getUserSettings()
            navView.isHidden = false

            outletBtnNext.setTitle("Save", for: .normal)
            outletBtnNext.addTarget(self, action: #selector(self.nextAction(_:)), for: .touchUpInside)
            lblNotifications.isHidden = false
            outletSwitch.isHidden = false
            //viewBottomConstraint.constant =  viewBottomConstraint.constant - 25
            //self.view.updateConstraints()
            outletSideMenuBtn.isHidden = false
            btnTerms.isHidden = true
            
            mainScrollView.contentSize = CGSize.init(width: UIScreen.main.bounds.size.width, height: 800)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if TYPE_CONTROLLER == controllerType.internalController {
            mainScrollView.alwaysBounceVertical = false
            mainScrollView.contentSize = CGSize.init(width: UIScreen.main.bounds.size.width, height: 0)
        }
        else{
            
            mainScrollView.contentSize = CGSize.init(width: UIScreen.main.bounds.size.width, height: 700)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:
    //MARK: UITableView Datasource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCatagory.count/2
    }

    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catagoryCell", for: indexPath) as! CatagoryCell

        cell.lblCat1.text = arrayCatagory[indexPath.row * 2] as String
        cell.lblCat2.text = arrayCatagory[indexPath.row * 2 + 1] as String

//        cell.lblCat1.calculateFontSizeAccordingToWidth(labelFrame: cell.lblCat1.frame)
//        cell.lblCat2.calculateFontSizeAccordingToWidth(labelFrame: cell.lblCat2.frame)

        cell.btnCat1.addTarget(self, action: #selector(self.addToIndustryAction(_ :)), for: .touchUpInside)
        cell.btnCat2.addTarget(self, action: #selector(self.addToMusicianAction(_ :)), for: .touchUpInside)

        cell.btnCat1.setImage(UIImage.init(named: "radio_unsel"), for: .normal)
        cell.btnCat2.setImage(UIImage.init(named: "radio_unsel"), for: .normal)
        
        cell.btnCat1.isSelected = false
        cell.btnCat2.isSelected = false
        
        
        
        let stringValueLocal = cell.lblCat1.text!
        let stringValueLocal2 = cell.lblCat2.text!
        
        for selectedIndustry in arrayCatagoryServer {
            
           let selectedIndustryLocal = selectedIndustry as! String
            
            if stringValueLocal == selectedIndustryLocal  {
                cell.btnCat1.setImage(UIImage.init(named: "radio_sel"), for: .normal)
                cell.btnCat1.isSelected = true
            }
            
            if stringValueLocal2 == selectedIndustryLocal  {
                cell.btnCat2.setImage(UIImage.init(named: "radio_sel"), for: .normal)
                cell.btnCat2.isSelected = true
            }
        }
        

        /*
        if arrayCatagoryServer.count > (indexPath.row * 2) {
            let stringValueServer = arrayCatagoryServer[indexPath.row * 2] as! String
            
            var stringValueServer2 = ""
            if arrayCatagoryServer.count > ((indexPath.row * 2)+1) {
              stringValueServer2 = arrayCatagoryServer[indexPath.row * 2+1] as! String
            }
        
            if stringValueLocal == stringValueServer  {
                cell.btnCat1.setImage(UIImage.init(named: "radio_sel"), for: .normal)
                cell.btnCat1.isSelected = true
            }else{
                cell.btnCat1.setImage(UIImage.init(named: "radio_unsel"), for: .normal)
                cell.btnCat1.isSelected = false
                if stringValueLocal2 == stringValueServer {
                    cell.btnCat2.setImage(UIImage.init(named: "radio_sel"), for: .normal)
                    cell.btnCat2.isSelected = true
                }else{
                    cell.btnCat2.setImage(UIImage.init(named: "radio_unsel"), for: .normal)
                    cell.btnCat2.isSelected = false
                }
            }
            //match two option
            if stringValueLocal == stringValueServer2  {
                cell.btnCat1.setImage(UIImage.init(named: "radio_sel"), for: .normal)
                cell.btnCat1.isSelected = true
            }else{
                cell.btnCat1.setImage(UIImage.init(named: "radio_unsel"), for: .normal)
                cell.btnCat1.isSelected = false
                if stringValueLocal2 == stringValueServer2 {
                    cell.btnCat2.setImage(UIImage.init(named: "radio_sel"), for: .normal)
                    cell.btnCat2.isSelected = true
                }else{
                    cell.btnCat2.setImage(UIImage.init(named: "radio_unsel"), for: .normal)
                    cell.btnCat2.isSelected = false
                }
            }
 
            
        } */
      
        cell.btnCat1.tag = indexPath.row * 2 + 1
        cell.btnCat2.tag = indexPath.row * 2 + 2
        
        


        return cell

    }

    //MARK:
    //MARK: UITableView Delegate Methods

    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {


    }
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
//        if DeviceType.IS_IPHONE_5 {
//            return 44.0
//        }
//        else{
//            return 60.0
//        }
        return 60.0
        
    }

    //MARK:
    //MARK: Webservices Methods
    func getUserSettings()  {
        AppManager.sharedInstance.showHud(showInView: self.view, label: "")
        let para = ["user_id": UserDefaults.SFSDefault(valueForKey: USER_ID)]

        ServerManager.sharedInstance.httpPost(String(format:"%@get_user_settings",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
            AppManager.sharedInstance.hidHud()
            var jsonResult = response as! Dictionary<String, Any>
            print(jsonResult)
            if jsonResult["success"] as! NSNumber == 1{
                let dict = jsonResult["data"]  as! Dictionary<String, Any>

                if dict["music_industry"] != nil{
                    
                    let stringMusic = dict["collab_with"] as! String
                    
                    let stringArray:[String] = stringMusic.components(separatedBy: ",")
                    
                    self.arrayCatagoryServer.addObjects(from: stringArray)
                    
                    /*
                    
                    let index1 = self.arrayCatagory.index(of: dict["Industry"] as! String)
                    let indexPath1:NSIndexPath = IndexPath(row: index1! / 2, section: 0) as NSIndexPath
                    let cell1 = self.tblCat.cellForRow(at: indexPath1 as IndexPath) as! CatagoryCell

                    cell1.btnCat1.setImage(#imageLiteral(resourceName: "radio_sel"), for: .normal)
                    cell1.btnCat1.isSelected = true
                    self.arrayIndustry.add(dict["Industry"]!)
                    self.arrayMusician.add(dict["Musician"]!)

                    let index2 = self.arrayCatagory.index(of: dict["Musician"] as! String)
                    let indexPath2 = IndexPath(row: (index2! - 1) / 2, section: 0)
                    let cell2 = self.tblCat.cellForRow(at: indexPath2 as IndexPath) as! CatagoryCell

                    cell2.btnCat2.setImage(#imageLiteral(resourceName: "radio_sel"), for: .normal)
                    cell2.btnCat2.isSelected = true
                */
                    
                    self.tblCat.reloadData()

                }
//                else if dict["Industry"] != nil{
//                    self.arrayIndustry.add(dict["Industry"]!)
//                    let index1 = self.arrayCatagory.index(of: dict["Industry"] as! String)
//                    let indexPath1 = IndexPath(row: index1! / 2 , section: 0)
//                    let cell1 = self.tblCat.cellForRow(at: indexPath1 as IndexPath) as! CatagoryCell
//
//                    cell1.btnCat1.setImage(#imageLiteral(resourceName: "radio_sel"), for: .normal)
//                    cell1.btnCat1.isSelected = true
//
//                }
//                else{
//                    self.arrayMusician.add(dict["Musician"]!)
//                    let index2 = self.arrayCatagory.index(of: dict["Musician"] as! String)
//                    let indexPath2 = IndexPath(row:(index2! - 1) / 2 , section: 0)
//                    let cell2 = self.tblCat.cellForRow(at: indexPath2 as IndexPath) as! CatagoryCell
//
//                    cell2.btnCat2.setImage(#imageLiteral(resourceName: "radio_sel"), for: .normal)
//                    cell2.btnCat2.isSelected = true
//
//                }
            }
        }) { (error) in
            AppManager.sharedInstance.hidHud()
            AppManager.showMessageView(view: self.view, meassage: error.description)
        }

    }

    func addIndustyOfUser(industry:String, type: String)  {
        AppManager.sharedInstance.showHud(showInView: self.view, label: "")
        let para = ["user_id": UserDefaults.SFSDefault(valueForKey: USER_ID),"industry_name":industry]
    
        ServerManager.sharedInstance.httpPost(String(format:"%@add_industry",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
            AppManager.sharedInstance.hidHud()
            var jsonResult = response as! Dictionary<String, Any>
            print(jsonResult)
            if jsonResult["success"] as! NSNumber == 1{
                if TYPE_CONTROLLER == controllerType.internalController {
                    let meVC = self.storyboard?.instantiateViewController(withIdentifier: "MeVC") as! MeVC
                    meVC.outSideController = "yes"
                    self.navigationController?.pushViewController(meVC, animated: true)
                }
                else{
                    AppManager.showMessageView(view: self.view, meassage: jsonResult["success_message"] as! String)
                }
            }
        }) { (error) in
            AppManager.sharedInstance.hidHud()
            AppManager.showMessageView(view: self.view, meassage: error.description)
        }

    }

    func updateUserDataOnFirebase(playerId:String) {
        let ref : DatabaseReference!
        ref = Database.database().reference()
        let refChild = ref.child("users")
        let refChatID = refChild.child(UserDefaults.SFSDefault(valueForKey: "user_id") as! String )

        var profilePic = Dictionary<String, String>()
        profilePic["player_id"] = playerId
        refChatID.updateChildValues(profilePic)

    }

    //MARK:
    //MARK: Button tap Actions

    @IBAction func switchAction(_ sender: Any) {
        if UserDefaults.SFSDefault(boolForKey: "isNotificationOff") == true{
            self.updateUserDataOnFirebase(playerId: "")
            UserDefaults.SFSDefault(setBool: false, forKey: "isNotificationOff")
        }
        else{
            let playerID: String = UserDefaults.SFSDefault(valueForKey: "player_id") as? String ?? ""
            self.updateUserDataOnFirebase(playerId: playerID)
            UserDefaults.SFSDefault(setBool: true, forKey: "isNotificationOff")
        }
    }
    func addToIndustryAction(_ sender :UIButton)  {
        let indexPath:NSIndexPath = IndexPath(row: sender.tag - 1, section: 0) as NSIndexPath
        if sender.isSelected {
            arrayCatagoryServer.remove(arrayCatagory[indexPath.row])
            sender.setImage(UIImage.init(named: "radio_unsel"), for: .normal)
            sender.isSelected = false
        }
        else{
            if arrayCatagoryServer.count  < 2 {
                arrayCatagoryServer.add(arrayCatagory[indexPath.row])
                sender.setImage(UIImage.init(named: "radio_sel"), for: .normal)
                sender.isSelected = true
            }
            else{
                AppManager.showMessageView(view: self.view, meassage: "You can only choose a maximum of 2 :)")
            }

        }

    }
    func addToMusicianAction(_ sender :UIButton)  {
        let indexPath:NSIndexPath = IndexPath(row: sender.tag - 2, section: 0) as NSIndexPath

        if sender.isSelected {
            arrayCatagoryServer.remove(arrayCatagory[indexPath.row + 1] )
            sender.setImage(UIImage.init(named: "radio_unsel"), for: .normal)
            sender.isSelected = false

        }
        else{
            if arrayCatagoryServer.count < 2 {
                arrayCatagoryServer.add(arrayCatagory[indexPath.row + 1])
                sender.setImage(UIImage.init(named: "radio_sel"), for: .normal)
                sender.isSelected = true
            }
            else{
                AppManager.showMessageView(view: self.view, meassage: "You can only choose a maximum of 2 :)")
            }
        }
    }
    func saveAction(_ sender: Any)  {

    }

    func nextAction(_ sender: Any) {
        var typeStr = NSString()
        var industryStr = NSString()

        if arrayCatagoryServer.count == 2 {
            typeStr = ""
            industryStr = arrayCatagoryServer.componentsJoined(by: ",")  as NSString
        }
        else if arrayCatagoryServer.count == 1{
            typeStr = ""
            industryStr =  arrayCatagoryServer[0] as! NSString
        }
        else if arrayCatagoryServer.count == 0 {
            
            AppManager.showMessageView(view: self.view, meassage: "Please choose atleast one job title :)")
            return
        }
        else{
            typeStr = "Musician"
            industryStr = arrayMusician[0] as! NSString
        }
        self.addIndustyOfUser(industry: industryStr as String, type: typeStr as String)
        
    }
    @IBAction func openSideMenu(_ sender: Any) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion {
        }
    }
    
    @IBAction func btnDeleteAction(_ sender: Any) {
        
        let alertController = UIAlertController.init(title: nil, message: "Do you want to delete your account?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction.init(title:"Yes", style: .default) { (alert) in
            self.deleteWebServiceCall()
        }
        
        let noAction = UIAlertAction.init(title:"No", style: .default) { (alert) in
            
        }
        
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteWebServiceCall(){
        
        AppManager.sharedInstance.showHud(showInView: self.view, label: "")
        
        let para :Dictionary = ["user_id":UserDefaults.SFSDefault(valueForKey: USER_ID),"account_status":"0"]
        
        let url  = String(format:"%@deactivateaccount",BASE_URL)
        
        ServerManager.sharedInstance.httpPost(url, postParams: para, SuccessHandle: { (response, urlString) in
            AppManager.sharedInstance.hidHud()
            var jsonResult = response as! Dictionary<String, Any>
            print(jsonResult)
            if jsonResult["success"] as! NSNumber == 1{
                
                //remove all preferences
                if let bundle = Bundle.main.bundleIdentifier {
                    UserDefaults.standard.removePersistentDomain(forName: bundle)
                }
                
                //move to login screen
                AppManager.showMessageView(view: self.view, meassage: "Your account has been de-activated.")
                
                let loginVc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                let navigationController : UINavigationController = UINavigationController.init(rootViewController: loginVc)
                
                AppDelegate.sharedDelegate.window?.rootViewController = navigationController
            }
            else{
                AppManager.showMessageView(view: self.view, meassage: jsonResult["error_message"] as! String)
            }
        }) { (error) in
            AppManager.showMessageView(view: self.view, meassage: error.localizedDescription)
        }
    }
    
    
}
