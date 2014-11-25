//
//  DatabaseController.swift
//  GarbageMaster
//
//  Created by 門脇裕 on 2014/10/12.
//  Copyright (c) 2014年 yu_kadowaki. All rights reserved.
//

import UIKit

class DatabaseController: NSObject {
    
    var dbDirPath: Array<AnyObject> = []
    var dbPath: String = String()
    var db: FMDatabase = FMDatabase()
    
//    var weekdayRangeArray: Array<AnyObject> = []
//    var weekdayOrdinalRangeArray: Array<AnyObject> = []
    var weekdayDictionary: Dictionary<String, Dictionary<String, Array<AnyObject>>> = Dictionary<String, Dictionary<String, Array<AnyObject>>>()
    var userDefaults: NSUserDefaults = NSUserDefaults()
    
    func initDb() {
        userDefaults = NSUserDefaults.standardUserDefaults()
        
        dbDirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        println("dirPath = \(dbDirPath[0])")

        dbPath = dbDirPath[0].stringByAppendingPathComponent("garbage_master.db")
        
        db = FMDatabase(path: dbPath)
        
        db.open()
        
        let sql1 = "CREATE TABLE IF NOT EXISTS garbages (id integer NOT NULL PRIMARY KEY AUTOINCREMENT, item text, division text, attention text);"
        let sql2 = "CREATE TABLE IF NOT EXISTS collection_days (region text NOT NULL, combustibles_day text NOT NULL, plastic_day text NOT NULL, incombustibles_day text NOT NULL, plastic_bottle_day text NOT NULL, dangerous_garbage_day text NOT NULL);"
        let sql3 = "CREATE TABLE IF NOT EXISTS garbage_lists (id integer NOT NULL PRIMARY KEY AUTOINCREMENT, garbage_id int NOT NULL, notify_date text NOT NULL, notify_time text NOT NULL, FOREIGN KEY (garbage_id) REFERENCES garbage (id));"

        let result1 = db.executeUpdate(sql1, withArgumentsInArray: nil)
        let result2 = db.executeUpdate(sql2, withArgumentsInArray: nil)
        let result3 = db.executeUpdate(sql3, withArgumentsInArray: nil)
        
        db.close()
        
        if result1 {
            println("garbagesテーブルの作成に成功")
            println(result1)
        }
        
        if result2 {
            println("garbage_listsテーブルの作成に成功")
            println(result2)
        }
        
        if result3 {
            println("collection_daysテーブルの作成に成功")
            println(result3)
        }
        
    }
    
    func selectGarbages() -> Array<AnyObject> {
        
        var garbageItemArray: Array<AnyObject> = []

        
        let sql = "SELECT * FROM garbages;"

        db.open()
        
        let results = db.executeQuery(sql, withArgumentsInArray: nil)
        
        while results.next() {
            // カラム名を指定して値を取得する方法
            let id = results.intForColumn("id")
            let item = results.stringForColumn("item")
            let division = results.stringForColumn("division")
            let attention = results.stringForColumn("attention")
            // カラムのインデックスを指定して取得する方法
            // let user_name = results.stringForColumnIndex(1)
            
            // println("id = \(id), item = \(item), division = \(division), attention = \(attention)")
            garbageItemArray.append(item)
        }
        
        results.close()
        
        db.close()
        
        return garbageItemArray
    }
    
    func selectCollectionDays() {
        
        let sql = "SELECT * FROM collection_days;"
        
        db.open()
        
        let results = db.executeQuery(sql, withArgumentsInArray: nil)
        
        while results.next() {
            // カラム名を指定して値を取得する方法
            let region = results.stringForColumn("region")
            let combustiblesDay = results.stringForColumn("combustibles_day")
            let plasticDay = results.stringForColumn("plastic_day")
            let incombustiblesDay = results.stringForColumn("incombustibles_day")
            let plasticBottleDay = results.stringForColumn("plastic_bottle_day")
            let dangerousGarbageDay = results.stringForColumn("dangerous_garbage_day")
            // カラムのインデックスを指定して取得する方法
            //let user_name = results.stringForColumnIndex(1)
            
            println("region = \(region), combustiblesDay = \(combustiblesDay), plasticDay = \(plasticDay), incombustiblesDay = \(incombustiblesDay), plasticBottleDay = \(plasticBottleDay), dangerousGarbageDay = \(dangerousGarbageDay)")
        }
        
        results.close()
        
        db.close()
        
    }
    
