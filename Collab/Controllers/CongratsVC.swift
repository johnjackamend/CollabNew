//
//  CongratsVC.swift
//  Collab
//
//  Created by Apple01 on 4/13/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit

class CongratsVC: UIViewController {
    @IBOutlet weak var ivCongrats: UIImageView!
    var isFlashing = Bool()



    //MARK:UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.tapNextButton( _ :)))
        ivCongrats.isUserInteractionEnabled = true
        ivCongrats .addGestureRecognizer(tapGesture)
        self.startFlashingbutton()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

     //MARK:Tap Gesture Action
    func tapNextButton(_ sender : UITapGestureRecognizer)  {

        AppDelegate.sharedDelegate.moveToFeedVC(index: 0)
        
    }

    func startFlashingbutton() {
        if isFlashing {
            return
        }
        isFlashing = true
        ivCongrats.alpha = 0.0
        UIView.animate(withDuration: 1.75, delay: 0.0, options: [.curveEaseOut,.repeat,.autoreverse, .allowUserInteraction], animations: {() -> Void in
            self.ivCongrats.alpha = 1.0
        }, completion: {(_ finished: Bool) -> Void in
            // Do nothing
        })
    }
}
