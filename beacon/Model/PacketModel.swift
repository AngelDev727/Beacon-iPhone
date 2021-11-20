//
//  PacketModel.swift
//  beacon
//
//  Created by Admin on 7/8/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import CocoaMQTT

class PacketModel {
    public var time : String
    public var ddt : String
    public var id : String
    public var lat : String
    public var lon : String
    public var sec : String
    public var tgs : String
    public var d_bat : String
    public var p_bat : String
    public var gps : String!
    public var ble : String
    public var loc_access : String!
    public var type : String
    public var speed : String!
    var locAcc : String!
    var locMode : String!
    var major : String!
    var minor : String!
    
    var locationManager = CLLocationManager()
    var currentLocation : CLLocation!
    
    init() {
        time = String(Date().millisecondsSince1970)
        ddt = time
        id = Common.userModel.user_name
        
        lat = Common.lat
        lon = Common.lng
        
        sec = Common.strMajor + Common.strMinor
        tgs = String(Common.linkStatus)
        d_bat = Common.strTxPower
        p_bat = String(Int(UIDevice.current.batteryLevel * 100))
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                self.gps = "1"
            default:
                self.gps = "0"
            }
        }
        
        if Common.isFakeGPS {
            gps = "2"
        }
        
        if  Common.isBleOn {
            ble = "1"
        }else{
            ble = "0"
        }
        
        type = "2"
        
        self.loc_access = getLocationPermissionStatus()
        self.speed = Common.speed
        self.locAcc = Common.locAccInPacket
        self.locMode = Common.locAcc
        self.major = Common.strMajor
        self.minor = Common.strMinor
    }
    
    init(time: String, ddt: String, u_id: String, lat: String, lon: String, sec: String, tgs: String, d_bat: String, p_bat: String, gps: String, ble: String, loc_access: String, type: String, speed : String, locAcc : String, locMode : String, major : String, minor : String) {
        self.time = time
        self.ddt = ddt
        self.id = u_id
        self.lat = lat
        self.lon = lon
        self.sec = sec
        self.tgs = tgs
        self.d_bat = d_bat
        self.p_bat = p_bat
        self.gps = gps
        self.ble = ble
        self.loc_access = loc_access
        self.type = type
        self.speed = speed
        self.locAcc = locAcc
        self.locMode = locMode
        self.major = major
        self.minor = minor
    }
    
    func getJSONString() -> String{
        var jsonString : String = ""
        
        let jsonObject : NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(time, forKey: "time")
        jsonObject.setValue(ddt, forKey: "ddt")
        jsonObject.setValue(id, forKey: "id")
        jsonObject.setValue(lat, forKey: "lat")
        jsonObject.setValue(lon, forKey: "lon")
        jsonObject.setValue(sec, forKey: "sec")
        jsonObject.setValue(tgs, forKey: "tgs")
        jsonObject.setValue(d_bat, forKey: "d_bat")
        jsonObject.setValue(p_bat, forKey: "p_bat")
        jsonObject.setValue(gps, forKey: "gps")
        jsonObject.setValue(ble, forKey: "ble")
        jsonObject.setValue(loc_access, forKey: "loc_access")
        jsonObject.setValue(type, forKey: "type")
        jsonObject.setValue(speed, forKey: "speed")
        jsonObject.setValue(locAcc, forKey: "locAcc")
        jsonObject.setValue(locMode, forKey: "locMode")
        jsonObject.setValue(major, forKey: "major")
        jsonObject.setValue(minor, forKey: "minor")
        
        let jsonData : NSData
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
            jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as! String
            
        }catch{
            print("JSON Failure")
        }
        
        return jsonString
    }
}
