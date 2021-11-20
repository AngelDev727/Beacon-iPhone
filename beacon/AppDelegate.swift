//
//  AppDelegate.swift
//  beacon
//
//  Created by Admin on 6/7/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseCore
import FirebaseMessaging
import FirebaseInstanceID

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
   
    var window: UIWindow?
    var beaconManager : ESTBeaconManager!
    var beaconRegion : CLBeaconRegion!
    var timer : Timer = Timer()
    var cnt_90 : Int = 0
    var cnt_60 : Int = 0
            
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
           
        /// enable battery level read
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            if granted {
                DispatchQueue.main.async { // Correct
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(startBeaconScan), name: Notification.Name.Action.START_BEACON_SCAN, object: nil)
        
       
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()

        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        
        InstanceID.instanceID().instanceID { (result, error) in
          if let error = error {
            print("Error fetching remote instance ID: \(error)")
          } else if let result = result {
            print("Remote instance ID token: \(result.token)")
            
            Common.firebase_token = result.token
          }
        }
        
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(sendMqtt), userInfo: nil, repeats: true)
        
        Common.db = DBHelper()
        
        Common.osVersion =  UIDevice.current.systemVersion
        Common.model = UIDevice().type.rawValue
        
        return true        
    }
    
    @objc func sendMqtt(){
        cnt_90 += 1
        
        if cnt_90 == 90 {
            if getLocationPermissionStatus() == "0" || getLocationPermissionStatus() == "2" || Common.linkStatus == Constant.LINK_DOWN {
                
                if Common.isMqttConnected {
                    Common.linkStatus = Constant.LINK_DOWN
                    NotificationCenter.default.post(name: Notification.Name.Action.LinkDown, object: nil)
                    
                    let packet = PacketModel.init()
                    packet.type = "1"
                    Common.mqttHelper.publicMsg(packet : packet)
                }
                
            }
            
            cnt_90 = 0
        }
        
        cnt_60 += 1
        
        if cnt_60 == 60 {
            if Common.isMqttConnected {
                let model : PacketModel = PacketModel.init()
                model.type = "2"
                Common.mqttHelper.publicMsg(packet: model)
            }
            cnt_60 = 0
        }
    }
    
    @objc func startBeaconScan() {
        
        beaconRegion = CLBeaconRegion(uuid: UUID(uuidString: Common.uuid)!, identifier: "monitored region")
        
        beaconManager = ESTBeaconManager()
        beaconManager.delegate = self
        beaconManager.requestAlwaysAuthorization()
        beaconManager.startMonitoring(for: beaconRegion)
        beaconManager.startRangingBeacons(in: beaconRegion)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")

        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("fcm1111 ==== \(userInfo)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("fcm2222 ==== \(userInfo)")
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func beaconManager(_ manager: Any, didEnter region: CLBeaconRegion) {
//        showNotification(msg: "The link with the bracelet is up")
        Common.linkStatus = Constant.LINK_UP
        
        let packetModel :  PacketModel = PacketModel.init()
        packetModel.type = "1"
    
        if Common.isMqttConnected {
            Common.mqttHelper.publicMsg(packet: packetModel)
        }
        
        Common.mqttHelper.packet = packetModel
        
        NotificationCenter.default.post(name: Notification.Name.Action.LinkUp, object: nil)
        print("Enter")
    }
    
    func beaconManager(_ manager: Any, didExitRegion region: CLBeaconRegion) {
//        showNotification(msg: "Please stay near your phone")
        Common.linkStatus = Constant.LINK_DOWN
        
        if !Common.isInForground {
            NotificationCenter.default.post(name: Notification.Name.Action.LinkDown, object: nil)
        }
        
        let packetModel :  PacketModel = PacketModel.init()
        packetModel.type = "1"
        if Common.isMqttConnected {
            Common.mqttHelper.publicMsg(packet: packetModel)
        }
        
        Common.mqttHelper.packet = packetModel
        
        NotificationCenter.default.post(name: Notification.Name.Action.LinkDown, object: nil)
                
        print("Exit")
    }
    
    func beaconManager(_ manager: Any, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons{
            if beacon.uuid.uuidString == Common.uuid {
                Common.strMajor = beacon.major.stringValue
                Common.strMinor = beacon.minor.stringValue

                if Common.strMinor == "-2" {
                    Common.strTxPower = Common.strMinor
                }else {
                    Common.strTxPower = "-1"
                }
                
                if beacon.proximity == .immediate || beacon.proximity == .near || beacon.proximity == .far{
                    
                    if beacon.major.stringValue == Constant.MAX_MAJOR {
                        Common.linkStatus = Constant.linkCorrupted
                        NotificationCenter.default.post(name: Notification.Name.Action.LinkCorrupted, object: nil)
                        let packet = PacketModel.init()
                        packet.type = "1"
                        Common.mqttHelper.publicMsg(packet : packet)
                    }else if Common.linkStatus != Constant.LINK_UP && Common.isBleOn{
                        
                        Common.linkStatus = Constant.LINK_UP
                        NotificationCenter.default.post(name: Notification.Name.Action.LinkUp, object: nil)
                        let packet = PacketModel.init()
                        packet.type = "1"
                        Common.mqttHelper.publicMsg(packet : packet)
                    }
                }else if Common.linkStatus != Constant.LINK_DOWN && Common.isBleOn{
                    Common.linkStatus = Constant.LINK_DOWN
//                    NotificationCenter.default.post(name: Notification.Name.Action.LinkDown, object: nil)
                    cnt_90 = 0
                }
            }
        }
        
//        if beacons.count == 0 && Common.isBleOn {
//            Common.linkStatus = Constant.LINK_DOWN
//            NotificationCenter.default.post(name: Notification.Name.Action.LinkDown, object: nil)
//        }
    }
    
    func beaconManager(_ manager: Any, rangingBeaconsDidFailFor region: CLBeaconRegion?, withError error: Error) {
        print("region beacons did fail for")
    }
    
    func beaconManager(_ manager: Any, didStartMonitoringFor region: CLBeaconRegion) {
        print("monitoring started")
    }
    
    func beaconManager(_ manager: Any, monitoringDidFailFor region: CLBeaconRegion?, withError error: Error) {
        print("monitoring failed")
    }
    
    func showNotification(msg : String) {
        let content = UNMutableNotificationContent()
        content.title = "HAZM"
        content.body = msg
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "com.sts.beacon"
        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest.init(identifier: content.categoryIdentifier as String, content: content, trigger: trigger)
        // Schedule the notification.
        let center = UNUserNotificationCenter.current()
        center.add(request)
    }
}


