//
//  HomeVC.swift
//  beacon
//
//  Created by Admin on 6/8/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import CoreBluetooth
import NotificationBannerSwift
import AVFoundation
import UserNotifications
import Connectivity

class HomeVC: BaseVC , CBCentralManagerDelegate {
    
    @IBOutlet weak var lblState: UILabel!
    @IBOutlet weak var lblAPIMsg: UILabel!
    @IBOutlet weak var imvLinkState: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    
    var bluetoothManager : CBCentralManager!
    var bannerNoti : FloatingNotificationBanner!
    let connectivity : Connectivity = Connectivity()
    
    var prevImg : String = ""
    var prevTxt : String = ""
    var timer : Timer = Timer()
    var offlinePackets : [PacketModel] = []
    
    override func viewDidLoad() {
        
        // bluetooth status linstenner
        bluetoothManager = CBCentralManager()
        bluetoothManager.delegate = self
        
        let connectivityChanged : (Connectivity) -> Void = {[weak self] connectivity in self?.updateConnectionStatus(connectivity.status)}
        connectivity.whenConnected = connectivityChanged
        connectivity.whenDisconnected = connectivityChanged        
        connectivity.startNotifier()

        lblUserName.text = Common.u_name
        
        addObserver()
        Common.isInForground = true
    
        checkLocationAccess()
    }
    
    
    func checkLocationAccess()  {
        
        // never = 2, ack = 0, while using the app = 4, always using = 3
        if CLLocationManager.locationServicesEnabled() {
            print("aaa == \(CLLocationManager.authorizationStatus().rawValue)")
            if CLLocationManager.authorizationStatus().rawValue != 3 {
                Common.locAcc = "-1"
                self.showAlert(okayResponse: {response in
                    self.gotoSetting()
                })
            }else {
                Common.locAcc = "1"
            }
        }
    }
    
    func gotoSetting()  {
        if let bundleId = Bundle.main.bundleIdentifier,
            let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func startTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(sendOfflinePackets), userInfo: nil, repeats: true)
    }
    
    @objc func sendOfflinePackets()  {
        if offlinePackets.count > 0 && Common.isInternetAvailable {
            let packet : PacketModel = offlinePackets[0]
            
            Common.db.deleteByID(time: packet.time)
            
            packet.time = String(Date().millisecondsSince1970)
            Common.mqttHelper.publicMsg(packet: packet)
            offlinePackets.remove(at: 0)
        }else{
            timer.invalidate()
        }
    }
        
    func updateConnectionStatus(_ status : Connectivity.Status) {
        if status == .connected || status == .connectedViaCellular || status == .connectedViaWiFi {
            
            Common.isInternetAvailable = true
            
            offlinePackets = Common.db.read()
            
            if offlinePackets.count > 0 {
                startTimer()
            }else{
                timer.invalidate()
            }
            
        }else{
            Common.isInternetAvailable = false
        }
    }
    
    // bluetooth status linstener
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .poweredOn:
                Common.isBleOn = true                
                break
            case .poweredOff:
                Common.isBleOn = false                
                showNotification(msg: "You must turn on Bluetooth")
                break
            case .resetting:
                break
            case .unauthorized:
                break
            case .unsupported:
                break
            case .unknown:
                break
            default:
                break
        }
    }
    
    func showBannerNotification(content : String) {
        bannerNoti = FloatingNotificationBanner(title: "HAZM", subtitle: content, style: .success)
        bannerNoti.show(cornerRadius: 8,shadowColor: UIColor(red: 0.431, green: 0.459, blue: 0.494, alpha: 1),shadowBlurRadius: 16, shadowEdgeInsets: UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8))
    }
    
    @objc func linkUp(){
        if Common.loc_ack != "2" {
            imvLinkState.image = UIImage(named: "link_up")
            lblState.text = ""
            prevImg = "link_up"
            prevTxt = ""
        }
            
    }
    
    @objc func linkDown(){
        if Common.loc_ack != "2" {
            imvLinkState.image = UIImage(named: "link_down")
            lblState.text = "Module is out of range!"
            
            prevImg = "link_down"
            prevTxt = "Module is out of range!"
        }
                
    }
    
    @objc func linkCorrupt(){
        if Common.loc_ack != "2"{
            imvLinkState.image = UIImage(named: "link_corrupted")
            lblState.text = "Module seems to be corrupted!"
            
            prevImg = "link_corrupted"
            prevTxt = "Module seems to be corrupted!"
        }
    }
    
    @objc func isInBackground(){
        Common.isInForground = false
    }
    
    @objc func isInForground() {
        Common.isInForground = true
        if !Common.isBleOn {
            showBannerNotification(content: "You must turn on Bluetooth")
            AudioServicesPlaySystemSound(SystemSoundID(1322))
            
            imvLinkState.image = UIImage(named: "ble_off")
            lblState.text = "Bluetooth is off. You must keep is always on!"
            
            prevImg = "ble_off"
            prevTxt = "Bluetooth is off. You must keep is always on!"
            
            Common.mqttHelper.publicMsg(packet: PacketModel.init())
        }
        
        if !Common.isInternetAvailable {
            showBannerNotification(content: "You must enable access to the interenet")
            AudioServicesPlaySystemSound(SystemSoundID(1322))
        }
        
        Common.linkStatus = 0
    }
    
    @objc func receivedMsg(){        
        let data = Common.receivedMsg?.data(using: .utf8)
                
        do {
            
            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! [String : AnyObject]
            
            if let time = json["time"], let loc_ack = json["loc_ack"], let sec_ack = json["sec_ack"], let msg = json["msg"]{
                
                Common.loc_ack = loc_ack as! String
                
                if loc_ack as! String == "2"{
                    showBannerNotification(content: "You Are Outside Your Quarantine Area")
                    
                    imvLinkState.image = UIImage(named: "user_outside_area")
                    lblState.text = "You Are Outside Your Quarantine Area"
                }else{
                    imvLinkState.image = UIImage(named: prevImg)
                    lblState.text = prevTxt
                }
            }

        } catch  {
            print("Error")
        }
    }
    
    func addObserver()  {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(linkUp), name: Notification.Name.Action.LinkUp, object: nil)
        notificationCenter.addObserver(self, selector: #selector(linkDown), name: Notification.Name.Action.LinkDown, object: nil)
        notificationCenter.addObserver(self, selector: #selector(linkCorrupt), name: Notification.Name.Action.LinkCorrupted, object: nil)
        notificationCenter.addObserver(self, selector: #selector(isInBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(isInForground), name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(receivedMsg), name: Notification.Name.Action.MsgReceived, object: nil)
    
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
