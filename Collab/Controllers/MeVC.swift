//
//  MeVC.swift
//  Collab
//
//  Created by Apple01 on 4/14/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit
import MediaPlayer
import Firebase

class MeVC: UIViewController,PassSongData,UIImagePickerControllerDelegate,UINavigationControllerDelegate ,NPAudioStreamDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate,MBProgressHUDDelegate{
    
    @IBOutlet weak var btnMusic: UIButton!
    var HUD : MBProgressHUD!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet var tfDatePicker: UITextField!
    @IBOutlet weak var collectionImages: UICollectionView!
    @IBOutlet weak var lblSong: UILabel!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfBio: UITextField!
    @IBOutlet weak var outletBtnNext: UIButton!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var btnOutletSideMenu: UIButton!
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var btnFemale: UIButton!

    @IBOutlet var viewDatePicker: UIView!
    @IBOutlet var ivSong: UIImageView!
    var isEdited = Bool()
    
    @IBOutlet var outletBtnSideMenu: UIButton!
    var gender = String()

    var isPlaying: Bool = Bool()
    var songStr = ""
    var cellTag = NSInteger()
    var userDataDict = Dictionary <String, Any>()
    
    var imageDict = Dictionary <String, Any>()
    
    var audioStream : NPAudioStream = NPAudioStream()
    
    var urlArray = NSMutableArray()
    var dataDict = NSDictionary()
    var picker = UIImagePickerController()
    var isFirstTime = Bool()
    var dateString = String()
    
    let searchMusic = SearchMusicVC()
    var outSideController = NSString()
    
