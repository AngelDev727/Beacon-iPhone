//
//  DBHelper.swift
//  beacon
//
//  Created by Admin on 7/16/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation
import SQLite3

class DBHelper {
    
    init(){
        db = openDatabase()
        createTable()
    }

    let dbPath: String = "hazm.sqlite"
    var db:OpaquePointer?

    func openDatabase() -> OpaquePointer?{
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK
        {
            print("error opening database")
            return nil
        }
        else {
            print("Successfully opened connection to database at \(dbPath)")
            return db
        }
    }
    
    func createTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS packet(Id INTEGER PRIMARY KEY,time TEXT,ddt TEXT, u_id TEXT, lat TEXT, lon TEXT, sec TEXT, tgs TEXT, d_bat TEXT, p_bat TEXT, gps TEXT, ble TEXT, loc_access TEXT, type TEXT, speed TEXT, locAcc TEXT, locMode TEXT, major TEXT, minor TEXT);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("packet table created.")
            } else {
                print("packet table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    
    func insert(time:String, ddt:String, u_id:String, lat: String, lon: String, sec: String, tgs: String, d_bat:String, p_bat: String, gps: String, ble: String, loc_access: String, type: String, speed : String, locAcc : String, locMode : String, major : String, minor : String) {
                
        let insertStatementString = "INSERT INTO packet (Id, time, ddt, u_id, lat, lon, sec, tgs, d_bat, p_bat, gps, ble, loc_access, type, speed, locAcc, locMode, major, minor) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int64(insertStatement, 1, Int64(time)!)
            sqlite3_bind_text(insertStatement, 2, (time as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (ddt as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, (u_id as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, (lat as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 6, (lon as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7, (sec as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 8, (tgs as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 9, (d_bat as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 10, (p_bat as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 11, (gps as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 12, (ble as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 13, (loc_access as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 14, (type as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 14, (speed as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 14, (locAcc as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 14, (locMode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 14, (major as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 14, (minor as NSString).utf8String, -1, nil)
            
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func read() -> [PacketModel] {
        let queryStatementString = "SELECT * FROM packet;"
        var queryStatement: OpaquePointer? = nil
        var packets : [PacketModel] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let time = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let ddt = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let u_id = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let lat = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let lon = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                let sec = String(describing: String(cString: sqlite3_column_text(queryStatement, 6)))
                let tgs = String(describing: String(cString: sqlite3_column_text(queryStatement, 7)))
                let d_bat = String(describing: String(cString: sqlite3_column_text(queryStatement, 8)))
                let p_bat = String(describing: String(cString: sqlite3_column_text(queryStatement, 9)))
                let gps = String(describing: String(cString: sqlite3_column_text(queryStatement, 10)))
                let ble = String(describing: String(cString: sqlite3_column_text(queryStatement, 11)))
                let loc_access = String(describing: String(cString: sqlite3_column_text(queryStatement, 12)))
                let type = String(describing: String(cString: sqlite3_column_text(queryStatement, 13)))
                let speed = String(describing: String(cString: sqlite3_column_text(queryStatement, 14)))
                let locAcc = String(describing: String(cString: sqlite3_column_text(queryStatement, 15)))
                let locMode = String(describing: String(cString: sqlite3_column_text(queryStatement, 16)))
                let major = String(describing: String(cString: sqlite3_column_text(queryStatement, 17)))
                let minor = String(describing: String(cString: sqlite3_column_text(queryStatement, 18)))
                                
                packets.append(PacketModel.init(time: time, ddt: ddt, u_id: u_id, lat: lat, lon: lon, sec: sec, tgs: tgs, d_bat: d_bat, p_bat: p_bat, gps: gps, ble: ble, loc_access: loc_access, type: type, speed : speed, locAcc : locAcc, locMode : locMode, major : major, minor : minor))
                
                
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return packets
    }
    
    func deleteByID(time:String) {        
        let deleteStatementStirng = "DELETE FROM packet WHERE Id = ?;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {            
            sqlite3_bind_int64(deleteStatement, 1, Int64(time)!)
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
}
