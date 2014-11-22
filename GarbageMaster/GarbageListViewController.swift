//
//  GarbageListViewController.swift
//  GarbageMaster
//
//  Created by 門脇裕 on 2014/10/11.
//  Copyright (c) 2014年 yu_kadowaki. All rights reserved.
//

import UIKit

class CustomScrollView: UIScrollView {
    override func scrollRectToVisible(rect: CGRect, animated: Bool) {
        
    }
}

class GarbageListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate, AddViewDelegate {

    var userDefaults: NSUserDefaults = NSUserDefaults()
    
    var sectionList: Array<AnyObject> = []

//    var todayGarbageList: Array<AnyObject> = []
//    var tomorrowGarbageList: Array<AnyObject> = []
//    var dayAfterTomorrowGarbageList: Array<AnyObject> = []
//    var afterThreeDaysGarbageList: Array<AnyObject> = []
//    var afterFourDaysGarbageList: Array<AnyObject> = []
//    var afterFiveDaysGarbageList: Array<AnyObject> = []
//    var afterSixDaysGarbageList: Array<AnyObject> = []
//    var afterSevenDaysGarbageList: Array<AnyObject> = []

    var arrayList: Array<AnyObject> = []
    
    var dataSource: NSMutableDictionary = [:]
    
    var scrollView: UIScrollView = CustomScrollView()
    var tableView: UITableView = UITableView()
    var logo: UIImage = UIImage()
    var logoView: UIImageView = UIImageView()
    var button: UIButton = UIButton()
    
    var tabBarHeight: CGFloat = CGFloat()
    
    // NTYCSVTable専用変数
    var parseCSV: ParseCSV = ParseCSV()
    
    // FMDB専用変数
    var databaseController: DatabaseController = DatabaseController()
    
    var addViewNavigationController: UINavigationController = UINavigationController()
    var configViewNavigationController: UINavigationController = UINavigationController()
    
    var array: Array<AnyObject> = []
    
    var region: String = String()
    var startFlag: Int = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDefaults = NSUserDefaults.standardUserDefaults()
        
        startFlag = userDefaults.integerForKey("start_flag")
        
        databaseController.initDb()

//        notify(array)
        if startFlag == 0 {
            getCSVData()
            // databaseController.selectCollectionDays()
            // CSVデータをパースするとともに, 各テーブルにデータを挿入する
            parseCSV.parseGomibunbetsuCSV(databaseController)
            parseCSV.parseGomiyoubiCSV(databaseController)
            userDefaults.setObject(1, forKey: "start_flag")
        }
        
        self.title = "GarbageList"
        
        sectionList = ["今日", "明日", "明後日", "3日後", "4日後", "5日後", "6日後", "7日後"]

        arrayList = databaseController.getGarbageData()
        
        var count = arrayList.count
        
        for (var i = 0; i < count; i++) {
            if arrayList.count > i {
                if arrayList[i].count == 0 {
                    arrayList.removeAtIndex(i)
                    sectionList.removeAtIndex(i)
                    i--
                }
            }
            else {
                break
            }
        }
        
        dataSource = NSMutableDictionary(objects: arrayList, forKeys: sectionList)
        
        let screenHeight = UIScreen.mainScreen().applicationFrame.size.height
        let screenWidth = UIScreen.mainScreen().applicationFrame.size.width
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        //tabBarHeight = (self.tabBarController?.tabBar.frame.size.height)!
        
        let logoViewWidth = screenWidth / 4 * 3
        let logoViewHeight = screenHeight / 6
        let logoViewX = (screenWidth - logoViewWidth) / 2
        let logoViewY = navigationBarHeight! + statusBarHeight
        
        logo = UIImage(named: "GarbageMaster_Logo.png")!
        logoView = UIImageView(image: logo)
        logoView.frame = CGRectMake(logoViewX, logoViewY, logoViewWidth, logoViewHeight)

//        self.automaticallyAdjustsScrollViewInsets = false
//        scrollView.setTranslatesAutoresizingMaskIntoConstraints(true)
//        scrollView = UIScrollView(frame: CGRect(x: 0, y: navigationBarHeight! + statusBarHeight, width: screenWidth, height: screenHeight))
//        scrollView.contentSize = CGSizeMake(screenWidth, screenHeight + 200)
//        scrollView.pagingEnabled = true

