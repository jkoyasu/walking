//
//  Member.swift
//  walking
//
//  Created by koyasu on 2022/02/16.
//

import Foundation

struct Member:Codable{
    let errorMessage:String?
    let content:memberContent?
    
    enum CodingKeys: String, CodingKey {
        case errorMessage = "error_message"
        case content
    }
}

struct memberContent:Codable{
    let teamMemberList:[teamMemberList]
    enum CodingKeys: String, CodingKey {
    case teamMemberList = "team_member_list"
    }
}

struct teamMemberList:Codable{
    let mail:String
    let name:String
}
