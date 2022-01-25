//
//  TeamRankCell.swift
//  walking
//
//  Created by Yousuke Hasegawa on 2022/01/14.
//

import UIKit

class TeamRankCell: UITableViewCell {

    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var crown: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(index:IndexPath){
        
        self.rankLabel.text = String(index.row+1)
        
        if index.row == 0{
            self.crown.image = UIImage(systemName: "crown")
            self.crown.tintColor = UIColor.systemYellow
        }
        
        if index.row == 1{
            self.crown.image = UIImage(systemName: "crown")
            self.crown.tintColor = UIColor.systemGray
        }
        
        if index.row == 2{
            self.crown.image = UIImage(systemName: "crown")
            self.crown.tintColor = UIColor.systemBrown
        }
        
    }
    
}
