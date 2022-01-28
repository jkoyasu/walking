//
//  walkingData.swift
//  walking
//
//  Created by Yousuke Hasegawa on 2022/01/27.
//

import Foundation
import UIKit


struct WalkingData:Codable{
    var walkingDataLists:[WalkingDataList]
}

struct WalkingDataList:Codable{
    var aaaid:String?
    var date:String?
    var steps:Int
    var distance:Int
    var calorie:Int
    
    enum CodingKeys: String, CodingKey {
        case aaaid
        case date
        case steps
        case distance
        case calorie
    }
}


