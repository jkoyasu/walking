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
   
//    var homeRecord:HomeRecord?{
//        didSet{
//            reloadStepLabel()
//            indicatorView.isHidden = true
//        }
//    }
    @IBOutlet weak var indicatorView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var baseStackView: UIStackView!
//    日付、歩数の表示
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    
//    個人データの表示
    @IBOutlet weak var personalRankLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
//    チームのデータ表示
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var teamRankLabel: UILabel!
    @IBOutlet weak var teamStepLabel: UILabel!
//    イベント名の表示
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventTermLabel: UILabel!
    
    @IBOutlet weak var profileButton: UIButton!
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
        //reloadボタンを押すとトークンを故意に削除（デバッグ用）
 //       ApplicationData.shared.idToken = ""
        self.loadHome()
    }
    
    func setup(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        scrollView.refreshControl = refreshControl
    }
    
    @objc func handleRefresh(sender: UIRefreshControl) {
        //reloadボタンを押すとトークンを故意に削除（デバッグ用）
//        ApplicationData.shared.idToken = ""
        // ここが引っ張られるたびに呼び出される
        self.loadHome()
        sender.endRefreshing()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
 //       profileButton.setTitle(String(ApplicationData.shared.displayName.prefix(1)), for: .normal)
        setup()
        indicatorView.isHidden = true
        self.loadHome()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    //Home画面の表示を行うスクリプト
    func loadHome(){
        dateLabel.text = "更新中..."
        indicatorView.isHidden = false
        ApplicationData.shared.pushData(){ result in
            switch result{
            case true:
                self.dateLabel.text = "歩数データを送信しました"
            case false:
                self.dateLabel.text = "歩数データ送信に失敗しました"
            }
            ApplicationData.shared.reloadHomeData(){ result in
                switch result{
                case .success:
                        self.reloadStepLabel(true)
                case .failure:
                        self.reloadStepLabel(false)
                }
                ApplicationData.shared.loadEvents(){
                    self.reloadEventLabel(true)
                }
            }
        }
    }
    
    //表記を行う
    func reloadEventLabel(_ result:Bool){
        switch result{
            case true:
                if let content = ApplicationData.shared.events?.content{
                    eventNameLabel.text = ApplicationData.shared.events!.content?.eventName
                    eventNameLabel.font = UIFont.boldSystemFont(ofSize: 32.0)
                    let eventTermFrom = ApplicationData.shared.events!.content!.validPeriodFrom
                    let eventTermTo = ApplicationData.shared.events!.content!.validPeriodTo
                    eventTermLabel.text = "\(eventTermFrom)~\(eventTermTo)"
                    eventTermLabel.font = UIFont.systemFont(ofSize: 18.0)
                }else{
                    eventNameLabel.text = "現在開催中のイベントはありません"
                    eventNameLabel.font = UIFont.systemFont(ofSize: 18.0)
                    eventTermLabel.text = ""
                    eventTermLabel.font = UIFont.systemFont(ofSize: 18.0)
                }
        case false:
            eventNameLabel.text = "イベント情報の取得に失敗しました。"
            eventNameLabel.font = UIFont.systemFont(ofSize: 18.0)
            eventTermLabel.text = ""
            eventTermLabel.font = UIFont.systemFont(ofSize: 18.0)
            
        }
    }
    
    
    func reloadStepLabel(_ result:Bool){
//    func reloadStepLabel(){ result in
        switch result{
              case true:
//            case .success:
                print("RELOAD STEP LABEL")
                let dateString = HomeView.formatter2.string(from: Date())
                dateLabel.text = dateString
                //歩数データはカンマ区切りにするs
                let steps = ApplicationData.shared.homeRecord!.content.personalData.steps
                let stepString = String.localizedStringWithFormat("%d", steps)
                stepLabel.font = UIFont.boldSystemFont(ofSize: 48.0)
                stepLabel.text = stepString
                stepLabel.addUnit(unit: "歩", size: stepLabel.font.pointSize / 2)
                personalRankLabel.text = String(ApplicationData.shared.homeRecord!.content.personalData.ranking)
                //個人ランキングに参加人数を追加
                let personalEntry = "位/\(ApplicationData.shared.homeRecord!.content.personalData.totalCount)名"
                personalRankLabel.addUnit(unit: personalEntry, size: personalRankLabel.font.pointSize / 2)
                //距離データはメートル表記をキロに変換して返す。
                let personalDistance = ApplicationData.shared.homeRecord!.content.personalData.distance
                let personalDistanceKilo:Double = Double(personalDistance / 1000 * 1000)
                let personalDistance2 = round(personalDistanceKilo) / 1000
                distanceLabel.text = String(personalDistance2)
                distanceLabel?.addUnit(unit: "km", size: distanceLabel.font.pointSize / 2)
                //チーム名の変更
                teamNameLabel.text = String(ApplicationData.shared.team!.content.groupName)
                teamRankLabel.text = String(ApplicationData.shared.homeRecord!.content.teamData.ranking)
                //チームランキングに参加チーム数を追加
                let teamEntry = "位/\(ApplicationData.shared.homeRecord!.content.teamData.totalCount)チーム"
                teamRankLabel?.addUnit(unit: teamEntry, size: teamRankLabel.font.pointSize / 2)
                //チーム平均歩数はカンマ区切りにする
                let teamSteps = ApplicationData.shared.homeRecord!.content.teamData.avgSteps
                let teamStepString = String.localizedStringWithFormat("%d", teamSteps)
                teamStepLabel.text = teamStepString
                teamStepLabel?.addUnit(unit: "歩", size: teamStepLabel.font.pointSize / 2)
                //イベントは後日表記
//                eventNameLabel.text = ApplicationData.shared.events!.content?.eventName
//                eventNameLabel.font = UIFont.boldSystemFont(ofSize: 32.0)
//                let eventTermFrom = ApplicationData.shared.events!.content!.validPeriodFrom
//                let eventTermTo = ApplicationData.shared.events!.content!.validPeriodTo
//                eventTermLabel.text = "\(eventTermFrom)~\(eventTermTo)"
//                eventTermLabel.font = UIFont.systemFont(ofSize: 18.0)
                self.indicatorView.isHidden = true

//        default:
            case false:
                print("RELOAD STEP LABEL WITH ERROR")
                print(ApplicationData.shared.errorCode)
                let dateString = HomeView.formatter2.string(from: Date())
                dateLabel.text = dateString
                stepLabel.text = "通信環境の良い場所で更新してください。"
                stepLabel.font = UIFont.systemFont(ofSize: 18)
                personalRankLabel.text = ""
                distanceLabel.text = ""
                teamNameLabel.text = ""
                teamRankLabel.text = ""
                teamStepLabel.text = ""
//                eventNameLabel.text = ""
//                eventTermLabel.text = ""
                self.indicatorView.isHidden = true
        }
    }
}

