//
//  NotifySettingViewController.swift
//  GarbageMaster
//
//  Created by 門脇裕 on 2014/11/25.
//  Copyright (c) 2014年 yu_kadowaki. All rights reserved.
//

import UIKit

protocol NotifySettingViewDelegate {
    func notifySettingViewDidChanged(NotifySettingViewController)
}

class NotifySettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TimeSettingViewDelegate {

    var notifySettingViewDelegate: NotifySettingViewDelegate? = nil
    
    var tableView: UITableView = UITableView()
    var tableViewCellAndFooterHeight: CGFloat = CGFloat()
    
    var databaseController: DatabaseController = DatabaseController()
    
    var arrayList: Array<AnyObject> = []
    var weekdayDictionary: Dictionary<String, String> = Dictionary<String, String>()
    
    var garbageNotifyDataArray: Array<AnyObject> = []
    var garbageDistinctionArray: Array<AnyObject> = []
    var notifyTimeArray: Array<AnyObject> = []
    var notifyDayArray: Array<AnyObject> = []
    var notifyTime: String = String()
    var selectedSectionId: Int = Int()
    
    var alizarinColor: UIColor = UIColor()
    var sunFlowerColor: UIColor = UIColor()
    var peterRiverColor: UIColor = UIColor()
    var emeraldColor: UIColor = UIColor()
    var amethystColor: UIColor = UIColor()
    var concreteColor: UIColor = UIColor()
    var colorDictionary: Dictionary<String, UIColor> = Dictionary<String, UIColor>()
    
    var toTimeSettingFlag: Int = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "通知時間一覧"
        self.view.backgroundColor = UIColor.whiteColor()
        
        toTimeSettingFlag = 0
        
        alizarinColor = UIColor(red: 0.9, green: 0.3, blue: 0.25, alpha: 1.0)
        sunFlowerColor = UIColor(red: 0.95, green: 0.76, blue: 0.06, alpha: 1.0)
        peterRiverColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        emeraldColor = UIColor(red: 0.18, green: 0.8, blue: 0.44, alpha: 0.8)
        amethystColor = UIColor(red: 0.61, green: 0.35, blue: 0.71, alpha: 1.0)
        concreteColor = UIColor(red: 0.58, green: 0.62, blue: 0.62, alpha: 1.0)
        
        colorDictionary = ["燃やすごみ" : alizarinColor, "容器包装プラスチック類" : sunFlowerColor, "燃やさないごみ" : peterRiverColor, "ペットボトル" : emeraldColor, "有害・危険ごみ" : amethystColor, "資源ごみ" : concreteColor, "粗大ごみ" : concreteColor, "処理困難物" : concreteColor, "市では処理できないごみ" : concreteColor, "家電リサイクル法対象品" : concreteColor, "パソコンリサイクル対象品" : concreteColor]
        
        garbageDistinctionArray = ["燃やすごみ", "容器包装プラスチック類", "燃やさないごみ", "ペットボトル", "有害・危険ごみ"]
        notifyDayArray = ["ごみ出し日当日", "ごみ出し日前日"]
        notifyTimeArray = ["なし", "なし", "なし", "なし", "なし"]
        
        let screenHeight = UIScreen.mainScreen().applicationFrame.size.height
        let screenWidth = UIScreen.mainScreen().applicationFrame.size.width
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        let tabBarHeight = (self.tabBarController?.tabBar.frame.size.height)!
        tableViewCellAndFooterHeight = (screenHeight - navigationBarHeight! - statusBarHeight) / 10
        
        self.tabBarController?.tabBar.hidden = true
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight), style: UITableViewStyle.Plain)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.tableFooterView?.hidden = true
        tableView.backgroundColor = UIColor.clearColor()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        
        self.view.addSubview(tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    ///////////////////////////////// ここからTableViewを使った処理 /////////////////////////////////
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return garbageNotifyDataArray.count + 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableViewCellAndFooterHeight
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section >= garbageNotifyDataArray.count {
            return 0.0
        }
        return tableViewCellAndFooterHeight
    }
    
    //    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return "設定"
    //    }
    
    //    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        return self.view.bounds.height / 10
    //    }
    
