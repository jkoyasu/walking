//
//  ThreadView.swift
//  walking
//
//  Created by koyasu on 2022/01/13.
//

import UIKit

class ThreadView: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var message:[String:Any]?
    var name:String?
    
    @IBOutlet weak var TableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let body = self.message!["body"] as! [String:String]
        
        TableView.dataSource = self
        TableView.delegate = self
        TableView.register(UINib(nibName: "SelectedPostCell", bundle: nil), forCellReuseIdentifier: "selectedPostCell")
        TableView.register(UINib(nibName: "CommunicationCell", bundle: nil), forCellReuseIdentifier: "replieCell")
        TableView.rowHeight = UITableView.automaticDimension

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row{
                    
            case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectedPostCell") as! SelectedPostCell
            cell.setCell(message: self.message!, name: name!)
                return cell

            default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "replieCell", for: indexPath ) as! CommunicationCell
            cell.setCell(message: self.message!, name: name!)
                return cell
            }
    }
    

}
