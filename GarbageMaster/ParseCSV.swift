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
        getData = NSData.dataWithContentsOfURL(remoteCSVPath, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        string = NSString(data: getData, encoding: NSShiftJISStringEncoding)
        
        // 取得したCSVデータの文字コードがShiftJISであるため, 一旦UTF8に変換する
        let encodeString: NSString = string.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let encodeData: NSData = encodeString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        
        // 端末内のディレクトリへのパスを指定
        let dataPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let path = dataPath[0].stringByAppendingPathComponent(CSVName)
        
        encodeData.writeToFile(path, atomically: true)
    }
    
    func parseCSV() {
        let dataPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let path = dataPath[0].stringByAppendingPathComponent("garbage.csv")
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
            
            // println("rows \(i) = \(item), \(distinction), \(caution)")
            
        }
        
        
    }
    
}
