//
//  Inputbar.swift
//  Whatsapp
//
//  Created by Rafael Castro on 7/11/15. / Swift Version by Breno Oliveira on 02/18/16.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

import UIKit

let RIGHT_BUTTON_SIZE:CGFloat = 60
let LEFT_BUTTON_SIZE:CGFloat = 45

@objc protocol InputbarDelegate:NSObjectProtocol {
    func inputbarDidPressRightButton(inputbar:Inputbar)
    func inputbarDidPressLeftButton(inputbar:Inputbar)

@objc optional func inputbarDidChangeHeight(newHeight:CGFloat)
@objc optional func inputbarDidBecomeFirstResponder(inputbar:Inputbar)
}

class Inputbar: UIToolbar, HPGrowingTextViewDelegate {

    var inputDelegate:InputbarDelegate!
    
    var textView:HPGrowingTextView!
    var rightButton:UIButton!
    var leftButton:UIButton!
    
    var placeholder:String! {
        didSet {
            self.textView.placeholder = self.placeholder
        }
    }
    var leftButtonImage:UIImage! {
        didSet {
            self.leftButton?.setImage(self.leftButtonImage, for:.normal)
        }
    }
    var rightButtonTextColor:UIColor! {
        didSet {
            self.rightButton?.setTitleColor(self.rightButtonTextColor, for:.normal)
        }
    }
    var rightButtonText:String! {
        didSet {
            self.rightButton?.setTitle(self.rightButtonText, for:.normal)
        }
    }
    
    
    var text:String {
        return self.textView.text
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.addContent()
    }
    
    func addContent() {
        self.addTextView()
        self.addRightButton()
        //self.addLeftButton()
        
        self.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
    }
    
    func addTextView() {
        let size = self.frame.size
        self.textView = HPGrowingTextView(frame:CGRect(x:8,
                                                        y:5,
                                                       width:size.width - RIGHT_BUTTON_SIZE,
                                                       height:size.height))
        self.textView.isScrollable = false
        self.textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5)
        
        self.textView.minNumberOfLines = 1
        self.textView.maxNumberOfLines = 6
        // you can also set the maximum height in points with maxHeight
        // self.textView.maxHeight = 200;
        self.textView.returnKeyType = .go
        self.textView.font = UIFont.systemFont(ofSize: 15)
        self.textView.delegate = self
        self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0)
        self.textView.backgroundColor = UIColor.white
        self.textView.placeholder = self.placeholder
        
        //self.textView.autocapitalizationType = .Sentences
        self.textView.keyboardType = .default
        self.textView.returnKeyType = .default
        self.textView.enablesReturnKeyAutomatically = true
        //self.textView.scrollIndicatorInsets = UIEdgeInsetsMake(0, -1, 0, 1)
        //self.textView.textContainerInset = UIEdgeInsetsMake(8, 4, 8, 0)
        self.textView.layer.cornerRadius = 5
        self.textView.layer.borderWidth = 0.5
        self.textView.layer.borderColor =  UIColor(red:200/255 ,green:200/255, blue:205/255, alpha:1).cgColor
        
        self.textView.autoresizingMask = .flexibleWidth;
        
        // view hierachy
        self.addSubview(self.textView)
    }
    
    func addRightButton() {
        let size = self.frame.size
        
        self.rightButton = UIButton()
        self.rightButton.frame = CGRect(x:size.width - RIGHT_BUTTON_SIZE,y: 0, width:RIGHT_BUTTON_SIZE,height: size.height)
        self.rightButton.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
        self.rightButton.setTitleColor(UIColor.blue, for:.normal)
        self.rightButton.setTitleColor(UIColor.lightGray, for:.selected)
        self.rightButton.setTitle("Done", for:.normal)
        self.rightButton.titleLabel!.font = UIFont(name:"Helvetica", size:15)
        
        self.rightButton.addTarget(self, action: #selector(Inputbar.didPressRightButton(sender:)), for:.touchUpInside)
        
        self.addSubview(self.rightButton)
        
        self.rightButton.isSelected = true
    }
    
    func addLeftButton() {
        let size = self.frame.size
        
        self.leftButton = UIButton()
        self.leftButton.frame = CGRect(x:0,y: 0,width: LEFT_BUTTON_SIZE,height: size.height)
        self.leftButton.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        self.leftButton.setImage(self.leftButtonImage, for:.normal)
        
        self.leftButton.addTarget(self, action:#selector(Inputbar.didPressLeftButton(sender:)), for:.touchUpInside)
        
        self.addSubview(self.leftButton)
    }
    
    func inputResignFirstResponder() {
        self.textView.resignFirstResponder()
    }


    // MARK: - Delegate

    func didPressRightButton(sender:UIButton) {
        if self.rightButton.isSelected {
            return
        }
        
        self.inputDelegate?.inputbarDidPressRightButton(inputbar: self)
        self.textView.text = ""
    }
    
    func didPressLeftButton(sender:UIButton) {
        self.inputDelegate?.inputbarDidPressLeftButton(inputbar: self)
    }

    // MARK: - HPGrowingTextView

    func growingTextView(_ growingTextView: HPGrowingTextView!, willChangeHeight height: Float) {
        let diff = growingTextView.frame.size.height - CGFloat(height)
        
        var r = self.frame
        r.size.height -= diff
        r.origin.y += diff
        self.frame = r
        
        if self.inputDelegate != nil && self.inputDelegate!.responds(to: #selector(InputbarDelegate.inputbarDidChangeHeight(newHeight:))) {
            self.inputDelegate.inputbarDidChangeHeight!(newHeight: self.frame.size.height)
        }
    }
    
    func growingTextViewDidBeginEditing(_ growingTextView: HPGrowingTextView!) {
        if self.inputDelegate != nil && self.inputDelegate!.responds(to: #selector(InputbarDelegate.inputbarDidBecomeFirstResponder(inputbar:))) {
            self.inputDelegate.inputbarDidBecomeFirstResponder!(inputbar: self)
        }
    }

    
    func growingTextViewDidChange(_ growingTextView: HPGrowingTextView!) {
        let text = growingTextView.text.replacingOccurrences(of: " ", with:"")
        if text.characters.count == 0 {
            self.rightButton.isSelected = true
        }
        else {
            self.rightButton.isSelected = false
        }
    }
}