    func getGarbageData() -> Array<AnyObject> {
        // 一旦登録されている通知を全て消す
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        let region: String! = userDefaults.stringForKey("region")
        
        var arrayList: Array<AnyObject> = []
        
        // 分別区分ごとの配列を用意する
        var combustiblesList: Array<AnyObject> = []
        var incombustiblesList: Array<AnyObject> = []
        var plasticList: Array<AnyObject> = []
        var plasticBottleList: Array<AnyObject> = []
        var dangerousGarbageList: Array<AnyObject> = []
        var recyclableGarbageList: Array<AnyObject> = []
        var bulkyGarbageList: Array<AnyObject> = []
        var hardToManageGarbageList: Array<AnyObject> = []
        var cannotTrashInCityGarbageList: Array<AnyObject> = []
        var homeApplianceRecyclingGarbageList: Array<AnyObject> = []
        var PCRecycleGarbageList: Array<AnyObject> = []
        var otherGarbageList: Array<AnyObject> = []
        
        // notification通知時間をシステムの時間と合わせるための処理
        let now: NSDate = NSDate()
        println("now = \(now)")
        let calendar: NSCalendar = NSCalendar(identifier: NSGregorianCalendar)!
        let components: NSDateComponents = calendar.components(NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.WeekdayOrdinalCalendarUnit | NSCalendarUnit.WeekdayCalendarUnit | NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit, fromDate: now)
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateFormat = "HH:mm"
        println("now = \(dateFormatter.stringFromDate(now))")
        println("CURRENT year = \(components.year), month = \(components.month), day = \(components.day), weekdayOrdinal = \(components.weekdayOrdinal), weekday = \(components.weekday), hour = \(components.hour), minute = \(components.minute)")
        
        // notificationが通知された時に表示する文章を格納する変数
        var combustibles = ""
        var incombustibles = ""
        var plastics = ""
        var plasticBottles = ""
        var dangerousGarbages = ""
        
        let sql = "SELECT garbage_lists.id as garbage_lists_id, garbages.*, garbage_lists.* FROM garbages, garbage_lists WHERE garbages.id = garbage_lists.garbage_id;"
        
        db.open()
        
        let results = db.executeQuery(sql, withArgumentsInArray: nil)
        
        // notificationを設定するために地域のゴミ捨て曜日を処理できる形に変換し, 配列に格納する
        let weekday = "月曜日" as NSString
        weekdayDictionary = getWeekday(region) as Dictionary<String, Dictionary<String, Array<AnyObject>>>
        var weekdayNum: Int = Int()
        var weekdayNumArray: Array<Int> = []
        
        while results.next() {
            // カラム名を指定して値を取得する方法
            let garbageId = results.intForColumn("garbage_id")
            let item = results.stringForColumn("item")
            let division = results.stringForColumn("division")
            let attention = results.stringForColumn("attention")
            let garbageListId = results.intForColumn("garbage_lists_id")
            let notifyDate = results.stringForColumn("notify_date")
            let notifyTime = results.stringForColumn("notify_time")
            
//            weekdayRangeArray = [weekday.rangeOfString("日曜日"), weekday.rangeOfString("月曜日"), weekday.rangeOfString("火曜日"), weekday.rangeOfString("水曜日"), weekday.rangeOfString("木曜日"), weekday.rangeOfString("金曜日"), weekday.rangeOfString("土曜日")]
//            weekdayOrdinalRangeArray = [weekday.rangeOfString("1"), weekday.rangeOfString("2"), weekday.rangeOfString("3"), weekday.rangeOfString("4"), weekday.rangeOfString("5")]
//            
//            for var i = 0; i < weekdayRangeArray.count; i++ {
//                let weekdayRange: NSRange = weekdayRangeArray[i] as NSRange
//                
//                if weekdayRange.location != NSNotFound {
//                    // println("i = \(i), weekday = \(weekday)")
//                    weekdayNumArray.append(i)
//                }
//                // weekdayNum = Week.Monday.intValue()
//            }
//            
//            for var j = 0; j < weekdayOrdinalRangeArray.count; j++ {
//                let weekdayOrdinalRange: NSRange = weekdayOrdinalRangeArray[j] as NSRange
//                    if weekdayOrdinalRange.location != NSNotFound {
//                        println("weekday = \(weekday)")
//                    }
//            }
            
//            println("weekdayNumArray = \(weekdayNumArray)")
            
            var tempDictionary = ["garbageId" : "\(garbageId)", "item" : item, "division" : division, "attention" : attention, "garbageListId" : "\(garbageListId)", "weekday" : weekday, "notifyDate" : notifyDate, "notifyTime" : notifyTime]
            
            switch division {
                case "燃やすごみ":
                    if combustibles == "" {
                        combustibles += "\(item)"
                    }
                    if (combustibles as NSString).rangeOfString(item).location == NSNotFound {
                        combustibles += ", \(item)"
                    }
                    combustiblesList.append(tempDictionary)
                case "燃やさないごみ":
                    if incombustibles == "" {
                        incombustibles += "\(item)"
                    }
                    if (incombustibles as NSString).rangeOfString(item).location == NSNotFound {
                        incombustibles += ", \(item)"
                    }
                    incombustiblesList.append(tempDictionary)
                case "容器包装プラスチック類":
                    if plastics == "" {
                        plastics += "\(item)"
                    }
                    if (plastics as NSString).rangeOfString(item).location == NSNotFound {
                        plastics += ", \(item)"
                    }
                    plasticList.append(tempDictionary)
                case "ペットボトル":
                    if plasticBottles == "" {
                        plasticBottles += "\(item)"
                    }
                    if (plasticBottles as NSString).rangeOfString(item).location == NSNotFound {
                        plasticBottles += ", \(item)"
                    }
                    plasticBottleList.append(tempDictionary)
                case "資源ごみ":
                    recyclableGarbageList.append(tempDictionary)
                case "粗大ごみ":
                    bulkyGarbageList.append(tempDictionary)
                case "有害ごみ":
                    if dangerousGarbages == "" {
                        dangerousGarbages += "\(item)"
                    }
                    if (dangerousGarbages as NSString).rangeOfString(item).location == NSNotFound {
                        dangerousGarbages += ", \(item)"
                    }
                    dangerousGarbageList.append(tempDictionary)
                case "危険ごみ":
                    if dangerousGarbages == "" {
                        dangerousGarbages += "\(item)"
                    }
                    if (dangerousGarbages as NSString).rangeOfString(item).location == NSNotFound {
                        dangerousGarbages += ", \(item)"
                    }
                    dangerousGarbageList.append(tempDictionary)
                case "処理困難物":
                    hardToManageGarbageList.append(tempDictionary)
                case "市では処理できないごみ":
                    cannotTrashInCityGarbageList.append(tempDictionary)
                case "家電リサイクル法対象品":
                    homeApplianceRecyclingGarbageList.append(tempDictionary)
                case "パソコンリサイクル対象品", "パソコンリサイクル対商品":
                    PCRecycleGarbageList.append(tempDictionary)
                default:
                    otherGarbageList.append(tempDictionary)
            }
//            notify(0)
        }
        
        println("燃やすごみ = \(combustibles)")
        println("容器包装プラスチック類 = \(plastics)")
        println("燃やさないごみ = \(incombustibles)")
        println("ペットボトル = \(plasticBottles)")
        println("有害・危険ごみ = \(dangerousGarbages)")
        
        if combustibles != "" {
            setNotification("combustiblesDay", alertBody: "今日は燃やすごみの日です。\n対象のごみ: \(combustibles)")
        }
        if plastics != "" {
            setNotification("plasticsDay", alertBody: "今日は容器包装プラスチック類の日です。\n対象のごみ: \(plastics)")
        }
        if incombustibles != "" {
            setNotification("incombustiblesDay", alertBody: "今日は燃やさないごみの日です。\n対象のごみ: \(incombustibles)")
        }
        if plasticBottles != "" {
            setNotification("plasticBottlesDay", alertBody: "今日はペットボトルの日です。")
        }
        if dangerousGarbages != "" {
            setNotification("dangerousGarbagesDay", alertBody: "今日は有害・危険ごみの日です。\n対象のごみ: \(dangerousGarbages)")
        }
        
        results.close()
        db.close()
        
        arrayList = [combustiblesList, incombustiblesList, plasticList, plasticBottleList, recyclableGarbageList, bulkyGarbageList, dangerousGarbageList, hardToManageGarbageList, cannotTrashInCityGarbageList, homeApplianceRecyclingGarbageList, PCRecycleGarbageList]
        
        return arrayList
        
    }

    
    func insertGomibuntetsu(array: Array<AnyObject>) {
        
        let sql = "INSERT INTO garbages (id, item, division, attention) VALUES (NULL, ?, ?, ?);"
        
        db.open()
        // ?で記述したパラメータの値を渡す場合
        db.executeUpdate(sql, withArgumentsInArray: [array[0], array[1], array[2]])
        db.close()
        
    }
    
