//
//  GarbageDetailTableViewCell.swift
//  GarbageMaster
//
//  Created by 門脇裕 on 2014/11/13.
//  Copyright (c) 2014年 yu_kadowaki. All rights reserved.
//

import UIKit

class GarbageDetailTableViewCell: UITableViewCell {

    var title: UILabel = UILabel()
    var content: UILabel = UILabel()
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let screenHeight = UIScreen.mainScreen().applicationFrame.size.height
        let screenWidth = UIScreen.mainScreen().applicationFrame.size.width
        
        content = UILabel(frame: CGRect(x: screenWidth / 4 + 10, y: 0, width: screenWidth * (3 / 4) - 20 , height: 40))
        
        content.text = "content"
        self.textLabel.font = UIFont(name: "HiraKakuProN-W3", size: 17.0)
        
        self.textLabel.text = "処分時の注意"
        self.textLabel.font = UIFont(name: "HiraKakuProN-W3", size: 12.0)
        self.textLabel.textAlignment = NSTextAlignment.Center
        
        self.contentView.addSubview(content)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let screenWidth = UIScreen.mainScreen().applicationFrame.size.width
        self.textLabel.frame = CGRect(x: 0, y: 0, width: screenWidth / 4, height: self.textLabel.frame.size.height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
