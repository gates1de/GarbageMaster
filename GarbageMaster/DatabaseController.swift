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

        dbPath = dbDirPath[0].stringByAppendingPathComponent("sample.db")
        
        db = FMDatabase(path: dbPath)
        
        let sql = "CREATE TABLE IF NOT EXISTS sample (user_id INTEGER PRIMARY KEY AUTOINCREMENT, user_name TEXT);"
        //let sql = "DROP TABLE sample;"
        
        db.open()
        
        let result = db.executeUpdate(sql, withArgumentsInArray: nil)
        
        db.close()
        
        if result {
            println("テーブルの作成に成功")
            println(result)
        }
    }
    
    func selectQuery() {
        
        let sql = "SELECT * FROM sample;"
        
        db.open()
        
        let results = db.executeQuery(sql, withArgumentsInArray: nil)
        
        while results.next() {
            // カラム名を指定して値を取得する方法
            let user_id = results.intForColumn("user_id")
            // カラムのインデックスを指定して取得する方法
            let user_name = results.stringForColumnIndex(1)
            
            println("user_id = \(user_id), user_name = \(user_name)")
        }
        
        db.close()
        
    }
    
    func insertQuery(user_name: String) {
        println("insert \(user_name)")
        
        let sql = "INSERT INTO sample (user_id, user_name) VALUES (NULL, ?);"
        
        db.open()
        // ?で記述したパラメータの値を渡す場合
        db.executeUpdate(sql, withArgumentsInArray: [user_name])
        db.close()
        
    }
    
}
