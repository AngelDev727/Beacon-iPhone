//
//  UserInfoVC.swift
//  beacon
//
//  Created by Admin on 7/8/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import STPopup

class UserInfoVC: BaseVC {
    @IBOutlet weak var txfPhone: UITextField!
    @IBOutlet weak var txfUsername: UITextField!
    @IBOutlet weak var txfPwd: UITextField!
    
    let notificationCenter = NotificationCenter.default
    
    var isRequestSent : Bool = false
    var receivedMqttMsg : String = ""
    var user_name : String = ""
    var phone : String = ""
    var pwd : String = ""
    var isActiveBtnTapped : Bool = false
    
    override func viewDidLoad() {
        self.hideKeyboardWhenTappedAround()
        notificationCenter.addObserver(self, selector: #selector(receivedMsg), name: Notification.Name.Action.MsgReceived, object: nil)
        notificationCenter.addObserver(self, selector: #selector(mqttConnected), name: Notification.Name.Action.MQTT_CONNECTED, object: nil)
        notificationCenter.addObserver(self, selector: #selector(wrongCredential), name: Notification.Name.Action.WRONG_CREDENTIAL, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initBottomSheet()
        
        txfUsername.text = "hazmtest"
        txfPwd.text = "pwd123"
        txfPhone.text = "1234567"

    }
    
    @IBAction func txvPwdDidReturn(_ sender: Any) {
        dismissKeyboard()
        if isValid(){
            user_name = txfUsername.text!
            phone = txfPhone.text!
            pwd = txfPwd.text!

            Common.mqttHelper = MqttHelper.init(username: user_name, pwd: pwd)
            openBottomSheet(isStatus: 1)

            isActiveBtnTapped = true
        }
    }
        
    @objc func wrongCredential(){
        if isActiveBtnTapped {
            isActiveBtnTapped = false
            openBottomSheet(isStatus: 4) // wrong credential
        }
    }
    
    @objc func mqttConnected(){
        MqttHelper.publicTopic = Constant.BASE_API_PUBLIC + user_name
        MqttHelper.subscribeTopic = Constant.BASE_API_SUBSCRIBE + user_name
        Common.mqttHelper.mqtt.subscribe(MqttHelper.subscribeTopic)
        let userModel : UserModel = UserModel.init(user_name: user_name, phone: phone, pwd: pwd)
        Common.mqttHelper.publicMsg(user_model: userModel)
        
    }
    
    @objc func receivedMsg(){
        
        let data = Common.receivedMsg?.data(using: .utf8)
                
        do {
            
            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! [String : AnyObject]
            
            if let ack = json["ack"], let msg = json["msg"], let name = json["name"], let uuid = json["uuid"], let locAcc = json["locAcc"] {
                
                if ack as! String == "1"  {
                    openBottomSheet(isStatus: 2) // active success
                    user_name = txfUsername.text!
                    phone = txfPhone.text!
                    pwd = txfPwd.text!
                    writeAnyData(key: Constant.PERF_U_NAME, value: name as! String)
                    MqttHelper.subscribeTopic = Constant.BASE_API_SUBSCRIBE + user_name
                    Common.mqttHelper.mqtt.subscribe(MqttHelper.subscribeTopic)
                    Common.uuid = uuid as! String
                    Common.u_name = name as! String
                    
                    let fcmTokenPacket : FcmTokenPacket = FcmTokenPacket.init(user_name: user_name, fcm_token: Common.firebase_token)
                    Common.mqttHelper.publicMsg(fcmTokenPacket: fcmTokenPacket)
                    
                    Common.locAcc = locAcc as! String
                    
                }else{
                    receivedMqttMsg = msg as! String
                    openBottomSheet(isStatus: 3)  // active failed
                }
            }

        } catch  {
            print("Error")
        }
    }

    @IBAction func tappedActive(_ sender: Any) {
        if isValid(){
            user_name = txfUsername.text!
            phone = txfPhone.text!
            pwd = txfPwd.text!
            
            Common.mqttHelper = MqttHelper.init(username: user_name, pwd: pwd)
            openBottomSheet(isStatus: 1)
            
            isActiveBtnTapped = true
        }
    }
        
    var popupVController :  STPopupController?
    var bottomSheetVC : BottomSheetVC!
    func initBottomSheet() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        bottomSheetVC = storyBoard.instantiateViewController(identifier: "BottomSheetVC") as! BottomSheetVC
        popupVController = STPopupController(rootViewController: bottomSheetVC)
        popupVController!.style = .bottomSheet
        popupVController!.navigationBarHidden = true
        bottomSheetVC.btnCancel.addTarget(self, action: #selector(tappedCancelBtn), for: UIControl.Event.touchUpInside)
    }
    
    func openBottomSheet(isStatus : Int8) {
        popupVController!.present(in: self)
        switch isStatus {
        case 1:
            bottomSheetVC.activeView.startAnimating()
            bottomSheetVC.label.text = "Verifying Data"
            bottomSheetVC.imageView.isHidden = true
            break
        case 2:
            bottomSheetVC.activeView.stopAnimating()
            bottomSheetVC.activeView.isHidden = true
            bottomSheetVC.imageView.isHidden = false
            bottomSheetVC.imageView.image = UIImage(named: "ic_ok")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.popupVController?.dismiss()
                Common.userModel = UserModel(user_name: self.user_name, phone: self.phone, pwd: self.pwd)
                writeAnyData(key: Constant.PREF_USER_NAME, value: self.user_name)
                writeAnyData(key: Constant.PREF_PHONE, value: self.phone)
                writeAnyData(key: Constant.PREF_PWD, value: self.pwd)
                writeAnyData(key: Constant.PREF_MODULE_ID, value: Common.uuid)
                
                self.notificationCenter.removeObserver(self)
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let mainVC = storyBoard.instantiateViewController(identifier: "MainVC") as! MainVC
                mainVC.modalPresentationStyle = .fullScreen
                self.present(mainVC, animated: true, completion: nil)
            })
            break
        case 3:
            bottomSheetVC.activeView.stopAnimating()
            bottomSheetVC.activeView.isHidden = true
            bottomSheetVC.imageView.isHidden = false
            bottomSheetVC.imageView.image = UIImage(named: "ic_warring")
            bottomSheetVC.label.text = receivedMqttMsg
            break
        case 4:
            bottomSheetVC.activeView.stopAnimating()
            bottomSheetVC.activeView.isHidden = true
            bottomSheetVC.imageView.isHidden = false
            bottomSheetVC.imageView.image = UIImage(named: "ic_warring")
            bottomSheetVC.label.text = "Wrong Credential Information"
            break
        default:
            break
        }
    }
    
    @objc func tappedCancelBtn(){
        popupVController?.dismiss()
    }
    
    func isValid() -> Bool {
        
        if txfPhone.text?.count == 0 {
            
            showToast(message: "Input phone number")
            return false
        }
        
        if txfUsername.text?.count == 0 {
            showToast(message: "Inpute user name")
            return false
        }
        
        if txfPwd.text?.count == 0 {
            showToast(message: "Input password")
            return false
        }
        
        return true
    }
}
