//
//  CollabWithVC.swift
//  Collab
//
//  Created by SFS04 on 4/24/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit

class CollabWithVC: UIViewController , UITableViewDelegate , UITableViewDataSource {
    @IBOutlet var btnIndustryPro: UIButton!
    @IBOutlet var btnMusicians: UIButton!
    
    @IBOutlet var lblAge: UILabel!
    @IBOutlet var lblCollab: UILabel!
    @IBOutlet weak var btnMales: UIButton!
    @IBOutlet weak var btnFemales: UIButton!
    
    let arrayIndustry = NSMutableArray()
    let arrayCatagory: [String] = ["Musician","Model","Video","Acting","Photography", "Producer", "Visual artist", "Writer","Performer","Management","Dancer","GFX designer"]
    @IBOutlet weak var tblCat: UITableView!
    
    let arrayCatagoryServer = NSMutableArray()

    var minAgeStr = "18"
    var maxAgeStr = "40"
    var distanceStr = "50"
    var gender = NSMutableArray()
    
    @IBOutlet weak var tableViewHeightContsraint: NSLayoutConstraint!

    var userSettings  = Dictionary<String, Any>()
    
    @IBOutlet var sliderAge: MARKRangeSlider!
    
    //MARK:
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        
        self.getUserSettings()
        
        var constantValue = 1
        
