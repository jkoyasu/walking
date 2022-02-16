//
//  EventRecord.swift
//  walking
//
//  Created by koyasu on 2022/01/26.
//

import Foundation

struct EventRecord:Codable{
    let errorMessage:String?
    let content:EventContent?
    
    enum CodingKeys: String, CodingKey {
        case errorMessage = "error_message"
        case content
    }
}

struct EventContent:Codable{
    let eventRanking:[EventRanking]

    
    enum CodingKeys: String, CodingKey {
        case eventRanking = "event_ranking"
    }
}

struct EventRanking:Codable{
    @StringForcible var term:String?
    let rank:Int
    let teamId:String?
    let groupName:String?
    let avgSteps:Int
    let totalCount:Int

    enum CodingKeys: String, CodingKey {
        case term
        case rank
        case teamId = "team_id"
        case groupName = "group_name"
        case avgSteps = "avg_steps"
        case totalCount = "total_count"
    }
}
