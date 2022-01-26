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


    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    
    var stepStructs: [StepStruct] = []
    var calorieStructs: [CalorieStruct] = []
    
    @IBAction func reloadButton(_ sender: Any) {

        reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        stepLabel.text = "\(stepStructs[stepStructs.count-1].steps)歩"
    }
    
    //データを取得する関数
    func reloadData(){
    
        //      iPhoneから歩数情報を取得する
                let readDataTypes = Set([HKObjectType.quantityType(forIdentifier: .stepCount)!])
                HKHealthStore().requestAuthorization(toShare: nil, read: readDataTypes) { success, _ in
                    if success {
                        self.getSteps()
                    }
                }
               
        //      iPhoneからカロリー情報を取得する
                let readDataTypes2 = Set([HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!])
                HKHealthStore().requestAuthorization(toShare: nil, read: readDataTypes2) { success, _ in
                    if success {
                        self.getCalorie()
                    }
                }
                
        //      取得したデータをjson化
        
        //データ取得
        
        //画面更新
        print("tapped")
        //stepLabel.text = String(stepStructs[stepStructs.count-1].steps)
        stepLabel.text = "12345"
        stepLabel.addUinit(unit: "歩", size: stepLabel.font.pointSize / 2)
        calorieLabel.text = "789"
        //calorieLabel.text = String(calorieStructs[calorieStructs.count-1].calories)
        calorieLabel.addUinit(unit: "kcal", size: calorieLabel.font.pointSize / 2)
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
                        /// 構造体にデータを格納する
                        let stepImput = StepStruct(
                            id: udid!,
                            //datetime: date,
                            datetime: Self.formatter.string(from: date),
                            steps: stepCount
                        )
                    /// 取得した歩数を配列に格納する。
                    self.stepStructs.append(stepImput)
                        
                    ///データを表示
                    print("\([self.stepStructs.count-1]):\(self.stepStructs[self.stepStructs.count-1].id)")
                    print("\([self.stepStructs.count-1]):\(self.stepStructs[self.stepStructs.count-1].datetime)")
                    print("\([self.stepStructs.count-1]):\(self.stepStructs [self.stepStructs.count-1].steps)")
                    
                } else {
                    // No Data
                    print("Asseterror")
                   // sampleArray.append(0.0)
                }
            }
        }
        print("execute")
        HKHealthStore().execute(query)
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
