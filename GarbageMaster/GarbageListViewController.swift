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

class GarbageListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate, AddViewDelegate, NotifySettingViewDelegate {

    var userDefaults: NSUserDefaults = NSUserDefaults()
    
    var sectionList: Array<AnyObject> = []
    var arrayList: Array<AnyObject> = []
    var weekdayDictionary: Dictionary<String, String> = Dictionary<String, String>()
    var garbageNotifyDataArray: Array<AnyObject> = []
    
    var dataSource: NSMutableDictionary = [:]
    
    var scrollView: UIScrollView = CustomScrollView()
    var tableView: UITableView = UITableView()
    
    var logo: UIImage = UIImage()
    var logoView: UIImageView = UIImageView()
    var noDataImage: UIImage = UIImage()
    var noDataImageView: UIImageView = UIImageView()
    var button: UIButton = UIButton()
    
    var tabBarHeight: CGFloat = CGFloat()
    var cellHeight: CGFloat = CGFloat()
    
    // NTYCSVTable専用変数
    var parseCSV: ParseCSV = ParseCSV()
    
    // FMDB専用変数
    var databaseController: DatabaseController = DatabaseController()
    
    var addViewNavigationController: UINavigationController = UINavigationController()
    var configViewNavigationController: UINavigationController = UINavigationController()
    
    var array: Array<AnyObject> = []
    
    var region: String = String()
    var startFlag: Int = Int()
    
    var alizarinColor: UIColor = UIColor()
    var sunFlowerColor: UIColor = UIColor()
    var peterRiverColor: UIColor = UIColor()
    var emeraldColor: UIColor = UIColor()
    var amethystColor: UIColor = UIColor()
    var concreteColor: UIColor = UIColor()
    var colorArray: Array<AnyObject> = []
    var colorDictionary: Dictionary<String, UIColor> = Dictionary<String, UIColor>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "捨てるごみを追加"
        self.navigationItem.title = "捨てるごみリスト"
        region = ""
        
        alizarinColor = UIColor(red: 0.9, green: 0.3, blue: 0.25, alpha: 1.0)
        sunFlowerColor = UIColor(red: 0.95, green: 0.76, blue: 0.06, alpha: 1.0)
        peterRiverColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        emeraldColor = UIColor(red: 0.18, green: 0.8, blue: 0.44, alpha: 0.8)
        amethystColor = UIColor(red: 0.61, green: 0.35, blue: 0.71, alpha: 1.0)
        concreteColor = UIColor(red: 0.58, green: 0.62, blue: 0.62, alpha: 1.0)
        
        colorArray = [alizarinColor, sunFlowerColor, peterRiverColor, emeraldColor, amethystColor, concreteColor]
        colorDictionary = ["燃やすごみ" : alizarinColor, "容器包装プラスチック類" : sunFlowerColor, "燃やさないごみ" : peterRiverColor, "ペットボトル" : emeraldColor, "有害・危険ごみ" : amethystColor, "資源ごみ" : concreteColor, "粗大ごみ" : concreteColor, "処理困難物" : concreteColor, "市では処理できないごみ" : concreteColor, "家電リサイクル法対象品" : concreteColor, "パソコンリサイクル対象品" : concreteColor]
        
        userDefaults = NSUserDefaults.standardUserDefaults()
        
        startFlag = userDefaults.integerForKey("start_flag")
        
        databaseController.initDb()

        // 一度もアプリを開いたことがなければDBの初期化処理
        if startFlag == 0 {
            getCSVData()
            // CSVデータをパースするとともに, 各テーブルにデータを挿入する
            parseCSV.parseGomibunbetsuCSV(databaseController)
            parseCSV.parseGomiyoubiCSV(databaseController)
            
            databaseController.insertNotifyTime(["combustibles", 0, "07:00"])
            databaseController.insertNotifyTime(["plastic", 0, "07:00"])
            databaseController.insertNotifyTime(["incombustibles", 0, "07:00"])
            databaseController.insertNotifyTime(["plasticBottle", 0, "07:00"])
            databaseController.insertNotifyTime(["dangerousGarbage", 0, "07:00"])
            garbageNotifyDataArray = databaseController.getNotifyTime()
            
            userDefaults.setObject(1, forKey: "start_flag")
        }
        else {
            regionCheck()
            println("region = \(region)")
            if region != "" {
            sectionList = ["燃やすごみ", "容器包装プラスチック類", "燃やさないごみ", "ペットボトル", "有害・危険ごみ", "資源ごみ", "粗大ごみ", "処理困難物", "市では処理できないごみ", "家電リサイクル法対象品", "パソコンリサイクル対象品"]
            
            garbageNotifyDataArray = databaseController.getNotifyTime()
            arrayList = databaseController.getGarbageData()
            weekdayDictionary = databaseController.weekdayDictionary
            
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
//            println("dataSource = \(dataSource)")
            }
        }
        
