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
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        YMLoginClient.sharedInstance().startLogin(withContextViewController: self)
    }
}
