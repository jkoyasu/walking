//
//  PersonRankCell.swift
//  walking
//
//  Created by Yousuke Hasegawa on 2022/01/13.
//

import UIKit

class PersonRankCell: UITableViewCell {

    
    @IBOutlet weak var crown: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(index:IndexPath,record:[PersonRanking]){
        
        var sortedRecord = record
        sortedRecord.sort { $0.rank < $1.rank }
        
        if sortedRecord.count >= index.row{
            self.rankLabel.text = String(sortedRecord[index.row].rank)
            self.nameLabel.text = sortedRecord[index.row].name
            self.stepLabel.text = String(sortedRecord[index.row].steps)
        }
        
        switch index.row{
        case 0:
            self.crown.image = UIImage(systemName: "crown")
            self.crown.tintColor = UIColor.systemYellow
            
        case 1:
            self.crown.image = UIImage(systemName: "crown")
            self.crown.tintColor = UIColor.systemGray
        
        case 2:
            self.crown.image = UIImage(systemName: "crown")
            self.crown.tintColor = UIColor.systemBrown
            
        default:
            self.crown.image = nil
            self.crown.tintColor = nil
        }
            
        
    }
    
}
