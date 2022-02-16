import Foundation

struct Notification:Codable{
    let content:NotificationContent?
    let errorMessage:String?
    
    enum CodingKeys: String, CodingKey {
        case errorMessage = "error_message"
        case content
    }
}

struct NotificationContent:Codable{
    let noticeList:[NotificationList]
    enum CodingKeys: String, CodingKey {
        case noticeList = "notice_list"
    }
}

struct NotificationList:Codable{
    @StringForcible var createDate:String?
    let messages:String
    let title:String
    let id:Int
    let validPeriodFrom:String
    let validPeriodTo:String
    enum CodingKeys: String, CodingKey {
        case createDate = "create_date"
        case messages
        case title
        case id
        case validPeriodFrom = "valid_period_from"
        case validPeriodTo = "valid_period_to"
    }
}
