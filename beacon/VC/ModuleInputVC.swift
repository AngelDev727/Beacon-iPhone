//
//  ModuleInputVC.swift
//  beacon
//
//  Created by Admin on 6/8/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit

class ModuleInputVC: BaseVC {
    @IBOutlet weak var txfModuleId: UITextField!
    
    override func viewDidLoad() {

    }
    
    @IBAction func done(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    
    @IBAction func tappedActiveBtn(_ sender: Any) {
        
        writeAnyData(key: Constant.PREF_MODULE_ID, value: txfModuleId.text)
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(identifier: "MainVC")
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC, animated: true, completion: nil)
    }
}
