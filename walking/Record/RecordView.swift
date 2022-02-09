//
//  StapCountView.swift
//  walking
//
//  Created by koyasu on 2021/12/28.
//

import UIKit

class RecordView: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate {
    
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var dayMenu: UIMenu!
    @IBOutlet weak var dayPullDownButton: UIButton!
    @IBOutlet weak var weekPullDownButton: UIButton!
    @IBOutlet weak var monthPullDownButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    let selectedButtonsAttributes: [NSAttributedString.Key : Any] = [
        .foregroundColor : UIColor.black,
        .font : UIFont.systemFont(ofSize: 24.0),
        NSAttributedString.Key(rawValue:NSAttributedString.Key.underlineStyle.rawValue):NSUnderlineStyle.thick.rawValue,NSAttributedString.Key.underlineColor: #colorLiteral(red: 0.03529411765, green: 0.4784313725, blue: 0.4784313725, alpha: 1)
        ]
    let selectedTermButtonsAttributes: [NSAttributedString.Key : Any] = [
        .foregroundColor : UIColor.black,
        .font : UIFont.systemFont(ofSize: 24.0),
        NSAttributedString.Key(rawValue:NSAttributedString.Key.underlineStyle.rawValue):NSUnderlineStyle.thick.rawValue,NSAttributedString.Key.underlineColor: UIColor.white
        ]
    let ButtonsAttributes: [NSAttributedString.Key : Any] = [
        .foregroundColor : UIColor.black,
        .font : UIFont.systemFont(ofSize: 24.0)
        ]
    
    var calendar = Calendar(identifier: .gregorian)
    var selectedTerm:String?
    var currentDay:String?
    var currentWeek:String?
    var currentMonth:String?
    var tabSelect:Int! = 1
    var termSelect:Int! = 1
    var startView = StartView()
    
