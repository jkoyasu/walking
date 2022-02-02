//
//  Homedata.swift
//  walking
//
//  Created by Yousuke Hasegawa on 2022/01/28.
//

import Foundation
import Metal

//Inputデータ
struct HomeData : Codable{
    let aadid: String
    let teamid: Int
}

//Outputデータ
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

//個人のデータ
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

//チームのデータ
struct TeamData : Codable{
    let avgSteps: Int
    let ranking: Int
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case avgSteps = "avg_steps"
        case ranking
        case totalCount = "total_count"
    }
}
