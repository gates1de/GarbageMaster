//
//  ViewController.swift
//  GarbageMaster
//
//  Created by 門脇裕 on 2014/10/15.
//  Copyright (c) 2014年 yu_kadowaki. All rights reserved.
//

import UIKit

class AddViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SelectTableViewDelegate {
    
    var tableView: UITableView = UITableView()
    
    var garbageNameLabel: UILabel = UILabel()
    var backButton: UIButton = UIButton()
    
    // SelectTableViewControllerで選択されたセル番号の格納用変数
    var garbageArray: Array<AnyObject> = []
    var timeArray: Array<AnyObject> = []
    var garbageArrayId = Int()
    var timeArrayId = Int()
    var selectedGarbage = String()
    var selectedTime = String()
    
    // enumeration用変数(flagの代わり)
    var itemArray = [Item.Garbage, Item.Time]
    var item = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "追加"
        
        garbageArray = ["燃えるごみ", "燃えないごみ", "粗大ごみ"]
        timeArray = ["明日", "明後日", "3日後", "毎週月曜日"]
        // 選択されていない時は「〜を選択」という表示にするため, 未選択状態を初期設定しておく
        garbageArrayId = -1
        timeArrayId = -1
        
        let screenHeight = UIScreen.mainScreen().applicationFrame.size.height
        let screenWidth = UIScreen.mainScreen().applicationFrame.size.width
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 60 * 3 + 40), style: UITableViewStyle.Grouped)
        tableView.scrollEnabled = false
        
        
        var labelWidth: CGFloat = 200
        var labelHeight: CGFloat = 30
        var labelX = (self.view.bounds.width - labelWidth) / 2
        var labelY = (self.view.bounds.width - labelHeight) / 5
        
        var backButtonWidth: CGFloat = 200
        var backButtonHeight: CGFloat = 30
        var backButtonX = (self.view.bounds.width - backButtonWidth) / 2
        var backButtonY = (self.view.bounds.height - backButtonHeight) / 1.5
                
        garbageNameLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight)
        garbageNameLabel.textAlignment = NSTextAlignment.Center
        
        backButton = UIButton(frame: CGRect(x: backButtonX, y: backButtonY, width: backButtonWidth, height: backButtonHeight))
        
        backButton.titleLabel?.text = "戻る"
        backButton.titleLabel?.textAlignment = NSTextAlignment.Center
        backButton.titleLabel?.textColor = UIColor.cyanColor()
        backButton.backgroundColor = UIColor.redColor()
        
        backButton.addTarget(self, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
        
        // 背景の画像を設定してブラーをかける処理
//        var image = UIImage(named: "background.jpg")
//        var imageView = UIImageView(image: image)
//        imageView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
//        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
//        visualEffectView.frame = imageView.bounds
//        imageView.addSubview(visualEffectView)
//        
//        self.view.addSubview(imageView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.addSubview(tableView)
        //self.view.addSubview(garbageNameLabel)
        self.view.addSubview(backButton)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    ///////////////////////////////// ここからTableViewを使った処理 /////////////////////////////////
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "設定"
    }
    
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
        
        item = itemArray[indexPath.row].stringValue()
        
        if item == "Garbage" {
            if garbageArrayId == -1 {
                cell.textLabel?.text = "ごみを選択してください"
            }
            else {
                cell.textLabel?.text = garbageArray[garbageArrayId] as String
            }
        }
        else if item == "Time" {
            if timeArrayId == -1 {
                cell.textLabel?.text = "通知時間を選択してください"
            }
            else {
                cell.textLabel?.text = timeArray[timeArrayId] as String
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
        item = itemArray[indexPath.row].stringValue()
        
        var selectTableViewController: SelectTableViewController = SelectTableViewController()
        
        // navigationBarの戻るボタンの文字を「back」にする
        var buckButtonItem = UIBarButtonItem(title: "back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = buckButtonItem
        
        if item == "Garbage" {
            selectTableViewController.selectedArray = garbageArray
        }
        else if item == "Time" {
            selectTableViewController.selectedArray = timeArray
        }
        
        selectTableViewController.delegate = self
        
        // 画面遷移
         self.navigationController?.pushViewController(selectTableViewController, animated: true)
    }
    
    ///////////////////////////////// TableViewを使った処理 ここまで /////////////////////////////////
    
    func back() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func selectTableViewDidChanged(selectTableViewController: SelectTableViewController) {
        if item == "Garbage" {
            garbageArrayId = selectTableViewController.arrayId
            selectedGarbage = garbageArray[garbageArrayId] as String
        }
        else if item == "Time" {
            timeArrayId = selectTableViewController.arrayId
            selectedTime = timeArray[timeArrayId] as String
        }
        tableView.reloadData()
    }
    
    enum Item {
        case Garbage, Time
        func stringValue() -> String {
            switch self {
            case .Garbage:
                return "Garbage"
            case .Time:
                return "Time"
            }
        }
    }
}
