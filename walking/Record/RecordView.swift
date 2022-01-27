//
//  StapCountView.swift
//  walking
//
//  Created by koyasu on 2021/12/28.
//

import UIKit

class RecordView: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate {
    
    var personRecord:PersonRecord?
    
    @IBOutlet weak var dayMenu: UIMenu!
    @IBOutlet weak var dayPullDownButton: UIButton!
    @IBOutlet weak var weekPullDownButton: UIButton!
    @IBOutlet weak var monthPullDownButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var tabSelect:Int! = 1
    var termSelect:Int! = 1
    var startView = StartView()
    
    /// DateFomatterクラスのインスタンス生成
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadMessage()
        
        showTab(tabSelect)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "PersonRankCell", bundle: nil), forCellReuseIdentifier: "PersonRankCell")
        tableView.register(UINib(nibName: "TeamRankCell", bundle: nil), forCellReuseIdentifier: "TeamRankCell")
        tableView.register(UINib(nibName: "EventRankCell", bundle: nil), forCellReuseIdentifier: "EventRankCell")
        addMenuToButton()
        
        dateFormatter.dateFormat = "yyyy年M月d日"
        self.dayPullDownButton.setTitle(dateFormatter.string(from: Date()),for: .normal)
        self.weekPullDownButton.setTitle(dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -7, to: Date())!)+"〜"+dateFormatter.string(from: Date()),for: .normal)
        dateFormatter.dateFormat = "yyyy年M月"
        self.monthPullDownButton.setTitle(dateFormatter.string(from: Date()),for: .normal)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tabSelect == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PersonRankCell", for: indexPath ) as! PersonRankCell
            cell.setCell(index: indexPath)
            return cell
        }else if tabSelect == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TeamRankCell", for: indexPath ) as! TeamRankCell
            cell.setCell(index: indexPath)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventRankCell", for: indexPath ) as! EventRankCell
            cell.setCell(index: indexPath)
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func didSelectTab(tabBarController: TabBarController) {
        print("first!")
    }

    @IBOutlet weak var dataButtonStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dataLabelStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventTitleStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventLabelStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventTermLabel: UILabel!
    @IBOutlet weak var reloadButton1: UIButton!
    @IBOutlet weak var reloadButton2: UIButton!
    
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
        //1:個人
        if tabSelect == 1 {
            dataLabelStackHeightConstraint.constant = 47.5
            dataButtonStackHeightConstraint.constant = 47.5
            eventTitleStackHeightConstraint.constant = 0
            eventLabelStackHeightConstraint.constant = 0
            reloadButton1.isHidden = false
            reloadButton2.isHidden = true
            showTerm(termSelect)
        //2:チーム
        }else if tabSelect == 2{
            dataLabelStackHeightConstraint.constant = 47.5
            dataButtonStackHeightConstraint.constant = 47.5
            eventTitleStackHeightConstraint.constant = 0
            eventLabelStackHeightConstraint.constant = 0
            reloadButton1.isHidden = false
            reloadButton2.isHidden = true
            showTerm(termSelect)
        //3: イベント
        }else{
            dataLabelStackHeightConstraint.constant = 0
            dataButtonStackHeightConstraint.constant = 0
            eventTitleStackHeightConstraint.constant = 47.5
            eventLabelStackHeightConstraint.constant = 47.5
            dayPullDownButton.isHidden = true
            weekPullDownButton.isHidden = true
            monthPullDownButton.isHidden = true
            reloadButton1.isHidden = true
            reloadButton2.isHidden = false
        }
    }
    
    //タブ表示（日/週/月）を制御
    private func showTerm(_ termSelect: Int){
        //1:日
        if termSelect == 1 {
            dayPullDownButton.isHidden = false
            weekPullDownButton.isHidden = true
            monthPullDownButton.isHidden = true
        //2:週
        }else if termSelect == 2{
            dayPullDownButton.isHidden = true
            weekPullDownButton.isHidden = false
            monthPullDownButton.isHidden = true
        //3:月
        }else{
            dayPullDownButton.isHidden = true
            weekPullDownButton.isHidden = true
            monthPullDownButton.isHidden = false
        }
    }
    //UIbuttonのメニュー表示(iOS14以上でのみ機能）
    func addMenuToButton(){
        /// 変換フォーマット定義
        dateFormatter.dateFormat = "yyyy年M月d日"
        
        var today = Date()

        //日次
        var daylist:[UIAction] = []

        for i in 0...13{
            let modifiedDate = Calendar.current.date(byAdding: .day, value: -i, to: today)!
            let dateString = dateFormatter.string(from: modifiedDate)
            let action = UIAction(title: dateString, image: nil){ (action) in self.dayPullDownButton.setTitle(dateString,for: .normal)
            }
            daylist.append(action)
        }

        let dayMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: daylist)
        dayPullDownButton.menu = dayMenu
        dayPullDownButton.showsMenuAsPrimaryAction = true
        
        //週次
        var weeklist:[UIAction] = []
        
        for i in 0...3{
            let modifiedDate = Calendar.current.date(byAdding: .day, value: -(i*7), to: today)!
            let modifiedDate2 = Calendar.current.date(byAdding: .day, value: -((i+1)*7), to: today)!
            let dateString = dateFormatter.string(from: modifiedDate)
            let dateString2 = dateFormatter.string(from: modifiedDate2)
            let weekString = dateString + "〜" + dateString2
            let action = UIAction(title: weekString, image: nil){ (action) in self.dayPullDownButton.setTitle(weekString,for: .normal)
            }
            weeklist.append(action)
        }

        let weekMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: weeklist)
        weekPullDownButton.menu = weekMenu
        weekPullDownButton.showsMenuAsPrimaryAction = true
            
        //月次
        dateFormatter.dateFormat = "yyyy年M月"
            
        var monthlist:[UIAction] = []
            
        for i in 0...2{
            let modifiedDate = Calendar.current.date(byAdding: .month, value: -i, to: today)!
            let monthString = dateFormatter.string(from: modifiedDate)
            let action = UIAction(title: monthString, image: nil){ (action) in self.dayPullDownButton.setTitle(monthString,for: .normal)
            }
            monthlist.append(action)
        }
        let monthMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: monthlist)
        monthPullDownButton.menu = monthMenu
        monthPullDownButton.showsMenuAsPrimaryAction = true
    }
    
    func loadMessage(){
        AWSAPI.download(token: startView.accessToken) { [weak self] result in
            switch result {
            case .success(let result):
                
                print(result)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
