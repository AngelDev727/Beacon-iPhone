//
//  MqttHelper.swift
//  beacon
//
//  Created by Admin on 6/24/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation
import CocoaMQTT

class MqttHelper {
    
    let clientID = "Beacon-" + String(ProcessInfo().processIdentifier)
    let hostUrl :String = "broker.hazm.tech"
    var mqtt : CocoaMQTT
    public static var subscribeTopic : String = ""
    public static var publicTopic : String = ""
    var packet : PacketModel!
    
    init(username : String, pwd : String) {
        mqtt = CocoaMQTT(clientID: clientID, host: hostUrl, port: 8883)
        mqtt.username = username
        mqtt.password = pwd
        mqtt.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        mqtt.keepAlive = 20
        mqtt.enableSSL = true
        mqtt.allowUntrustCACertificate = true        
        mqtt.delegate = self
        mqtt.connect()        
    }
        
    func publicMsg (packet : PacketModel) {
        if Common.isInternetAvailable {
            mqtt.publish(MqttHelper.publicTopic, withString: packet.getJSONString())
        }else{
            Common.db.insert(time: packet.time, ddt: packet.ddt, u_id: packet.id, lat: packet.lat, lon: packet.lon, sec: packet.sec, tgs: packet.tgs, d_bat: packet.d_bat, p_bat: packet.p_bat, gps: packet.gps, ble: packet.ble, loc_access: packet.loc_access, type: packet.type, speed: packet.speed, locAcc : packet.locAcc, locMode : packet.locMode, major : packet.major, minor : packet.minor)
        }
    }
    
    func publicMsg(user_model: UserModel) {
        mqtt.publish(MqttHelper.publicTopic, withString: user_model.getJSONString())
    }
    
    func publicMsg(fcmTokenPacket : FcmTokenPacket) {
        mqtt.publish(MqttHelper.publicTopic, withString: fcmTokenPacket.getJSONString())
    }
}


extension MqttHelper : CocoaMQTTDelegate{
    
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
        
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        if !Common.isCredentialAvailable{
            NotificationCenter.default.post(name: Notification.Name.Action.WRONG_CREDENTIAL, object: nil)
        }
        
        Common.isMqttConnected = false
        let user_name : String = readStringData(key: Constant.PREF_USER_NAME)
        let pwd : String = readStringData(key: Constant.PREF_PWD)
        Common.mqttHelper = MqttHelper(username: user_name, pwd: pwd)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
         if ack == .accept {

            Common.isCredentialAvailable = true
            
            print("mqtt connected")
            Common.isMqttConnected = true
            NotificationCenter.default.post(name: Notification.Name.Action.MQTT_CONNECTED, object: nil)
            if Common.mqttHelper.packet != nil {
                publicMsg(packet: Common.mqttHelper.packet)
            }
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        Common.mqttHelper.packet = nil
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {        
        Common.receivedMsg = message.string?.description
        NotificationCenter.default.post(name: Notification.Name.Action.MsgReceived, object: nil)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
    }
}
