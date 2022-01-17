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

    
    @IBOutlet weak var command1: UICommand!
 
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showTab(tabSelect)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "PersonRankCell", bundle: nil), forCellReuseIdentifier: "PersonRankCell")
        tableView.register(UINib(nibName: "TeamRankCell", bundle: nil), forCellReuseIdentifier: "TeamRankCell")
        tableView.register(UINib(nibName: "EventRankCell", bundle: nil), forCellReuseIdentifier: "EventRankCell")
        // Do any additional setup after loading the view.
    }

}