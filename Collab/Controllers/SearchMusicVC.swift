

//
//  SearchMusicVC.swift
//  Collab
//
//  Created by Apple01 on 4/17/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit
protocol PassSongData {
    func addSong(songDict : NSDictionary)
}
class SearchMusicVC: UIViewController,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource {

    var delegate:PassSongData?

    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var noResultsView: UIView!
    @IBOutlet weak var musicSearchBar: UISearchBar!
    @IBOutlet weak var tblSearchResults: UITableView!
    var searchArray  = Array<SearchModel> ()

    //MARK:UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        musicSearchBar.delegate = self

        
        tblSearchResults.isHidden = true
//        lblMessage.adjustsFontSizeToFitWidth = true
        
        tblSearchResults.delegate = self
        tblSearchResults.dataSource = self
        tblSearchResults.isHidden = true
        tblSearchResults.estimatedRowHeight = 60
        tblSearchResults.rowHeight = UITableViewAutomaticDimension
        tblSearchResults.tableFooterView = UIView()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:Search Songs Methods

    @IBAction func backBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func searchMusic(searchStr: NSString) {
       // AppManager.sharedInstance.showHud(showInView: self.view, label: "")

        let searchTerm = searchStr.replacingOccurrences(of: " ", with: "+")

        if searchTerm != "" {
            let urlStr = String(format:"http://api.soundcloud.com/tracks.json?client_id=355503a68ddc02f17cb5d10afdf7548e&q=%@&limit=10",searchTerm)
            let searchUrl = NSURL.init(string: urlStr)
            DispatchQueue.global(qos: .userInitiated).async {
                let data = NSData.init(contentsOf: searchUrl! as URL )
                if data != nil{
                    self.perform(#selector(self.fetchedData(data:)), on: .main, with: data, waitUntilDone: true)
                }
            }
        }
        else{
            tblSearchResults.isHidden = true
        }
    }

    func fetchedData(data:NSData)  {
        if searchArray.count != 0 {
            self.searchArray.removeAll()
        }
        do
        {
            let dataArray = try JSONSerialization.jsonObject(with: data as  Data, options: JSONSerialization.ReadingOptions(rawValue: UInt(0))) as? NSArray

            for item in dataArray! { // loop through data items
                let dict :[String:Any] = (item as? [String:Any])!
                let obj = SearchModel(dict as Dictionary<String, AnyObject>)
                self.searchArray.append(obj)
            }
            AppManager.sharedInstance.hidHud()
            DispatchQueue.main.async {
                print(self.searchArray)
                if self.searchArray.count != 0{
                    self.tblSearchResults.isHidden = false
                    self.lblMessage.isHidden = true
                    self.tblSearchResults.isHidden = false
                    AppManager.sharedInstance.hidHud()
                    self.tblSearchResults.reloadData()
                }
                else{
                     AppManager.sharedInstance.hidHud()
                    self.tblSearchResults.isHidden = true
                }
            }

        } catch  {
            print("json error: \(error)")
        }
    }

    //MARK:
    //MARK: UITableView Datasource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblSearchResults.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell

        let searchModel: SearchModel = self.searchArray[indexPath.row]
        cell.lblSongName.text = searchModel.songName
        cell.lblSongName.sizeToFit()
        var imageUrl = NSURL()

        if searchModel.songImageUrl != nil {
            imageUrl = NSURL.init(string: searchModel.songImageUrl!)!
        }
        cell.ivSong.setImageWith(imageUrl as URL, placeholderImage: UIImage.init(named: "img"))

        return cell
    }

    //MARK:
    //MARK: UITableView Delegate Methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let searchModel: SearchModel = self.searchArray[indexPath.row]
        let dataDict  = NSMutableDictionary()

        let songUrl = String(format:"%@?client_id=355503a68ddc02f17cb5d10afdf7548e",searchModel.songUrl!)
        print(songUrl)

        dataDict.setValue(searchModel.songName, forKey: "songName")
        dataDict.setValue(songUrl, forKey: "songUrl")

        self.delegate?.addSong(songDict: dataDict)
        self.dismiss(animated: true, completion: nil)

    }

    //MARK:UISearchBar Delegate Methods

    func searchBar(_ searchBar: UISearchBar,
                   shouldChangeTextIn range: NSRange,
                   replacementText text: String) -> Bool{
        let searchTerm = NSString(string: searchBar.text!).replacingCharacters(in: range, with: text)
        
        if searchTerm.characters.count > 0 {
            self.searchMusic(searchStr: searchTerm as NSString)
        }else{
            self.tblSearchResults.isHidden = true
            self.lblMessage.isHidden = false
        }
        
        
        return true

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            tblSearchResults.isHidden = true
             searchBar.resignFirstResponder()

        }
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool{

 NotificationCenter.default.post(name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        return true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {

    }
    
}
