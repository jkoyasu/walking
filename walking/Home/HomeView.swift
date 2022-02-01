//
//  Home.swift
//  walking
//
//  Created by koyasu on 2021/12/28.
//

import UIKit
import HealthKit
import HealthKitUI

class HomeView: UIViewController {
    
    var homeRecord:HomeRecord?{
        didSet{
            reloadHomeData()
        }
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var baseStackView: UIStackView!
//    日付、歩数の表示
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
//    個人データの表示
    @IBOutlet weak var personalRankLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
//    チームのデータ表示
    @IBOutlet weak var teamRankLabel: UILabel!
    @IBOutlet weak var teamStepLabel: UILabel!
//    イベント名の表示
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventTermLabel: UILabel!
    
    @IBOutlet weak var infoButton: UIButton!
    
    
    var stepStructs: [StepStruct] = []
    var distanceStructs: [DistanceStruct] = []
    var calorieStructs: [CalorieStruct] = []
    //var homeData:HomeData!
    var startView = StartView()
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = baseStackView.frame.size
        scrollView.flashScrollIndicators()
    }
    
    @IBAction func reloadButton(_ sender: Any) {

        pushData()
//        reloadHomeData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
 //       pushData()
        reloadHomeData()

    }
    
    override func viewDidAppear(_ animated: Bool) {
//        stepLabel.text = "\(stepStructs[stepStructs.count-1].steps)歩"
    }
    
