//
//  ThreadView.swift
//  walking
//
//  Created by koyasu on 2022/01/13.
//

import UIKit

class ThreadView: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var TableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TableView.dataSource = self
        TableView.delegate = self
        TableView.register(UINib(nibName: "CommunicationCell", bundle: nil), forCellReuseIdentifier: "Cell")
        TableView.rowHeight = UITableView.automaticDimension
        
        self.UserName.text = "MCSY 之介"
        self.postDate.text = DateUtils.stringFromDate(date: Date(), format: "YYYY/MM/DD")
        self.message.text = "テストメッセージテストメッセージテストメッセージテストメッセージテストメッセージ"

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath ) as! CommunicationCell
       cell.setCell()
//        cell.setCell(message:self.messages[indexPath.row],name:nameList[self.messages[indexPath.row]["sender_id"] as! Int]!)
        return cell
    }
    

}
