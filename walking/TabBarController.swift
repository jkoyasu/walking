//
//  ViewController.swift
//  walking
//
//  Created by koyasu on 2021/12/22.
//

import UIKit
import YammerSDK
import MSAL

class TabBarController: UITabBarController, UITabBarControllerDelegate {
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if viewController is UITabBarDelegate {
            let v = viewController as! UITabBarDelegate
        }
    }
}