    //iPhoneデータを送る
    func pushData(){
        
        //構造体の初期化
        stepStructs.removeAll()
        distanceStructs.removeAll()
    
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
        
        for i in 0...7{
            let walkingDataList = WalkingDataList(
                aadid:"3312756@mchcgr.jp",
                date:self.stepStructs[i].datetime,
                steps: stepStructs[i].steps,
                distance: distanceStructs[i].distance,
                calorie: 0
            )
            walkingDataLists.append(walkingDataList)
        }
            
        let walkingData = WalkingData(
            walkingDataLists:walkingDataLists
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
        
        //画面更新
        //stepLabel.text = String(stepStructs[stepStructs.count-1].steps)
        stepLabel.text = "12345"
        stepLabel.addUinit(unit: "歩", size: stepLabel.font.pointSize / 2)
        distanceLabel.text = "7.89"
        //calorieLabel.text = String(calorieStructs[calorieStructs.count-1].calories)
        distanceLabel.addUinit(unit: "km", size: distanceLabel.font.pointSize / 2)
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
                        let udid = UIDevice.current.identifierForVendor?.uuidString
                        let stepValue = quantity.doubleValue(for: HKUnit.count())
                        let stepCount = Int(stepValue)
//                        let distanceValue = HKUnit.meter()
//                        let distanceValue = quantity.doubleValue(for: HKUnit.meter())
//                        let distanceCount = Int(distanceValue)
//                        let distanceCount = distanceValue.count
                        
                        /// 構造体にデータを格納する
                        let stepImput = StepStruct(
//                            id: udid!,
                            datetime: Self.formatter.string(from: date),
                            steps: stepCount
                        )
                    /// 取得した歩数を配列に格納する。
                    self.stepStructs.append(stepImput)
                        
                    ///データを表示
//                    print("\([self.stepStructs.count-1]):\(self.stepStructs[self.stepStructs.count-1].id)")
                    print("StepData")
                    print("\([self.stepStructs.count-1]):\(self.stepStructs[self.stepStructs.count-1].datetime)")
                    print("\([self.stepStructs.count-1]):\(self.stepStructs [self.stepStructs.count-1].steps)")
                    
                } else {
                    // No Data
                    /// 構造体にデータを格納する
                    let date = statistics.startDate
                    let stepImput = StepStruct(
//                                id: udid!
                        datetime: Self.formatter.string(from: date),
                        steps: 0
                        )
                    self.stepStructs.append(stepImput)
                        print("No StepData")
                        print("\([self.stepStructs.count-1]):\(self.stepStructs[self.stepStructs.count-1].datetime)")
                        print("\([self.stepStructs.count-1]):\(self.stepStructs [self.stepStructs.count-1].steps)")
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
                            let udid = UIDevice.current.identifierForVendor?.uuidString
//                            let stepValue = quantity.doubleValue(for: HKUnit.count())
//                            let stepCount = Int(stepValue)
//                            let distanceValue = HKUnit.meter()
                            let distanceValue = quantity.doubleValue(for: HKUnit.meter())
                            let distanceCount = Int(distanceValue)
    //                        let distanceCount = distanceValue.count
                            
                            /// 構造体にデータを格納する
                            let DistanceImput = DistanceStruct(
//                                id: udid!,
                                datetime: Self.formatter.string(from: date),
                                distance: distanceCount
                            )
                        /// 取得した歩数を配列に格納する。
                        self.distanceStructs.append(DistanceImput)
                            
                        ///データを表示
//                        print("\([self.distanceStructs.count-1]):\(self.distanceStructs[self.distanceStructs.count-1].id)")
                        print("No Distance Data")
                        print("\([self.distanceStructs.count-1]):\(self.distanceStructs[self.distanceStructs.count-1].datetime)")
                        print("\([self.distanceStructs.count-1]):\(self.distanceStructs[self.distanceStructs.count-1].distance)")
                        
                    } else {
                        // No Data

                        /// 構造体にデータを格納する
                        let date = statistics.startDate
                        let DistanceImput = DistanceStruct(
//                                id: udid!
                            datetime: Self.formatter.string(from: date),
                            distance: 0
                        )
                    /// 取得した歩数を配列に格納する。
                    self.distanceStructs.append(DistanceImput)
                    }
                        ///データを表示
//                        print("\([self.distanceStructs.count-1]):\(self.distanceStructs[self.distanceStructs.count-1].id)")
                        print("No Distance Data")
                        print("\([self.distanceStructs.count-1]):\(self.distanceStructs[self.distanceStructs.count-1].datetime)")
                        print("\([self.distanceStructs.count-1]):\(self.distanceStructs[self.distanceStructs.count-1].distance)")
                }
            }
            print("execute")
            HKHealthStore().execute(query)
        }
    
    
    //データを送信する
    private func upsertSteps(data:Data){
        print("upsertSteps")
        AWSAPI.upload(message:data, url:"https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/upsert_steps_api",token: idToken) { [weak self] result in
            switch result{
            case .success(let result):
                
                do{
                    print("upsert data")
                    print(result)
                }catch{
                    print(error)
                }
                
            case .failure(let error):
                print(error)
                print("upload error")
            }
        }
    }
    
    //Home画面からデータを取得する
    private func reloadHomeData(){
        print("reloadHomeData")
        AWSAPI.download(url:"https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/select_home_data_api",token: idToken) { [weak self] result in
            switch result{
            case .success(let result):
                
                do{
                    let decoder = JSONDecoder()
                    self!.homeRecord = try decoder.decode(HomeRecord.self, from: result as! Data)
                    print(self?.homeRecord)
                    print("get")
                    
                    //日付を送信する
                    
                    
                    
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
        //カロリー情報を取得する関数
    private func getCalorie() {
        print("getCalorie")
        
        /// 取得したいサンプルデータの期間の開始日を指定する。（今回は７日前の日付を取得する。）
        let sevenDaysAgo = Calendar.current.date(byAdding: DateComponents(day: -7), to: Date())!
        let startDate = Calendar.current.startOfDay(for: sevenDaysAgo)

        /// サンプルデータの検索条件を指定する。（フィルタリング）
        let predicate = HKQuery.predicateForSamples(withStart: startDate,
                                                    end: Date(),
                                                    options: [])

        /// サンプルデータを取得するためのクエリを生成する。
        let query = HKStatisticsCollectionQuery(quantityType: HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
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
            
            /// クエリ結果から期間（開始日・終了日）を指定して消費カロリーの統計情報を取り出す。
                statsCollection.enumerateStatistics(from: startDate, to: Date()) { [self] statistics, _ in
                    
                    /// `statistics` に最小単位（今回は１日分の消費カロリー）のサンプルデータが返ってくる。
                    /// `statistics.sumQuantity()` でサンプルデータの合計（１日の消費カロリー）を取得する。
                    if let quantity = statistics.sumQuantity() {
                        
                        /// サンプルデータは`quantity.doubleValue`で取り出し、単位を指定して取得する。
                        let date = statistics.startDate
                        let udid = UIDevice.current.identifierForVendor?.uuidString
                        let calorieValue = quantity.doubleValue(for: HKUnit.kilocalorie())
                        let calorieCount = Int(calorieValue)
                        /// 構造体にデータを格納する
                        let calorieImput = CalorieStruct(
                            id: udid!,
                            //datetime: Self.formatter.string(from: date),
                            datetime: date,
                            calories: calorieCount
                        )
                    /// 取得した消費カロリーを配列に格納する。
                    self.calorieStructs.append(calorieImput)
                        
                    ///データを表示
                    print("\([self.calorieStructs.count-1]):\(self.calorieStructs[self.calorieStructs.count-1].id)")
                    print("\([self.calorieStructs.count-1]):\(self.calorieStructs[self.calorieStructs.count-1].datetime)")
                    print("\([self.calorieStructs.count-1]):\(self.calorieStructs [self.calorieStructs.count-1].calories)")
                    
                } else {
                    // No Data
                    print("Asseterror2")
                   // sampleArray.append(0.0)
                }
            }
        }
        print("execute")
        HKHealthStore().execute(query)
    }
}

extension UILabel {
    func addUinit(unit: String, size: CGFloat) {
        guard let label = self.text else {
            return
        }
        // 単位との間隔
        let mainString = NSMutableAttributedString(string: label)
        let unitString = NSMutableAttributedString(
            string: unit,
            attributes: [.font: UIFont.systemFont(ofSize: size)])
        let attributedString = NSMutableAttributedString()
        attributedString.append(mainString)
        attributedString.append(unitString)
        
        self.attributedText = attributedString
    }
}

//記録日時のフォーマッター
extension HomeView {
    private static var formatter: DateFormatter{
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
