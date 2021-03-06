//
//  AppliCationDataExtention.swift
//  walking
//
//  Created by koyasu on 2022/02/02.

import Foundation
import HealthKit
import UIKit
import WebKit
import MSAL

enum UpsertError:Error{
    case UpsertInvalidRequest
    case UpsertUnauthorized
    case UpsertNoBodyContent
    //case invalidBodyContent(reason: String)
}
enum ReloadHomeError:Error{
    case ReloadHomeInvalidRequest
    case ReloadHomeUnauthorized
    case ReloadHomeNoBodyContent
    //case invalidBodyContent(reason: String)
}
    
extension ApplicationData{
    
    
    //iPhoneからAWSに歩数・距離データを送信する関数
    func pushData(closure: @escaping (Bool)->Void){
        
        //構造体の初期化
        self.stepStructs = []
        self.distanceStructs = []
        //iPhoneから歩数情報を取得する
        let readDataTypes = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: .stepCount)!, HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!)
        HKHealthStore().requestAuthorization(toShare: nil, read: readDataTypes) { success, _ in
            if success {
                self.getSteps(){result in
                    self.getDistance(){result in
                        self.mergeData(){result in
                            self.upsertSteps(data:self.pushedData!){result in
                                switch result{
                                case .success:
                                    closure(true)
                                case .failure(let error):
                                    switch error{
                                    case .UpsertUnauthorized:
                                        print("認証に失敗しました")
                                        ApplicationData.shared.acquireTokenSilently(ApplicationData.shared.currentAccount){ success in
                                            self.pushData(){result in
                                                closure(true)
                                            }
                                        }
                                    default:
                                        print("データ送信に失敗しました")
                                        closure(false)
                                    }
                                }
                                
//                                if result == true{
//                                    closure(true)
//                                }else{
//                                    print("データ送信に失敗しました")
//                                    closure(false)
////                                    //認証に失敗した場合は、再認証を行う。
////                                    if ApplicationData.shared.httpErrorCode == 401{
////                                        print("認証に失敗しました")
////                                        ApplicationData.shared.acquireTokenSilently(ApplicationData.shared.currentAccount){ success in
////                                            self.pushData(){result in
////                                                closure(true)
////                                            }
////                                        }
////                                    //それ以外のエラーは、送信失敗を返す。
////                                    }else{
////                                        print("データ送信に失敗しました")
////                                        closure(false)
////                                    }
//                                }
                            }
                        }
                    }
                }
            }else{
                print("ヘルスケアの認証に失敗しました。")
                closure(false)
                return
            }
        }
    }
//      iPhoneからカロリー情報を取得する
//                let readDataTypes2 = Set([HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!])
//                HKHealthStore().requestAuthorization(toShare: nil, read: readDataTypes2) { success, _ in
//                    if success {
//                        self.getCalorie()
//                    }
//                }

