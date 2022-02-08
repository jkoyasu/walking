//
//  AWSAPI.swift
//  walking
//
//  Created by koyasu on 2021/12/28.
//

import Foundation

enum AWSAPIError: Error{
    case AWSInvalidRequest
    case AWSNoBodyContent
    //case invalidBodyContent(reason: String)
}

enum AWSAPI{

    static func download(url:String,token:String,handler: @escaping (Result<Data, AWSAPIError>) -> Void){
        
        var urlComponents = URLComponents(string: url)!
    //        var urlComponents = URLComponents(string: "https://graph.microsoft.com/v1.0/me/")!
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print(request.allHTTPHeaderFields)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let result: Result<Data, AWSAPIError>
            defer {
                DispatchQueue.main.async {
                    handler(result)
                }
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                      result = .failure(.AWSInvalidRequest)
                      return
                  }
            
            guard let data = data else {
                result = .failure(.AWSNoBodyContent)
                return
            }
            result = .success(data)
        }
        task.resume()
    }
    
    
    //message本文あり
    static func upload(message:Data,url:String,token:String,handler: @escaping (Result<Data, AWSAPIError>) -> Void){
        var urlComponents = URLComponents(string: url)!
//        var urlComponents = URLComponents(string: "https://graph.microsoft.com/v1.0/me/")!
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.httpBody = message

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let result: Result<Data, AWSAPIError>
            defer {
                DispatchQueue.main.async {
                    handler(result)
                }
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                      result = .failure(.AWSInvalidRequest)
                      return
                  }
            
            guard let data = data else {
                result = .failure(.AWSNoBodyContent)
                return
            }
            result = .success(data)
        }
        task.resume()
    }
}
