//
//  ApplicationData.swift
//  walking
//
//  Created by koyasu on 2022/02/02.
//

import Foundation

class ApplicationData{
    
    static var shared = ApplicationData()
    
    var stepStructs: [StepStruct]?
    var distanceStructs: [DistanceStruct]?
    var calorieStructs: [CalorieStruct]?
    
    var homeRecord:HomeRecord?{
        didSet{
//            self.indicatorView.isHidden = true
//            HomeView().reloadStepLabel()
        }
    }
    
    var walkingResult:WalkingResult?{
        didSet{
//            reloadHomeData()
        }
    }
    
    var personRecord:PersonRecord?
    var teamRecord:TeamRecord?
    var eventRecord:EventRecord?
    
    //AADのToken
    var accessToken = String()
    var idToken = String()
    //AAD上のMailId、兼、AWS上のMailId
    var mailId = String()
    
    //自分のチーム情報
    var team:Team?
    
    func loadMyRanking(id:String, completion: @escaping (Bool)->Void){
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
                    completion(true)
                    return
                }catch{
                    print("myInfo",error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func authorizeAWS(id:String, completion: @escaping (Bool)->Void){
        let data = ["aadid":id]
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(data)
        
        AWSAPI.upload(message: encoded, url: "https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/select_team_api", token: ApplicationData.shared.idToken) { result in
            switch result {
            case .success(let result):
                
                do{
                    let decoder = JSONDecoder()
//                    let str = try JSONSerialization.jsonObject(with: result, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : Any]
                    ApplicationData.shared.team = try decoder.decode(Team.self, from: result)
                    print("teamInfo",ApplicationData.shared.team ?? "" )
                    completion(true)
                    return
                }catch{
                    print("teamInfo",error)
                }
            case .failure(let error):
                print(error)
            }
            completion(false)
            return
        }
    }
    
    func loadPersonalRanking(closure: @escaping ()->Void){
        AWSAPI.download(url:"https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/select_personal_ranking_api",token: ApplicationData.shared.idToken) { [weak self] result in
            switch result {
            case .success(let result):
                
                do{
                    let decoder = JSONDecoder()
                    self?.personRecord = try decoder.decode(PersonRecord.self, from: result)
                    closure()
                }catch{
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func loadTeamRanking(closure: @escaping ()->Void){
        AWSAPI.download(url:"https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/select_team_ranking_api",token: ApplicationData.shared.idToken) { [weak self] result in
            switch result {
            case .success(let result):
                
                do{
                    let decoder = JSONDecoder()
                    self!.teamRecord = try decoder.decode(TeamRecord.self, from: result)
                    closure()
                }catch{
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func loadEventRanking(closure: @escaping ()->Void){
        AWSAPI.download(url:"https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/select_event_api",token: ApplicationData.shared.idToken) { [weak self] result in
            switch result {
            case .success(let result):
                
                do{
                    let decoder = JSONDecoder()
                    self!.eventRecord = try decoder.decode(EventRecord.self, from: result)
                    closure()
                }catch{
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
