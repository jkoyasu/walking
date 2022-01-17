//
//  CommunicationView.swift
//  walking
//
//  Created by koyasu on 2022/01/06.
//

import UIKit

class CommunicationView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var TableView: UITableView!
    
    var messages:[[String:Any]] = []{
        didSet {
            TableView.reloadData()
        }
    }
    var replies:[[String:Any]] = []
    var references:[[String:Any]] = []
    var nameList:[Int:String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadMessage()
        TableView.dataSource = self
        TableView.delegate = self
        TableView.register(UINib(nibName: "CommunicationCell", bundle: nil), forCellReuseIdentifier: "Cell")
        TableView.rowHeight = UITableView.automaticDimension

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.messages.count
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath ) as! CommunicationCell
       cell.setCell()
//        cell.setCell(message:self.messages[indexPath.row],name:nameList[self.messages[indexPath.row]["sender_id"] as! Int]!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "toThread", sender: nil)
    }
    
    func loadMessage(){
        YammerAPI.APICAll{ [weak self] result in
            switch result {
            case .success(let result):
                self!.messages = []
                let jsonString : String = String(describing:result)
                let jsonData : Data  = jsonString.data(using: .utf8)! as Data
                do{
                    let jsonObject : AnyObject = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as AnyObject
                    let message = jsonObject as? [String:Any]
                    let message1 = message?["messages"] as! [[String:Any]]
                    for i in message1{
                        if i["system_message"] as! Bool == false{
                            self?.messages.append(i)
                        }
                    }
                    
                    let references = message?["references"] as! [[String:Any]]
                    for i in references{
                        if i.keys.contains("full_name"){
                            self?.references.append(i)
                        }
                    }
                    
                    self?.makeNameList()
                    print(self?.messages)
                    
                } catch let error as NSError {
                       print("Details of JSON parsing error:\n \(error)")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func makeNameList(){
        for i in self.messages{
            let id = i["sender_id"] as! Int
            for ref in self.references{
                if id == ref["id"] as! Int{
                    let name = ref["full_name"]
                    self.nameList[id] = name as! String
                }
            }
        }
        print(self.nameList)
    }
}

//class TableView:UIViewController{
//
//    @IBOutlet weak var TableView: UITableView!
//
//    var messages:[[String:Any]] = []{
//        didSet {
//            TableView.reloadData()
//        }
//    }
//    var replies:[[String:Any]] = []
//    var references:[[String:Any]] = []
//    var nameList:[Int:String] = [:]
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.loadMessage()
//        TableView.dataSource = self
//        TableView.delegate = self
//        TableView.register(UINib(nibName: "CommunicationCell", bundle: nil), forCellReuseIdentifier: "Cell")
//        TableView.rowHeight = UITableView.automaticDimension
//
//        // Do any additional setup after loading the view.
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        return self.messages.count
//        return 5
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath ) as! CommunicationCell
//       cell.setCell()
////        cell.setCell(message:self.messages[indexPath.row],name:nameList[self.messages[indexPath.row]["sender_id"] as! Int]!)
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        performSegue(withIdentifier: "toThread", sender: nil)
//    }
//
//    func loadMessage(){
//        YammerAPI.APICAll{ [weak self] result in
//            switch result {
//            case .success(let result):
//                self!.messages = []
//                let jsonString : String = String(describing:result)
//                let jsonData : Data  = jsonString.data(using: .utf8)! as Data
//                do{
//                    let jsonObject : AnyObject = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as AnyObject
//                    let message = jsonObject as? [String:Any]
//                    let message1 = message?["messages"] as! [[String:Any]]
//                    for i in message1{
//                        if i["system_message"] as! Bool == false{
//                            self?.messages.append(i)
//                        }
//                    }
//
//                    let references = message?["references"] as! [[String:Any]]
//                    for i in references{
//                        if i.keys.contains("full_name"){
//                            self?.references.append(i)
//                        }
//                    }
//
//                    self?.makeNameList()
//                    print(self?.messages)
//
//                } catch let error as NSError {
//                       print("Details of JSON parsing error:\n \(error)")
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
//
//    func makeNameList(){
//        for i in self.messages{
//            let id = i["sender_id"] as! Int
//            for ref in self.references{
//                if id == ref["id"] as! Int{
//                    let name = ref["full_name"]
//                    self.nameList[id] = name as! String
//                }
//            }
//        }
//        print(self.nameList)
//    }
//}

class DateUtils {
    class func dateFromString(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }

    class func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
