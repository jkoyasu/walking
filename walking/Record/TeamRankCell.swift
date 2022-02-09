//
//  TeamRankCell.swift
//  walking
//
//  Created by Yousuke Hasegawa on 2022/01/14.
//

import UIKit

class TeamRankCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var crown: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(index:IndexPath,record:[TeamRanking]){
        
        let current = record.filter({ $0.rank == index.row+1 })
        
        if current.count > 0{
            self.rankLabel.text = String(current[0].rank)
            self.nameLabel.text = current[0].groupName
            self.stepLabel.text = String(current[0].avgSteps)
        }

        switch index.row{
        case 1:
            self.crown.image = UIImage(systemName: "crown")
            self.crown.tintColor = UIColor.systemYellow
            
        case 2:
            self.crown.image = UIImage(systemName: "crown")
            self.crown.tintColor = UIColor.systemGray
        
        case 3:
            self.crown.image = UIImage(systemName: "crown")
            self.crown.tintColor = UIColor.systemBrown
            
        default:
            self.crown.image = nil
            self.crown.tintColor = nil
        }
    }
}
