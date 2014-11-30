//
//  ConfigViewController.swift
//  GarbageMaster
//
//  Created by 門脇裕 on 2014/11/17.
//  Copyright (c) 2014年 yu_kadowaki. All rights reserved.
//

import UIKit

protocol ConfigViewDelegate {
    func configViewDidChanged(ConfigViewController)
}

class ConfigViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SelectTableViewDelegate {
    
    var userDefaults: NSUserDefaults = NSUserDefaults()
    
    var configViewDelegate: ConfigViewDelegate? = nil
    
    var label: UILabel = UILabel()
    var button: UIButton = UIButton()
    
    var region: String = String()
    var regionArray: Array<AnyObject> = []
    var regionArrayId: Int = Int()
    
    var tableView: UITableView = UITableView()
    
    var databaseController: DatabaseController = DatabaseController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDefaults = NSUserDefaults.standardUserDefaults()

        self.title = "地域の設定"
        
        region = ""
        regionArray = databaseController.getRegion()
        regionArrayId = -1
        
        let screenHeight = UIScreen.mainScreen().applicationFrame.size.height
        let screenWidth = UIScreen.mainScreen().applicationFrame.size.width
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        
        var labelWidth: CGFloat = screenWidth / 3 * 2
        var labelHeight: CGFloat = screenHeight / 10
        var labelX = (self.view.bounds.width - labelWidth) / 2
        var labelY = (self.view.bounds.width - labelHeight) / 3
        
        label = UILabel(frame: CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight))
        label.text = "この画面で自分の住んでいる地域を設定します"
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping
        label.sizeToFit()
        
        tableView = UITableView(frame: CGRect(x: 0, y: labelY + labelHeight + 20, width: screenWidth, height: 60), style: UITableViewStyle.Plain)
        tableView.layer.borderColor = UIColor.blueColor().CGColor
        tableView.layer.borderWidth = 2.0
        tableView.layer.cornerRadius = 3.0
        tableView.scrollEnabled = false
        
        var buttonWidth: CGFloat = screenWidth / 2
        var buttonHeight: CGFloat = 30
        var buttonX = (self.view.bounds.width - buttonWidth) / 2
        var buttonY = tableView.frame.origin.y + tableView.frame.size.height + 20

        button = UIButton(frame: CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight))
        button.setTitle("決定", forState: UIControlState.Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
//        button.setTitleColor(UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0), forState: UIControlState.Highlighted)
        button.titleLabel?.textAlignment = NSTextAlignment.Center
        button.backgroundColor = UIColor.grayColor()
        button.layer.borderColor = UIColor.grayColor().CGColor
        button.layer.borderWidth = 2.0
        button.layer.cornerRadius = 5.0
        button.addTarget(self, action: "decideRegion", forControlEvents: UIControlEvents.TouchUpInside)
        button.enabled = false
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        var image = UIImage(named: "background.jpg")
        var imageView = UIImageView(image: image)
        imageView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView.frame = imageView.bounds
        imageView.addSubview(visualEffectView)
        
        self.view.addSubview(imageView)
        self.view.addSubview(label)
        self.view.addSubview(button)
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
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40.0
//    }
    
    //    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return "設定"
    //    }
    
    //    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        return self.view.bounds.height / 10
    //    }
    
    //    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        // sectionListから要素を文字列として取得(タイトルを取得)
    //        var sectionTitle: String = sectionList[section] as String
    //
    //        return sectionTitle
    //    }
    
    
    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId: String = "Cell"
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellId)
        
        if regionArrayId == -1 {
            cell.textLabel.text = "地域を選択してください"
        }
        else {
            cell.textLabel.text = regionArray[regionArrayId - 1] as String
        }
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
        var selectTableViewController: SelectTableViewController = SelectTableViewController()
        
        // navigationBarの戻るボタンの文字を「back」にする
        var buckButtonItem = UIBarButtonItem(title: "back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = buckButtonItem
        
        selectTableViewController.selectedArray = regionArray
        
        selectTableViewController.selectTableViewDelegate = self
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        // 画面遷移
        self.navigationController?.pushViewController(selectTableViewController, animated: true)
    }
    
    ///////////////////////////////// TableViewを使った処理 ここまで /////////////////////////////////
    
    func decideRegion() {
        userDefaults.setObject(region, forKey: "region")
        if userDefaults.stringForKey("first_flag") == nil {
            userDefaults.setObject(1, forKey: "first_flag")
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func selectTableViewDidChanged(selectTableViewController: SelectTableViewController) {
        regionArrayId = selectTableViewController.arrayId
        region = regionArray[regionArrayId - 1] as String
        tableView.reloadData()
        buttonEnabled()
    }
    
    func buttonEnabled() {
        if region == "" {
            button.enabled = false
        }
        else {
            button.enabled = true
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.backgroundColor = UIColor(red: 0.9, green: 0.28, blue: 0.25, alpha: 1.0)
            button.layer.borderColor = UIColor(red: 0.9, green: 0.28, blue: 0.25, alpha: 1.0).CGColor
        }
    }
}
