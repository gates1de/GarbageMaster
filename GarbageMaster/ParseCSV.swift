//
//  ParseCSV.swift
//  GarbageMaster
//
//  Created by 門脇裕 on 2014/10/12.
//  Copyright (c) 2014年 yu_kadowaki. All rights reserved.
//

import UIKit

class ParseCSV: NSObject {
    
    var string: NSString = "could not get data"
    var getData: NSData!
    
    func getCSV(path: NSURL, CSVName: String) {
        
        let remoteCSVPath = path
        //let remoteCSVPath = NSURL.URLWithString("http://www.city.nagareyama.chiba.jp/dbps_data/_material_/localhost/gomibunbetu.csv".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        
        // リモートからCSVのデータを取得
        getData = NSData(contentsOfURL: remoteCSVPath, options: NSDataReadingOptions(), error: nil)
        string = NSString(data: getData, encoding: NSShiftJISStringEncoding)!
        
        // 取得したCSVデータの文字コードがShiftJISであるため, 一旦UTF8に変換する
        let encodeString: NSString = string.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let encodeData: NSData = encodeString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        
        // 端末内のディレクトリへのパスを指定
        let dataPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let path = dataPath[0].stringByAppendingPathComponent(CSVName)
        // println("\(path)")
        
        encodeData.writeToFile(path, atomically: true)
    }
    
    func parseGomibunbetsuCSV(databaseController: DatabaseController) {
        let dataPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let path = dataPath[0].stringByAppendingPathComponent("gomibunbetsu.csv")
        let pathURL: NSURL! = NSURL.fileURLWithPath(path)
        let table: NTYCSVTable = NTYCSVTable(contentsOfURL: pathURL)
        
        var itemArray = table.columns[table.headers[0] as NSObject]
        var distinctionArray = table.columns[table.headers[1] as NSObject]
        var cautionArray = table.columns[table.headers[2] as NSObject]
        
        for var i = 0; i < itemArray!.count; i++ {
            var item = itemArray![i]
            var distinction = distinctionArray![i]
            var caution = cautionArray![i]
            
            if (item as NSObject == 0) {
                item = ""
            }
            if (distinction as NSObject == 0) {
                distinction = ""
            }
            if (caution as NSObject == 0) {
                caution = ""
            }
            
//             println("rows \(i) = \(item), \(distinction), \(caution)")
            
            databaseController.insertGomibuntetsu([item, distinction, caution])
        }
        
    }
    
    func parseGomiyoubiCSV(databaseController: DatabaseController) {
        let dataPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let path = dataPath[0].stringByAppendingPathComponent("gomiyoubi_2.csv")
        let pathURL: NSURL! = NSURL.fileURLWithPath(path)
        let table: NTYCSVTable = NTYCSVTable(contentsOfURL: pathURL)
        
        var regionArray = table.columns[table.headers[0] as NSObject]
        var combustiblesDayArray = table.columns[table.headers[1] as NSObject]
        var plasticDayArray = table.columns[table.headers[2] as NSObject]
        var incombustiblesDayArray = table.columns[table.headers[3] as NSObject]
        var plasticBottleDayArray = table.columns[table.headers[4] as NSObject]
        var dangerousGarbageDayArray = table.columns[table.headers[5] as NSObject]
        
        for var i = 0; i < regionArray!.count; i++ {
            var region = regionArray![i]
            var combustiblesDay = combustiblesDayArray![i]
            var plasticDay = plasticDayArray![i]
            var incombustiblesDay = incombustiblesDayArray![i]
            var plasticBottleDay = plasticBottleDayArray![i]
            var dangerousGarbageDay = dangerousGarbageDayArray![i]
            
            if (region as NSObject == 0) {
                region = ""
            }
            if (combustiblesDay as NSObject == 0) {
                combustiblesDay = ""
            }
            if (plasticDay as NSObject == 0) {
                plasticDay = ""
            }
            if (incombustiblesDay as NSObject == 0) {
                incombustiblesDay = ""
            }
            if (plasticBottleDay as NSObject == 0) {
                plasticBottleDay = ""
            }
            if (dangerousGarbageDay as NSObject == 0) {
                dangerousGarbageDay = ""
            }
            
//             println("rows \(i) = \(region), \(combustiblesDay), \(plasticDay), \(incombustiblesDay), \(plasticBottleDay), \(dangerousGarbageDay)")
            
            databaseController.insertGomiyoubi([region, combustiblesDay, plasticDay, incombustiblesDay, plasticBottleDay, dangerousGarbageDay])
        }
        
    }

    
}
