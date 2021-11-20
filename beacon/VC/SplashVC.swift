//
//  ViewController.swift
//  beacon
//
//  Created by Admin on 6/7/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit

class SplashVC: BaseVC {
    
    let notificationCenter = NotificationCenter.default
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        notificationCenter.addObserver(self, selector: #selector(mqttConnected), name: Notification.Name.Action.MQTT_CONNECTED, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let user_name : String = readStringData(key: Constant.PREF_USER_NAME)
        let pwd : String = readStringData(key: Constant.PREF_PWD)
        
        if user_name.count > 0 {
            showLoadingView(msg: "Connecting to the server")
            Common.mqttHelper = MqttHelper.init(username: user_name, pwd: pwd)
        }else{
            gotoUserInfoVC()
        }
    }
    
    @objc func mqttConnected(){
        hideLoadingView()
        let moduleId = readStringData(key: Constant.PREF_MODULE_ID)
        let user_name = readStringData(key: Constant.PREF_USER_NAME)
        let phone = readStringData(key: Constant.PREF_PHONE)
        let pwd = readStringData(key: Constant.PREF_PWD)
        
        Common.userModel = UserModel(user_name: user_name, phone: phone, pwd: pwd)
        Common.isMqttConnected = true
        Common.uuid = readStringData(key: Constant.PREF_MODULE_ID)
        Common.u_name = readStringData(key: Constant.PERF_U_NAME)
    
        
        MqttHelper.subscribeTopic = Constant.BASE_API_SUBSCRIBE + user_name
        MqttHelper.publicTopic = Constant.BASE_API_PUBLIC + user_name
        Common.mqttHelper.mqtt.subscribe(MqttHelper.subscribeTopic)
        
        gotoMainVC()
    }
    
    private func gotoUserInfoVC(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let userInfoVC = storyBoard.instantiateViewController(identifier: "UserInfoVC") as! UserInfoVC
        userInfoVC.modalPresentationStyle = .fullScreen
        self.present(userInfoVC, animated: true, completion: nil)
        
        notificationCenter.removeObserver(self)
    }
    
    private func gotoMainVC(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyBoard.instantiateViewController(identifier: "MainVC") as! MainVC
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC, animated: true, completion: nil)
                
        notificationCenter.removeObserver(self)
    }
}