    func insertGomiyoubi(array: Array<AnyObject>) {
        let sql = "INSERT INTO collection_days (region, combustibles_day, plastic_day, incombustibles_day, plastic_bottle_day, dangerous_garbage_day) VALUES (?, ?, ?, ?, ?, ?);"
        db.open()
        // ?で記述したパラメータの値を渡す場合
        db.executeUpdate(sql, withArgumentsInArray: [array[0], array[1], array[2], array[3], array[4], array[5]])
        db.close()
        
    }
    
    func insertGarbageLists(array: Array<AnyObject>) {
        
        let sql = "INSERT INTO garbage_lists (id, garbage_id, notify_date, notify_time) VALUES (NULL, ?, ?, ?);"
        
        db.open()
        // ?で記述したパラメータの値を渡す場合
        db.executeUpdate(sql, withArgumentsInArray: [array[0], array[1], array[2]])
        db.close()
        
    }
    
    // AddViewControllerでゴミを追加する時に, その地域のゴミ(燃やすゴミとかペットボトルとか)の捨てる曜日を取得する
    func getWeekday(region: String) -> Dictionary<String, Dictionary<String, Array<AnyObject>>> {
        var weekday = ""
        var weekdayDictionary = Dictionary<String, Dictionary<String, Array<AnyObject>>>()
    
        let sql = "SELECT * FROM collection_days WHERE region = ?;"
        
        let results = db.executeQuery(sql, withArgumentsInArray: [region])
        
        while results.next() {
            var combustiblesDay = results.stringForColumn("combustibles_day")
            var plasticsDay = results.stringForColumn("plastic_day")
            var incombustiblesDay = results.stringForColumn("incombustibles_day")
            var plasticBottlesDay = results.stringForColumn("plastic_bottle_day")
            var dangerousGarbagesDay = results.stringForColumn("dangerous_garbage_day")
            
            weekdayDictionary = ["combustiblesDay": parseWeekday(combustiblesDay), "plasticsDay": parseWeekday(plasticsDay), "incombustiblesDay": parseWeekday(incombustiblesDay), "plasticBottlesDay": parseWeekday(plasticBottlesDay), "dangerousGarbagesDay": parseWeekday(dangerousGarbagesDay)]
        }
        
//        var sql2 = ""
//        
//        // DBをopenさせた状態で呼び出しているので, DBのopenとcloseはいらない
//        // db.open()
//        
//        let results1 = db.executeQuery(sql1, withArgumentsInArray: [garbage_id])
//        
//        while results1.next() {
//            item = results1.stringForColumn("item")
//            division = results1.stringForColumn("division")
//        }
//        
//        if division != "" {
//            switch(division) {
//                case "燃やすごみ":
//                    sql2 = "SELECT combustibles_day FROM collection_days WHERE region = ?;"
//                    divisionDay = "combustibles_day"
//                case "容器包装プラスチック類":
//                    sql2 = "SELECT plastic_day FROM collection_days WHERE region = ?;"
//                    divisionDay = "plastic_day"
//                case "燃やさないごみ":
//                    sql2 = "SELECT incombustibles_day FROM collection_days WHERE region = ?;"
//                    divisionDay = "incombustibles_day"
//                case "ペットボトル":
//                    sql2 = "SELECT plastic_bottle_day FROM collection_days WHERE region = ?;"
//                    divisionDay = "plastic_bottle_day"
//                case "危険ごみ", "有害ごみ":
//                    sql2 = "SELECT dangerous_garbage_day FROM collection_days WHERE region = ?;"
//                    divisionDay = "dangerous_garbage_day"
//                default:
//                    println("該当なし")
//                    return ""
//            }
//            
//            let results2 = db.executeQuery(sql2, withArgumentsInArray: [region])
//            
//            while results2.next() {
//                weekday = results2.stringForColumn(divisionDay)
//            }
//            
//            results2.close()
//        }
//        
        results.close()
        
        return weekdayDictionary
        //db.close()        
    }
    
