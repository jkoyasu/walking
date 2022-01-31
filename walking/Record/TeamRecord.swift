//
//  TeamRecord.swift
//  walking
//
//  Created by koyasu on 2022/01/26.
//

import Foundation

struct TeamRecord{
    let errorMessage:String?
    let content:TeamContent?
    
    enum CodingKeys: String, CodingKey {
        case errorMessage = "error_message"
        case content
    }
}

struct TeamContent:Codable{
    let dailyRankingList:[TeamRankingList]
    let weeklyRankingList:[TeamRankingList]
    let monthlyRankingList:[TeamRankingList]
    
    enum CodingKeys: String, CodingKey {
        case dailyRankingList = "daily_ranking_list"
        case weeklyRankingList = "weekly_ranking_list"
        case monthlyRankingList = "monthly_ranking_list"
    }
}

struct TeamRankingList:Codable{
    let term:String
    let ranking:TeamRanking
}

struct TeamRanking:Codable{
    let term:String
    let rank:Int
    let teamId:String?
    let groupName:String?
    let avgSteps:Int
    
    enum CodingKeys: String, CodingKey {
        case term
        case rank
        case teamId = "team_id"
        case groupName = "group_name"
        case avgSteps = "avg_steps"
    }
}
