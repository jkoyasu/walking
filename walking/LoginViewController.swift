//
//  LoginView.swift
//  walking
//
//  Created by koyasu on 2021/12/28.
//

import Foundation
import UIKit
import YammerSDK

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        //super.viewDidLoad()
        //YMLoginClient.sharedInstance().startLogin(withContextViewController: self)
    }
    override func viewDidAppear(_ animated: Bool) {
        //super.viewDidLoad()
        YMLoginClient.sharedInstance().startLogin(withContextViewController: self)
    }
    
}
