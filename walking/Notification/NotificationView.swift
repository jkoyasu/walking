//
//  NotificationView.swift
//  walking
//
//  Created by koyasu on 2022/01/12.
//

import UIKit

class NotificationView: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var TableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.dataSource = self
        TableView.delegate = self
        TableView.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
        TableView.register(UINib(nibName: "ErrorCell", bundle: nil), forCellReuseIdentifier: "ErrorCell")

        // Do any additional setup after loading the view.
        ApplicationData.shared.loadNotification {
            self.TableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ApplicationData.shared.notifications?.content?.noticeList.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let content = ApplicationData.shared.notifications?.content{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath ) as! NotificationCell
            cell.setCell(index: indexPath, record: content.noticeList)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ErrorCell", for: indexPath ) as! ErrorCell
            return cell
        }
    }
    
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
