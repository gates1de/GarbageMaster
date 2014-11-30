//
//  TimeSettingViewController.swift
//  GarbageMaster
//
//  Created by 門脇裕 on 2014/11/26.
//  Copyright (c) 2014年 yu_kadowaki. All rights reserved.
//

import UIKit

protocol TimeSettingViewDelegate {
    func timeSettingViewDidChanged(TimeSettingViewController)
}

class TimeSettingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var timeSettingViewDelegate: TimeSettingViewDelegate? = nil
    
    var databaseController: DatabaseController = DatabaseController()
    
    var datePickerView = UIPickerView()
    var timePicker = UIDatePicker()
    var dateFormatter: NSDateFormatter = NSDateFormatter()
    var initTime: NSDate = NSDate()
    
    var garbageDistinctionArray: Array<AnyObject> = []
    var garbageNotifyDataArray: Array<AnyObject> = []
    var notifyDayArray: Array<AnyObject> = []
    var selectedSectionId: Int = Int()
    var selectedDay: String = String()
    var selectedDayNum: Int = Int()
    var selectedHourTime: String = String()
    var selectedTime: String = String()
    
    var backButton: UIButton = UIButton()
    var addButton: UIButton = UIButton()
    
    var updateFlag: Int = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor(red: 0.08, green: 0.63, blue: 0.52, alpha: 1.0)
        self.view.backgroundColor = UIColor.whiteColor()
        updateFlag = 0
        
        garbageDistinctionArray = ["combustibles", "plastic", "incombustibles", "plasticBottle", "dangerousGarbage"]
        notifyDayArray = ["ごみ出し日当日", "ごみ出し日前日"]
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateFormat = "HH:mm"
        
        selectedDay = notifyDayArray[0] as String
//        selectedHourTime = "07:00"
//        selectedTime = "\(selectedDay) の \(selectedHourTime)"
//        initTime = dateFormatter.dateFromString("07:00")!
        
        let screenHeight = UIScreen.mainScreen().applicationFrame.size.height
        let screenWidth = UIScreen.mainScreen().applicationFrame.size.width
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        
        var addButtonWidth: CGFloat = screenWidth / 2
        var addButtonHeight: CGFloat = screenHeight / 10
        var addButtonX = (self.view.bounds.width - addButtonWidth) / 2
        var addButtonY = (self.view.bounds.height - addButtonHeight) / 1.5
        
        datePickerView.frame = CGRectMake(0, screenHeight / 3, screenWidth / 2, screenHeight / 3)
        datePickerView.backgroundColor = UIColor.whiteColor()
        timePicker.frame = CGRectMake(screenWidth / 2, screenHeight / 3, screenWidth / 2, screenHeight / 3)
        timePicker.backgroundColor = UIColor.whiteColor()
        timePicker.datePickerMode = UIDatePickerMode.Time
        timePicker.date = initTime
        timePicker.addTarget(self, action: "selectTime", forControlEvents: UIControlEvents.ValueChanged)
        
        datePickerView.delegate = self
        datePickerView.dataSource = self
        // 通知の日付(ごみ出し日当日かごみ出し日前日)の初期値は「ごみ出し日当日」にしておく
        datePickerView.selectRow(selectedDayNum, inComponent: 0, animated: false)
        
        addButton = UIButton(frame: CGRect(x: addButtonX, y: timePicker.frame.origin.y + timePicker.frame.size.height + 50, width: addButtonWidth, height: addButtonHeight))
        addButton.titleLabel?.textAlignment = NSTextAlignment.Center
        addButton.setTitle("変更する", forState: UIControlState.Normal)
        addButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        addButton.backgroundColor = UIColor.grayColor()
        addButton.layer.borderColor = UIColor.grayColor().CGColor
        addButton.layer.borderWidth = 2.0
        addButton.layer.cornerRadius = 5.0
        addButton.addTarget(self, action: "changeNotifyTime", forControlEvents: UIControlEvents.TouchUpInside)
        addButton.enabled = false
        
//        backButton = UIButton(frame: CGRect(x: backButtonX, y: addButton.frame.origin.y + addButton.frame.size.height + 20, width: addButtonWidth, height: addButtonHeight))
//        backButton.titleLabel?.textAlignment = NSTextAlignment.Center
//        backButton.setTitle("戻る", forState: UIControlState.Normal)
//        backButton.setTitleColor(UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0), forState: UIControlState.Normal)
//        //        backButton.layer.borderColor = UIColor.grayColor().CGColor
//        //        backButton.layer.borderWidth = 2.0
//        //        backButton.layer.cornerRadius = 5.0
//        backButton.addTarget(self, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(datePickerView)
        self.view.addSubview(timePicker)
        self.view.addSubview(addButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    ///////////////////////////////// PickerViewを使った処理 ここから /////////////////////////////////
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return notifyDayArray.count
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100.0
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 32.0
    }
    
    func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String!{
        return "\(notifyDayArray[row])"
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.frame.size.width, height: pickerView.frame.size.height))
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(18)
        label.text = notifyDayArray[row] as String
        
        return label
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        addButton.enabled = true
        addButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        addButton.backgroundColor = UIColor(red: 0.9, green: 0.28, blue: 0.25, alpha: 1.0)
        addButton.layer.borderColor = UIColor(red: 0.9, green: 0.28, blue: 0.25, alpha: 1.0).CGColor
        selectedDayNum = row
        selectedDay = notifyDayArray[row] as String
        selectedTime = "\(selectedDay) の \(selectedHourTime)"
        println("selectedTime = \(selectedTime)")
    }
    
    ///////////////////////////////// PickerViewを使った処理 ここまで /////////////////////////////////
    
    func changeNotifyTime() {
        updateFlag = 1
        databaseController.updateNotifyTime([selectedDayNum, selectedHourTime, garbageDistinctionArray[selectedSectionId]])
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func selectTime() {
        addButton.enabled = true
        addButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        addButton.backgroundColor = UIColor(red: 0.9, green: 0.28, blue: 0.25, alpha: 1.0)
        addButton.layer.borderColor = UIColor(red: 0.9, green: 0.28, blue: 0.25, alpha: 1.0).CGColor
        selectedHourTime = dateFormatter.stringFromDate(timePicker.date)
        selectedTime = "\(selectedDay) の \(selectedHourTime)"
        println("selectedTime = \(selectedTime)")
    }
    
    override func viewWillAppear(animated: Bool) {
        println("selectedDayNum = \(selectedDayNum), selectedHourTime = \(selectedHourTime)")
    }
    
    override func viewDidDisappear(animated: Bool) {
        if updateFlag == 1 {
            func reload() -> Void {
//                garbageNotifyDataArray.removeAll(keepCapacity: false)
                garbageNotifyDataArray = databaseController.getNotifyTime()
                return timeSettingViewDelegate!.timeSettingViewDidChanged(self)
            }
            reload()
        }
    }

}
