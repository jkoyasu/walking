//
//  TitleView.swift
//  walking
//
//  Created by koyasu on 2022/02/04.
//

import UIKit
import MSAL
import YammerSDK
import HealthKit

class TitleView: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ApplicationData.shared.currentViewController = self
        
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
        let readDataTypes = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: .stepCount)!, HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!)
        HKHealthStore().requestAuthorization(toShare: nil, read: readDataTypes) { success, _ in
            if success {
                if let currentAccount = ApplicationData.shared.currentAccount{
                    
//        YammerTokenが空ならログイン画面表示
//                    if YMLoginClient.sharedInstance().storedAuthToken() == nil {
//                        DispatchQueue.main.async {
//                            self.performSegue(withIdentifier: "toStart", sender: nil)
//                        }
//                    }
                    ApplicationData.shared.callGraphAPI()
                    
                }else{
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toMSAL", sender: nil)
                    }
                }
            }
        }
    }
}
