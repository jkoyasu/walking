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
    var aadid:String?
    var date:String?
    var steps:Int
    var distance:Int
    var calorie:Int
    
    enum CodingKeys: String, CodingKey {
        case aadid
        case date
        case steps
        case distance
        case calorie
    }
}

struct WalkingResult:Codable{
    var errorMessage:String?
    var content:Data
    
    enum CodingKeys: String, CodingKey {
        case errorMessage = "error_message"
        case content
    }
}