    func parseWeekday(weekday: NSString) -> Dictionary<String, Array<AnyObject>> {
        var weekdayArray = ["weekday": [], "weekdayOrdinal": []]
        var weekdayRangeArray = [weekday.rangeOfString("日曜日"), weekday.rangeOfString("月曜日"), weekday.rangeOfString("火曜日"), weekday.rangeOfString("水曜日"), weekday.rangeOfString("木曜日"), weekday.rangeOfString("金曜日"), weekday.rangeOfString("土曜日")]
        var weekdayOrdinalRangeArray = [weekday.rangeOfString("1"), weekday.rangeOfString("2"), weekday.rangeOfString("3"), weekday.rangeOfString("4"), weekday.rangeOfString("5")]
        
        for var i = 0; i < weekdayRangeArray.count; i++ {
            let weekdayRange: NSRange = weekdayRangeArray[i] as NSRange
            
            if weekdayRange.location != NSNotFound {
                // println("i = \(i), weekday = \(weekday)")
                weekdayArray["weekday"]?.append(i + 1)
            }
            // weekdayNum = Week.Monday.intValue()
        }
        
        for var j = 0; j < weekdayOrdinalRangeArray.count; j++ {
            let weekdayOrdinalRange: NSRange = weekdayOrdinalRangeArray[j] as NSRange
            if weekdayOrdinalRange.location != NSNotFound {
                weekdayArray["weekdayOrdinal"]?.append(j + 1)
            }
        }
        
        return weekdayArray
    }
    
