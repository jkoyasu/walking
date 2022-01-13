//
//  StapCountView.swift
//  walking
//
//  Created by koyasu on 2021/12/28.
//

import UIKit

class RecordView: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonRankCell", for: indexPath ) as! PersonRankCell
        return cell

    }
    
    @IBOutlet weak var dataButtonStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dataLabelStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventTitleStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventLabelStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventTermLabel: UILabel!
    
    
    @IBAction func tappedTeamButton(_ sender: Any) {
        dataLabelStackHeightConstraint.constant = 47.5
        dataButtonStackHeightConstraint.constant = 30
        eventTitleStackHeightConstraint.constant = 0
        eventLabelStackHeightConstraint.constant = 0
    }
    @IBAction func tappedPersonalButton(_ sender: Any) {
        dataLabelStackHeightConstraint.constant = 47.5
        dataButtonStackHeightConstraint.constant = 30
        eventTitleStackHeightConstraint.constant = 0
        eventLabelStackHeightConstraint.constant = 0

    }
    @IBAction func tappedEventButton(_ sender: Any) {
        dataLabelStackHeightConstraint.constant = 0
        dataButtonStackHeightConstraint.constant = 0
        eventTitleStackHeightConstraint.constant = 47.5
        eventLabelStackHeightConstraint.constant = 30
    }
    
    @IBAction func tappedDayButton(_ sender: Any) {
    }
    @IBAction func tappedWeekButton(_ sender: Any) {
    }
    @IBAction func tappedMonthButton(_ sender: Any) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataLabelStackHeightConstraint.constant = 47.5
        dataButtonStackHeightConstraint.constant = 30
        eventTitleStackHeightConstraint.constant = 0
        eventLabelStackHeightConstraint.constant = 0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "PersonRankCell", bundle: nil), forCellReuseIdentifier: "PersonRankCell")
        // Do any additional setup after loading the view.
    }

}
