//
//  ViewController.swift
//  GarbageMaster
//
//  Created by 門脇裕 on 2014/10/11.
//  Copyright (c) 2014年 yu_kadowaki. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var garbageNameLabel: UILabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "ViewController"
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        var labelWidth: CGFloat = 200
        var labelHeight: CGFloat = 30
        var labelX = (self.view.bounds.width - labelWidth) / 2
        var labelY = (self.view.bounds.width - labelHeight) / 5
        
        self.garbageNameLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight)
        self.garbageNameLabel.textAlignment = NSTextAlignment.Center
        
        self.view.addSubview(self.garbageNameLabel)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

