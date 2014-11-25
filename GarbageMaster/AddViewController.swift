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

class AddViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, SelectTableViewDelegate {
    
    var addViewDelegate: AddViewDelegate? = nil
    
    var tableView: UITableView = UITableView()
    
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
    var selectedDate = String()
    var selectedTime = String()

    var initTime: NSDate = NSDate()
    var weekday = String()
    
    var dateFormatter: NSDateFormatter = NSDateFormatter()
    
    var datePickerView = UIPickerView()
    var timePicker = UIDatePicker()
    
    // enumeration用変数(flagの代わり)
    var itemArray = [Item.Garbage, Item.Time]
    var item = String()
    
    // 入力したデータをGarbageListViewControllerの配列にも追加するための変数
    var arrayList: Array<AnyObject> = []
    
    var addFlag = Int()
    
    var databaseController: DatabaseController = DatabaseController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var notificationArray = UIApplication.sharedApplication().scheduledLocalNotifications
        for var i = 0; i < notificationArray.count; i++ {
            println("fireDate = \(notificationArray[i].fireDate)")
        }
        
        self.title = "追加"
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateFormat = "HH:mm"
        
        garbageItemArray = databaseController.selectGarbages()
        dateArray = ["ゴミ収集日の前日", "ゴミ収集日の当日"]
        // 未入力を判定するために, 入力項目は初期値として空文字を設定する
        selectedGarbage = ""
        selectedDate = "ゴミ収集日の当日"
        selectedTime = "07:00"
        initTime = dateFormatter.dateFromString("07:00")!

        // 選択されていない時は「〜を選択」という表示にするため, 未選択状態を初期設定しておく
        garbageItemArrayId = -1
        timeArrayId = -1
        addFlag = -1
        
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
        
        datePickerView.frame = CGRectMake(0, tableView.frame.size.height + 10, screenWidth / 2, 100)
        
        timePicker.frame = CGRectMake(screenWidth / 2, tableView.frame.size.height + 10, screenWidth / 2, 100)
        timePicker.datePickerMode = UIDatePickerMode.Time
        timePicker.date = initTime
        timePicker.addTarget(self, action: "selectTime", forControlEvents: UIControlEvents.ValueChanged)

        
        addButton = UIButton(frame: CGRect(x: 0, y: timePicker.frame.origin.y + timePicker.frame.size.height + 20, width: screenWidth, height: backButtonHeight))
        addButton.titleLabel?.textAlignment = NSTextAlignment.Center
        addButton.setTitle("追加する", forState: UIControlState.Normal)
        addButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        addButton.addTarget(self, action: "addData", forControlEvents: UIControlEvents.TouchUpInside)
        addButton.enabled = false
        
        backButton = UIButton(frame: CGRect(x: backButtonX, y: addButton.frame.origin.y + addButton.frame.size.height + 20, width: backButtonWidth, height: backButtonHeight))
        backButton.titleLabel?.textAlignment = NSTextAlignment.Center
        backButton.setTitle("戻る", forState: UIControlState.Normal)
        backButton.setTitleColor(UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0), forState: UIControlState.Normal)
        //        backButton.layer.borderColor = UIColor.grayColor().CGColor
        //        backButton.layer.borderWidth = 2.0
        //        backButton.layer.cornerRadius = 5.0
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
        
        datePickerView.delegate = self
        datePickerView.dataSource = self
        // 通知の日付(ごみ出し日当日かごみ出し日前日)の初期値は「ごみ出し日当日」にしておく
        datePickerView.selectRow(1, inComponent: 0, animated: false)
        
        self.view.addSubview(tableView)
        //self.view.addSubview(garbageNameLabel)
        self.view.addSubview(backButton)
        self.view.addSubview(addButton)
        self.view.addSubview(datePickerView)
        self.view.addSubview(timePicker)
//        var viewsDictionary: Dictionary = ["datePicker" : datePicker]
//        backButton.setTranslatesAutoresizingMaskIntoConstraints(false)
//        datePicker.setTranslatesAutoresizingMaskIntoConstraints(false)
//        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-100-[datePicker]", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
//        backButton.addConstraints(constraints)

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
        return 60.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
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
        
        item = itemArray[indexPath.row].stringValue()
        
        if item == "Garbage" {
            if garbageItemArrayId == -1 {
                cell.textLabel.text = "ごみを選択してください"
            }
            else {
                cell.textLabel.text = garbageItemArray[garbageItemArrayId - 1] as String
            }
        }
        else if item == "Time" {
            if timeArrayId == -1 {
                cell.textLabel.text = "通知時間を選択してください"
            }
            else {
                cell.textLabel.text = timeArray[timeArrayId] as String
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
            selectTableViewController.selectedArray = garbageItemArray
        }
        else if item == "Time" {
            selectTableViewController.selectedArray = timeArray
        }
        
        selectTableViewController.selectTableViewDelegate = self
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        // 画面遷移
         self.navigationController?.pushViewController(selectTableViewController, animated: true)
    }
    
    ///////////////////////////////// TableViewを使った処理 ここまで /////////////////////////////////
    
    
    ///////////////////////////////// PickerViewを使った処理 ここから /////////////////////////////////
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return dateArray.count
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100.0
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 32.0
    }
    
    func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String!{
        return "\(dateArray[row])"
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.frame.size.width, height: pickerView.frame.size.height))
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(18)
        label.text = dateArray[row] as String
        
        return label
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDate = dateArray[row] as String
    }
    
    ///////////////////////////////// PickerViewを使った処理 ここまで /////////////////////////////////

    func back() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addData() {
        addFlag = 1
        databaseController.insertGarbageLists([garbageItemArrayId, selectedDate, selectedTime])
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // selectTableViewControllerでアイテムが選択された時に, 画面が戻るのでその時に選択されたアイテムを保存するメソッド
    func selectTableViewDidChanged(selectTableViewController: SelectTableViewController) {
        if item == "Garbage" {
            garbageItemArrayId = selectTableViewController.arrayId
            selectedGarbage = garbageItemArray[garbageItemArrayId - 1] as String
        }
        else if item == "Time" {
            timeArrayId = selectTableViewController.arrayId
            selectedTime = timeArray[timeArrayId] as String
        }

        tableView.reloadData()
        addButtonEnabled()
    }
    
    func selectTime() {
        selectedTime = dateFormatter.stringFromDate(timePicker.date)
    }
    
    func addButtonEnabled() {
        if selectedGarbage == "" {
            addButton.enabled = false
        }
        else {
            addButton.enabled = true
            addButton.setTitleColor(UIColor(red: 0.9, green: 0.28, blue: 0.25, alpha: 1.0), forState: UIControlState.Normal)
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
                return addViewDelegate!.addViewDidChanged(self)
            }
            reload()
        }
    }
}
