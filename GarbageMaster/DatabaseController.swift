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
    
    func initDb() {
        
        dbDirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)

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
        let region = "青田"
        
        var arrayList: Array<AnyObject> = []
        
        var todayGarbageList: Array<AnyObject> = []
        var tomorrowGarbageList: Array<AnyObject> = []
        var dayAfterTomorrowGarbageList: Array<AnyObject> = []
        var afterThreeDaysGarbageList: Array<AnyObject> = []
        var afterFourDaysGarbageList: Array<AnyObject> = []
        var afterFiveDaysGarbageList: Array<AnyObject> = []
        var afterSixDaysGarbageList: Array<AnyObject> = []
        var afterSevenDaysGarbageList: Array<AnyObject> = []
        
        let now: NSDate = NSDate()
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateFormat = "HH:mm"
        println("now = \(dateFormatter.stringFromDate(now))")
        
        let sql = "SELECT garbage_lists.id as garbage_lists_id, garbages.*, garbage_lists.* FROM garbages, garbage_lists WHERE garbages.id = garbage_lists.garbage_id;"
        
        db.open()
        
        let results = db.executeQuery(sql, withArgumentsInArray: nil)
        
        while results.next() {
            // カラム名を指定して値を取得する方法
            let garbageId = results.intForColumn("garbage_id")
            let item = results.stringForColumn("item")
            let division = results.stringForColumn("division")
            let attention = results.stringForColumn("attention")
            let garbageListId = results.intForColumn("garbage_lists_id")
            let notifyDate = results.stringForColumn("notify_date")
            let notifyTime = results.stringForColumn("notify_time")
            
            let weekday = getWeekday(region, garbage_id: Int(garbageId))
//            println("garbage weekday = \(weekday)")
            
            // println("garbage_id = \(garbageId), item = \(item), notify_date = \(notifyDate), notify_time = \(notifyTime)")
            switch notifyDate {
                case "ゴミ収集日の当日":
                    var tempDictionary = ["garbageId" : "\(garbageId)", "item" : item, "division" : division, "attention" : attention, "garbageListId" : "\(garbageListId)", "weekday" : weekday, "notifyDate" : notifyDate, "notifyTime" : notifyTime]
                    todayGarbageList.append(tempDictionary)
                case "ゴミ収集日の前日":
                    var tempDictionary = ["garbageId" : "\(garbageId)", "item" : item, "division" : division, "attention" : attention, "garbageListId" : "\(garbageListId)", "weekday" : weekday, "notifyDate" : notifyDate, "notifyTime" : notifyTime]
                    tomorrowGarbageList.append(tempDictionary)
                default:
                    var tempDictionary = ["garbageId" : "\(garbageId)", "item" : item, "division" : division, "attention" : attention, "garbageListId" : "\(garbageListId)", "weekday" : weekday, "notifyDate" : notifyDate, "notifyTime" : notifyTime]
                    afterSevenDaysGarbageList.append(tempDictionary)
            }
        }
        
        results.close()
        db.close()
        
        arrayList = [todayGarbageList, tomorrowGarbageList, dayAfterTomorrowGarbageList, afterThreeDaysGarbageList, afterFourDaysGarbageList, afterFiveDaysGarbageList, afterSixDaysGarbageList, afterSevenDaysGarbageList]
        
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
    func getWeekday(region: String, garbage_id: Int) -> String {
        // println("region = \(region), garbage_id = \(garbage_id)")
        var weekday = ""
        var divisionDay = ""
        var item = ""
        var division = ""
        
        let sql1 = "SELECT item, division FROM garbages WHERE id = ?;"
        var sql2 = ""
        
        // DBをopenさせた状態で呼び出しているので, DBのopenとcloseはいらない
        // db.open()
        
        let results1 = db.executeQuery(sql1, withArgumentsInArray: [garbage_id])
        
        while results1.next() {
            item = results1.stringForColumn("item")
            division = results1.stringForColumn("division")
        }
        
        if division != "" {
            switch(division) {
                case "燃やすごみ":
                    sql2 = "SELECT combustibles_day FROM collection_days WHERE region = ?;"
                    divisionDay = "combustibles_day"
                case "容器包装プラスチック類":
                    sql2 = "SELECT plastic_day FROM collection_days WHERE region = ?;"
                    divisionDay = "plastic_day"
                case "燃やさないごみ":
                    sql2 = "SELECT incombustibles_day FROM collection_days WHERE region = ?;"
                    divisionDay = "incombustibles_day"
                case "ペットボトル":
                    sql2 = "SELECT plastic_bottle_day FROM collection_days WHERE region = ?;"
                    divisionDay = "plastic_bottle_day"
                case "危険ごみ", "有害ごみ":
                    sql2 = "SELECT dangerous_garbage_day FROM collection_days WHERE region = ?;"
                    divisionDay = "dangerous_garbage_day"
                default:
                    println("該当なし")
                    return ""
            }
            
            let results2 = db.executeQuery(sql2, withArgumentsInArray: [region])
            
            while results2.next() {
                weekday = results2.stringForColumn(divisionDay)
            }
            
            results2.close()
        }
        
        results1.close()
        
        return weekday
        //db.close()        
    }
    
    func deleteGarbageData(id: Int) {
        let sql = "DELETE FROM garbage_lists WHERE id = ?;"
        
        db.open()
        // ?で記述したパラメータの値を渡す場合
        db.executeUpdate(sql, withArgumentsInArray: [id])
        db.close()
        
        println("garbageListId = \(id) を削除しました.")

    }
    
}