        tableView = UITableView(frame: CGRect(x: 0, y: logoViewY + logoViewHeight, width: screenWidth, height: screenHeight - logoViewHeight - navigationBarHeight!), style: UITableViewStyle.Plain)
        tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, screenWidth, navigationBarHeight!))
        tableView.tableFooterView?.hidden = true
        tableView.backgroundColor = UIColor.clearColor()
        
//        // buttonに関する記述(とっておいてるやつ)
        button = UIButton(frame: CGRectMake(0, 0, screenWidth, navigationBarHeight!))
        button.setTitle("button", forState: .Normal)
        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        
        tableView.dataSource = self
        tableView.delegate = self
        //self.tabBarController?.delegate = self
        
        scrollView.addSubview(tableView)
        
        // 背景の画像を設定してブラーをかける処理
        var image = UIImage(named: "background2.jpg")
        var imageView = UIImageView(image: image)
        imageView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView.frame = imageView.bounds
        imageView.addSubview(visualEffectView)
        
        // tableView.tableFooterView = button
        self.view.addSubview(imageView)
        self.view.addSubview(logoView)
        self.view.addSubview(tableView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        regionCheck()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
///////////////////////////////// ここからTableViewを使った処理 /////////////////////////////////
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // footerをheader代わりに使うため, sectionを一個分増やす
        return sectionList.count + 1
    }
    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 0 {
//            return nil
//        }
//        var sectionTitle: String = sectionList[section - 1] as String
//        
//        var headerSectionLabel: UILabel = UILabel()
//        headerSectionLabel.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height / 10)
//        headerSectionLabel.backgroundColor = UIColor(red: 0.18, green: 0.8, blue: 0.44, alpha: 0.8)
//        headerSectionLabel.textAlignment = NSTextAlignment.Center
//        headerSectionLabel.text = sectionTitle
//        headerSectionLabel.textColor = UIColor.whiteColor()
//        
//        return headerSectionLabel
//    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section >= sectionList.count {
            return nil
        }
        var sectionTitle: String = sectionList[section] as String
        
        var headerSectionLabel: UILabel = UILabel()
        headerSectionLabel.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height / 10)
        headerSectionLabel.backgroundColor = UIColor(red: 0.18, green: 0.8, blue: 0.44, alpha: 0.8)
        headerSectionLabel.textAlignment = NSTextAlignment.Center
        headerSectionLabel.text = sectionTitle
        headerSectionLabel.textColor = UIColor.whiteColor()
        
        return headerSectionLabel
    }
    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return self.view.bounds.height / 11
//    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section >= sectionList.count {
            return 0.0
        }
        return self.view.bounds.height / 11
    }

