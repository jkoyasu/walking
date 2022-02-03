//
//  AppliCationDataExtention.swift
//  walking
//
//  Created by koyasu on 2022/02/02.

import Foundation
import HealthKit

extension ApplicationData{
    

    //iPhoneからデータを送る
    func pushData(){
        
//
        //構造体の初期化
        self.stepStructs = []
        self.distanceStructs = []
    
        //      iPhoneから歩数情報を取得する
            let readDataTypes = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: .stepCount)!, HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!)
//            let readDataTypes = Set(arrayLiteral: [HKObjectType.quantityType(forIdentifier: .stepCount)!],
//                                                      [HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!])
                HKHealthStore().requestAuthorization(toShare: nil, read: readDataTypes) { success, _ in
                    if success {
                        self.getSteps()
                        self.getDistance()
                    }
                }
               
        //      iPhoneからカロリー情報を取得する
//                let readDataTypes2 = Set([HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!])
//                HKHealthStore().requestAuthorization(toShare: nil, read: readDataTypes2) { success, _ in
//                    if success {
//                        self.getCalorie()
//                    }
//                }
                
        //取得したデータをオブジェクト化
        sleep(1)
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
                let data = try encoder.encode(walkingData)
                print("JSON DATA")
                print(String(data: data, encoding: .utf8)!)
                //データを送信する
                upsertSteps(data: data)
            }catch{
                print(error)
            }
        }else{
            print("歩数・距離の取得に失敗しました。")
        }
        
    }
    
//  歩数情報を習得する関数
    private func getSteps() {
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
        
        /// クエリ結果を配列に格納 する
        query.initialResultsHandler = { _, results, _ in
            
            /// `results (HKStatisticsCollection?)` からクエリ結果を取り出す。
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

                        
                        /// 構造体にデータを格納する
                        let stepImput = StepStruct(
                            datetime: Self.formatter.string(from: date),
                            steps: stepCount
                        )
                    /// 取得した歩数を配列に格納する。
                    self.stepStructs!.append(stepImput)
                        
                    ///データを表示
                    print("StepData")
                        print("\([self.stepStructs!.count-1]):\(self.stepStructs![self.stepStructs!.count-1].datetime)")
                        print("\([self.stepStructs!.count-1]):\(self.stepStructs![self.stepStructs!.count-1].steps)")
                    
                } else {
                    // No Data
                    /// 構造体にデータを格納する
                    let date = statistics.startDate
                     let stepImput = StepStruct(
                        datetime: Self.formatter.string(from: date),
                        steps: 0
                        )
                    self.stepStructs!.append(stepImput)
                        print("No StepData")
                    print("\([self.stepStructs!.count-1]):\(self.stepStructs![self.stepStructs!.count-1].datetime)")
                    print("\([self.stepStructs!.count-1]):\(self.stepStructs![self.stepStructs!.count-1].steps)")
                }
            }
        }
        print("execute")
        HKHealthStore().execute(query)
    }
    
    //  距離情報を習得する関数
        private func getDistance() {
            print("getDistance")
            
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
                            
                            /// 構造体にデータを格納する
                            let DistanceImput = DistanceStruct(
                                datetime: Self.formatter.string(from: date),
                                distance: distanceCount
                            )
                        /// 取得した歩数を配列に格納する。
                        self.distanceStructs!.append(DistanceImput)
                            
                        ///データを表示
                        print("No Distance Data")
                        print("\([self.distanceStructs!.count-1]):\(self.distanceStructs![self.distanceStructs!.count-1].datetime)")
                        print("\([self.distanceStructs!.count-1]):\(self.distanceStructs![self.distanceStructs!.count-1].distance)")
                        
                    } else {
                        // No Data

                        /// 構造体にデータを格納する
                        let date = statistics.startDate
                        let DistanceImput = DistanceStruct(
                            datetime: Self.formatter.string(from: date),
                            distance: 0
                        )
                    /// 取得した歩数を配列に格納する。
                    self.distanceStructs!.append(DistanceImput)
                    }
                        ///データを表示
                        print("No Distance Data")
                        print("\([self.distanceStructs!.count-1]):\(self.distanceStructs![self.distanceStructs!.count-1].datetime)")
                        print("\([self.distanceStructs!.count-1]):\(self.distanceStructs![self.distanceStructs!.count-1].distance)")
                }
            }
            print("execute")
            HKHealthStore().execute(query)
        }
    
    
    //データを送信する
    private func upsertSteps(data:Data){
        print("upsertSteps")
        
        
        AWSAPI.upload(message:data, url:"https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/upsert_steps_api",token: ApplicationData.shared.idToken) { [weak self] result in
            switch result{
            case .success(let result):
                
                do{
                    print(String(data: result, encoding: .utf8)!)
                    let decoder = JSONDecoder()
                    self!.walkingResult = try decoder.decode(WalkingResult.self, from: result)
                    print(self!.walkingResult)
                }catch{
                    print(error)
                }
                
            case .failure(let error):
                print(error)
                print("upload error")
            }
        }
    }
    
    //Home画面のデータを取得する
    func reloadHomeData(){
        print("reloadHomeData")
        
        //送信データを取得
        let homeData = HomeData(
            aadid: ApplicationData.shared.mailId,
            teamid: 3
//            teamid:ApplicationData.shared.team!.content.teamId
        )
        

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let encodedData = try? encoder.encode(homeData)
        print("JSON DATA")
        print(String(data: encodedData!, encoding: .utf8)!)
        
        
        AWSAPI.upload(message: encodedData!, url:"https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/select_home_data_api",token: ApplicationData.shared.idToken) { [weak self] result in
            switch result{
            case .success(let result):

                do{
                    let decoder = JSONDecoder()
                    print(String(data: result, encoding: .utf8)!)
                    self?.homeRecord = try decoder.decode(HomeRecord.self, from: result)
                    print(self?.homeRecord)
                    //HomeView().reloadStepLabel()

                }catch{
                    print(error)
                    print("error1")
                }
            case .failure(let error):
                print(error)
                print("error2")
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
