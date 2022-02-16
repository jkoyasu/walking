//
//  Event.swift
//  walking
//
//  Created by koyasu on 2022/02/15.
//

import Foundation

struct Events:Codable{
    let content:EventsContent?
    let errorMessage:String?
    
    enum CodingKeys: String, CodingKey {
        case errorMessage = "error_message"
        case content
    }
}


struct EventsContent:Codable{
    @StringForcible var createDate:String?
    let eventDetail:String
    let eventName:String
    let id:Int
    let validPeriodFrom:String
    let validPeriodTo:String
    enum CodingKeys: String, CodingKey {
        case createDate = "create_date"
        case eventDetail = "event_detail"
        case eventName = "event_name"
        case id
        case validPeriodFrom = "valid_period_from"
        case validPeriodTo = "valid_period_to"
    }
}