        if DeviceType.IS_IPHONE_5 {
             constantValue =  (44*7) + (86*2)
        }
        else{
            constantValue = (60*7) + (86*2)
        }
//        self.tableViewHeightContsraint.constant = CGFloat(constantValue)
//        self.tblCat.updateConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:
    //MARK: Button Actions
    @IBAction func openSideMenu(_ sender: Any) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion {
        }

    }
    
    // MARK: Slider Actions
    @IBAction func ageSliderAction(_ sender: MARKRangeSlider) {
         print(String(format:"%0.2f - %0.2f", sender.leftValue, sender.rightValue))
         self.minAgeStr = String(format:"%d",Int(sender.leftValue))
         self.maxAgeStr = String(format:"%d",Int(sender.rightValue))
        
         let indexPath:NSIndexPath = IndexPath(row: 0, section: 2) as NSIndexPath
        
        let cell : SliderCell = self.tblCat.cellForRow(at: indexPath as IndexPath) as! SliderCell
        
        cell.lblCollab.text = self.minAgeStr + "-" + self.maxAgeStr
        
    }
    
    @IBAction func distanceSliderAction(_ sender: UISlider) {
       
        self.distanceStr = String(format:"%d",Int(sender.value))
        
        let indexPath:NSIndexPath = IndexPath(row: 1, section: 2) as NSIndexPath
        
        let cell : SliderCell = self.tblCat.cellForRow(at: indexPath as IndexPath) as! SliderCell
        if Int(sender.value) == 100 {
            cell.lblCollab.text = String(format:"Global")
        }else{
            cell.lblCollab.text = String(format:"%@ mile",self.distanceStr)
        }
        
    }

    @IBAction func musicianAction(_ sender: Any) {
        if btnMusicians.isSelected == true {
            btnMusicians.isSelected = false
            btnMusicians.setImage(#imageLiteral(resourceName: "radio_unsel"), for: .normal)
        }
        else{
            btnMusicians.isSelected = true
            btnMusicians.setImage(#imageLiteral(resourceName: "radio_sel"), for: .normal)
        }
    }
    @IBAction func industryAction(_ sender: Any) {
        if btnIndustryPro.isSelected == true {
            btnIndustryPro.isSelected = false
            btnIndustryPro.setImage(#imageLiteral(resourceName: "radio_unsel"), for: .normal)
        }
        else{
            btnIndustryPro.isSelected = true
            btnIndustryPro.setImage(#imageLiteral(resourceName: "radio_sel"), for: .normal)
        }
    }
    @IBAction func btnSaveAction(_ sender: Any) {
        self.updateUserSettings()
    }
    @IBAction func femalesBtnAction(_ sender: Any) {
        
    }

    @IBAction func malesBtnAction(_ sender: Any) {
       

    }
    //MARK:
    //MARK: Webservices Methods
    
    func getUserSettings()  {
        AppManager.sharedInstance.showHud(showInView: self.view, label: "")
        let para = ["user_id":UserDefaults.SFSDefault(valueForKey:  "user_id")]
        ServerManager.sharedInstance.httpPost(String(format:"%@my_profile",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
            var jsonResult = response as! Dictionary<String, Any>
            AppManager.sharedInstance.hidHud()
            print(jsonResult)
            if jsonResult["success"] as! NSNumber == 1{
                let data = jsonResult["data"]as! Dictionary<String, Any>
                //                let userData = data["app_users"] as! Dictionary<String, Any>
                
                /*
                self.userSettings = data["user_settings"] as? [String: Any] ?? [:]
                self.sliderAge.setMinValue(18.0, maxValue: 40.0)
                self.sliderAge.minimumDistance = 1;
                self.minAgeStr = self.userSettings["minage"] as! String
                let minAge = CGFloat(Double(self.minAgeStr)!)
                
                self.maxAgeStr = self.userSettings["maxage"] as! String
                let maxAge = CGFloat(Double(self.maxAgeStr)!)

                self.gender = self.userSettings["users_gender"] as! String

                if self.gender == "male,female" || self.gender == "female,male"{
                    self.btnMales.isSelected = true
                    self.btnFemales.isSelected = true
                    
                }
                else if self.gender == "male"{
                    self.btnMales.isSelected = true
                    self.btnFemales.isSelected = false
                }
                else{
                    self.btnMales.isSelected = false
                    self.btnFemales.isSelected = true
                }

                self.lblAge.text = String(format:"%d-%d", Int(minAge),Int(maxAge))
                self.sliderAge.setLeftValue(minAge, rightValue: maxAge)
              
                if self.userSettings["music_industry"] as! String == "Industry,Musician"{
                    self.btnIndustryPro.isSelected = true
                    self.btnMusicians.isSelected = true
                    
                    self.btnMusicians.setImage(#imageLiteral(resourceName: "radio_sel"), for: .normal)
                    self.btnIndustryPro.setImage(#imageLiteral(resourceName: "radio_sel"), for: .normal)
                }
                else if self.userSettings["music_industry"] as! String == "Industry"{
                    self.btnIndustryPro.isSelected = true
                    self.btnMusicians.isSelected = false
                    
                    self.btnMusicians.setImage(#imageLiteral(resourceName: "radio_unsel"), for: .normal)
                    self.btnIndustryPro.setImage(#imageLiteral(resourceName: "radio_sel"), for: .normal)
                }
                else{
                    self.btnIndustryPro.isSelected = false
                    self.btnMusicians.isSelected = true
                    
                    self.btnMusicians.setImage(#imageLiteral(resourceName: "radio_sel"), for: .normal)
                    self.btnIndustryPro.setImage(#imageLiteral(resourceName: "radio_unsel"), for: .normal)
                    
                }*/
                let user_settings = data["user_settings"]as! Dictionary<String, Any>
                let music_industry_string = user_settings["music_industry"] as! String
                let gender_string = user_settings["users_gender"] as! String
                self.arrayCatagoryServer.addObjects(from: music_industry_string.components(separatedBy: ","))
                self.gender.addObjects(from: gender_string.components(separatedBy: ","))
                self.minAgeStr = user_settings["minage"] as! String
                self.maxAgeStr = user_settings["maxage"] as! String
                self.distanceStr = user_settings["distance"] as! String
                
                self.tblCat.reloadData()
            }
            else{
                AppManager.showMessageView(view: self.view, meassage: jsonResult["error_message"] as! String)
            }
        }) { (error) in
            AppManager.sharedInstance.hidHud()
            AppManager.showMessageView(view: self.view, meassage: error.description)
        }
    }
    
    func updateUserSettings()  {
        if gender.count == 0 {
             AppManager.showMessageView(view: self.view, meassage: "Please select atleast one choice :)")
            return
        }
        
        var genderString = ""
        
        if gender.count >= 2{
            genderString = gender.componentsJoined(by: ",")
        }else if gender.count == 1 {
            genderString = (gender[0] as! NSString) as String
        }

        var musicIndustry = String()
        
        if arrayCatagoryServer.count >= 2  {
            musicIndustry = arrayCatagoryServer.componentsJoined(by: ",")
        }
        else if arrayCatagoryServer.count == 1 {
            musicIndustry = arrayCatagoryServer[0] as! String
        }
        else{
           AppManager.showMessageView(view: self.view, meassage: "Please select atleast one choice :)")
            return
        }
        
        AppManager.sharedInstance.showHud(showInView: self.view, label: "")
        
        let para: Dictionary = ["user_id":UserDefaults.SFSDefault(valueForKey: "user_id"),
                    "music_industry": musicIndustry,
                    "maxage": maxAgeStr,
                    "minage" : minAgeStr,
                    "distance" : self.distanceStr,
                    "users_gender" : genderString]
        
        
    ServerManager.sharedInstance.httpPost(String(format:"%@update_user_settings",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
        AppManager.sharedInstance.hidHud()
        var jsonResult = response as! Dictionary<String, Any>
        AppManager.sharedInstance.hidHud()
        print(jsonResult)
        if jsonResult["success"] as! NSNumber == 1{
            AppManager.showMessageView(view: self.view, meassage: jsonResult["success_message"] as! String)
        }
        else{
            AppManager.showMessageView(view: self.view, meassage: jsonResult["error_message"] as! String)
        }
        }) { (error) in
            AppManager.sharedInstance.hidHud()
            AppManager.showMessageView(view: self.view, meassage: error.description)
        }
    }
    
    
    
    
    //MARK:
    //MARK: UITableView DataSource & Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        }else if section == 2 {
            return 1
        }
        return arrayCatagory.count/2
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "catagoryCell", for: indexPath) as! CatagoryCell
            
            cell.selectionStyle = .none
            
            cell.lblCat1.text = arrayCatagory[indexPath.row * 2] as String
            cell.lblCat2.text = arrayCatagory[indexPath.row * 2 + 1] as String
            
            
            cell.btnCat1.removeTarget(self, action: #selector(self.addToMusicianAction(_ :)), for: .touchUpInside)
            cell.btnCat2.removeTarget(self, action: #selector(self.addToMusicianAction(_ :)), for: .touchUpInside)
            
            cell.btnCat1.addTarget(self, action: #selector(self.addToIndustryAction(_ :)), for: .touchUpInside)
            cell.btnCat2.addTarget(self, action: #selector(self.addToIndustryAction(_ :)), for: .touchUpInside)
            
            cell.btnCat1.setImage(UIImage.init(named: "radio_unsel"), for: .normal)
            cell.btnCat2.setImage(UIImage.init(named: "radio_unsel"), for: .normal)
            
            cell.btnCat1.isSelected = false
            cell.btnCat2.isSelected = false
            
            let stringValueLocal = cell.lblCat1.text!
            let stringValueLocal2 = cell.lblCat2.text!
            
            for selectedIndustry in arrayCatagoryServer {
                
                var selectedIndustryLocal = selectedIndustry as! String
                
                selectedIndustryLocal = selectedIndustryLocal.trimmingCharacters(in: CharacterSet.whitespaces)
                
                print("Catagory:\(selectedIndustryLocal)")
                
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
                
                let stringValueLocal = cell.lblCat1.text
                let stringValueLocal2 = cell.lblCat2.text
                
                
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
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "catagoryCell", for: indexPath) as! CatagoryCell
            
            cell.selectionStyle = .none
            
            cell.lblCat1.text = "Male"
            cell.lblCat2.text = "Female"
            
            cell.btnCat1.removeTarget(self, action: #selector(self.addToIndustryAction(_ :)), for: .touchUpInside)
            cell.btnCat2.removeTarget(self, action: #selector(self.addToIndustryAction(_ :)), for: .touchUpInside)
            
            cell.btnCat1.addTarget(self, action: #selector(self.addToMusicianAction(_ :)), for: .touchUpInside)
            cell.btnCat2.addTarget(self, action: #selector(self.addToMusicianAction(_ :)), for: .touchUpInside)
            
            cell.btnCat1.setImage(UIImage.init(named: "radio_unsel"), for: .normal)
            cell.btnCat2.setImage(UIImage.init(named: "radio_unsel"), for: .normal)
            
            if (gender.count) >= 2 {
                cell.btnCat1.setImage(UIImage.init(named: "radio_sel"), for: .normal)
                cell.btnCat2.setImage(UIImage.init(named: "radio_sel"), for: .normal)
                
                cell.btnCat1.isSelected = true
                cell.btnCat2.isSelected = true
            }else if(gender.count) == 1 {
                let genderString = gender[0] as! NSString
                if genderString == "male" {
                    cell.btnCat1.isSelected = true
                    cell.btnCat2.isSelected = false
                    cell.btnCat1.setImage(UIImage.init(named: "radio_sel"), for: .normal)
                }else {
                    cell.btnCat1.isSelected = false
                    cell.btnCat2.isSelected = true
                    cell.btnCat2.setImage(UIImage.init(named: "radio_sel"), for: .normal)
                }
            }
            
            cell.btnCat1.tag = 1
            cell.btnCat2.tag = 2
            
            return cell
        }else
        {
            
            var cell : SliderCell
            
            if indexPath.row == 11 {
                cell = tableView.dequeueReusableCell(withIdentifier: "SliderCell", for: indexPath) as! SliderCell
            }else {
                 cell = tableView.dequeueReusableCell(withIdentifier: "SliderCell2", for: indexPath) as! SliderCell
            }
            
            cell.selectionStyle = .none
            
            if indexPath.row == 11 {
                cell.lblAge.text = "Age"
                
                let minAge = CGFloat(Double(self.minAgeStr)!)
                let maxAge = CGFloat(Double(self.maxAgeStr)!)
                //cell.lblCollab.text = String(format:"%d-%d", Int(minAge),Int(maxAge))
                cell.lblCollab.text = "All Age"
                cell.sliderAge.setLeftValue(0.0, rightValue: maxAge)
                cell.sliderAge.setMinValue(0.0, maxValue: 40.0)
                cell.sliderAge.minimumDistance = 2.0
                cell.sliderAge.isUserInteractionEnabled = false
                
                
//              cell.sliderAge.removeTarget(self, action: #selector(self.ageSliderAction(_ :)), for: .valueChanged)
                
                cell.sliderAge.addTarget(self, action: #selector(self.ageSliderAction(_ :)), for: .valueChanged)
                
            }else
            {
                cell.lblAge.text = "Distance"
                cell.lblCollab.text = String(format:"%d miles", Int(self.distanceStr)!)
                
                let maxDistance = CGFloat(Double(self.distanceStr)!)
                
                cell.sliderDistance.value = Float(maxDistance)
                
//                cell.sliderAge.removeTarget(self, action: #selector(self.distanceSliderAction(_ :)), for: .valueChanged)
        
                cell.sliderDistance.addTarget(self, action: #selector(self.distanceSliderAction(_ :)), for: .valueChanged)
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0
        {
            return 1
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //let labelText = UILabel.init(frame: CGRect.init(x: 20, y: 0, width: tableView.frame.size.width - 40, height: 40))
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        let labelText = UILabel.init(frame: CGRect(x: 20, y: 0, width: tableView.frame.size.width - 40, height: 40))
        
        if section == 2 {
            labelText.text = "Both can be selected!"
            
            labelText.textAlignment = .left
            
            labelText.font = UIFont.init(name: "HelveticaNeue-Light", size: 16)
            
        }else if section == 1 {
            labelText.textAlignment = .left
            labelText.text = "GENDER"
            labelText.font = UIFont.init(name: "HelveticaNeue-Light", size: 16)
        }
        
        if section == 0 {
            labelText.text = ""
        }
        headerView.addSubview(labelText)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 2 {
            return 86
        }
        
        if DeviceType.IS_IPHONE_5 {
            return 44.0
        }
        else{
            return 60.0
        }
    }
    
    // MARK: cell button actions
    func addToIndustryAction(_ sender :UIButton)  {
        let indexPath:NSIndexPath = IndexPath(row: sender.tag - 1, section: 0) as NSIndexPath
        if sender.isSelected {
            arrayCatagoryServer.remove(arrayCatagory[indexPath.row])
            sender.setImage(UIImage.init(named: "radio_unsel"), for: .normal)
            sender.isSelected = false
        }
        else{
         //   if arrayCatagoryServer.count  < 2 {
                arrayCatagoryServer.add(arrayCatagory[indexPath.row])
                sender.setImage(UIImage.init(named: "radio_sel"), for: .normal)
                sender.isSelected = true
//                }
//                else{
//                    AppManager.showMessageView(view: self.view, meassage: "You can only choose a maximum of 2 ")
//                }
            
        }
        
    }
    func addToMusicianAction(_ sender :UIButton)  {
        if sender.tag == 1 {
            if gender.contains("male") {
                gender.remove("male")
                sender.setImage(UIImage.init(named: "radio_unsel"), for: .normal)
                sender.isSelected = false
            }else{
                gender.add("male")
                sender.setImage(UIImage.init(named: "radio_sel"), for: .normal)
                sender.isSelected = true
            }
        }
        else{
            if gender.contains("female") {
                gender.remove("female")
                sender.setImage(UIImage.init(named: "radio_unsel"), for: .normal)
                sender.isSelected = false
            }else{
                gender.add("female")
                sender.setImage(UIImage.init(named: "radio_sel"), for: .normal)
                sender.isSelected = true
            }
            
        }
    }

}
