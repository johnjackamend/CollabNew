//
//  FullProfileVC.swift
//  Collab
//
//  Created by Apple01 on 5/11/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit
import MediaPlayer
import CMPageControl

class FullProfileVC: UIViewController,NPAudioStreamDelegate,CMPageControlDelegate,UICollectionViewDataSource,UICollectionViewDelegate {

    //MARK:
    //MARK: Properties
    @IBOutlet weak var btnOutletPlayPause: UIButton!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var btnOutletInsta: UIButton!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var collectionImages: UICollectionView!
    var pageControl = CMPageControl()



    var instaUrlStr = String()
    var audioStream : NPAudioStream = NPAudioStream()
    var isPlaying = Bool()
    var urlArray = [URL]()
    var isMyProfile = String()
    var userID = String()
    var bioStr = String()
    var userImageDict = [String: Any]()
    var imagesArray = [URL]()



    //MARK:
    //MARK: Outlet Connections PopUp View
    @IBOutlet weak var shortBioView: UIView!
    @IBOutlet var popUpView: UIView!
    @IBOutlet weak var lblAboutUser: UILabel!
    @IBOutlet weak var lblCategoryPopUp: UILabel!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var lblSharedFollowers: UILabel!
    @IBOutlet weak var btnInstaView: UIButton!
    @IBOutlet weak var btnPlaySongPopUpView: UIButton!

    //MARK:
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        isPlaying = false
        self.pageControl = CMPageControl(frame: CGRect(x: self.view.frame.size.width - 40, y: 64, width: 40, height: 100))
        self.pageControl.numberOfElements = 3
        self.pageControl.elementBackgroundColor = UIColor.white
        self.pageControl.elementWidth = 10.0
        self.pageControl.elementBorderWidth = 1.0
        self.pageControl.elementSelectedBorderWidth = 0.0
        self.pageControl.elementSelectedBackgroundColor = UIColor.black
        self.pageControl.elementBorderColor = UIColor.black
        self.pageControl.orientation = .vertical
        self.view.addSubview(self.pageControl)

