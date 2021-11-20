//
//  FcmTokenPacket.swift
//  beacon
//
//  Created by Admin on 7/15/20.
//  Copyright © 2020 Admin. All rights reserved.
//

class FcmTokenPacket {
    
    var time : String
    var user_name : String
    var fcm_token : String
    
    init(user_name : String, fcm_token : String) {
        time = String(Date().timeIntervalSince1970)
        self.user_name = user_name
        self.fcm_token = fcm_token
    }
    
    func getJSONString() -> String {
        var jsonString : String = ""
        
        let jsonObject : NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(time, forKey: "time")
        jsonObject.setValue(user_name, forKey: "username")
        jsonObject.setValue(fcm_token, forKey: "fcmToken")
        
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
