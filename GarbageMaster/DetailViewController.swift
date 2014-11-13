//
//  ViewController.swift
//  GarbageMaster
//
//  Created by 門脇裕 on 2014/10/11.
//  Copyright (c) 2014年 yu_kadowaki. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var garbageNameLabel: UILabel = UILabel()
    var garbageDataArray: AnyObject = []
    
    var tableView: UITableView = UITableView()
    var detailTableViewCell: UITableViewCell = UITableViewCell()
    
    var screenHeight: CGFloat = CGFloat()
    var screenWidth: CGFloat = CGFloat()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "ViewController"
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        println("garbageDataArray = \(garbageDataArray), count = \(garbageDataArray.count)")
        
        screenHeight = UIScreen.mainScreen().applicationFrame.size.height
        screenWidth = UIScreen.mainScreen().applicationFrame.size.width
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        let statusBarWidth = UIApplication.sharedApplication().statusBarFrame.size.width
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height
        
        var labelHeight: CGFloat = screenHeight / 12
        var labelY = statusBarHeight + navigationBarHeight!
        
        garbageNameLabel.frame = CGRectMake(0, labelY, screenWidth, labelHeight)
        garbageNameLabel.textColor = UIColor.whiteColor()
        garbageNameLabel.textAlignment = NSTextAlignment.Center
        garbageNameLabel.backgroundColor = UIColor(red: 0.16, green: 0.5, blue: 0.73, alpha: 1.0)
        
        self.view.addSubview(garbageNameLabel)
        
        tableView = UITableView(frame: CGRect(x: 0, y: labelY + labelHeight, width: screenWidth, height: screenHeight / 2))
        tableView.registerClass(GarbageDetailTableViewCell.classForCoder(), forCellReuseIdentifier: "GarbageDetailTableViewCell")
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.tableFooterView?.hidden = true
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollEnabled = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.addSubview(tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///////////////////////////////// ここからTableViewを使った処理 /////////////////////////////////
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*
         * -4しているのは, garbage_idとgarbage_lists_idとitemはtableViewに表示しない,
         * かつ, notifyDateとnotifyTimeを一緒のセルに表示するため
        */
        return garbageDataArray.count - 4
    }
    
    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GarbageDetailTableViewCell", forIndexPath: indexPath) as GarbageDetailTableViewCell
        cell.textLabel!.backgroundColor = UIColor.cyanColor()
        cell.content.lineBreakMode = NSLineBreakMode.ByCharWrapping
        cell.content.numberOfLines = 0
        cell.content.frame.size.width = screenWidth * (3 / 4) - 20
        cell.content.frame.size.height = cell.frame.size.height
        switch(indexPath.row) {
            case 0:
                cell.textLabel!.text = "分別区分"
                cell.content.text = garbageDataArray["division"] as String
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            case 1:
                cell.textLabel!.text = "収集曜日"
                cell.content.text = garbageDataArray["weekday"] as String
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            case 2:
                cell.textLabel!.text = "通知時間"
                let notifyDate = garbageDataArray["notifyDate"] as String
                let notifyTime = garbageDataArray["notifyTime"] as String
                cell.content.text = "\(notifyDate)  の  \(notifyTime)"
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            case 3:
                cell.textLabel!.text = "処分時の注意"
                cell.content.text = garbageDataArray["attention"] as String
                cell.content.frame.size.height += 20
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            default:
                cell.textLabel!.text = "?"
                cell.content.text = "?"
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let maxSize: CGSize = CGSizeMake(screenWidth, screenHeight);
        
        if indexPath.row == 3 {
            var text = garbageDataArray["attention"] as String
        
            let attr: Dictionary = [NSFontAttributeName: UIFont.boldSystemFontOfSize(17.0)]
        
            let modifySize: CGSize = text.boundingRectWithSize(maxSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attr, context: nil).size
            if modifySize.height <= 44.0 {
                return 44.0
            }
            
            return modifySize.height + 20
        }
        
        return 44.0
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if(self.tableView.respondsToSelector(Selector("setSeparatorInset:"))){
            self.tableView.separatorInset = UIEdgeInsetsZero
        }
        
        if(self.tableView.respondsToSelector(Selector("setLayoutMargins:"))){
            self.tableView.layoutMargins = UIEdgeInsetsZero
        }
        
        if(cell.respondsToSelector(Selector("setLayoutMargins:"))){
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    ///////////////////////////////// TableViewを使った処理 ここまで /////////////////////////////////


}

