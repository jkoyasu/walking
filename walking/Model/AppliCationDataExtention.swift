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

extension ApplicationData{
    
    //iPhoneからAWSに歩数・距離データを送信する関数
    func pushData(closure: @escaping ()->Void){
        
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
                                closure()
                            }
                        }
                    }
                }
            }else{
                print("ヘルスケアの認証に失敗しました。")
                closure()
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
                //データを送信する
                //upsertSteps(data: data)
            }catch{
                print("データのJSON化に失敗しました。")
                print(error)
            }
        }else{
            print("iPhoneからのデータ取得に失敗しました。")
            return
        }
    }
    
    //歩数データをサーバに送信するサブプログラム
    private func upsertSteps(data:Data,completion: @escaping (Bool)->Void){
        print("upsertSteps")
        
        AWSAPI.upload(message:data, url:"https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/upsert_steps_api",token: ApplicationData.shared.idToken) { [weak self] result in
            
            switch result{
            case .success(let result):
                do{
                    print(String(data: result, encoding: .utf8)!)
                    let decoder = JSONDecoder()
                    self!.walkingResult = try decoder.decode(WalkingResult.self, from: result)
                    print("歩数データを送信しました。")
                    print(self!.walkingResult)
                    completion(true)
                    
                }catch{
                    print("歩数データの取得に失敗しました。")
                    print(error)
                    completion(true)
                }
            case .failure(let error):
                
                if ApplicationData.shared.httpErrorCode == 401 {
                    print("サーバとの認証に失敗しました。")

                    completion(false)
                    return
                }
                print("サーバとの通信に失敗しました。")
                print(error)
                completion(false)
                return
            }
        }
    }
    
    //Home画面に配置するデータを取得
    func reloadHomeData(closure: @escaping ()-> Void){
        print("reloadHomeData")
        
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
            
        //故意にエラーを発生させるスクリプト
//        AWSAPI.upload(message: encodedData!, url:"https://error.xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/select_home_data_api",token: ApplicationData.shared.idToken) { [weak self] result in
            
            
            let result = result
            switch result{
            case .success(let result):
                do{
                    let decoder = JSONDecoder()
                    self?.homeRecord = try decoder.decode(HomeRecord.self, from: result)
                    print("ホーム画面データ")
                    print(self?.homeRecord!)
                    closure()
                }catch{
                    print(error)
                    print("受信データを展開できませんでした")
                    closure()
                }
            case .failure(let error):
                
                print("error:\(error)")
                print("サーバとの通信に失敗しました。")
                self!.errorCode = error
                print(self!.errorCode)
                closure()
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

