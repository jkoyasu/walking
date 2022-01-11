//
//  CommunicationCell.swift
//  walking
//
//  Created by koyasu on 2022/01/06.
//

import UIKit

class CommunicationCell: UITableViewCell {

    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var Message: UILabel!
    @IBOutlet weak var ReplieButton: UIButton!
    @IBOutlet weak var LikeButton: UIButton!
    @IBOutlet weak var NameButton: UIButton!
    @IBOutlet weak var postDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(message:[String:Any],name:String) {
        let body = message["body"] as! [String:String]
        let date = message["created_at"] as! String
        self.NameButton.setTitle(String(name.prefix(1)), for: .normal)
        self.UserName.text = name
        self.Message.text = body["plain"]
        self.postDate.text = String(date.prefix(10))
        self.ReplieButton.setImage(UIImage(systemName: "bubble.left"), for:.normal)
        self.LikeButton.setImage(UIImage(systemName: "heart"), for:.normal)
      }
    
}
