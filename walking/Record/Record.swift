//
//  File.swift
//  walking
//
//  Created by koyasu on 2022/01/25.
//

import Foundation

struct myRecord: Codable {
    let error_message:String
    let content:Content
}

struct Content: Codable{
    let myDailyRanking:MyDailyRanking
    let myWeeklyRanking:MyWeeklyRanking
    let myMonthlyRanking:MyMonthlyRanking
    
    enum CodingKeys: String, CodingKey {
        case myDailyRanking = "my_daily_ranking"
        case myWeeklyRanking = "my_weekly_ranking"
        case myMonthlyRanking = "my_monthly_ranking"
    }
}

struct MyDailyRanking: Codable{
    let term:String
    let rank:Int
    let steps:Int
}

struct MyWeeklyRanking: Codable{
    let term:String
    let rank:Int
    let steps:Int
}

struct MyMonthlyRanking:Codable{
    let term:String
    let rank:Int
    let steps:Int
}
