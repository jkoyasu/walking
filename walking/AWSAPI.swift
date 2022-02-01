//
//  AWSAPI.swift
//  walking
//
//  Created by koyasu on 2021/12/28.
//

import Foundation


enum AWSAPI{

    static func download(url:String,token:String,handler: @escaping (Result<Data, UserAPIError>) -> Void){
        
        var urlComponents = URLComponents(string: url)!
    //        var urlComponents = URLComponents(string: "https://graph.microsoft.com/v1.0/me/")!
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
            request.setValue(token, forHTTPHeaderField: "Authorization")
        print(request.allHTTPHeaderFields)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in guard let data = data else { return }
            let result: Result<Data, UserAPIError>
            defer {
                DispatchQueue.main.async {
                    handler(result)
                }
            }
            
            result = .success(data)
        }
        task.resume()
    }
}
