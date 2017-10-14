//
//  LoginVC.swift
//  Collab
//
//  Created by Apple01 on 4/12/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    //TODO: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//TODO: Custom button actions


    @IBAction func signInInstaAction(_ sender: Any) {
        let instaloginVC = self.storyboard?.instantiateViewController(withIdentifier: "InstaLoginVC") as!
            
            
        InstaLoginVC
        self.navigationController?.pushViewController(instaloginVC, animated: true)
    }
    
    
    @IBAction func beginApplicationAction(_ sender: Any) {
        let instaloginVC = self.storyboard?.instantiateViewController(withIdentifier: "InstaLoginVC") as!
        InstaLoginVC
        self.navigationController?.pushViewController(instaloginVC, animated: true)
    }
}
