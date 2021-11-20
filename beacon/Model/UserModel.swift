//
//  UserModel.swift
//  beacon
//
//  Created by Admin on 7/8/20.
//  Copyright © 2020 Admin. All rights reserved.
//

class UserModel {
    var time : String
    public var user_name : String
    public var phone : String
    public var pwd : String
    public var os : String
    var osVersion : String
    var manufacturer : String
    var model : String
    var appVersion : String
    
    init(user_name : String, phone : String, pwd : String) {
        self.time = String(Date().timeIntervalSince1970)
        self.user_name = user_name
        self.phone = phone
        self.pwd = pwd
        self.os = "ios"
        self.osVersion = Common.osVersion
        self.manufacturer = "apple"
        self.model = Common.model
        self.appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
    }
    
    func getJSONString() -> String {
        var jsonString : String = ""
        
        let jsonObject : NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(time, forKey: "time")
        jsonObject.setValue(phone, forKey: "phone")
        jsonObject.setValue(user_name, forKey: "uname")
        jsonObject.setValue(pwd, forKey: "pwd")
        jsonObject.setValue(os, forKey: "os")
        jsonObject.setValue(osVersion, forKey: "osVersion")
        jsonObject.setValue(manufacturer, forKey: "manufacturer")
        jsonObject.setValue(model, forKey: "model")
        jsonObject.setValue(appVersion, forKey: "appVersion")
        
        let jsonData : NSData
        do{
            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
            jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as! String
        }catch{
            print("JSON Failure")
        }
        return jsonString
    }
}
