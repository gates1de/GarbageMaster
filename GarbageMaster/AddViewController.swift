//
//  ViewController.swift
//  GarbageMaster
//
//  Created by 門脇裕 on 2014/10/15.
//  Copyright (c) 2014年 yu_kadowaki. All rights reserved.
//

import UIKit

protocol AddViewDelegate {
    func addViewDidChanged(AddViewController)
}

class AddViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SelectTableViewDelegate {
    
    var addViewDelegate: AddViewDelegate? = nil
    
    var tableView: UITableView = UITableView()
    var tableViewCellHeight: CGFloat = CGFloat()
    
    var garbageNameLabel: UILabel = UILabel()
    var backButton: UIButton = UIButton()
    var addButton: UIButton = UIButton()
    
    // SelectTableViewControllerで選択されたセル番号の格納用変数
    var garbageItemArray: Array<AnyObject> = []
    var dateArray: Array<AnyObject> = []
    var timeArray: Array<AnyObject> = []
    var garbageItemArrayId = Int()
    var timeArrayId = Int()
    var selectedGarbage = String()

    var initTime: NSDate = NSDate()
    var weekday = String()
    
    var dateFormatter: NSDateFormatter = NSDateFormatter()
    
    // enumeration用変数(flagの代わり)
    var itemArray = [Item.Garbage, Item.Time]
    var item = String()
    
    // 入力したデータをGarbageListViewControllerの配列にも追加するための変数
    var arrayList: Array<AnyObject> = []
    var weekdayDictionary: Dictionary<String, String> = Dictionary<String, String>()
    
    var addFlag = Int()
    
    var databaseController: DatabaseController = DatabaseController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "捨てるごみの追加"
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateFormat = "HH:mm"
        
        garbageItemArray = databaseController.selectGarbages()
        dateArray = ["ゴミ収集日の前日", "ゴミ収集日の当日"]
        // 未入力を判定するために, 入力項目は初期値として空文字を設定する
        selectedGarbage = ""
        
        // 選択されていない時は「〜を選択」という表示にするため, 未選択状態を初期設定しておく
        garbageItemArrayId = -1
        timeArrayId = -1
        addFlag = -1
        
        let screenHeight = UIScreen.mainScreen().applicationFrame.size.height
        let screenWidth = UIScreen.mainScreen().applicationFrame.size.width
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        
        var tableViewWidth = screenWidth / 4 * 3
        var tableViewHeight = screenHeight / 8
        var tableViewX = (screenWidth - tableViewWidth) / 2
        var tableViewY = (screenHeight - tableViewHeight) / 2
        tableViewCellHeight = screenWidth / 8
        
        var labelWidth: CGFloat = 200
        var labelHeight: CGFloat = 30
        var labelX = (self.view.bounds.width - labelWidth) / 2
        var labelY = (self.view.bounds.width - labelHeight) / 5
        
        var backButtonWidth: CGFloat = screenWidth / 2
        var backButtonHeight: CGFloat = screenHeight / 10
        var backButtonX = (self.view.bounds.width - backButtonWidth) / 2
        var backButtonY = (self.view.bounds.height - backButtonHeight) / 1.5
        
        // 背景の画像を設定してブラーをかける処理
        var image = UIImage(named: "background2.jpg")
        var imageView = UIImageView(image: image)
        imageView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView.frame = imageView.bounds
        imageView.addSubview(visualEffectView)
        
        // ロゴの設定
        var logo = UIImage(named: "GarbageMaster_Logo2.png")!
        var logoView = UIImageView(image: logo)
        logoView.frame = CGRectMake(0, screenWidth / 4, screenWidth, screenHeight / 2)
        
        // tableViewの設定
        tableView = UITableView(frame: CGRect(x: tableViewX, y: tableViewY, width: tableViewWidth, height: tableViewCellHeight), style: UITableViewStyle.Plain)
        tableView.tableHeaderView = UIView(frame: CGRectZero)
        tableView.tableHeaderView?.hidden = true
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.tableFooterView?.hidden = true
        tableView.backgroundColor = UIColor.clearColor()
        tableView.layer.borderColor = UIColor.blackColor().CGColor
        tableView.layer.borderWidth = 2.0
        tableView.layer.cornerRadius = 3.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.scrollEnabled = false

