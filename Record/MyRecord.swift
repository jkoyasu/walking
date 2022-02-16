//
//  File.swift
//  walking
//
//  Created by koyasu on 2022/01/25.
//

import Foundation

struct myRecord: Codable {
    let errorMessage:String?
    let content:myContent?
    
    enum CodingKeys: String, CodingKey {
        case errorMessage = "error_message"
        case content
    }
}

struct myContent: Codable{
    let myDailyRanking:[MyRanking]
    let myWeeklyRanking:[MyRanking]
    let myMonthlyRanking:[MyRanking]
    
    enum CodingKeys: String, CodingKey {
        case myDailyRanking = "my_daily_ranking"
        case myWeeklyRanking = "my_weekly_ranking"
        case myMonthlyRanking = "my_monthly_ranking"
    }
}

struct MyRanking: Codable{
    let term:String
    let rank:Int
    let steps:Int
}