    /// DateFomatterクラスのインスタンス生成
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        indicatorView.isHidden = true
        loadRanking()
        showTab(tabSelect)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "PersonRankCell", bundle: nil), forCellReuseIdentifier: "PersonRankCell")
        tableView.register(UINib(nibName: "TeamRankCell", bundle: nil), forCellReuseIdentifier: "TeamRankCell")
        tableView.register(UINib(nibName: "EventRankCell", bundle: nil), forCellReuseIdentifier: "EventRankCell")
        tableView.register(UINib(nibName: "ErrorCell", bundle: nil), forCellReuseIdentifier: "ErrorCell")
        addMenuToButton()
        
        self.dayPullDownButton.layer.borderColor = UIColor.gray.cgColor
        self.weekPullDownButton.layer.borderColor = UIColor.gray.cgColor
        self.monthPullDownButton.layer.borderColor = UIColor.gray.cgColor
        self.dayPullDownButton.layer.borderWidth = 1
        self.weekPullDownButton.layer.borderWidth = 2
        self.monthPullDownButton.layer.borderWidth = 3
        
        //日付データ設定
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.currentDay = dateFormatter.string(from: Date())
        self.currentWeek = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -7, to: calendar.nextWeekend(startingAfter: Date())!.end)!)+","+dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: calendar.nextWeekend(startingAfter: Date())!.end)!)
        self.selectedTerm = self.currentDay
        dateFormatter.dateFormat = "M月d日"
        self.dayPullDownButton.setTitle(dateFormatter.string(from: Date()),for: .normal)
        self.weekPullDownButton.setTitle(dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -7, to: calendar.nextWeekend(startingAfter: Date())!.end)!)+"〜"+dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: calendar.nextWeekend(startingAfter: Date())!.end)!),for: .normal)
        dateFormatter.dateFormat = "M"
        self.currentMonth = dateFormatter.string(from: Date())
        dateFormatter.dateFormat = "M月"
        self.monthPullDownButton.setTitle(dateFormatter.string(from: Date()),for: .normal)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tabSelect == 1 {
            if let content = ApplicationData.shared.personRecord?.content {
                switch termSelect{
                case 1:
                    let rankingList = content.dailyRankingList.filter({ $0.term == self.selectedTerm! })
//                    if rankingList[0].ranking.count > 0{
                    if rankingList.count > 0{
                        if rankingList[0].ranking[0].rank != -1{
                            return rankingList[0].ranking.count
                        }else{
                            return 0
                        }
                    }else{
                        return 0
                    }
                case 2:
                    let rankingList = content.weeklyRankingList.filter({ $0.term == self.selectedTerm! })
                    if rankingList[0].ranking.count > 0{
                        if rankingList[0].ranking[0].rank != -1{
                            return rankingList[0].ranking.count
                        }else{
                            return 0
                        }
                    }else{
                        return 0
                    }
                case 3:
                    let rankingList = content.monthlyRankingList.filter({ $0.term == self.selectedTerm! })
                    if rankingList[0].ranking.count > 0{
                        if rankingList[0].ranking[0].rank != -1{
                            return rankingList[0].ranking.count
                        }else{
                            return 0
                        }
                    }else{
                        return 0
                    }
                default:
                    return 1
                }
            }else{
                return 1
            }
        }else if tabSelect == 2 {
            if let content = ApplicationData.shared.teamRecord?.content {
                switch termSelect{
                case 1:
                    let rankingList = content.dailyRankingList.filter({ $0.term == self.selectedTerm! })
                    if rankingList[0].ranking.count > 0{
                        if rankingList[0].ranking[0].rank != -1{
                            return rankingList[0].ranking.count
                        }else{
                            return 0
                        }
                    }else{
                        return 0
                    }
                case 2:
                    let rankingList = content.weeklyRankingList.filter({ $0.term == self.selectedTerm! })
                    if rankingList[0].ranking.count > 0{
                        if rankingList[0].ranking[0].rank != -1{
                            return rankingList[0].ranking.count
                        }else{
                            return 0
                        }
                    }else{
                        return 0
                    }
                case 3:
                    let rankingList = content.monthlyRankingList.filter({ $0.term == self.selectedTerm! })
                    if rankingList[0].ranking.count > 0{
                        if rankingList[0].ranking[0].rank != -1{
                            return rankingList[0].ranking.count
                        }else{
                            return 0
                        }
                    }else{
                        return 0
                    }
                default:
                    return 1
                }
            }else{
                return 1
            }
        }else{
            if let content = ApplicationData.shared.eventRecord?.content{
                return content.eventRanking.count
            }else{
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tabSelect == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PersonRankCell", for: indexPath ) as! PersonRankCell
            if let content = ApplicationData.shared.personRecord?.content {
                switch termSelect{
                case 1:
                    cell.setCell(index: indexPath, record: content.dailyRankingList.filter({ $0.term == self.selectedTerm! })[0].ranking)
                    return cell
                case 2:
                    cell.setCell(index: indexPath, record: content.weeklyRankingList.filter({ $0.term == self.selectedTerm! })[0].ranking)
                    return cell
                case 3:
                    cell.setCell(index: indexPath, record: content.monthlyRankingList.filter({ $0.term == self.selectedTerm! })[0].ranking)
                    return cell
                default:
                    print("error")
                    return cell
                }
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ErrorCell") as! ErrorCell
                return cell
            }
        }else if tabSelect == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TeamRankCell", for: indexPath ) as! TeamRankCell
            if let content = ApplicationData.shared.teamRecord?.content {
                switch termSelect{
                case 1:
                    cell.setCell(index: indexPath, record: content.dailyRankingList.filter({ $0.term == self.selectedTerm! })[0].ranking)
                    return cell
                case 2:
                    cell.setCell(index: indexPath, record: content.weeklyRankingList.filter({ $0.term == self.selectedTerm! })[0].ranking)
                    return cell
                case 3:
                    cell.setCell(index: indexPath, record: content.monthlyRankingList.filter({ $0.term == self.selectedTerm! })[0].ranking)
                    return cell
                default:
                    print("error")
                    return cell
                }
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ErrorCell") as! ErrorCell
                return cell
            }
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventRankCell", for: indexPath ) as! EventRankCell
            if let content = ApplicationData.shared.eventRecord?.content{
                cell.setCell(index: indexPath, record: content.eventRanking)
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ErrorCell") as! ErrorCell
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func didSelectTab(tabBarController: TabBarController) {
        print("first!")
    }

    

    @IBOutlet weak var personalButton: UIButton!
    @IBOutlet weak var teamButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var dataButtonStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dataLabelStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventTitleStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventLabelStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventTermLabel: UILabel!
    @IBOutlet weak var reloadButton1: UIButton!
    @IBOutlet weak var reloadButton2: UIButton!
    
    @IBAction func tappedReloadButton(_ sender: Any) {
        self.loadRanking()
    }
    
    @IBAction func tappedPersonalButton(_ sender: Any) {
        tabSelect = 1
        showTab(1)
        tableView?.reloadData()
    }
    
    @IBAction func tappedTeamButton(_ sender: Any) {
        tabSelect = 2
        showTab(2)
        tableView?.reloadData()
    }
 
    @IBAction func tappedEventButton(_ sender: Any) {

        dayPullDownButton.isHidden = true
        weekPullDownButton.isHidden = true
        monthPullDownButton.isHidden = true
        tabSelect = 3
        showTab(3)
        tableView?.reloadData()
    }
    
    @IBAction func tappedDayButton(_ sender: Any) {
        termSelect = 1
        showTerm(termSelect)
        tableView?.reloadData()
    }
    
    @IBAction func tappedWeekButton(_ sender: Any) {
        termSelect = 2
        showTerm(termSelect)
        tableView?.reloadData()
    }
    @IBAction func tappedMonthButton(_ sender: Any) {
        termSelect = 3
        showTerm(termSelect)
        tableView?.reloadData()
    }
    
    //タブ表示（個人/チーム/イベント）を制御
    private func showTab(_ tabSelect: Int){
        let selectedPersonalButtonText = NSAttributedString(string: "個人", attributes: selectedButtonsAttributes)
        let personalButtonText = NSAttributedString(string: "個人", attributes: ButtonsAttributes)
        let selectedTeamButtonText = NSAttributedString(string: "チーム", attributes: selectedButtonsAttributes)
        let teamButtonText = NSAttributedString(string: "チーム", attributes: ButtonsAttributes)
        let selectedEventButtonText = NSAttributedString(string: "イベント", attributes: selectedButtonsAttributes)
        let eventButtonText = NSAttributedString(string: "イベント", attributes: ButtonsAttributes)
        
        //1:個人
        if tabSelect == 1 {
            dataLabelStackHeightConstraint.constant = 47.5
            dataButtonStackHeightConstraint.constant = 47.5
            eventTitleStackHeightConstraint.constant = 0
            eventLabelStackHeightConstraint.constant = 0
            reloadButton1.isHidden = false
            reloadButton2.isHidden = true
            dayButton.isHidden = false
            weekButton.isHidden = false
            monthButton.isHidden = false
            showTerm(termSelect)
            personalButton.setAttributedTitle(selectedPersonalButtonText, for: .normal)
            teamButton.setAttributedTitle(teamButtonText, for: .normal)
            eventButton.setAttributedTitle(eventButtonText, for: .normal)
        //2:チーム
        }else if tabSelect == 2{
            dataLabelStackHeightConstraint.constant = 47.5
            dataButtonStackHeightConstraint.constant = 47.5
            eventTitleStackHeightConstraint.constant = 0
            eventLabelStackHeightConstraint.constant = 0
            reloadButton1.isHidden = false
            reloadButton2.isHidden = true
            dayButton.isHidden = false
            weekButton.isHidden = false
            monthButton.isHidden = false
            showTerm(termSelect)
            personalButton.setAttributedTitle(personalButtonText, for: .normal)
            teamButton.setAttributedTitle(selectedTeamButtonText, for: .normal)
            eventButton.setAttributedTitle(eventButtonText, for: .normal)
        //3: イベント
        }else{
            dataLabelStackHeightConstraint.constant = 0
            dataButtonStackHeightConstraint.constant = 0
            eventTitleStackHeightConstraint.constant = 47.5
            eventLabelStackHeightConstraint.constant = 47.5
            dayPullDownButton.isHidden = true
            weekPullDownButton.isHidden = true
            monthPullDownButton.isHidden = true
            dayButton.isHidden = true
            weekButton.isHidden = true
            monthButton.isHidden = true
            reloadButton1.isHidden = true
            reloadButton2.isHidden = false
            personalButton.setAttributedTitle(personalButtonText, for: .normal)
            teamButton.setAttributedTitle(teamButtonText, for: .normal)
            eventButton.setAttributedTitle(selectedEventButtonText, for: .normal)
        }
    }
    
    //タブ表示（日/週/月）を制御
    private func showTerm(_ termSelect: Int){
        let selectedTabColor = UIColor(red: 210.0/255.0, green: 238.0/255.0, blue: 212.0/255.0, alpha: 1.0)
        let unSelectedTabColor = UIColor(red: 121.0/255.0, green: 202.0/255.0, blue: 124.0/255.0, alpha: 1.0)
        
        //1:日
        if termSelect == 1 {
            dayPullDownButton.isHidden = false
            weekPullDownButton.isHidden = true
            monthPullDownButton.isHidden = true
            
            dayButton.backgroundColor = selectedTabColor
            weekButton.backgroundColor = unSelectedTabColor
            monthButton.backgroundColor = unSelectedTabColor
            
            self.selectedTerm = self.currentDay
        //2:週
        }else if termSelect == 2{
            dayPullDownButton.isHidden = true
            weekPullDownButton.isHidden = false
            monthPullDownButton.isHidden = true
            
            dayButton.backgroundColor = unSelectedTabColor
            weekButton.backgroundColor = selectedTabColor
            monthButton.backgroundColor = unSelectedTabColor
            
            self.selectedTerm = self.currentWeek
        //3:月
        }else{
            dayPullDownButton.isHidden = true
            weekPullDownButton.isHidden = true
            monthPullDownButton.isHidden = false
            
            dayButton.backgroundColor = unSelectedTabColor
            weekButton.backgroundColor = unSelectedTabColor
            monthButton.backgroundColor = selectedTabColor
            
            self.selectedTerm = self.currentMonth
        }
    }
    //UIbuttonのメニュー表示(iOS14以上でのみ機能）
    func addMenuToButton(){
        /// 変換フォーマット定義
        dateFormatter.dateFormat = "M月d日"
        
        var today = Date()

        //日次
        var daylist:[UIAction] = []

        for i in 0...13{
            let modifiedDate = Calendar.current.date(byAdding: .day, value: -i, to: today)!
            let dateString = dateFormatter.string(from: modifiedDate)
            let action = UIAction(title: dateString, image: nil){ (action) in self.dayPullDownButton.setTitle(dateString,for: .normal)
                self.dateFormatter.dateFormat = "yyyy-MM-dd"
                self.currentDay = self.dateFormatter.string(from: modifiedDate)
                self.selectedTerm = self.dateFormatter.string(from: modifiedDate)
                self.tableView.reloadData()
            }
            daylist.append(action)
        }

        let dayMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: daylist)
        dayPullDownButton.menu = dayMenu
        dayPullDownButton.showsMenuAsPrimaryAction = true
        
        //週次
        var weeklist:[UIAction] = []
        
        for i in 0...3{
            let modifiedDate = Calendar.current.date(byAdding: .day, value: -(i*7), to: Calendar.current.date(byAdding: .day, value: -1, to: calendar.nextWeekend(startingAfter: Date())!.end)!)!
            let modifiedDate2 = Calendar.current.date(byAdding: .day, value: -((i+1)*7), to: calendar.nextWeekend(startingAfter: Date())!.end)!
            let dateString = dateFormatter.string(from: modifiedDate)
            let dateString2 = dateFormatter.string(from: modifiedDate2)
            let weekString = dateString2 + "〜" + dateString
            let action = UIAction(title: weekString, image: nil){ (action) in self.weekPullDownButton.setTitle(weekString,for: .normal)
                self.dateFormatter.dateFormat = "yyyy-MM-dd"
                self.currentWeek = self.dateFormatter.string(from: modifiedDate2) + "," + self.dateFormatter.string(from: modifiedDate)
                self.selectedTerm = self.dateFormatter.string(from: modifiedDate2) + "," + self.dateFormatter.string(from: modifiedDate)
                self.tableView.reloadData()
            }
            weeklist.append(action)
        }

        let weekMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: weeklist)
        weekPullDownButton.menu = weekMenu
        weekPullDownButton.showsMenuAsPrimaryAction = true
            
        //月次
        dateFormatter.dateFormat = "M月"
            
        var monthlist:[UIAction] = []
            
        for i in 0...2{
            let modifiedDate = Calendar.current.date(byAdding: .month, value: -i, to: today)!
            let monthString = dateFormatter.string(from: modifiedDate)
            let action = UIAction(title: monthString, image: nil){ (action) in self.monthPullDownButton.setTitle(monthString,for: .normal)
                self.dateFormatter.dateFormat = "M"
                self.currentMonth = self.dateFormatter.string(from: modifiedDate)
                self.selectedTerm = self.dateFormatter.string(from: modifiedDate)
                self.tableView.reloadData()
            }
            monthlist.append(action)
        }
        let monthMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: monthlist)
        monthPullDownButton.menu = monthMenu
        monthPullDownButton.showsMenuAsPrimaryAction = true
    }
    
    func loadRanking(){
        self.indicatorView.isHidden = false
        ApplicationData.shared.loadPersonalRanking(){
            ApplicationData.shared.loadTeamRanking(){
                ApplicationData.shared.loadEventRanking(){
                    self.tableView.reloadData()
                    self.indicatorView.isHidden = true
                }
            }
        }
    }
}
