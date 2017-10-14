//
//  WelcomeVC.swift
//  Collab
//
//  Created by Apple01 on 4/13/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {
    
    @IBOutlet var lblWelcome: UILabel!
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        lblWelcome.numberOfLines = 3
   //lblWelcome.calculateFontSizeAccordingToWidth(labelFrame: lblWelcome.frame)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: Button Actions
    @IBAction func btnNextAction(_ sender: Any) {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC

    self.navigationController?.pushViewController(loginVC, animated: true)
    }
   
}