    func setNotification(garbageWeekDay: String, alertBody: String) {
        var weekdayArray = weekdayDictionary[garbageWeekDay]!["weekday"]!
        var weekdayOrdinalArray = weekdayDictionary[garbageWeekDay]!["weekdayOrdinal"]!
        for var i = 0; i < weekdayArray.count; i++ {
            if weekdayOrdinalArray.count == 0 {
                notify(weekdayArray[i] as Int, weekdayOrdinalNum: 0, notifyTime: "08:20", alertBody: alertBody)
//                println("weekday = \(weekdayArray[i])")
            }
            else {
                for var j = 0; j < weekdayOrdinalArray.count; j++ {
                    notify(weekdayArray[i] as Int, weekdayOrdinalNum: weekdayOrdinalArray[j] as Int, notifyTime: "08:10", alertBody: alertBody)
//                    println("weekday = \(weekdayArray[i]), weekdayOrdinal = \(weekdayOrdinalArray[j])")
                }
            }
        }
    }
    
    func getRegion() -> Array<AnyObject> {
        var region = ""
        var regionArray: Array<AnyObject> = []
        
        let sql = "SELECT region FROM collection_days;"
        
        db.open()
        
        let results = db.executeQuery(sql, withArgumentsInArray: nil)
        
        while results.next() {
            region = results.stringForColumn("region")
            regionArray.append(region)
        }
        
        results.close()
        
        db.close()
        
        return regionArray
    }
    
