//
//  Homedata.swift
//  walking
//
//  Created by Yousuke Hasegawa on 2022/01/28.
//

import Foundation
import Metal

struct HomeData : Codable{
    let aaaid: String?
    let teamid: Int
}

struct HomeRecord : Codable{
    let content:HomeContent
    let errorMessage:String?
    
    enum CodingKeys: String, CodingKey {
        case errorMessage = "error_message"
        case content
    }
}

struct HomeContent : Codable{
    let personalData : PersonalData
    let teamData: TeamData
    
    enum CodingKeys: String, CodingKey {
        case personalData = "personal_data"
        case teamData = "team_data"
    }
}

struct PersonalData : Codable{
    let steps: Int
    let distance: Int
    let calorie: Int
    let ranking: Int
    let totalCount : Int
    
    enum CodingKeys: String, CodingKey {
        case steps
        case distance
        case calorie
        case ranking
        case totalCount = "total_count"
    }
}

struct TeamData : Codable{
    let steps_: Int
    let distance: Int
    let calorie: Int
    let ranking: Int
    let total_count : Int
}
