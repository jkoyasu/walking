//
//  ApplicationData.swift
//  walking
//
//  Created by koyasu on 2022/02/02.
//

import Foundation

class ApplicationData{
    
    static var shared = ApplicationData()
    
    //AADのToken
    var accessToken = String()
    var idToken = String()
    //AAD上のMailId、兼、AWS上のMailId
    var mailId = String()
    
    //自分のチーム情報
    var team:Team?
    
    func loadMyRanking(id:String){
        let data = ["aadid":id]
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(data)
        
        AWSAPI.upload(message: encoded, url: "https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/select_personal_ranking_api", token: ApplicationData.shared.idToken) { [weak self] result in
            switch result {
            case .success(let result):
                
                do{
                    let decoder = JSONDecoder()
                    let str = try JSONSerialization.jsonObject(with: result, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : Any]
//                    StartView.team = try decoder.decode(Team.self, from: result)
                    print("myInfo",str)
                }catch{
                    print("myInfo",error)
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    func authorizeAWS(id:String){
        let data = ["aadid":id]
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(data)
        
        AWSAPI.upload(message: encoded, url: "https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/select_team_api", token: ApplicationData.shared.idToken) { [weak self] result in
            switch result {
            case .success(let result):
                
                do{
                    let decoder = JSONDecoder()
//                    let str = try JSONSerialization.jsonObject(with: result, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : Any]
                    StartView.team = try decoder.decode(Team.self, from: result)
                    print("teamInfo",StartView.team)
                }catch{
                    print("teamInfo",error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
}
