//
//  MemberCellTableViewCell.swift
//  walking
//
//  Created by koyasu on 2022/01/12.
//

import UIKit

class MemberCell: UITableViewCell {

    @IBOutlet weak var initial: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(index:IndexPath,record:[teamMemberList]){
        
        if record.count >= index.row{
            initial.text = String(record[index.row].name.prefix(1))
            nameLabel.text = record[index.row].name
        }
    }
    
}
