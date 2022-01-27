//
//  PersonRecord.swift
//  walking
//
//  Created by koyasu on 2022/01/26.
//

import Foundation

struct PersonRecord:Codable{
    let content:PersonContent
    let errorMessage:String?
    
    enum CodingKeys: String, CodingKey {
        case errorMessage = "error_message"
        case content
    }
}

struct PersonContent:Codable{
    let dailyRankingList:[PersonRankingList]
    let weeklyRankingList:[PersonRankingList]
    let monthlyRankingList:[PersonRankingList]
    
    enum CodingKeys: String, CodingKey {
        case dailyRankingList = "daily_ranking_list"
        case weeklyRankingList = "weekly_ranking_list"
        case monthlyRankingList = "monthly_ranking_list"
    }
}

struct PersonRankingList:Codable{
    let term:String?
    let ranking:[PersonRanking]
}

struct PersonRanking:Codable{
    let term:String?
    let rank:Int
    let mail:String?
    let name:String?
    let steps:Int
}
