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
    
    let attrs1 : [NSAttributedString.Key : Any] = [
        .font : UIFont.boldSystemFont(ofSize: 20.0)
        ]
    let attrs2 : [NSAttributedString.Key : Any] = [
        .font : UIFont.boldSystemFont(ofSize: 25.0)
        ]
    let attrs3 : [NSAttributedString.Key : Any] = [
        .font : UIFont.boldSystemFont(ofSize: 20.0)
        ]
    let attrs4 : [NSAttributedString.Key : Any] = [
        .font : UIFont.boldSystemFont(ofSize: 15.0)
        ]
    
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
            
            var firstWord = sortedRecord[index.row].name!
            var secondWord = "さん"
            
            var attributedText = NSMutableAttributedString(string:firstWord, attributes: attrs1)
            attributedText.append(NSAttributedString(string: secondWord, attributes: attrs2))

            self.nameLabel.attributedText = attributedText
            
            firstWord = String(sortedRecord[0].steps)
            secondWord = "歩"
            attributedText = NSMutableAttributedString(string:firstWord, attributes: attrs3)
            attributedText.append(NSAttributedString(string: secondWord, attributes: attrs4))
            
            self.stepLabel.attributedText = attributedText
        }
        
        switch sortedRecord[index.row].rank{
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
