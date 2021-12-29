//
//  ViewController.swift
//  walking
//
//  Created by koyasu on 2021/12/22.
//

import UIKit
import YammerSDK

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    //msalToken
    
    //yammerToken
    
    //msalID
    
    //CurrentTeam
    var CurrentTeams = 0
    //JoinedTeams
    var JoinedTeams = [["TeamName":"〇○チーム","Id":20000],["TeamName":"××チーム","Id":30000]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //msalTokenが空ならログイン画面表示
        
        //YammerTokenが空ならログイン画面表示
        if YMLoginClient.sharedInstance().storedAuthToken() == nil {
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(loginViewController!, animated: true, completion: nil)
        }
    }
}