    //MARK:
    //MARK: UIView Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isEdited = false
        isFirstTime = true
        picker.delegate = self
        tfBio.delegate = self
        self.navigationController?.navigationBar.isHidden = true
        if outSideController == "yes" {
            TYPE_CONTROLLER = controllerType.externalController
            lblSong.text = "Tap music to add song"
            viewDatePicker.isHidden = true
            ivSong.isHidden = false
            self.view.bringSubview(toFront: ivSong)
            btnMale.isSelected = false
            btnFemale.isSelected = false

        }
        else{
            self.getUser()
            TYPE_CONTROLLER = controllerType.internalController
            viewDatePicker.isHidden = false
            ivSong.isHidden = true
            let datePickerView:UIDatePicker = UIDatePicker()
            datePickerView.datePickerMode = UIDatePickerMode.date
            tfDatePicker.inputView = datePickerView
            tfDatePicker.delegate = self
            datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControlEvents.valueChanged)
        }
        
        tfEmail.delegate = self
        
        //draw border on textfields or on button
        self.tfBio.layer.borderColor = UIColor.black.cgColor
        self.tfBio.layer.borderWidth = 4.0
        
        self.tfDatePicker.layer.borderColor = UIColor.black.cgColor
        self.tfDatePicker.layer.borderWidth = 4.0
        
        
        let leftView1 = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        let leftView2 = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        
        self.tfBio.leftView = leftView1
        self.tfBio.leftViewMode = .always
        
        self.tfDatePicker.leftView = leftView2
        self.tfDatePicker.leftViewMode = .always
        
        self.btnMusic.layer.borderColor = UIColor.black.cgColor
        self.btnMusic.layer.borderWidth = 1.5
        
    }
       override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if TYPE_CONTROLLER == controllerType.externalController {
            userDataDict = UserDefaults.SFSDefault(valueForKey: "userInfo") as! Dictionary<String, Any>
            if userDataDict["profile_pic"] != nil {
                self.imageDict["profile_pic"] = userDataDict["profile_pic"]
            }
            outletBtnNext.setTitle("Next", for: .normal)
            outletBtnNext.addTarget(self, action: #selector(self.nextAction(_:)), for: .touchUpInside)
            btnOutletSideMenu.isHidden = true
            var name = userDataDict["full_name"] as? String

            tfBio.layer.borderWidth = 1.0
            tfBio.layer.borderColor = UIColor.black.cgColor
            
            name = name?.capitalized
            lblName.text = name
            if isFirstTime == true{
                isFirstTime = false
                collectionImages.reloadData()
            }
        }
        else{
            tfBio.layer.borderWidth = 1.0
            tfBio.layer.borderColor = UIColor.black.cgColor

            tfDatePicker.layer.borderWidth = 1.0
            tfDatePicker.layer.borderColor = UIColor.black.cgColor

            outletBtnNext.setTitle("My Profile", for: .normal)
            outletBtnNext.addTarget(self, action: #selector(self.viewMyProfile(_:)), for: .touchUpInside)
            btnOutletSideMenu.isHidden = false
            lblName.text =  UserDefaults.SFSDefault(valueForKey:  "full_name") as? String
        }

        tfBio.tag = 1
        audioStream.delegate = self
        isPlaying = false
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture))
        longPressGesture.delegate = self
        collectionImages.addGestureRecognizer(longPressGesture)
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:
    //MARK: WebServices methods
    
    func updateUser() {
        if gender == "" {
            AppManager.showMessageView(view: self.view, meassage: "Please choose gender")
            return
        }
        if  AppManager.isValidEmail(tfEmail.text!) == false || tfEmail.text == "" || tfEmail.text == nil {
            AppManager.sharedInstance.shakeTextField(textField: tfEmail, withText: "Please enter valid email", currentText: "Tap to enter email")
            return
        }
        if imageDict.keys.count < 3 {
            AppManager.showMessageView(view: self.view, meassage: "Please upload all images")
            return
        }
        if  lblSong.text!  == "" || lblSong.text!.isEmpty || lblSong.text! == "Tap music to add song" {
            AppManager.showMessageView(view: self.view, meassage: "Please first add song")
            return
        }
        
        if tfBio.text == "" || tfBio.text == nil{
            AppManager.sharedInstance.shakeTextField(textField: tfBio, withText: "Please enter some in bio", currentText: "Max 32 characters")
            return
        }
        
        var para  = Dictionary<String, Any>()
        
        if TYPE_CONTROLLER == controllerType.externalController {
            para = ["user_id":UserDefaults.SFSDefault(valueForKey: USER_ID),
                                    "bio":tfBio.text!,
                                    "music_file_url":dataDict["songUrl"] ?? "" ,
                                    "music_file_name" : lblSong.text!,
                                    "email":tfEmail.text!,
                                    "gender" : gender]
        }
        else{
            if dataDict.allKeys.count != 0 {
                para = ["user_id":UserDefaults.SFSDefault(valueForKey: USER_ID),
                        "bio":tfBio.text!,
                        "music_file_url":dataDict["songUrl"] ?? "",
                        "music_file_name" : lblSong.text!,
                        "dob" : dateString,
                        "email":tfEmail.text!,
                "gnder": gender]
            }
            else{
                if dateString.isEmpty != true {
                    para = ["user_id":UserDefaults.SFSDefault(valueForKey: USER_ID),
                            "bio":tfBio.text!,
                            "music_file_name" : lblSong.text!,
                            "dob" : dateString,
                            "email":tfEmail.text!]
                }
                else{
                    para = ["user_id":UserDefaults.SFSDefault(valueForKey: USER_ID),
                            "bio":tfBio.text!,
                            "music_file_name" : lblSong.text!,
                            "email":tfEmail.text!]
                }
                
            }
        }
        
        let url  = String(format:"%@update_user",BASE_URL)
        
        AppManager.sharedInstance.showHud(showInView: self.view, label: "Saving...")
        ServerManager.sharedInstance.httpPost(url, postParams: para, SuccessHandle: { (response, url) in
            AppManager.sharedInstance.hidHud()
            let jsonResult = response as! Dictionary<String, Any>
            
            print("json result \(jsonResult)")
            if jsonResult["success"] as! NSNumber   == 1{
                
                if jsonResult["success"] as! NSNumber   == 1{
                     if TYPE_CONTROLLER != controllerType.externalController {
                    self.menuContainerViewController.toggleLeftSideMenuCompletion {
                    }
                    }
                     else{
                        let userInfo: Dictionary = jsonResult["user_data"] as! Dictionary<String, Any>
                        let congratsVC = self.storyboard?.instantiateViewController(withIdentifier: "CongratsVC") as! CongratsVC
                        UserDefaults.SFSDefault(setValue: userInfo, forKey: "userInfo")
                        self.navigationController?.pushViewController(congratsVC, animated: true)
                    }
                }
            }
            
        }) { (error) in
            AppManager.showServerErrorDialog(error, view: self.view)
        }
    }
    
    func deleteImage(mediaKey : String)  {
        let para :Dictionary = ["user_id":UserDefaults.SFSDefault(valueForKey: USER_ID),
                                "image_type":mediaKey]
        
        let url  = String(format:"%@delete_image",BASE_URL)
        
        AppManager.sharedInstance.showHud(showInView: self.view, label: "")
        ServerManager.sharedInstance.httpPost(url, postParams: para, SuccessHandle: { (response, url) in
            AppManager.sharedInstance.hidHud()
            let jsonResult = response as! Dictionary<String, Any>
            
            print("json result \(jsonResult)")
            if jsonResult["success"] as! NSNumber   == 1{
                if jsonResult["success"] as! NSNumber   == 1{
                    self.imageDict.removeValue(forKey: mediaKey)
                }
            }
        }) { (error) in
            AppManager.showServerErrorDialog(error, view: self.view)
        }
    }
    
    func addImage(keyName :String , image :UIImage) {
        
        ShowProgressBar()
        let para :Dictionary = ["user_id":UserDefaults.SFSDefault(valueForKey: USER_ID),
                                "image_type":keyName]
        let url  = String(format:"%@upload_image",BASE_URL)
        let keyObject = [image]
        
        ServerManager.sharedInstance.httpMultipartDataPostSingle(url, postParams: para, meidaObject: keyObject, mediaKey: "image", isVideo: false,  SuccessHandle: { (response, url) in
            self.hudWasHidden()
            let jsonResult = response as! Dictionary<String, Any>
            
            print("json result \(jsonResult)")
            if jsonResult["success"] as! NSNumber   == 1{
                
                if jsonResult["success"] as! NSNumber   == 1{
                    let data: Dictionary = jsonResult["data"] as! Dictionary<String, Any>
                    let imageUrl = data[keyName]
                    if  self.imageDict[keyName] == nil{
                        self.imageDict[keyName] = imageUrl
                        if keyName == "profile_pic"{
                            UserDefaults.SFSDefault(setValue: imageUrl!, forKey: keyName)
                            self.updateUserDataOnFirebase(pic: imageUrl! as! String)
                        }
                    }
                    else{
                        self.imageDict.removeValue(forKey: keyName)
                        if keyName == "profile_pic"{
                            self.updateUserDataOnFirebase(pic: imageUrl! as! String)
                            UserDefaults.SFSDefault(setValue: imageUrl!, forKey: keyName)
                        }
                        self.imageDict[keyName] = imageUrl
                    }
                }
            }
            
        }, failier: { (error) in
            self.hudWasHidden()
            AppManager.showServerErrorDialog(error, view: self.view)
            
        }) { (Progress) in
            self.UpdateProgressBar(progress: Float(Progress.fractionCompleted))
        }
        
    }
    func getUser()  {
        
        AppManager.sharedInstance.showHud(showInView: self.view, label: "")
        let para :Dictionary = ["user_id":UserDefaults.SFSDefault(valueForKey: USER_ID)]
        let url  = String(format:"%@my_profile",BASE_URL)
        
        ServerManager.sharedInstance.httpPost(url, postParams: para, SuccessHandle: { (response, urlString) in
            AppManager.sharedInstance.hidHud()
            var jsonResult = response as! Dictionary<String, Any>
            print(jsonResult)
            if jsonResult["success"] as! NSNumber == 1{
        
                let dataDict = jsonResult["data"] as! Dictionary<String, Any>
                self.setUpView(userDataDict: dataDict["app_users"] as! Dictionary<String, Any> )
                   self.imageDict = dataDict["gallery"] as! Dictionary<String, Any>
                self.collectionImages.reloadData()
                UserDefaults.SFSDefault(setValue: self.userDataDict, forKey: "userInfo")
            }
            else{
                AppManager.showMessageView(view: self.view, meassage: jsonResult["error_message"] as! String)
            }
        }) { (error) in
            AppManager.showMessageView(view: self.view, meassage: error.localizedDescription)
        }
    }
    
    func swapImage(dictImages : Dictionary<String, Any>)  {
        var JSONString = String()
         AppManager.sharedInstance.showHud(showInView: self.view, label: "")
        do {
            //Convert to Data
            let jsonData = try JSONSerialization.data(withJSONObject: dictImages, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            //Do this for print data only otherwise skip
          JSONString = String(data: jsonData, encoding: String.Encoding.utf8)!
            
        } catch {
            //print(error.description)
        }
       
        let para :Dictionary = ["user_id":UserDefaults.SFSDefault(valueForKey: USER_ID),
                                "images" : JSONString]
        let url  = String(format:"%@update_images",BASE_URL)
        
        ServerManager.sharedInstance.httpPost(url, postParams: para, SuccessHandle: { (response, urlString) in
            AppManager.sharedInstance.hidHud()
            var jsonResult = response as! Dictionary<String, Any>
            print(jsonResult)
            if jsonResult["success"] as! NSNumber == 1{

                self.imageDict.removeAll()
                self.imageDict = jsonResult["user_data"] as! Dictionary<String, Any>
                if self.imageDict["profile_pic"] != nil {
                    UserDefaults.SFSDefault(setValue: self.imageDict["profile_pic"]!, forKey: "profile_pic")
                    self.updateUserDataOnFirebase(pic: self.imageDict["profile_pic"] as! String)
                }
                self.collectionImages.reloadData()
                UserDefaults.SFSDefault(setValue: self.userDataDict, forKey: "userInfo")
            }
            else{
                AppManager.showMessageView(view: self.view, meassage: jsonResult["error_message"] as! String)
            }
        }) { (error) in
            AppManager.showMessageView(view: self.view, meassage: error.localizedDescription)
        }
    }
    
    func setUpView(userDataDict : Dictionary<String, Any>)  {
    
        lblName.text = userDataDict["full_name"] as? String
        lblSong.text = userDataDict["music_file_name"] as? String
        
        tfBio.text =  userDataDict["bio"] as? String
        tfEmail.text = userDataDict["email"] as? String
        if userDataDict["dob"] as? String  != "0000-00-00" {
            tfDatePicker.text = self.covertDateFormat(webDateStr: (userDataDict["dob"] as? String)!)
        }
        gender = (userDataDict["gender"] as? String)!
        if gender == "male" {
            btnMale.isSelected = true
            btnFemale.isSelected = false
        }
        else{
            btnFemale.isSelected = true
            btnMale.isSelected = false
        }
        
       
        if urlArray.count != 0 {
            urlArray.removeAllObjects()
        }
        else{
            let songUrl  = URL.init(string: userDataDict["music_file_url"] as! String )
            if songUrl != nil {
                urlArray.add(songUrl!)
            }
        }
    }
    
    // MARK:
    // MARK: UIprogressBar
    
    func ShowProgressBar() {
        HUD = MBProgressHUD(frame: UIScreen.main.bounds)
        HUD.mode = .determinateHorizontalBar
        HUD.delegate = self
        self.view.addSubview(HUD)
        HUD.show(true)
    }
    
    func UpdateProgressBar(progress : Float) {
        print(String (format: "Uploading %.0f%%", progress*100))
        HUD.labelText = String (format: "Uploading %.0f%%", progress*100)
        HUD.progress = progress
    }
    
    func hudWasHidden()  {
        HUD.hide(true)
        HUD.removeFromSuperview()
    }
    //MARK:
    //MARK: Button Actions
    @IBAction func openSideMenu(_ sender: Any) {
        if isEdited == true{
              isEdited = false
            if tfDatePicker.text! == "" || (tfDatePicker.text?.isEmpty)!{
                AppManager.showMessageView(view: self.view, meassage: "Please update your date of birthday")
            }else{
               self.updateUser()
            }
        }
        else{
            if imageDict.keys.count < 3 {
                AppManager.showMessageView(view: self.view, meassage: "Please upload all images")
                return
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateProfilePic"), object: nil)
            self.menuContainerViewController.toggleLeftSideMenuCompletion {
            }
        }
}
    func removeImage(_ sender : UIButton) {
        let indexPath = NSIndexPath.init(item: sender.tag, section: 0)
        
        let cell = collectionImages.cellForItem(at: indexPath as IndexPath) as! ImagesCell
        
        cell.ivUser.image = nil
        if sender.tag == 0 {
            self.deleteImage(mediaKey: "profile_pic")
        }
        else if sender.tag == 1{
            self.deleteImage(mediaKey: "image1")
        }else{
            self.deleteImage(mediaKey: "image2")
        }
        
    }
    
    func nextAction(_ sender: Any) {
        
        self.updateUser()
    }
    func viewMyProfile(_ sender: Any) {
        let myProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "FullProfileVC") as! FullProfileVC
        myProfileVC.isMyProfile = "yes"
        self.navigationController?.pushViewController(myProfileVC, animated: true)
    }
    
    @IBAction func btnPlaySong(_ sender: Any) {
        
        if isPlaying == false {
            self.perform(#selector(self.btnPlaySongAction(_:)), on: .main, with: nil, waitUntilDone: true)
        }
        else{
            self.perform(#selector(self.btnPauseSongAction(_:)), on: .main, with: nil, waitUntilDone: true)
        }
    }
    
    func btnPlaySongAction(_ sender :UIButton)  {
        btnPlayPause.setImage(UIImage.init(named: "pause"), for: .normal)
        audioStream.callMethod(urlArray)
        audioStream.selectIndex(forPlayback: 0)
        
        audioStream.play()
        isPlaying = true
        
    }
    
    func btnPauseSongAction(_ sender :UIButton)  {
        btnPlayPause.setImage(UIImage.init(named: "play"), for: .normal)
        audioStream.pause()
        isPlaying = false
    }
    @IBAction func maleBtnAction(_ sender: Any) {
        isEdited = true
        if btnFemale.isSelected == true {
            AppManager.showMessageView(view: self.view, meassage: "Only one can be selected..")
            return
        }
        if btnMale.isSelected == true {
            btnMale.isSelected = false
            gender = ""
            return
        }

        btnMale.isSelected = true
        btnFemale.isSelected = false
        gender = "male"
    }
    @IBAction func femaleBtnAction(_ sender: Any) {
        isEdited = true
        if btnMale.isSelected == true {
            AppManager.showMessageView(view: self.view, meassage: "Only one can be selected..")
            return
        }
        if btnFemale.isSelected == true {
            btnFemale.isSelected = false
            gender = ""
            return
        }
        btnMale.isSelected = false
        btnFemale.isSelected = true
        gender = "female"
    }
    
    //MARK:
    //MARK: Present Search Controller
    
    @IBAction func presentSearchControllerAction(_ sender: Any) {
        let searchMusicVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchMusicVC") as! SearchMusicVC
        searchMusicVC.delegate = self
        self.present(searchMusicVC, animated: true, completion: nil)
    }
    
    //MARK:
    //MARK: Delegate Method
    
    func addSong(songDict: NSDictionary) {
        isEdited = true
        dataDict = songDict as! Dictionary<String, Any> as NSDictionary
        songStr = dataDict["songName"] as! String
        lblSong.text = songStr
        let songUrl = NSURL.init(string: dataDict["songUrl"]! as! String)
        if urlArray.count != 0 {
            urlArray.removeAllObjects()
        }
        urlArray.add(songUrl! as NSURL)
    }
    
    //MARK:
    //MARK: UIImagePicker Delegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker .dismiss(animated: true, completion: nil)
        
        let indexPath = NSIndexPath.init(item: cellTag, section: 0)
        
        let cell = collectionImages.cellForItem(at: indexPath as IndexPath) as! ImagesCell
        
        var image : UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
     
        cell.ivUser.image = image
        
        if cellTag == 0 {
           let imageData = UIImageJPEGRepresentation(image, 0.8)
            image = UIImage.sd_image(with: imageData)
            self.addImage(keyName: "profile_pic", image: image)
        }
        else if cellTag == 1{
            let imageData = UIImageJPEGRepresentation(image, 0.8)
            image = UIImage.sd_image(with: imageData)
            self.addImage(keyName: "image1", image: image)
        }
        else{
            let imageData = UIImageJPEGRepresentation(image, 0.8)
            image = UIImage.sd_image(with: imageData)
            self.addImage(keyName: "image2", image: image)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        print("picker cancel.")
    }
    
    //MARK:
    //MARK: Show ActionSheet
    
    func showActionSheet(_ tag: NSInteger)  {
        cellTag = tag
        let alert:UIAlertController =   UIAlertController.showActionSheetInViewController(viewController: self, withTitle: nil, message: nil, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil , otherButtonTitles: ["Camera","Photo Library"]) { (alert:UIAlertController?, action:UIAlertAction?, buttonIndex:Int?) in
            if buttonIndex == 2 {
                let picker = UIImagePickerController()
                picker.sourceType =  .camera
                picker.delegate = self
                
                self .present(picker, animated: true, completion: nil)
            }
            else if buttonIndex == 3 {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.present(picker, animated: true, completion: nil)
                
            }
        }
        alert.view.tintColor = UIColor.black
        
    }
    
    //MARK:
    //MARK: Player Delegate methods
    
    func audioStream(_ audioStream :NPAudioStream , didUpdateTrackCurrentTime currentTime :CMTime)  {
        let time =  CMTimeGetSeconds(currentTime)
        // lblDuration.text = String(format:"%.0f Seconds",time)
        if time >= 15 {
            audioStream.pause()
            btnPlayPause.setImage(UIImage.init(named: "play"), for: .normal)
            audioStream.seekToTime(inSeconds: 0)
            isPlaying = false
            print("Stop Player")
        }
    }
    
    //MARK:
    //MARK: UICollectionView Datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: ImagesCell = collectionImages.dequeueReusableCell(withReuseIdentifier: "imagesCell", for: indexPath) as! ImagesCell
        cell.ivUser.contentMode = .scaleAspectFill
        
        cell.btnCross.addTarget(self, action: #selector(self.removeImage(_ :)), for: .touchUpInside)
        cell.btnCross.tag = indexPath.item
        
        if TYPE_CONTROLLER == controllerType.externalController{
            if indexPath.item == 0 {
                cell.ivUser.contentMode = .scaleAspectFill
                cell.ivUser.sd_setImage(with: URL(string: self.userDataDict["profile_pic"] as! String))
                cell.ivUser.clipsToBounds = true
            }
            else{
                cell.ivUser.image = nil
            }
        }
        else{
            
            if imageDict.keys.count != 0 {
                if indexPath.item == 0 {
                    let imageUrl = NSURL.init(string: self.imageDict["profile_pic"] as! String)
                    
                    if imageUrl != nil{
                         cell.ivUser.sd_setImage(with: imageUrl! as URL)
                        cell.ivUser.contentMode = .scaleAspectFill
                        cell.ivUser.clipsToBounds = true
                    }
                }
                else if (indexPath.item == 1){
                    let imageUrl = NSURL.init(string: self.imageDict["image1"] as! String)
                    if imageUrl != nil{
                        cell.ivUser.sd_setImage(with: imageUrl! as URL)
                        cell.ivUser.contentMode = .scaleAspectFill
                        cell.ivUser.clipsToBounds = true
                    }
                }
                else{
                    let imageUrl = NSURL.init(string: self.imageDict["image2"] as! String)
                    if imageUrl != nil{
                        cell.ivUser.sd_setImage(with: imageUrl! as URL)
                        cell.ivUser.contentMode = .scaleAspectFill
                        cell.ivUser.clipsToBounds = true
                    }
                }
            }
        }
        return cell
    }
    
    // MARK:
    // MARK: - UICollectionView Delegates
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        self.showActionSheet(indexPath.item)
    }
    func collectionView(_ collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath,toIndexPath destinationIndexPath: NSIndexPath) {
        
   //---------------- Swaping images------------------------
        // cell 1
        let cellSource = collectionImages.cellForItem(at: sourceIndexPath as IndexPath)  as! ImagesCell
        
        // cell 2
        let cellDestination = collectionImages.cellForItem(at: destinationIndexPath as IndexPath) as! ImagesCell
        
        if sourceIndexPath.item == 0  { // source cell is first cell
            if destinationIndexPath.item == 1 {
//                swapImage
                
                let swappedDict : Dictionary = ["profile_pic":self.imageDict["image1"]!,
                               "image1":self.imageDict["profile_pic"]!] as Dictionary<String, Any>
                self.swapImage(dictImages: swappedDict )
            }
            else{
                // will be 2
                let swappedDict : Dictionary = ["profile_pic":self.imageDict["image2"]!,
                                                "image2":self.imageDict["profile_pic"]!] as Dictionary<String, Any>
                self.swapImage(dictImages: swappedDict )
            }
            
        }
        else if sourceIndexPath.item == 1{ // source cell is second cell
            if destinationIndexPath.item == 0 {
                let swappedDict : Dictionary = ["profile_pic":self.imageDict["image1"]!,
                                                "image1":self.imageDict["profile_pic"]!] as Dictionary<String, Any>
                self.swapImage(dictImages: swappedDict )
            }
            else{
                let swappedDict : Dictionary = ["image2":self.imageDict["image1"]!,
                                                "image1":self.imageDict["image2"]!] as Dictionary<String, Any>
                self.swapImage(dictImages: swappedDict )
            }
        }
        else{ // source cell is third cell
            if destinationIndexPath.item == 1 {
                let swappedDict : Dictionary = ["image1":self.imageDict["image2"]!,
                                                "image2":self.imageDict["image1"]!] as Dictionary<String, Any>
                self.swapImage(dictImages: swappedDict )
            }
            else{
                let swappedDict : Dictionary = ["profile_pic":self.imageDict["image2"]!,
                                                "image2":self.imageDict["profile_pic"]!] as Dictionary<String, Any>
                self.swapImage(dictImages: swappedDict )
            }
        }
        cellSource.btnCross.tag = sourceIndexPath.item
        cellDestination.btnCross.tag = destinationIndexPath.item
        
    }
    
    //MARK: Collection view layout things
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
        var sizeOfElement : CGSize
        sizeOfElement = CGSize(width: collectionImages.frame.size.width/3 - 1, height: collectionImages.frame.size.width/3 - 1)
        return sizeOfElement
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 1.0, 0.0,0.0)
    }
    
    
    // MARK:
    // MARK: - UILongPressGestureRecognizer Delegate
    func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = collectionImages.indexPathForItem(at: gesture.location(in: collectionImages)) else {
                break
            }
            collectionImages.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            collectionImages.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            collectionImages.endInteractiveMovement()
        default:
            collectionImages.cancelInteractiveMovement()
        }
    }
    
    //MARK:
    //MARK:UISearchBar Delegate Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
         isEdited = true
        if textField.tag == 1 {
            let strBio = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
            if strBio.characters.count > 32 {
                return false
            }
            else{
                return true
            }
        }
        else{
            return true
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let toolBar : UIToolbar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        
        let flexBarButton : UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let doneBarButton : UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(self.donePressed))
        
        toolBar.items = [flexBarButton,doneBarButton]
        
        textField.inputAccessoryView = toolBar
        
        return true
    }
    
    func donePressed() {
       self.view.endEditing(true)
    }
    
    
    //MARK:
    //MARK:Date  Methods
    
    func covertDateFormat(webDateStr : String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let date = formatter.date(from: webDateStr)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat="dd-MMM-yyyy"
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.none
        let dateStr = dateFormatter.string(from:date)
        return dateStr
    }
    func datePickerValueChanged(sender:UIDatePicker)  {
        // textField date
        isEdited = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.none
        tfDatePicker.text = dateFormatter.string(from: sender.date)
        
        // backend date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dateString = formatter.string(from: sender.date)
    }
    //MARK: Firebase Methods

    func updateUserDataOnFirebase(pic:String) {
        let ref : DatabaseReference!
        ref = Database.database().reference()
        let refChild = ref.child("users")
        let refChatID = refChild.child(UserDefaults.SFSDefault(valueForKey: "user_id") as! String )

        var profilePic = Dictionary<String, String>()
        profilePic["profile_pic"] = pic
        refChatID.updateChildValues(profilePic)

    }
}