        let rightBarButtonItem = UIBarButtonItem(title: "通知設定", style: UIBarButtonItemStyle.Plain, target: self, action: "toNotifySetting:")
        self.navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: false)
        
        let screenHeight = UIScreen.mainScreen().applicationFrame.size.height
        let screenWidth = UIScreen.mainScreen().applicationFrame.size.width
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        //tabBarHeight = (self.tabBarController?.tabBar.frame.size.height)!
        
        let logoViewWidth = screenWidth / 4 * 3
        let logoViewHeight = screenHeight / 6
        let logoViewX = (screenWidth - logoViewWidth) / 2
        let logoViewY = navigationBarHeight! + statusBarHeight
        
        let noDataImageViewWidth = screenWidth / 10 * 9
        let noDataImageViewHeight = screenHeight / 5
        let noDataImageViewX = (screenWidth - noDataImageViewWidth) / 2
        let noDataImageViewY = screenHeight - noDataImageViewHeight - navigationBarHeight!
        
        noDataImage = UIImage(named: "GarbageMaster_Logo3.png")!
        noDataImageView = UIImageView(image: noDataImage)
        noDataImageView.frame = CGRectMake(noDataImageViewX, noDataImageViewY, noDataImageViewWidth, noDataImageViewHeight)
        
        logo = UIImage(named: "GarbageMaster_Logo1.png")!
        logoView = UIImageView(image: logo)
        logoView.frame = CGRectMake(logoViewX, logoViewY, logoViewWidth, logoViewHeight)

//        self.automaticallyAdjustsScrollViewInsets = false
//        scrollView.setTranslatesAutoresizingMaskIntoConstraints(true)
//        scrollView = UIScrollView(frame: CGRect(x: 0, y: navigationBarHeight! + statusBarHeight, width: screenWidth, height: screenHeight))
//        scrollView.contentSize = CGSizeMake(screenWidth, screenHeight + 200)
//        scrollView.pagingEnabled = true

        tableView = UITableView(frame: CGRect(x: 0, y: logoViewY + logoViewHeight, width: screenWidth, height: screenHeight - logoViewHeight - navigationBarHeight!), style: UITableViewStyle.Grouped)
        tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, screenWidth, navigationBarHeight!))
        tableView.tableFooterView?.hidden = true
        tableView.backgroundColor = UIColor.clearColor()
        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.layer.borderColor = UIColor.blueColor().CGColor
//        tableView.layer.borderWidth = 2.0
//        tableView.layer.cornerRadius = 3.0

        
//        // buttonに関する記述(とっておいてるやつ)
        button = UIButton(frame: CGRectMake(0, 0, screenWidth, navigationBarHeight!))
        button.setTitle("button", forState: .Normal)
        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        
        tableView.dataSource = self
        tableView.delegate = self
        self.tabBarController?.delegate = self
        
        scrollView.addSubview(tableView)
        
        // 背景の画像を設定してブラーをかける処理
        var image = UIImage(named: "background2.jpg")
        var imageView = UIImageView(image: image)
        imageView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView.frame = imageView.bounds
        imageView.addSubview(visualEffectView)
        
        // 各区分のごみの数を数えて格納する変数
        var count = sectionList.count
        println("count = \(count)")
        
        self.view.addSubview(imageView)
        if count == 0 {
            self.view.addSubview(noDataImageView)
        }
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
//        return sectionList.count + 1
        return sectionList.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section >= sectionList.count {
//            return nil
//        }
        var sectionTitle: String = sectionList[section] as String
        var weekday: String = String()
        
        var headerSectionLabel: UILabel = UILabel()
        headerSectionLabel.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height / 10)
        headerSectionLabel.backgroundColor = colorDictionary[sectionTitle]
        headerSectionLabel.textAlignment = NSTextAlignment.Center
        headerSectionLabel.font = UIFont(name: "HelveticaNeue-Bold",size:16)
        if sectionTitle == "資源ごみ" || sectionTitle == "粗大ごみ" || sectionTitle == "資源ごみ" || sectionTitle == "処理困難物" || sectionTitle == "市では処理できないごみ" || sectionTitle == "家電リサイクル法対象品" || sectionTitle == "パソコンリサイクル対象品" {
            headerSectionLabel.text = sectionTitle
        }
        else {
            println("sectionTitle = \(sectionTitle)")
            weekday = weekdayDictionary[sectionTitle]!
            headerSectionLabel.text = "\(sectionTitle) → 収集日 :  \(weekday)"
        }

//        headerSectionLabel.text = sectionTitle
        headerSectionLabel.textColor = UIColor.whiteColor()
        
        return headerSectionLabel
    }
        
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section >= sectionList.count {
//            return 0.0
//        }
        return self.view.bounds.height / 11
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return 0
//        }
//        var sectionTitle: String = sectionList[section - 1] as String
        var sectionTitle: String = sectionList[section] as String

        // dataSourceからsectionのタイトルをキーとしてゴミリストの配列を取得
        var dataArray: Array<AnyObject> = dataSource.objectForKey(sectionTitle) as Array
        let x: CGFloat = 0.0
        let y: CGFloat = 40.0
        let height: CGFloat = 80.0 * CGFloat(dataArray.count)
        return dataArray.count
    }
    
    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // println("indexPath.section = \(indexPath.section), indexPath.row = \(indexPath.row)")

        
