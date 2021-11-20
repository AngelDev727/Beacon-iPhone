//
//  Common.swift
//  beacon
//
//  Created by Admin on 6/22/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation

class Common{
    public static var uuid : String = ""
    public static var lat : String = ""
    public static var lng : String = ""
    public static var homeMsg : String = ""
    public static var strMinor : String = ""
    public static var strMajor : String = ""
    public static var strTxPower : String = ""
    public static var isBleOn : Bool = false
    public static var isInternetAvailable = false
    public static var mqttHelper : MqttHelper!
    public static var isGPSEnabled : Bool = false
    public static var receivedMsg :String? = ""
    public static var isMqttConnected : Bool = false
    public static var region : Int8 = 0
    public static var userModel : UserModel!
    public static var linkStatus : Int8 = Constant.LINK_DOWN
    public static var isFakeGPS : Bool = false
    public static var loc_ack : String = ""
    public static var u_name : String = ""
    public static var fcm : String = ""
    public static var firebase_token : String = ""
    public static var db : DBHelper!
    public static var isCredentialAvailable : Bool = false
    static var locAcc : String = ""
    static var osVersion : String = ""
    static var model : String = ""
    static var speed : String = ""
    static var selectedLocAcc : String = ""
    static var isInForground : Bool = false
    static var locAccInPacket : String = ""
}