//  歩数情報を取得するサブプログラム
    private func getSteps(completion: @escaping (Bool)->Void) {
        print("getSteps")
        /// 取得したいサンプルデータの期間の開始日を指定する。（今回は７日前の日付を取得する。）
        let sevenDaysAgo = Calendar.current.date(byAdding: DateComponents(day: -7), to: Date())!
        let startDate = Calendar.current.startOfDay(for: sevenDaysAgo)
        /// サンプルデータの検索条件を指定する。（フィルタリング）
        let predicate = HKQuery.predicateForSamples(withStart: startDate,
                                                    end: Date(),
                                                    options: [])
        /// サンプルデータを取得するためのクエリを生成する。
        let query = HKStatisticsCollectionQuery(quantityType: HKObjectType.quantityType(forIdentifier: .stepCount)!,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: startDate,
                                                intervalComponents: DateComponents(day: 1))
        //クエリ結果を配列に格納 する
        query.initialResultsHandler = { _, results, _ in
            //results (HKStatisticsCollection?)` からクエリ結果を取り出す。
            guard let statsCollection = results else {
                print("queryError")
                return
            }
            /// クエリ結果から期間（開始日・終了日）を指定して歩数の統計情報を取り出す。
            statsCollection.enumerateStatistics(from: startDate, to: Date()) { [self] statistics, _ in
            /// `statistics` に最小単位（今回は１日分の歩数）のサンプルデータが返ってくる。
            /// `statistics.sumQuantity()` でサンプルデータの合計（１日の合計歩数）を取得する。
                if let quantity = statistics.sumQuantity() {
                    /// サンプルデータは`quantity.doubleValue`で取り出し、単位を指定して取得する。
                    let date = statistics.startDate
                    let stepValue = quantity.doubleValue(for: HKUnit.count())
                    let stepCount = Int(stepValue)
                    // 構造体にデータを格納する
                    let stepImput = StepStruct(
                        datetime: Self.formatter.string(from: date),
                        steps: stepCount
                    )
                    /// 取得した歩数を配列に格納する。
                    self.stepStructs!.append(stepImput)
                } else {
                    //当該日時にデータがない場合、構造体に0歩としてデータを格納する
                    let date = statistics.startDate
                    let stepImput = StepStruct(
                        datetime: Self.formatter.string(from: date),
                        steps: 0
                        )
                    self.stepStructs!.append(stepImput)
                }
                    //ログ出力
                print("歩数データ\([self.stepStructs!.count-1]):\(self.stepStructs![self.stepStructs!.count-1].datetime):\(self.stepStructs![self.stepStructs!.count-1].steps)歩")
            }
            completion(true)
        }
        HKHealthStore().execute(query)
    }
    
    //  iPhoneから距離情報を習得するサブプログラム
    private func getDistance(completion: @escaping (Bool)->Void) {
        /// 取得したいサンプルデータの期間の開始日を指定する。（今回は７日前の日付を取得する。）
        let sevenDaysAgo = Calendar.current.date(byAdding: DateComponents(day: -7), to: Date())!
        let startDate = Calendar.current.startOfDay(for: sevenDaysAgo)
        /// サンプルデータの検索条件を指定する。（フィルタリング）
        let predicate = HKQuery.predicateForSamples(withStart: startDate,
                                                    end: Date(),
                                                    options: [])
        /// サンプルデータを取得するためのクエリを生成する。
        let query = HKStatisticsCollectionQuery(quantityType: HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: startDate,
                                                intervalComponents: DateComponents(day: 1))
        /// クエリ結果を配列に格納 する
            query.initialResultsHandler = { _, results, _ in
                /// `results (HKStatisticsCollection?)` からクエリ結果を取り出す。
                guard let statsCollection = results else {
                    print("queryError")
                    completion(false)
                    return
                }
            /// クエリ結果から期間（開始日・終了日）を指定して歩数の統計情報を取り出す。
                statsCollection.enumerateStatistics(from: startDate, to: Date()) { [self] statistics, _ in
                    /// `statistics` に最小単位（今回は１日分の歩数）のサンプルデータが返ってくる。
                    /// `statistics.sumQuantity()` でサンプルデータの合計（１日の合計歩数）を取得する。
                if let quantity = statistics.sumQuantity() {
                    /// サンプルデータは`quantity.doubleValue`で取り出し、単位を指定して取得する。
                    let date = statistics.startDate
                    let distanceValue = quantity.doubleValue(for: HKUnit.meter())
                    let distanceCount = Int(distanceValue)
                    /// 構造体にデータ距離情報を取得
                    let DistanceImput = DistanceStruct(
                        datetime: Self.formatter.string(from: date),
                        distance: distanceCount
                    )
                /// 取得した歩数を配列に格納する。
                    self.distanceStructs!.append(DistanceImput)
                } else {
                    // 記録なしの場合、構造体に0mとしてデータを格納
                    let date = statistics.startDate
                    let DistanceImput = DistanceStruct(
                        datetime: Self.formatter.string(from: date),
                        distance: 0
                    )
                    // 取得した歩数を配列に格納する。
                    self.distanceStructs!.append(DistanceImput)
                }
                //ログ出力
                print("距離データ\([self.distanceStructs!.count-1]):\(self.distanceStructs![self.distanceStructs!.count-1].datetime):\(self.distanceStructs![self.distanceStructs!.count-1].distance)m")
            }
            completion(true)
        }//query
        print("execute")
        HKHealthStore().execute(query)
    }
    
    //歩数と距離のデータをマージしてJSON化するサブプログラム
    private func mergeData(completion: @escaping (Bool)->Void){
        //iPhoneから取得したデータをオブジェクト化
        var walkingDataLists:[WalkingDataList]=[]
        if stepStructs!.count >= 1{
            for i in 0...7{
                let walkingDataList = WalkingDataList(
                    aadid:ApplicationData.shared.mailId,
                    date:self.stepStructs?[i].datetime,
                    steps: (stepStructs?[i].steps)!,
                    distance: (distanceStructs?[i].distance)!,
                    calorie: 0
                )
                walkingDataLists.append(walkingDataList)
            }
            let walkingData = WalkingData(
                walkingDataList:walkingDataLists
            )
            //JSONEncoderの生成
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            do{
                //構造体→JSONへのエンコード
                self.pushedData = try encoder.encode(walkingData)
                print("JSON DATA")
                print(String(data: self.pushedData!, encoding: .utf8)!)
                completion(true)
            }catch{
                print("データのJSON化に失敗しました。")
                print(false)
            }
        }else{
            print("iPhoneからのデータ取得に失敗しました。")
            return
        }
    }
    //歩数データをサーバに送信するサブプログラム
