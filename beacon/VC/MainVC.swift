//
//  MainVC.swift
//  beacon
//
//  Created by Admin on 6/8/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import AVFoundation
var timer : Timer = Timer()
var cnt_120 : Int64 = 0

class MainVC: UITabBarController, CLLocationManagerDelegate {
    
    private lazy var locationManager: CLLocationManager = {
      let manager = CLLocationManager()
      manager.desiredAccuracy = kCLLocationAccuracyBest
      manager.delegate = self
      manager.requestAlwaysAuthorization()
      manager.allowsBackgroundLocationUpdates = true        
      return manager
    }()
    
    override func viewDidLoad() {
        NotificationCenter.default.post(name: Notification.Name.Action.START_BEACON_SCAN, object: nil)
        
        if Common.locAcc == "1" {
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        } else if Common.locAcc == "2" {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        locationManager.requestAlwaysAuthorization()
        
        locationManager.startMonitoringVisits()
        locationManager.delegate = self
        
        locationManager.startUpdatingLocation()
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location : CLLocation =  locations[0]
        
        if location.altitude < 0.1 {
            Common.isFakeGPS = true
        }else{
            Common.isFakeGPS = false
        }
        
        Common.lat = String(location.coordinate.latitude)
        Common.lng = String(location.coordinate.longitude)
        
        let mostRecentLocation = locations.last
        Common.locAccInPacket = mostRecentLocation?.horizontalAccuracy.debugDescription as! String
        
        
        var speed: CLLocationSpeed = CLLocationSpeed()
        speed = locationManager.location!.speed
        
        
        if speed.description.contains("-"){
            Common.speed = "0"
        }else {
            Common.speed = "\(speed)"
        }
        

    }
}
