//
//  AWSAPI.swift
//  walking
//
//  Created by koyasu on 2021/12/28.
//

import Foundation


enum AWSAPI{

    static func download(token:String,handler: @escaping (Result<Any, UserAPIError>) -> Void){
        var urlComponents = URLComponents(string: "https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/select_personal_ranking_api")!
    //        var urlComponents = URLComponents(string: "https://graph.microsoft.com/v1.0/me/")!
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
    //        request.setValue(self.accessToken, forHTTPHeaderField: "Authorization")
        print(request.allHTTPHeaderFields)
        var tmp:[String:Any] = [:]

        let task = URLSession.shared.dataTask(with: request) { data, response, error in guard let data = data else { return }
            var result: Result<PersonRecord, UserAPIError>
            do {
                let decoder = JSONDecoder()
                result = .success(try decoder.decode(PersonRecord.self, from: data))
                print(result)
                
            } catch let error{
                print("-------",error)}
        }
        task.resume()
    }
}