//    private func upsertSteps(data:Data,completion: @escaping (Bool)->Void){
    private func upsertSteps(data:Data,completion: @escaping (Result<String, UpsertError>)->Void){
        print("upsertSteps")
    
        AWSAPI.upload(message:data, url:"https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/upsert_steps_api",token: ApplicationData.shared.idToken) { [weak self] result in
        //Pushデータであえてエラーを起こす
//        AWSAPI.upload(message:data, url:"https://error.xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/upsert_steps_api",token: ApplicationData.shared.idToken) { [weak self] result in
            switch result{
            case .success(let result):
                do{
                    print(String(data: result, encoding: .utf8)!)
                    let decoder = JSONDecoder()
                    self!.walkingResult = try decoder.decode(WalkingResult.self, from: result)
                    print("upsertSteps:歩数データを送信しました。")
                    print(self!.walkingResult)
                    let string = "success"
                    completion(.success(string))
                }catch{
                    print("upsertSteps:歩数データの送信に失敗しました。")
//                    self!.errorCode = error
                    completion(.failure(.UpsertInvalidRequest))
                }
            case .failure(let error):
                switch error{
                case .AWSUnauthorized:
                        print("upsertSteps:サーバとの認証に失敗しました。")
//                        self!.errorCode = error
                        completion(.failure(.UpsertUnauthorized))
                        return
                default:
                    print("upsertSteps:サーバとの接続に失敗しました。")
                        print(error)
//                        self!.errorCode = error
                        completion(.failure(.UpsertInvalidRequest))
                        return
                }
            }
        }
    }
    
    //Home画面に配置するデータを取得
