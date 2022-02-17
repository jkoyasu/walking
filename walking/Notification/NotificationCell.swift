//
//  NotificationCell.swift
//  walking
//
//  Created by koyasu on 2022/01/12.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(index:IndexPath,record:[NotificationList]){
        
        var sortedRecord = record
        sortedRecord.sort { $0.createDate! < $1.createDate! }
        
        if sortedRecord.count >= index.row{
            messageLabel.text = sortedRecord[index.row].messages
            dateLabel.text = sortedRecord[index.row].createDate
        }
            
        
    }
}
