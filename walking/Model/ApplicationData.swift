//
//  ApplicationData.swift
//  walking
//
//  Created by koyasu on 2022/02/02.
//

import Foundation
import MSAL

class ApplicationData{
    
    //全情報取得
    let kClientID = "2ce72229-93e5-4624-99e8-5a490cbe40f9"
    let kGraphEndpoint = "https://graph.microsoft.com/"
    let kAuthority = "https://login.microsoftonline.com/4c321fca-b3bc-4df6-b1da-a7c90c3dc546/oauth2/v2.0/authorize?"
    let kRedirectUri =  "msauth.com.walkingEventApp://auth"

    let kScopes: [String] = ["user.read"]
    var applicationContext : MSALPublicClientApplication?
    var webViewParamaters : MSALWebviewParameters?
    var loggingText: String?
    var currentAccount: MSALAccount?
    
    static var shared = ApplicationData()
    var errorCode: Error?
    var httpErrorCode: Int?
    var stepStructs: [StepStruct]?
    var distanceStructs: [DistanceStruct]?
    var calorieStructs: [CalorieStruct]?
    var pushedData: Data?
    
    var currentViewController: UIViewController?
    
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
    var events:Events?
    var notifications:Notification?
    var members:Member?
    
    //AADのToken
    var accessToken = String()
    var idToken = String()
    //AAD上のMailId、兼、AWS上のMailId
    var mailId = String()
    var displayName = String()
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
    
    func loadEvents(closure: @escaping ()->Void){
        AWSAPI.download(url:"https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/select_event_api",token: ApplicationData.shared.idToken) { [weak self] result in
            switch result {
            case .success(let result):
                
                do{
                    let decoder = JSONDecoder()
                    self!.events = try decoder.decode(Events.self, from: result)
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
        if let id = self.events?.content?.id{
            let data = ["eventid":self.events?.content?.id]
            let encoder = JSONEncoder()
            let encoded = try! encoder.encode(data)
            
            AWSAPI.upload(message: encoded, url: "https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/select_event_ranking_api", token: ApplicationData.shared.idToken) { result in
                switch result {
                case .success(let result):
                    
                    do{
                        let decoder = JSONDecoder()
                        self.eventRecord = try decoder.decode(EventRecord.self, from: result)
                        closure()
                    }catch{
                        print(error)
                    }
                case .failure(let error):
                    print(error)
                }
                closure()
                return
            }
        }
    }
    
    func loadNotification(closure: @escaping ()->Void){
        AWSAPI.download(url:"https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/select_notification_api",token: ApplicationData.shared.idToken) { [weak self] result in
            switch result {
            case .success(let result):
                
                do{
                    let decoder = JSONDecoder()
                    self?.notifications = try decoder.decode(Notification.self, from: result)
                    closure()
                }catch{
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func loadMember(closure: @escaping ()->Void){
        if let id = self.team?.content.teamId{
            let data = ["teamid":self.team?.content.teamId]
            let encoder = JSONEncoder()
            let encoded = try! encoder.encode(data)
            
            AWSAPI.upload(message: encoded, url: "https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/select_team_member_api", token: ApplicationData.shared.idToken) { result in
                switch result {
                case .success(let result):
                    
                    do{
                        let decoder = JSONDecoder()
                        self.members = try decoder.decode(Member.self, from: result)
                        closure()
                    }catch{
                        print(error)
                    }
                case .failure(let error):
                    print(error)
                }
                closure()
                return
            }
        }
    }
}