//        func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//            var sectionTitle: String = garbageDistinctionArray[section] as String
//    
//            return sectionTitle
//        }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        //        if section >= sectionList.count {
        //            return nil
        //        }
        var sectionTitle: String = garbageDistinctionArray[section] as String
        
        var headerSectionLabel: UILabel = UILabel()
        headerSectionLabel.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height / 10)
        headerSectionLabel.backgroundColor = colorDictionary[sectionTitle]
        headerSectionLabel.textAlignment = NSTextAlignment.Center
        headerSectionLabel.text = sectionTitle
        headerSectionLabel.textColor = UIColor.whiteColor()
        
        return headerSectionLabel
    }
    
    
//    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
//        return true
//    }
    
//    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId: String = "Cell"
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellId)
        var notifyDay: String = String()
        var notifyDayNum = garbageNotifyDataArray[indexPath.section - 1][1] as Int
        notifyDay = notifyDayArray[notifyDayNum] as String
        var notifyHourTime = garbageNotifyDataArray[indexPath.section - 1][2] as String
        cell.textLabel.text = "\(notifyDay) の \(notifyHourTime)"
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        selectedSectionId = indexPath.section - 1
        
        var timeSettingViewController: TimeSettingViewController = TimeSettingViewController()
        timeSettingViewController.title = "通知時間の設定"
        timeSettingViewController.databaseController = databaseController
        timeSettingViewController.selectedSectionId = selectedSectionId
        
        var selectedDayNum = garbageNotifyDataArray[selectedSectionId][1] as Int
        var selectedHourTime = garbageNotifyDataArray[selectedSectionId][2] as String
        
        timeSettingViewController.selectedDayNum = selectedDayNum
        timeSettingViewController.selectedHourTime = selectedHourTime
        timeSettingViewController.notifyDayArray = notifyDayArray
        timeSettingViewController.selectedDay = notifyDayArray[selectedDayNum] as String
        
        var dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateFormat = "HH:mm"
        
        timeSettingViewController.initTime = dateFormatter.dateFromString(selectedHourTime)!
        timeSettingViewController.timePicker.date = timeSettingViewController.initTime
        timeSettingViewController.datePickerView.selectRow(selectedDayNum, inComponent: 0, animated: true)
        
        // navigationBarの戻るボタンの文字を「back」にする
        var buckButtonItem = UIBarButtonItem(title: "back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = buckButtonItem
        
//        selectTableViewController.selectedArray = garbageItemArray
        
        timeSettingViewController.timeSettingViewDelegate = self
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        // 画面遷移
        self.navigationController?.pushViewController(timeSettingViewController, animated: true)
    }
    
    ///////////////////////////////// TableViewを使った処理 ここまで /////////////////////////////////
    
    func timeSettingViewDidChanged(timeSettingViewController: TimeSettingViewController) {
        toTimeSettingFlag = 1

//        garbageNotifyDataArray.removeAll(keepCapacity: false)
        garbageNotifyDataArray = timeSettingViewController.garbageNotifyDataArray
        arrayList = databaseController.getGarbageData()
        weekdayDictionary = databaseController.weekdayDictionary
//        notifyTimeArray[selectedSectionId] = timeSettingViewController.selectedTime
//        println("garbageNotifyDataArray = \(garbageNotifyDataArray)")
        var notificationArray = UIApplication.sharedApplication().scheduledLocalNotifications
        for var i = 0; i < notificationArray.count; i++ {
            println("fireDate = \(notificationArray[i].fireDate)")
        }
        tableView.reloadData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        if toTimeSettingFlag == 1 {
            notifySettingViewDelegate!.notifySettingViewDidChanged(self)
        }
    }
}