//        var sectionTitle: String = sectionList[indexPath.section - 1] as String
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
//                sectionList.removeAtIndex(indexPath.section - 1)
                sectionList.removeAtIndex(indexPath.section)
                
                var count = sectionList.count
                println("count = \(count)")
                
                if count == 0 {
                    self.view.addSubview(noDataImageView)
                }

                tableView.reloadData()
            }
            reloadData(databaseController.getGarbageData())
//            arrayList.removeAll(keepCapacity: false)
//            arrayList = databaseController.getGarbageData()
//            dataSource.removeAllObjects()
//            dataSource = NSMutableDictionary(objects: arrayList, forKeys: sectionList)
        } else if editingStyle == .Insert {
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId: String = "Cell"
        
//        var sectionTitle: String = sectionList[indexPath.section - 1] as String
        var sectionTitle: String = sectionList[indexPath.section] as String
        var dataArray: Array<AnyObject> = dataSource.objectForKey(sectionTitle) as Array
        // println("\(dataArray)")
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellId)
        cell.textLabel.text = dataArray[indexPath.row]["item"] as String
        cell.textLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        cell.textLabel.numberOfLines = 0
        //        cell.content.frame.size.width = screenWidth * (3 / 4) - 20
        cell.textLabel.frame.size.height = cell.frame.size.height
        cell.textLabel.font = UIFont.systemFontOfSize(16)
        cellHeight = cell.frame.size.height
        cell.textLabel.frame.size.height += 20
//        cell.detailTextLabel?.text = dataArray[indexPath.row]["division"] as String
//        cell.detailTextLabel?.textColor = UIColor.redColor()
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let detailViewController = DetailViewController()
        
//        var sectionTitle: String = sectionList[indexPath.section - 1] as String
        var sectionTitle: String = sectionList[indexPath.section] as String

        var dataArray: Array<AnyObject> = dataSource.objectForKey(sectionTitle) as Array
        
        detailViewController.garbageNameLabel.text = dataArray[indexPath.row]["item"] as String
        detailViewController.garbageDataArray = dataArray[indexPath.row]
        
        // databaseController.insertQuery(dataArray[indexPath.row] as String)
        
        // navigationBarの戻るボタンの文字を「back」にする
        let backButtonItem = UIBarButtonItem(title: "back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        self.navigationItem.backBarButtonItem = backButtonItem
        
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
        weekdayDictionary = addViewController.weekdayDictionary
        reloadData(addViewController.arrayList)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func notifySettingViewDidChanged(notifySettingViewController: NotifySettingViewController) {
        garbageNotifyDataArray = notifySettingViewController.garbageNotifyDataArray
        weekdayDictionary = notifySettingViewController.weekdayDictionary
        arrayList.removeAll(keepCapacity: false)
        arrayList = notifySettingViewController.arrayList
        reloadData(arrayList)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func reloadData(list: Array<AnyObject>) {
        arrayList = list
        sectionList = ["燃やすごみ", "容器包装プラスチック類", "燃やさないごみ", "ペットボトル", "有害・危険ごみ", "資源ごみ", "粗大ごみ", "処理困難物", "市では処理できないごみ", "家電リサイクル法対象品", "パソコンリサイクル対象品"]
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
        var sectionListCount = sectionList.count
        
        if sectionListCount != 0 {
            noDataImageView.removeFromSuperview()
        }
        
        tableView.reloadData()
    }
    
    func testNotification(notification: NSNotification) {
        println("test notification")
    }
    
    func regionCheck() {
        let region = userDefaults.stringForKey("region")

        if region == nil {
            let configViewController = ConfigViewController()
            configViewController.label.text = "まずはこの画面で自分の住んでいる地域の設定を行いましょう!"
            configViewController.button.titleLabel?.text = "戻る"
            
            configViewController.databaseController = databaseController
            
            configViewNavigationController = UINavigationController(rootViewController: configViewController)
            configViewNavigationController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
            
            self.presentViewController(configViewNavigationController, animated: true, completion: nil)
        }
        else {
            self.region = region!
            println("region = \(region)")
        }
    }
    
    func toNotifySetting(sender: UIButton) {
        let notifySettingViewController = NotifySettingViewController()
        // navigationBarの戻るボタンの文字を「back」にする
        let backButtonItem = UIBarButtonItem(title: "back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        self.navigationItem.backBarButtonItem = backButtonItem
        
        notifySettingViewController.databaseController = databaseController
        notifySettingViewController.arrayList = arrayList
        notifySettingViewController.garbageNotifyDataArray = garbageNotifyDataArray
        notifySettingViewController.notifySettingViewDelegate = self
        
        notifySettingViewController.hidesBottomBarWhenPushed = true
        
        // 画面遷移
        self.navigationController?.pushViewController(notifySettingViewController, animated: true)
    }
    
}