//    func reloadHomeData(completion: @escaping (Bool)-> Void){
    func reloadHomeData(completion: @escaping (Result<String, ReloadHomeError>)-> Void){
        print("reloadHomeData:開始します。")
//        self.errorCode = nil
        //サーバに個人を特定するデータを送信する
        let homeData = HomeData(
            aadid: ApplicationData.shared.mailId,
            teamid:ApplicationData.shared.team!.content.teamId
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encodedData = try? encoder.encode(homeData)
        print("SEND DATA")
        print(String(data: encodedData!, encoding: .utf8)!)
        //AWSAPIにてデータを送信し、結果をうけとる
        AWSAPI.upload(message: encodedData!, url:"https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/select_home_data_api",token: ApplicationData.shared.idToken) { [weak self] result in
        //reloadHomeDataで故意にエラーを発生させる（デバッグ用）
//        AWSAPI.upload(message: encodedData!, url:"https://error.xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/select_home_data_api",token: ApplicationData.shared.idToken) { [weak self] result in
//            let result = result
            switch result{
            case .success(let result):
                do{
                    let decoder = JSONDecoder()
                    self?.homeRecord = try decoder.decode(HomeRecord.self, from: result)
                    print("ホーム画面データ")
                    print(self?.homeRecord!)
                    let success = "success!"
                    completion(.success(success))
                }catch{
                    print(error)
                    print("reloadHomeData:受信データを展開できませんでした")
//                    self!.errorCode = error
                    completion(.failure(.ReloadHomeInvalidRequest))
                }
            case .failure(let error):
                print("error:\(error)")
                print("reloadHomeData:サーバとの通信に失敗しました。")
//                self!.errorCode = error
//                print(self!.errorCode)
                completion(.failure(.ReloadHomeInvalidRequest))
            }
        }
    }
    
    //AAD上の自分の情報取得
    func getmyInfo(completion:@escaping(Bool)->Void){
        let url = URL(string: "https://graph.microsoft.com/v1.0/me/")
        var request = URLRequest(url: url!)
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        print("----",ApplicationData.shared.accessToken)
        request.setValue("Bearer \(ApplicationData.shared.accessToken)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.updateLogging(text: "Couldn't get graph result: \(error)")
                return
            }
            guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any] else {
                self.updateLogging(text:"Couldn't deserialize result JSON")
                return
            }
            self.updateLogging(text: "Result from Graph: \(result))")
            let MailId = result["userPrincipalName"] as! String
            ApplicationData.shared.mailId = MailId
            let DisplayName = result["displayName"] as! String
            ApplicationData.shared.displayName = DisplayName.uppercased()
            ApplicationData.shared.authorizeAWS(id:ApplicationData.shared.mailId) { team in
                ApplicationData.shared.loadMyRanking(id: ApplicationData.shared.mailId) { result in
                    completion(result)
                    return
                }
            }
        }.resume()
    }
    
    //以下msalログイン処理部分
    typealias AccountCompletion = (MSALAccount?) -> Void
    
    //APIを取得
    func callGraphAPI() {
        self.loadCurrentAccount { (account) in
            guard let currentAccount = account else {
                // We check to see if we have a current logged in account.
                // If we don't, then we need to sign someone in.
                self.acquireTokenInteractively(){ success in
                    self.finishCallGraphAPI(result:success)
                }
                return
            }
            self.acquireTokenSilently(currentAccount){ success in
                self.finishCallGraphAPI(result: success)
            }
        }
    }
    
    func finishCallGraphAPI(result: Bool) {
        //tabのHomeViewにteamが必要ですから、ここに判断を追加
        if (result) {
            DispatchQueue.main.async {
                self.currentViewController!.performSegue(withIdentifier: "toTab", sender: nil)
            }
        }
    }
    
    func loadCurrentAccount(completion: AccountCompletion? = nil) {
        guard let applicationContext = self.applicationContext else { return }
        let msalParameters = MSALParameters()
        msalParameters.completionBlockQueue = DispatchQueue.main
        // Note that this sample showcases an app that signs in a single account at a time
        // If you're building a more complex app that signs in multiple accounts at the same time, you'll need to use a different account retrieval API that specifies account identifier
        // For example, see "accountsFromDeviceForParameters:completionBlock:" - https://azuread.github.io/microsoft-authentication-library-for-objc/Classes/MSALPublicClientApplication.html#/c:objc(cs)MSALPublicClientApplication(im)accountsFromDeviceForParameters:completionBlock:
        applicationContext.getCurrentAccount(with: msalParameters, completionBlock: { (currentAccount, previousAccount, error) in
            
            if let error = error {
                self.updateLogging(text: "Couldn't query current account with error: \(error)")
                return
            }
            if let currentAccount = currentAccount {
                self.updateLogging(text: "Found a signed in account \(String(describing: currentAccount.username)). Updating data for that account...")
                self.updateCurrentAccount(account: currentAccount)
                if let completion = completion {
                    completion(self.currentAccount)
                }
                return
            }
            self.updateLogging(text: "Account signed out. Updating UX")
            ApplicationData.shared.accessToken = ""
            self.updateCurrentAccount(account: nil)
            if let completion = completion {
                completion(nil)
            }
        })
    }
    
    
    //ログイントークンを対話的に取得
    func acquireTokenInteractively(completion: @escaping (Bool)->Void) {
        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParamaters else { return }
        let parameters = MSALInteractiveTokenParameters(scopes: kScopes, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount
        var requestError: NSError? = nil
        let request = MSALClaimsRequest(jsonString: "{\"id_token\":{\"auth_time\":{\"essential\":true},\"acr\":{\"values\":[\"urn:mace:incommon:iap:silver\"]}}}",error: &requestError)
        parameters.claimsRequest = request
        applicationContext.acquireToken(with: parameters) { (result, error) in
            if let error = error {
                self.updateLogging(text: "Could not acquire token: \(error)")
                return
            }
            guard let result = result else {
                self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }
            ApplicationData.shared.accessToken = result.accessToken
            ApplicationData.shared.idToken = result.idToken!
            self.updateLogging(text: "Access token is \(ApplicationData.shared.accessToken)")
            self.updateCurrentAccount(account: result.account)
            self.getmyInfo(){ result in
                completion(result)
                return
            }
        }
    }
    
    //ログイントークンを暗黙的に取得
    func acquireTokenSilently(_ account : MSALAccount!, completion : @escaping (Bool)->Void) {
        guard let applicationContext = self.applicationContext else {
            completion(false)
            return
        }
        /**
         
         Acquire a token for an existing account silently
         
         - forScopes:           Permissions you want included in the access token received
         in the result in the completionBlock. Not all scopes are
         guaranteed to be included in the access token returned.
         - account:             An account object that we retrieved from the application object before that the
         authentication flow will be locked down to.
         - completionBlock:     The completion block that will be called when the authentication
         flow completes, or encounters an error.
         */
        let parameters = MSALSilentTokenParameters(scopes: kScopes, account: account)
        var requestError: NSError? = nil
        let request = MSALClaimsRequest(jsonString: "{\"id_token\":{\"auth_time\":{\"essential\":true},\"acr\":{\"values\":[\"urn:mace:incommon:iap:silver\"]}}}",error: &requestError)
        
        parameters.claimsRequest = request
        applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
            
            if let error = error {
                let nsError = error as NSError
                // interactionRequired means we need to ask the user to sign-in. This usually happens
                // when the user's Refresh Token is expired or if the user has changed their password
                // among other possible reasons.
                if (nsError.domain == MSALErrorDomain) {
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        DispatchQueue.main.async {
                            self.acquireTokenInteractively(){ result in
                                completion(result)
                            }
                        }
                        return
                    }
                }
                
                self.updateLogging(text: "Could not acquire token silently: \(error)")
                completion(false)
                return
            }
            guard let result = result else {
                self.updateLogging(text: "Could not acquire token: No result returned")
                completion(false)
                return
            }
            ApplicationData.shared.idToken = result.idToken!
            ApplicationData.shared.accessToken = result.accessToken
            self.updateLogging(text: "Refreshed Id token is \(ApplicationData.shared.accessToken)")
            self.getmyInfo(){ result in
                completion(true)
//                completion(false)
                return
            }
        }
    }
    
    func initMSAL() throws {
        guard let authorityURL = URL(string: kAuthority) else {
            self.updateLogging(text: "Unable to create authority URL")
            return
        }
        let authority = try MSALAADAuthority(url: authorityURL)
        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: kClientID,
                                                                  redirectUri: kRedirectUri,
                                                                  authority: authority)
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
        self.initWebViewParams()
    }
    
    func initWebViewParams() {
        self.webViewParamaters = MSALWebviewParameters(authPresentationViewController: self.currentViewController!)
    }
    
    func updateCurrentAccount(account: MSALAccount?) {
        self.currentAccount = account
    }
    
    func updateLogging(text : String) {
        print(text)
        if Thread.isMainThread {
            self.loggingText = text
        } else {
            DispatchQueue.main.async {
                self.loggingText = text
            }
        }
        
    }
}
    
    

//記録日時のフォーマッター
extension ApplicationData {
    private static var formatter: DateFormatter{
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}

