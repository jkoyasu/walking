//
//  MemberViewController.swift
//  walking
//
//  Created by koyasu on 2022/01/12.
//

import UIKit

class MemberView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var TableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.dataSource = self
        TableView.delegate = self
        TableView.register(UINib(nibName: "MemberCell", bundle: nil), forCellReuseIdentifier: "MemberCell")
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath ) as! MemberCell
        return cell    }
    
    


}
