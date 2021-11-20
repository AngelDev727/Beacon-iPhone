//
//  BaseVC.swift
//  beacon
//
//  Created by Admin on 6/8/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation
import UIKit

class BaseVC: UIViewController{
    
    func showAlert(okayResponse : @escaping(Bool) -> Void) {
        let alert = UIAlertController(title: "", message: "Please change location authorization to always from setting.", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) in
            okayResponse(true)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func showLoadingView(msg : String) {
        let alert = UIAlertController(title: "Please wait...", message: msg, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
                
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    func hideLoadingView() {
        dismiss(animated: false, completion: nil)
    }
    
    func showToast(message : String) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

public extension UIViewController {
    func setStatusBar(color: UIColor) {
        let tag = 12321
        if let taggedView = self.view.viewWithTag(tag){
            taggedView.removeFromSuperview()
        }
        let overView = UIView()
        overView.frame = UIApplication.shared.statusBarFrame
        overView.backgroundColor = color
        overView.tag = tag
        self.view.addSubview(overView)
    }
}

extension Notification.Name {
    struct Action {
        //notification name
        static let LinkUp = Notification.Name("LinkUp")
        static let LinkDown = Notification.Name("LinkDown")
        static let LinkCorrupted = Notification.Name("LinkCorrupted")
        static let IsInForground = Notification.Name("isInForground")
        static let IsInBackground = Notification.Name("isInBackground")
        static let MsgReceived = Notification.Name("msgReceived")
        static let INITIALIZE = Notification.Name("initialize")
        static let MQTT_CONNECTED = Notification.Name("mqtt connected")
        static let START_BEACON_SCAN = Notification.Name("start_beacon_scan")
        static let FCM_RECEIVED = Notification.Name("fcm")
        static let WRONG_CREDENTIAL = Notification.Name("wrong_credential")
    }
}

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded()) 
    }
}

func getLocationPermissionStatus() -> String {
    let locStatus = CLLocationManager.authorizationStatus()
    
    if locStatus.rawValue == 3 {
        return "1"
    }
    
    return "-1"
}