//ラベルに単位を付記する関数
extension UILabel {
    func addUnit(unit: String, size: CGFloat) {
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
    
    private static var formatter2: DateFormatter{
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日の記録"
        return formatter
    }
}

//    //iPhoneからデータを送る
//    func pushData(){
//        print("pushdata")
//        //構造体の初期化
//        stepStructs.removeAll()
//        distanceStructs.removeAll()
//
//        //      iPhoneから歩数情報を取得する
//            let readDataTypes = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: .stepCount)!, HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!)
////            let readDataTypes = Set(arrayLiteral: [HKObjectType.quantityType(forIdentifier: .stepCount)!],
////                                                      [HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!])
//                HKHealthStore().requestAuthorization(toShare: nil, read: readDataTypes) { success, _ in
//                    if success {
//                        self.getSteps()
//                        self.getDistance()
//                    }
//                }
//
//        //      iPhoneからカロリー情報を取得する
////                let readDataTypes2 = Set([HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!])
////                HKHealthStore().requestAuthorization(toShare: nil, read: readDataTypes2) { success, _ in
////                    if success {
////                        self.getCalorie()
////                    }
////                }
//
//        //取得したデータをオブジェクト化
//        sleep(1)
//        var walkingDataLists:[WalkingDataList]=[]
//
//        for i in 0...7{
//            let walkingDataList = WalkingDataList(
//                aadid:ApplicationData.shared.mailId,
//                date:self.stepStructs[i].datetime,
//                steps: stepStructs[i].steps,
//                distance: distanceStructs[i].distance,
//                calorie: 0
//            )
//            walkingDataLists.append(walkingDataList)
//        }
//
//        let walkingData = WalkingData(
//            walkingDataList:walkingDataLists
//        )
//
//        //JSONEncoderの生成
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
//
//        do{
//            //構造体→JSONへのエンコード
//            let data = try encoder.encode(walkingData)
//            print("JSON DATA")
//            print(String(data: data, encoding: .utf8)!)
//            //データを送信する
//            upsertSteps(data: data)
//        }catch{
//            print(error)
//        }
//
//        //画面更新
//        //stepLabel.text = String(stepStructs[stepStructs.count-1].steps)
//        stepLabel.text = "12345"
//        stepLabel.addUinit(unit: "歩", size: stepLabel.font.pointSize / 2)
//        distanceLabel.text = "7.89"
//        //calorieLabel.text = String(calorieStructs[calorieStructs.count-1].calories)
//        distanceLabel.addUinit(unit: "km", size: distanceLabel.font.pointSize / 2)
//    }
//    

    
////  歩数情報を習得する関数
//    private func getSteps() {
//        print("getSteps")
//
//        /// 取得したいサンプルデータの期間の開始日を指定する。（今回は７日前の日付を取得する。）
//        let sevenDaysAgo = Calendar.current.date(byAdding: DateComponents(day: -7), to: Date())!
//        let startDate = Calendar.current.startOfDay(for: sevenDaysAgo)
//
//        /// サンプルデータの検索条件を指定する。（フィルタリング）
//        let predicate = HKQuery.predicateForSamples(withStart: startDate,
//                                                    end: Date(),
//                                                    options: [])
//
//        /// サンプルデータを取得するためのクエリを生成する。
//        let query = HKStatisticsCollectionQuery(quantityType: HKObjectType.quantityType(forIdentifier: .stepCount)!,
//                                                quantitySamplePredicate: predicate,
//                                                options: .cumulativeSum,
//                                                anchorDate: startDate,
//                                                intervalComponents: DateComponents(day: 1))
//
//        /// クエリ結果を配列に格納 する
//        query.initialResultsHandler = { _, results, _ in
//
//            /// `results (HKStatisticsCollection?)` からクエリ結果を取り出す。
//            guard let statsCollection = results else {
//                print("queryError")
//                return
//            }
//
//            /// クエリ結果から期間（開始日・終了日）を指定して歩数の統計情報を取り出す。
//                statsCollection.enumerateStatistics(from: startDate, to: Date()) { [self] statistics, _ in
//
//                    /// `statistics` に最小単位（今回は１日分の歩数）のサンプルデータが返ってくる。
//                    /// `statistics.sumQuantity()` でサンプルデータの合計（１日の合計歩数）を取得する。
//                    if let quantity = statistics.sumQuantity() {
//
//                        /// サンプルデータは`quantity.doubleValue`で取り出し、単位を指定して取得する。
//                        let date = statistics.startDate
//                        let udid = UIDevice.current.identifierForVendor?.uuidString
//                        let stepValue = quantity.doubleValue(for: HKUnit.count())
//                        let stepCount = Int(stepValue)
////                        let distanceValue = HKUnit.meter()
////                        let distanceValue = quantity.doubleValue(for: HKUnit.meter())
////                        let distanceCount = Int(distanceValue)
////                        let distanceCount = distanceValue.count
//
//                        /// 構造体にデータを格納する
//                        let stepImput = StepStruct(
//                            datetime: Self.formatter.string(from: date),
//                            steps: stepCount
//                        )
//                    /// 取得した歩数を配列に格納する。
//                    self.stepStructs.append(stepImput)
//
//                    ///データを表示
//                    print("StepData")
//                    print("\([self.stepStructs.count-1]):\(self.stepStructs[self.stepStructs.count-1].datetime)")
//                    print("\([self.stepStructs.count-1]):\(self.stepStructs [self.stepStructs.count-1].steps)")
//
//                } else {
//                    // No Data
//                    /// 構造体にデータを格納する
//                    let date = statistics.startDate
//                     let stepImput = StepStruct(
//                        datetime: Self.formatter.string(from: date),
//                        steps: 0
//                        )
//                    self.stepStructs.append(stepImput)
//                        print("No StepData")
//                        print("\([self.stepStructs.count-1]):\(self.stepStructs[self.stepStructs.count-1].datetime)")
//                        print("\([self.stepStructs.count-1]):\(self.stepStructs [self.stepStructs.count-1].steps)")
//                }
//            }
//        }
//        print("execute")
//        HKHealthStore().execute(query)
//    }
//
//    //  距離情報を習得する関数
//        private func getDistance() {
//            print("getDistance")
//
//            /// 取得したいサンプルデータの期間の開始日を指定する。（今回は７日前の日付を取得する。）
//            let sevenDaysAgo = Calendar.current.date(byAdding: DateComponents(day: -7), to: Date())!
//            let startDate = Calendar.current.startOfDay(for: sevenDaysAgo)
//
//            /// サンプルデータの検索条件を指定する。（フィルタリング）
//            let predicate = HKQuery.predicateForSamples(withStart: startDate,
//                                                        end: Date(),
//                                                        options: [])
//
//            /// サンプルデータを取得するためのクエリを生成する。
//            let query = HKStatisticsCollectionQuery(quantityType: HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
//                                                    quantitySamplePredicate: predicate,
//                                                    options: .cumulativeSum,
//                                                    anchorDate: startDate,
//                                                    intervalComponents: DateComponents(day: 1))
//
//            /// クエリ結果を配列に格納 する
//            query.initialResultsHandler = { _, results, _ in
//
//                /// `results (HKStatisticsCollection?)` からクエリ結果を取り出す。
//                guard let statsCollection = results else {
//                    print("queryError")
//                    return
//                }
//
//                /// クエリ結果から期間（開始日・終了日）を指定して歩数の統計情報を取り出す。
//                    statsCollection.enumerateStatistics(from: startDate, to: Date()) { [self] statistics, _ in
//
//                        /// `statistics` に最小単位（今回は１日分の歩数）のサンプルデータが返ってくる。
//                        /// `statistics.sumQuantity()` でサンプルデータの合計（１日の合計歩数）を取得する。
//                        if let quantity = statistics.sumQuantity() {
//
//                            /// サンプルデータは`quantity.doubleValue`で取り出し、単位を指定して取得する。
//                            let date = statistics.startDate
//                            let udid = UIDevice.current.identifierForVendor?.uuidString
////                            let stepValue = quantity.doubleValue(for: HKUnit.count())
////                            let stepCount = Int(stepValue)
////                            let distanceValue = HKUnit.meter()
//                            let distanceValue = quantity.doubleValue(for: HKUnit.meter())
//                            let distanceCount = Int(distanceValue)
//    //                        let distanceCount = distanceValue.count
//
//                            /// 構造体にデータを格納する
//                            let DistanceImput = DistanceStruct(
////                                id: udid!,
//                                datetime: Self.formatter.string(from: date),
//                                distance: distanceCount
//                            )
//                        /// 取得した歩数を配列に格納する。
//                        self.distanceStructs.append(DistanceImput)
//
//                        ///データを表示
////                        print("\([self.distanceStructs.count-1]):\(self.distanceStructs[self.distanceStructs.count-1].id)")
//                        print("Distance Data")
//                        print("\([self.distanceStructs.count-1]):\(self.distanceStructs[self.distanceStructs.count-1].datetime)")
//                        print("\([self.distanceStructs.count-1]):\(self.distanceStructs[self.distanceStructs.count-1].distance)")
//
//                    } else {
//                        // No Data
//
//                        /// 構造体にデータを格納する
//                        let date = statistics.startDate
//                        let DistanceImput = DistanceStruct(
////                                id: udid!
//                            datetime: Self.formatter.string(from: date),
//                            distance: 0
//                        )
//                    /// 取得した歩数を配列に格納する。
//                    self.distanceStructs.append(DistanceImput)
//                    }
//                        ///データを表示
////                        print("\([self.distanceStructs.count-1]):\(self.distanceStructs[self.distanceStructs.count-1].id)")
//                        print("Distance Data")
//                        print("\([self.distanceStructs.count-1]):\(self.distanceStructs[self.distanceStructs.count-1].datetime)")
//                        print("\([self.distanceStructs.count-1]):\(self.distanceStructs[self.distanceStructs.count-1].distance)")
//                }
//            }
//            print("execute")
//            HKHealthStore().execute(query)
//        }
//
//
//    //データを送信する
//    private func upsertSteps(data:Data){
//        print("upsertSteps")
//
//
//        AWSAPI.upload(message:data, url:"https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/upsert_steps_api",token: ApplicationData.shared.idToken) { [weak self] result in
//            switch result{
//            case .success(let result):
//
//                do{
//                    print(String(data: result, encoding: .utf8)!)
//                    let decoder = JSONDecoder()
////                    self!.walkingResult = try decoder.decode(WalkingResult.self, from: result as! Data)
//                    print(result)
//                }catch{
//                    print(error)
//                }
//
//            case .failure(let error):
//                print(error)
//                print("upload error")
//            }
//        }
//    }
//
//    //Home画面のデータを取得する
//    private func reloadHomeData(){
//        print("reloadHomeData")
//
//        //送信データを取得
//        let homeData = HomeData(
//            aadid: ApplicationData.shared.mailId,
//            teamid: ApplicationData.shared.team!.content.teamId
//        )
//
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
//
//        let encodedData = try? encoder.encode(homeData)
//        print("JSON DATA")
//        print(String(data: encodedData!, encoding: .utf8)!)
//
//
//        AWSAPI.upload(message: encodedData!, url:"https://xoli50a9r4.execute-api.ap-northeast-1.amazonaws.com/prod/select_home_data_api",token: ApplicationData.shared.idToken) { [weak self] result in
//            switch result{
//            case .success(let result):
//
//                do{
//                    print(String(data: result, encoding: .utf8)!)
//
//                    let decoder = JSONDecoder()
////                    self!.homeRecord = try decoder.decode(HomeRecord.self, from: result as! Data)
////                    print(self?.homeRecord)
//
//                }catch{
//                    print(error)
//                    print("error1")
//                }
//            case .failure(let error):
//                print(error)
//                print("error2")
//            }
//        }
//    }
//        //カロリー情報を取得する関数
//    private func getCalorie() {
//        print("getCalorie")
//
//        /// 取得したいサンプルデータの期間の開始日を指定する。（今回は７日前の日付を取得する。）
//        let sevenDaysAgo = Calendar.current.date(byAdding: DateComponents(day: -7), to: Date())!
//        let startDate = Calendar.current.startOfDay(for: sevenDaysAgo)
//
//        /// サンプルデータの検索条件を指定する。（フィルタリング）
//        let predicate = HKQuery.predicateForSamples(withStart: startDate,
//                                                    end: Date(),
//                                                    options: [])
//
//        /// サンプルデータを取得するためのクエリを生成する。
//        let query = HKStatisticsCollectionQuery(quantityType: HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
//                                                quantitySamplePredicate: predicate,
//                                                options: .cumulativeSum,
//                                                anchorDate: startDate,
//                                                intervalComponents: DateComponents(day: 1))
//
//        /// クエリ結果を配列に格納 する
//        query.initialResultsHandler = { _, results, _ in
//
//            /// `results (HKStatisticsCollection?)` からクエリ結果を取り出す。
//            guard let statsCollection = results else {
//                print("queryError")
//                return
//            }
//
//            /// クエリ結果から期間（開始日・終了日）を指定して消費カロリーの統計情報を取り出す。
//                statsCollection.enumerateStatistics(from: startDate, to: Date()) { [self] statistics, _ in
//
//                    /// `statistics` に最小単位（今回は１日分の消費カロリー）のサンプルデータが返ってくる。
//                    /// `statistics.sumQuantity()` でサンプルデータの合計（１日の消費カロリー）を取得する。
//                    if let quantity = statistics.sumQuantity() {
//
//                        /// サンプルデータは`quantity.doubleValue`で取り出し、単位を指定して取得する。
//                        let date = statistics.startDate
//                        let udid = UIDevice.current.identifierForVendor?.uuidString
//                        let calorieValue = quantity.doubleValue(for: HKUnit.kilocalorie())
//                        let calorieCount = Int(calorieValue)
//                        /// 構造体にデータを格納する
//                        let calorieImput = CalorieStruct(
//                            id: udid!,
//                            //datetime: Self.formatter.string(from: date),
//                            datetime: date,
//                            calories: calorieCount
//                        )
//                    /// 取得した消費カロリーを配列に格納する。
//                    self.calorieStructs.append(calorieImput)
//
//                    ///データを表示
//                    print("\([self.calorieStructs.count-1]):\(self.calorieStructs[self.calorieStructs.count-1].id)")
//                    print("\([self.calorieStructs.count-1]):\(self.calorieStructs[self.calorieStructs.count-1].datetime)")
//                    print("\([self.calorieStructs.count-1]):\(self.calorieStructs [self.calorieStructs.count-1].calories)")
//
//                } else {
//                    // No Data
//                    print("Asseterror2")
//                   // sampleArray.append(0.0)
//                }
//            }
//        }
//        print("execute")
//        HKHealthStore().execute(query)
//    }
