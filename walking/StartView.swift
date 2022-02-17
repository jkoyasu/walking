//
//  StartView.swift
//  walking
//
//  Created by koyasu on 2022/01/06.
//

import UIKit
import MSAL
import YammerSDK


class StartView: UIViewController {
        
    @IBOutlet weak var forwardButton: UIButton!
    
    //画面取得後
    override func viewDidLoad() {
        super.viewDidLoad()
        ApplicationData.shared.currentViewController = self
        forwardButton.isEnabled = false
        
        do {
            try ApplicationData.shared.initMSAL()
        } catch let error {
            ApplicationData.shared.updateLogging(text: "Unable to create Application Context \(error)")
        }
        ApplicationData.shared.loadCurrentAccount()
        
    }
    
    //画面表示後
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//      Yammerのアクセス情報を取得
        ApplicationData.shared.acquireTokenInteractively(){ success in
            self.forwardButton.isEnabled = true
        }
//        YammerTokenが空ならログイン画面表示
//            if YMLoginClient.sharedInstance().storedAuthToken() == nil {
//                let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
//                self.performSegue(withIdentifier: "fromStartToLogin", sender: nil)
//            }
    }
    
    @IBAction func tappedForwardButton(_ sender: Any) {
//                YammerTokenが空ならログイン画面表示
//                    if YMLoginClient.sharedInstance().storedAuthToken() == nil {
//                        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
//                        self.performSegue(withIdentifier: "fromStartToLogin", sender: nil)
//                    }
        ApplicationData.shared.authorizeAWS(id:ApplicationData.shared.mailId) { team in
            ApplicationData.shared.loadMyRanking(id: ApplicationData.shared.mailId) { result in
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "fromStartToTab", sender: nil)
                    return
                }
            }
        }
    }
}