        collectionImages.dataSource = self
        collectionImages.delegate = self
        pageControl.delegate = self
        collectionImages.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if isMyProfile == "yes" {
            self.getUser(userID: UserDefaults.SFSDefault(valueForKey: USER_ID) as! String)
        }
        else{
            let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.showPopUpView(_:)))
            shortBioView.isUserInteractionEnabled = true
            shortBioView.addGestureRecognizer(tapGesture)
            popUpView.frame = CGRect.init(x: 0, y: ScreenSize.SCREEN_HEIGHT, width: self.view.frame.size.width, height: popUpView.frame.size.height)
            self.view.addSubview(popUpView)
            popUpView.isHidden = true
            self.getUser(userID: userID)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:
    //MARK: Webservices Methods
    func getUser(userID : String)  {
        AppManager.sharedInstance.showHud(showInView: self.view, label: "")
        let para = ["user_id": userID]

        ServerManager.sharedInstance.httpPost(String(format:"%@my_profile",BASE_URL), postParams: para, SuccessHandle: { (response, url) in
            AppManager.sharedInstance.hidHud()
            let jsonResult = response as! Dictionary<String, Any>

            print("json result \(jsonResult)")
            if jsonResult["success"] as! NSNumber   == 1{
                let dataDict = jsonResult["data"] as! Dictionary<String, Any>
                
                let userDataDict = dataDict["app_users"] as! Dictionary<String, Any>
                
                self.lblUserName.text = userDataDict["full_name"] as? String
                self.bioStr = (userDataDict["bio"] as? String)!
                
                let userSettings = dataDict["user_settings"] as! Dictionary<String, Any>
                
                let cataDict = userSettings["music_industry"] as! String
            
                let musicIndustryArray:[String] = cataDict.components(separatedBy: ",")
                
                if musicIndustryArray.count >= 2 {
                    self.lblCategory.text = "\(musicIndustryArray[0]) | \(musicIndustryArray[1])"
                }
                else if musicIndustryArray.count == 1  {
                    self.lblCategory.text = "\(musicIndustryArray[0])"
                }
                else{
                    self.lblCategory.text = ""
                }
                self.btnOutletInsta.setTitle("@\(userDataDict["username"]!)", for: .normal)

                self.instaUrlStr = userDataDict["instagram_profile_link"] as! String

                self.userImageDict = dataDict["gallery"] as! Dictionary<String, Any>
                self.imagesArray.append(URL.init(string:  self.userImageDict["image1"] as! String)!)
                self.imagesArray.append(URL.init(string:  self.userImageDict["image2"] as! String)!)
                self.imagesArray.append(URL.init(string:  self.userImageDict["profile_pic"] as! String)!)
                self.collectionImages.reloadData()
                if self.urlArray.count != 0 {
                    self.urlArray.removeAll()
                }
                else{
                    let songUrl  = URL.init(string: userDataDict["music_file_url"] as! String )
                    if songUrl != nil {
                        self.urlArray.append(songUrl!)
                    }
                }

            }
            else{
                AppManager.showMessageView(view: self.view, meassage: jsonResult["error_message"] as! String)
            }

        }) { (error) in
            AppManager.showMessageView(view: self.view, meassage:error.localizedDescription)
        }
    }

    //MARK: Button actions
    @IBAction func btnPlayPause(_ sender: Any) {
        audioStream.delegate = self

        if isPlaying == false {
            btnOutletPlayPause.isSelected = true
            self.perform(#selector(self.btnPlaySongAction), on: .main, with: nil, waitUntilDone: true)
        }
        else{
            btnOutletPlayPause.isSelected = false
            self.perform(#selector(self.btnPauseSongAction), on: .main, with: nil, waitUntilDone: true)
        }
    }

    func btnPlaySongAction()  {
        audioStream.callMethod(urlArray as! NSMutableArray)
        audioStream.selectIndex(forPlayback: 0)
        audioStream.play()
        isPlaying = true
    }

    func btnPauseSongAction()  {
        audioStream.pause()
        isPlaying = false
    }

    @IBAction func goToInstaProfile(_ sender: Any) {
        if let url = URL(string: instaUrlStr ) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    @IBAction func bckBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func dismissPopUpViewAction(_ sender: Any) {
        if isPlaying == true {
            audioStream.pause()
            // infoView.btnPlayPause.setImage(UIImage.init(named: "play"), for: .normal)
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
    //MARK: Player Delegate methods

    func audioStream(_ audioStream :NPAudioStream , didUpdateTrackCurrentTime currentTime :CMTime)  {
        let time =  CMTimeGetSeconds(currentTime)
        // lblDuration.text = String(format:"%.0f Seconds",time)
        if time >= 15 {
            audioStream.pause()
            // infoView.btnPlayPause.setImage(UIImage.init(named: "play"), for: .normal)
            btnOutletPlayPause.isSelected = false
            btnOutletPlayPause.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            audioStream.seekToTime(inSeconds: 0)
            isPlaying = false
            print("Stop Player")
        }
    }
    //MARK:
    //MARK: Tap gesture Action
    func showPopUpView(_ sender : UITapGestureRecognizer) {
        if isPlaying == true {
            audioStream.pause()
            // infoView.btnPlayPause.setImage(UIImage.init(named: "play"), for: .normal)
            btnOutletPlayPause.isSelected = false
            btnOutletPlayPause.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            audioStream.seekToTime(inSeconds: 0)
            isPlaying = false
        }
        popUpView.frame = CGRect.init(x: 0, y: ScreenSize.SCREEN_HEIGHT, width: ScreenSize.SCREEN_WIDTH, height: popUpView.frame.size.height)
        lblAboutUser.text = "About \(lblUserName!.text!)".capitalized

        lblCategoryPopUp.text = lblCategory.text
        lblBio.text = bioStr
        btnInstaView.tag = (sender.view?.tag)!
        btnInstaView.setTitle(btnOutletInsta.titleLabel!.text!, for: .normal)
        btnInstaView.sizeToFit()
        btnInstaView.addTarget(self, action:#selector( self.goToInstaProfile(_:)), for: .touchUpInside)
        btnPlaySongPopUpView.addTarget(self, action: #selector(self.btnPlayPause(_:)), for: .touchUpInside)
        btnPlaySongPopUpView.tag = (sender.view?.tag)!
        btnPlaySongPopUpView.isSelected = false
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: {
            self.popUpView.isHidden = false
            self.popUpView.frame = CGRect.init(x: 0, y: ScreenSize.SCREEN_HEIGHT - self.popUpView.frame.size.height, width: ScreenSize.SCREEN_WIDTH, height: self.popUpView.frame.size.height)
        }, completion: { (finished: Bool) in
        })
    }
    //MARK: UICollectionView Datasource & Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : UICollectionViewCell = collectionImages.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageView : UIImageView  = UIImageView.init(frame: .init(x: 0, y: 0, width: (self.view.window?.bounds.size.width)!, height: (self.view.window?.bounds.size.height)! - 64 ))
        imageView.backgroundColor = UIColor.lightGray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.sd_setImage(with: imagesArray[indexPath.item])
        cell.contentView.addSubview(imageView)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.currentIndex = indexPath.row
    }
    
    // Layout: Set cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
        let mElementSize = CGSize(width: CGFloat((self.view.window?.bounds.size.width)!), height: CGFloat((self.view.window?.bounds.size.height)! - 64))
        return mElementSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    //MARK: Pagecontrol Delegates

    func elementClicked(_ pageControl: CMPageControl, atIndex: Int) {
        var frame = collectionImages.frame
        frame.origin.x = 0;
        let y : Double = Double(collectionImages.frame.size.height) *  Double(atIndex)
        frame.origin.y = CGFloat(y)
        collectionImages.scrollRectToVisible(frame, animated: true)
    }
//    func shouldChangeIndex(_ from: Int, to: Int) -> Bool {
//        return true
//    }
}