    func deleteGarbageData(id: Int) {
        let sql = "DELETE FROM garbage_lists WHERE id = ?;"
        
        db.open()
        // ?で記述したパラメータの値を渡す場合
        db.executeUpdate(sql, withArgumentsInArray: [id])
        db.close()
        
        println("garbageListId = \(id) を削除しました.")

    }
    
    func notify(weekdayNum: Int, weekdayOrdinalNum: Int, notifyTime: String, alertBody: String) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        // notifyTimeから時と分を抽出し, 後の時間比較のために時間を全て分に変換する
        var hour = (notifyTime as NSString).substringWithRange(NSRange(location: 0, length: 2)).toInt()!
        var minute = (notifyTime as NSString).substringWithRange(NSRange(location: 3, length: 2)).toInt()!
        var timeToMinute = hour * 60 + minute
        
        let now: NSDate = NSDate()
        let calendar: NSCalendar = NSCalendar(identifier: NSGregorianCalendar)!
        calendar.timeZone = NSTimeZone.localTimeZone()
        let nowComponents: NSDateComponents = NSDateComponents()
        let current: NSDate = calendar.dateByAddingComponents(nowComponents, toDate: now, options: nil)!
//        println("current = \(current)")
        let fireDateComponents: NSDateComponents = calendar.components(NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.WeekdayOrdinalCalendarUnit | NSCalendarUnit.WeekdayCalendarUnit | NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit, fromDate: current)
        
        // 週の設定がない場合
        if weekdayOrdinalNum == 0 {
            var difDay = weekdayNum - fireDateComponents.weekday
            fireDateComponents.weekday = weekdayNum
            fireDateComponents.day += difDay
            fireDateComponents.hour = hour
            fireDateComponents.minute = minute
        }
        else {
            var difDay = (weekdayOrdinalNum - fireDateComponents.weekdayOrdinal) * 7
            difDay += weekdayNum - fireDateComponents.weekday
            fireDateComponents.weekdayOrdinal = weekdayOrdinalNum
            fireDateComponents.weekday = weekdayNum
            fireDateComponents.day += difDay
            fireDateComponents.hour = hour
            fireDateComponents.minute = minute
        }
        
        let date: NSDate = calendar.dateFromComponents(fireDateComponents)!
//        println("fireDate = \(date) +9000")
        let span: NSTimeInterval = date.timeIntervalSinceDate(current)
//        println("span = \(span)")
        
        notificationCenter.addObserver(self, selector: "testNotification:", name: "Test Notification", object: nil)
        
        var notification: UILocalNotification = UILocalNotification()
        notification.timeZone = NSTimeZone.localTimeZone()
        notification.category = "category"
        notification.alertBody = alertBody
        notification.alertAction = "OK"
        notification.fireDate = now.dateByAddingTimeInterval(span)
        notification.repeatInterval = NSCalendarUnit.WeekCalendarUnit
        //println("notification.fireDate = \(notification.fireDate)")
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    
    }
    
    enum Week {
        case Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
        func intValue() -> Int {
            switch self {
            case .Sunday:
                return 1
            case .Monday:
                return 2
            case .Tuesday:
                return 3
            case .Wednesday:
                return 4
            case .Thursday:
                return 5
            case .Friday:
                return 6
            case .Saturday:
                return 7
            default:
                return -1
            }
        }
    }
}
