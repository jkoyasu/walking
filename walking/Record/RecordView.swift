//
//  StapCountView.swift
//  walking
//
//  Created by koyasu on 2021/12/28.
//

import UIKit

class RecordView: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var dayPullDownButton: UIButton!
    @IBOutlet weak var weekPullDownButton: UIButton!
    @IBOutlet weak var monthPullDownButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var tabSelect:Int! = 1
    var termSelect:Int! = 1
    
    @IBOutlet weak var dayMenu: UIMenu!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tabSelect == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PersonRankCell", for: indexPath ) as! PersonRankCell
            return cell
        }else if tabSelect == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TeamRankCell", for: indexPath ) as! TeamRankCell
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventRankCell", for: indexPath ) as! EventRankCell
            return cell
            
        }

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
            //日次
            let dayButton1 = UIAction(title: "2022/1/7", image: nil) { (action) in
                self.dayPullDownButton.setTitle("2022/1/7",for: .normal)
            }
            let dayButton2 = UIAction(title: "2022/1/6", image: nil){ (action) in
                self.dayPullDownButton.setTitle("2022/1/6",for: .normal)
            }
            let dayButton3 = UIAction(title: "2022/1/5", image: nil){ (action) in
                self.dayPullDownButton.setTitle("2022/1/5",for: .normal)
            }
            let dayButton4 = UIAction(title: "2022/1/4", image: nil){ (action) in
                self.dayPullDownButton.setTitle("2022/1/4",for: .normal)
            }
            let dayButton5 = UIAction(title: "2022/1/3", image: nil){ (action) in
                self.dayPullDownButton.setTitle("2022/1/3",for: .normal)
            }
            let dayButton6 = UIAction(title: "2022/1/2", image: nil){ (action) in
                self.dayPullDownButton.setTitle("2022/1/2",for: .normal)
            }
            let dayButton7 = UIAction(title: "2022/1/1", image: nil){ (action) in
                self.dayPullDownButton.setTitle("2022/1/1",for: .normal)
            }
            let dayButton8 = UIAction(title: "2021/12/31", image: nil) { (action) in
                self.dayPullDownButton.setTitle("2021/12/31",for: .normal)
            }
            let dayButton9 = UIAction(title: "2021/12/30", image: nil){ (action) in
                self.dayPullDownButton.setTitle("2021/12/30",for: .normal)
            }
            let dayButton10 = UIAction(title: "2021/12/29", image: nil){ (action) in
                self.dayPullDownButton.setTitle("2021/12/29",for: .normal)
            }
            let dayButton11 = UIAction(title: "2021/12/28", image: nil){ (action) in
                self.dayPullDownButton.setTitle("2021/12/28",for: .normal)
            }
            let dayButton12 = UIAction(title: "2021/12/27", image: nil){ (action) in
                self.dayPullDownButton.setTitle("2021/12/27",for: .normal)
            }
            let dayButton13 = UIAction(title: "2021/12/26", image: nil){ (action) in
                self.dayPullDownButton.setTitle("2021/12/26",for: .normal)
            }
            let dayButton14 = UIAction(title: "2021/12/25", image: nil){ (action) in
                self.dayPullDownButton.setTitle("2021/12/25",for: .normal)
            }

            let dayMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [dayButton1, dayButton2, dayButton3, dayButton4, dayButton5, dayButton6, dayButton7,dayButton8, dayButton9, dayButton10, dayButton11, dayButton12, dayButton13, dayButton14])
            dayPullDownButton.menu = dayMenu
            dayPullDownButton.showsMenuAsPrimaryAction = true
            
            //週次
            let weekButton1 = UIAction(title: "2022/1/1~2022/1/7", image: nil) { (action) in
                self.weekPullDownButton.setTitle("2022/1/1~2022/1/7",for: .normal)
            }
            let weekButton2 = UIAction(title: "2021/12/25~2021/12/31", image: nil){ (action) in
                self.weekPullDownButton.setTitle("2021/12/25~2021/12/31",for: .normal)
            }
            let weekButton3 = UIAction(title: "2021/12/18~2021/12/24", image: nil){ (action) in
                self.weekPullDownButton.setTitle("2021/12/18~2021/12/24",for: .normal)
            }
            let weekButton4 = UIAction(title: "2021/12/11~2021/12/17", image: nil){ (action) in
                self.weekPullDownButton.setTitle("2021/12/11~2021/12/17",for: .normal)
            }

            let weekMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [weekButton1, weekButton2, weekButton3, weekButton4])
            weekPullDownButton.menu = weekMenu
            weekPullDownButton.showsMenuAsPrimaryAction = true
            
            //月次
            let monthButton1 = UIAction(title: "2022/1", image: nil) { (action) in
                self.monthPullDownButton.setTitle("2022/1",for: .normal)
            }
            let monthButton2 = UIAction(title: "2021/12", image: nil){ (action) in
                self.monthPullDownButton.setTitle("2021/12",for: .normal)
            }
            let monthButton3 = UIAction(title: "2021/11", image: nil){ (action) in
                self.monthPullDownButton.setTitle("2021/11",for: .normal)
            }
            
            let monthMenu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [monthButton1, monthButton2, monthButton3])
            monthPullDownButton.menu = monthMenu
            monthPullDownButton.showsMenuAsPrimaryAction = true
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        showTab(tabSelect)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "PersonRankCell", bundle: nil), forCellReuseIdentifier: "PersonRankCell")
        tableView.register(UINib(nibName: "TeamRankCell", bundle: nil), forCellReuseIdentifier: "TeamRankCell")
        tableView.register(UINib(nibName: "EventRankCell", bundle: nil), forCellReuseIdentifier: "EventRankCell")
        addMenuToButton()
        self.dayPullDownButton.setTitle("2022/1/7",for: .normal)
        self.weekPullDownButton.setTitle("2022/1/1~2022/1/7",for: .normal)
        self.monthPullDownButton.setTitle("2022/1",for: .normal)
    }

}
