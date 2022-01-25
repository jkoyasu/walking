//
//  SelectedPostCell.swift
//  walking
//
//  Created by koyasu on 2022/01/24.
//

import UIKit

class SelectedPostCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var replieButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(message:[String:Any],name:String) {

        self.replieButton.setImage(UIImage(systemName: "bubble.left"), for:.normal)
        self.likeButton.setImage(UIImage(systemName: "heart"), for:.normal)
        let body = message["body"] as! [String:String]
        let date = message["created_at"] as! String
//        self.NameButton.setTitle(String(name.prefix(1)), for: .normal)
        self.userNameLabel.text = name
        self.userNameLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        self.messageLabel.text = body["plain"]
        self.postDateLabel.text = String(date.prefix(10))
      }
    
}
