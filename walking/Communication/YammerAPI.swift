//
//  YammerAPI.swift
//  walking
//
//  Created by koyasu on 2021/12/28.
//

import Foundation
import YammerSDK
import UIKit
//Yammer諸々API

enum UserAPIError: Error {
    case invalidRequest
    case noBodyContent
    case invalidBodyContent(reason: String)
}

enum YammerAPI{
    
    static func APICAll(handler: @escaping (Result<Any, UserAPIError>) -> Void){
        let authToken = YMLoginClient.sharedInstance().storedAuthToken()
        NSLog("Making sample API call")
        let params:[String:Any] = ["threaded": "extended", "limit": 30 ]
//        let params:[String:Any] = ["replied_to_id": "20767801483264", "body": "test用の投稿です。"]
        let client:YMAPIClient = YMAPIClient.init(authToken: authToken)
        
        client.getPath("/api/v1/messages.json", parameters: params, success: { data in
            var result: Result<Any, UserAPIError>
            result = .success(data)
            
            defer {
                DispatchQueue.main.async {
                    handler(result)
                }
            }
        }, failure: { data in
            print("thisisresult failure",data)
        })
    }
}
