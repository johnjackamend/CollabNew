//
//  NoInternetView.swift
//  Collab
//
//  Created by Apple01 on 6/5/17.
//  Copyright © 2017 Apple01. All rights reserved.
//

import UIKit
protocol reloadPageDelegate : class {
    func reloadPageAction()
}
class NoInternetView: UIView {
    weak var delegate:reloadPageDelegate?

    @IBAction func retryBtnAction(_ sender: Any) {
        delegate?.reloadPageAction()
    }
}