//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        // sectionListから要素を文字列として取得(タイトルを取得)
//        var sectionTitle: String = sectionList[section] as String
//        
//        return sectionTitle
//    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        var sectionTitle: String = sectionList[section - 1] as String
        // dataSourceからsectionのタイトルをキーとしてゴミリストの配列を取得
        var dataArray: Array<AnyObject> = dataSource.objectForKey(sectionTitle) as Array
        let x: CGFloat = 0.0
        let y: CGFloat = 40.0
        let height: CGFloat = 80.0 * CGFloat(dataArray.count)
        //tableView.frame = CGRectMake(x, y, self.view.frame.width, height)
        return dataArray.count
    }
    
    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // println("indexPath.section = \(indexPath.section), indexPath.row = \(indexPath.row)")

        
        var sectionTitle: String = sectionList[indexPath.section] as String
        var dataArray: Array<AnyObject> = dataSource.objectForKey(sectionTitle) as Array
        
        if editingStyle == .Delete {
            NSLog("Delete = %@", dataArray[indexPath.row]["item"] as String)
            var garbageListIdString: String = dataArray[indexPath.row]["garbageListId"] as String
            databaseController.deleteGarbageData(garbageListIdString.toInt()!)
            dataArray.removeAtIndex(indexPath.row)
            dataSource.setValue(dataArray, forKey: sectionTitle)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

            if dataArray.count == 0 {
                dataSource.removeObjectForKey(sectionTitle)
                sectionList.removeAtIndex(indexPath.section)
                tableView.reloadData()
            }
        } else if editingStyle == .Insert {
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId: String = "Cell"
        
        var sectionTitle: String = sectionList[indexPath.section - 1] as String
        var dataArray: Array<AnyObject> = dataSource.objectForKey(sectionTitle) as Array
        // println("\(dataArray)")
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellId)
        cell.textLabel.text = dataArray[indexPath.row]["item"] as String
        cell.detailTextLabel?.text = dataArray[indexPath.row]["division"] as String
        cell.detailTextLabel?.textColor = UIColor.redColor()
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let detailViewController = DetailViewController()
        
        var sectionTitle: String = sectionList[indexPath.section - 1] as String
        var dataArray: Array<AnyObject> = dataSource.objectForKey(sectionTitle) as Array
        
        detailViewController.garbageNameLabel.text = dataArray[indexPath.row]["item"] as String
        detailViewController.garbageDataArray = dataArray[indexPath.row]
        
        // databaseController.insertQuery(dataArray[indexPath.row] as String)
        
        // navigationBarの戻るボタンの文字を「back」にする
        var buckButtonItem = UIBarButtonItem(title: "back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = buckButtonItem
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        // 画面遷移
        self.navigationController?.pushViewController(detailViewController, animated: true)
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
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
        let addViewController = AddViewController()
        addViewController.garbageNameLabel.text = "追加画面だよ"
        addViewController.backButton.titleLabel?.text = "戻る"

        addViewController.databaseController = databaseController
        addViewController.addViewDelegate = self

        //addViewController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        
        addViewNavigationController = UINavigationController(rootViewController: addViewController)
        addViewNavigationController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        
        self.presentViewController(addViewNavigationController, animated: true, completion: nil)
        
    }
    
    func getCSVData() {
        // 各地域のごみ別収集曜日のCSVデータを取得
        let remoteCSVPath1 = NSURL(string: "http://www.city.nagareyama.chiba.jp/dbps_data/_material_/localhost/gomiyoubi_2.csv".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        let CSVName1 = "gomiyoubi_2.csv"
        parseCSV.getCSV(remoteCSVPath1!, CSVName: CSVName1)
        
        // ごみの品目・区別・処分時注意のCSVデータを取得
        let remoteCSVPath2 = NSURL(string: "http://www.city.nagareyama.chiba.jp/dbps_data/_material_/localhost/gomibunbetu.csv".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        let CSVName2 = "gomibunbetsu.csv"
        parseCSV.getCSV(remoteCSVPath2!, CSVName: CSVName2)
    }
    
    func notify(item: Array<AnyObject>) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "testNotification:", name: "Test Notification", object: nil)
        
        var notification: UILocalNotification = UILocalNotification()
        notification.category = "category"
        notification.alertBody = "あぁ^~"
        notification.alertAction = "OK"
        notification.fireDate = NSDate(timeIntervalSinceNow: 10)
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func addViewDidChanged(addViewController: AddViewController) {
        arrayList.removeAll(keepCapacity: false)
        arrayList = addViewController.arrayList
        sectionList = ["今日", "明日", "明後日", "3日後", "4日後", "5日後", "6日後", "7日後"]
        var count = arrayList.count
        
        for (var i = 0; i < count; i++) {
            if arrayList.count > i {
                if arrayList[i].count == 0 {
                    arrayList.removeAtIndex(i)
                    sectionList.removeAtIndex(i)
                    i--
                }
            }
            else {
                break
            }
        }
        dataSource.removeAllObjects()
        dataSource = NSMutableDictionary(objects: arrayList, forKeys: sectionList)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func testNotification(notification: NSNotification) {
        println("test notification")
    }
    
    func regionCheck() {
        let region = userDefaults.stringForKey("region")
        println("region = \(region)")

        if region == nil {
            let configViewController = ConfigViewController()
            configViewController.label.text = "まずこの画面で地域の設定を行いましょう"
            configViewController.button.titleLabel?.text = "戻る"
            
            configViewController.databaseController = databaseController
            
            configViewNavigationController = UINavigationController(rootViewController: configViewController)
            configViewNavigationController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
            
            self.presentViewController(configViewNavigationController, animated: true, completion: nil)
        }
    }
    
}