        // 「追加する」ボタンの設定
        addButton = UIButton(frame: CGRect(x: backButtonX, y: logoView.frame.origin.y + logoView.frame.size.height + 20, width: backButtonWidth, height: backButtonHeight))
        addButton.titleLabel?.textAlignment = NSTextAlignment.Center
        addButton.setTitle("追加する", forState: UIControlState.Normal)
        addButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        addButton.backgroundColor = UIColor.grayColor()
        addButton.layer.borderColor = UIColor.grayColor().CGColor
        addButton.layer.borderWidth = 2.0
        addButton.layer.cornerRadius = 5.0
        addButton.addTarget(self, action: "addData", forControlEvents: UIControlEvents.TouchUpInside)
        addButton.enabled = false
        
        // 「戻る」ボタンの設定
        backButton = UIButton(frame: CGRect(x: backButtonX, y: addButton.frame.origin.y + addButton.frame.size.height + 20, width: backButtonWidth, height: backButtonHeight))
        backButton.titleLabel?.textAlignment = NSTextAlignment.Center
        backButton.setTitle("戻る", forState: UIControlState.Normal)
//        backButton.setTitleColor(UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0), forState: UIControlState.Normal)
        backButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        backButton.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        backButton.layer.borderColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0).CGColor
        backButton.layer.borderWidth = 2.0
        backButton.layer.cornerRadius = 5.0
        backButton.addTarget(self, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        self.view.addSubview(imageView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.addSubview(logoView)
        self.view.addSubview(tableView)
        self.view.addSubview(backButton)
        self.view.addSubview(addButton)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    ///////////////////////////////// ここからTableViewを使った処理 /////////////////////////////////
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableViewCellHeight
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
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        item = itemArray[indexPath.row].stringValue()
        
        if garbageItemArrayId == -1 {
            cell.textLabel.text = "ごみを選択してください"
        }
        else {
            cell.textLabel.text = garbageItemArray[garbageItemArrayId - 1] as String
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
        var selectTableViewController: SelectTableViewController = SelectTableViewController()
        
        // navigationBarの戻るボタンの文字を「back」にする
        var buckButtonItem = UIBarButtonItem(title: "back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = buckButtonItem
        
        selectTableViewController.selectedArray = garbageItemArray
        
        selectTableViewController.selectTableViewDelegate = self
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        // 画面遷移
         self.navigationController?.pushViewController(selectTableViewController, animated: true)
    }
    
    ///////////////////////////////// TableViewを使った処理 ここまで /////////////////////////////////
    

    func back() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addData() {
        addFlag = 1
        databaseController.insertGarbageLists(garbageItemArrayId)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // selectTableViewControllerでアイテムが選択された時に, 画面が戻るのでその時に選択されたアイテムを保存するメソッド
    func selectTableViewDidChanged(selectTableViewController: SelectTableViewController) {
        garbageItemArrayId = selectTableViewController.arrayId
        selectedGarbage = garbageItemArray[garbageItemArrayId - 1] as String

        tableView.reloadData()
        addButtonEnabled()
    }
    
    func addButtonEnabled() {
        if selectedGarbage == "" {
            addButton.enabled = false
        }
        else {
            addButton.enabled = true
            addButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            addButton.backgroundColor = UIColor(red: 0.9, green: 0.28, blue: 0.25, alpha: 1.0)
            addButton.layer.borderColor = UIColor(red: 0.9, green: 0.28, blue: 0.25, alpha: 1.0).CGColor
        }
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
    
    override func viewDidDisappear(animated: Bool) {
        if addFlag == 1 {
            func reload() -> Void {
                arrayList = databaseController.getGarbageData()
                weekdayDictionary = databaseController.weekdayDictionary
                return addViewDelegate!.addViewDidChanged(self)
            }
            reload()
        }
    }
}
