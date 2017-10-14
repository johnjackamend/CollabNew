//
//  MessageCell.swift
//  Whatsapp
//
//  Created by Rafael Castro on 7/23/15. / Swift Version by Breno Oliveira on 02/18/16.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

import UIKit


class MessageCell:UITableViewCell {
    
    private var timeLabel:UILabel!
    private var textView:UITextView!
    private var bubbleImage:UIImageView!
    private var statusIcon:UIImageView!
    
    var resendButton:UIButton!
    
    var message:Message! {
        didSet {
            self.buildCell()
            message.height = self.height
        }
    }
    

    var height:CGFloat! {
        get {
            return self.bubbleImage.frame.size.height
        }
    }
    
    
    func updateMessageStatus() {
        self.buildCell()
        //Animate Transition
        self.statusIcon.alpha = 0
        UIView.animate(withDuration: 0.5, animations:{
            self.statusIcon.alpha = 1
        })
    }

    // MARK: -

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }

    func commonInit() {
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        self.accessoryType = .none
        
        self.textView = UITextView()
        self.bubbleImage = UIImageView()
        self.timeLabel = UILabel()
        //self.statusIcon = UIImageView()
        self.resendButton = UIButton()
        self.resendButton.isHidden = true
        
        self.contentView.addSubview(self.bubbleImage)
        self.contentView.addSubview(self.textView)
        self.contentView.addSubview(self.timeLabel)
       // self.contentView.addSubview(self.statusIcon)
        self.contentView.addSubview(self.resendButton)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.textView.text = ""
        self.timeLabel.text = ""
      //  self.statusIcon.image = nil
        self.bubbleImage.image = nil
        self.resendButton.isHidden = true
    }

    func buildCell() {
        self.setTextView()
        self.setTimeLabel()
        self.setBubble()
        
//        self.addStatusIcon()
//        self.setStatusIcon()

        self.setFailedButton()
        
        self.setNeedsLayout()
    }

    // MARK: - TextView

    func setTextView() {
        let maxWitdh = 0.7*self.contentView.frame.size.width 
        self.textView.frame = CGRect(x:0,y: 0,width: maxWitdh,height: CGFloat(MAXFLOAT))
        self.textView.font = UIFont(name:"Helvetica", size:17)
        self.textView.backgroundColor = UIColor.clear
        self.textView.isUserInteractionEnabled = false
        
        self.textView.text = self.message.text
        self.textView.sizeToFit()
        
        var textViewX:CGFloat
        var textViewY:CGFloat
        let textViewW = self.textView.frame.size.width
        let textViewH = self.textView.frame.size.height + 7
        
        var autoresizing:UIViewAutoresizing
        
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if self.message.sender == .Myself {
            textViewX = self.contentView.frame.size.width - textViewW - 20
            textViewY = -1
            autoresizing = .flexibleLeftMargin
            textViewX -= self.isSingleLineCase() ? 65 : 0
            textViewX -= self.isStatusFailedCase() ? (self.failDelta()-15) : 0
        }
        else {
            textViewX = 10
            textViewY = -1
            autoresizing = .flexibleRightMargin;
        }
        
        self.textView.autoresizingMask = autoresizing
        self.textView.frame = CGRect(x:textViewX,y: textViewY,width: textViewW,height: textViewH)
    }

    // MARK: - TimeLabel

    func setTimeLabel() {
        self.timeLabel.frame = CGRect(x:0,y: 0,width: 52,height: 14)
        self.timeLabel.textColor = UIColor.lightGray
        self.timeLabel.font = UIFont(name:"Helvetica", size:12)
        self.timeLabel.isUserInteractionEnabled = false
        self.timeLabel.alpha = 0.7
        self.timeLabel.textAlignment = .right
        
        //Set Text to Label
        let df = DateFormatter()
        df.timeStyle = .short
        df.dateStyle = .none
        df.doesRelativeDateFormatting = true
        self.timeLabel.text = df.string(from: message.date as Date)
        
        //Set position
        var timeX:CGFloat
        var timeY = self.textView.frame.size.height - 10
        
        if self.message.sender == .Myself
        {
            timeX = self.textView.frame.origin.x + self.textView.frame.size.width - self.timeLabel.frame.size.width + 3
        }
        else
        {
            timeX = max(self.textView.frame.origin.x + self.textView.frame.size.width - self.timeLabel.frame.size.width,
                         self.textView.frame.origin.x)
        }
        
        if self.isSingleLineCase() {
            timeX = self.textView.frame.origin.x + self.textView.frame.size.width + 15

            timeY -= 15
        }
        
        self.timeLabel.frame = CGRect(x:timeX,y: timeY,width: self.timeLabel.frame.size.width, height:self.timeLabel.frame.size.height);
        self.timeLabel.autoresizingMask = self.textView.autoresizingMask
    }

    func isSingleLineCase() -> Bool {
        let deltaX:CGFloat = self.message.sender == .Myself ? 65.0 : 44
        
        let textViewHeight = self.textView.frame.size.height
        let textViewWidth = self.textView.frame.size.width
        let viewWidth = self.contentView.frame.size.width
        
        //Single Line Case
        return (textViewHeight <= 45 && textViewWidth + deltaX <= 0.8*viewWidth) ? true : false
    }

    // MARK: - Bubble

    func setBubble() {
        //Margins to Bubble
        let marginLeft:CGFloat = 10
        let marginRight:CGFloat = 2
        
        //Bubble positions
        var bubbleX:CGFloat
        let bubbleY:CGFloat = 0
        var bubbleWidth:CGFloat
        let bubbleHeight:CGFloat = min(self.textView.frame.size.height + 8, self.timeLabel.frame.origin.y + self.timeLabel.frame.size.height + 6)
        
        if (self.message.sender == .Myself) {
            
            bubbleX = min(self.textView.frame.origin.x - marginLeft, self.timeLabel.frame.origin.x - 2*marginLeft)
            
            self.bubbleImage.image = self.imageNamed(imageName: "bubbleMine").stretchableImage(withLeftCapWidth:15, topCapHeight:14)
            
            
            bubbleWidth = self.contentView.frame.size.width - bubbleX - marginRight
            bubbleWidth -= self.isStatusFailedCase() ? self.failDelta() : 0
        }
        else
        {
            bubbleX = marginRight;
            
            self.bubbleImage.image = self.imageNamed(imageName: "bubbleSomeone").stretchableImage(withLeftCapWidth:21, topCapHeight:14)
            
            bubbleWidth = max(self.textView.frame.origin.x + self.textView.frame.size.width + marginLeft,
                               self.timeLabel.frame.origin.x + self.timeLabel.frame.size.width + 2*marginLeft)
        }
        
        self.bubbleImage.frame = CGRect(x:bubbleX,y: bubbleY,width: bubbleWidth, height: bubbleHeight)
        self.bubbleImage.autoresizingMask = self.textView.autoresizingMask
    }

    // MARK: - StatusIcon

    func addStatusIcon() {
        let timeFrame = self.timeLabel.frame
        var statusFrame = CGRect(x:0,y: 0,width: 15,height: 14)
        statusFrame.origin.x = timeFrame.origin.x + timeFrame.size.width + 5
        statusFrame.origin.y = timeFrame.origin.y
       // self.statusIcon.frame = statusFrame
       // self.statusIcon.contentMode = .left
       // self.statusIcon.autoresizingMask = self.textView.autoresizingMask
    }
    func setStatusIcon() {
        switch self.message.status {
        case .Sending:
            self.statusIcon.image = self.imageNamed(imageName: "status_sending")
        case .Sent:
            self.statusIcon.image = self.imageNamed(imageName: "status_sent")
        case .Received:
            self.statusIcon.image = self.imageNamed(imageName: "status_notified")
        case .Read:
            self.statusIcon.image = self.imageNamed(imageName: "status_read")
        case .Failed:
            self.statusIcon.image = nil
        }

        self.statusIcon.isHidden = self.message.sender == .Someone
    }

    // MARK: - Failed Case

    //
    // This delta is how much TextView
    // and Bubble should shit left
    //
    func failDelta() -> CGFloat {
        return 60
    }
    
    func isStatusFailedCase() -> Bool {
        return self.message.status == .Failed
    }
    
    func setFailedButton() {
        let bSize:CGFloat = 22;
        let frame = CGRect(x:self.contentView.frame.size.width - bSize - self.failDelta()/2 + 5,
                           y:(self.contentView.frame.size.height - bSize)/2,
                           width:bSize,
                           height:bSize);
        
        self.resendButton.frame = frame
        self.resendButton.isHidden = !self.isStatusFailedCase()
       self.resendButton.setImage(self.imageNamed(imageName: "status_failed"), for:.normal)
    }

    // MARK: - UIImage Helper

    func imageNamed(imageName:String) -> UIImage {
        return UIImage(named:imageName)!
    }
}
