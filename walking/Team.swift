//
//  Team.swift
//  walking
//
//  Created by koyasu on 2022/02/02.
//

import Foundation

struct Team:Codable{
    let errorMessage:String?
    let content:Content
    enum CodingKeys: String, CodingKey {
        case errorMessage = "error_message"
        case content
    }
}

struct Content:Codable{
    let teamId:Int
    let groupName:String
    let abbreviated:String
    enum CodingKeys: String, CodingKey {
        case teamId = "team_id"
        case groupName = "group_name"
        case abbreviated
    }
}
