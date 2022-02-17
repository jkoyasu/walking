//
//  MemberViewController.swift
//  walking
//
//  Created by koyasu on 2022/01/12.
//

import UIKit

class MemberView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var profileButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.dataSource = self
        TableView.delegate = self
        profileButton.setTitle(String(ApplicationData.shared.displayName.prefix(1)), for: .normal)
        TableView.register(UINib(nibName: "MemberCell", bundle: nil), forCellReuseIdentifier: "MemberCell")
        TableView.register(UINib(nibName: "ErrorCell", bundle: nil), forCellReuseIdentifier: "ErrorCell")
        // Do any additional setup after loading the view.
        ApplicationData.shared.loadMember {
            self.TableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ApplicationData.shared.members?.content?.teamMemberList.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let content = ApplicationData.shared.members?.content{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath ) as! MemberCell
            cell.setCell(index: indexPath, record: content.teamMemberList)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ErrorCell", for: indexPath ) as! ErrorCell
            return cell
        }
    }
    
}
