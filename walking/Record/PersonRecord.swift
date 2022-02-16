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
    @StringForcible var term:String?
    let ranking:[PersonRanking]
}

struct PersonRanking:Codable{
    @StringForcible var term:String?
    let rank:Int
    let mail:String?
    let name:String?
    let steps:Int
}

@propertyWrapper
struct StringForcible: Codable {
    
    var wrappedValue: String?
    
    enum CodingKeys: CodingKey {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            wrappedValue = string
        } else if let integer = try? container.decode(Int.self) {
            wrappedValue = "\(integer)"
        } else if let double = try? container.decode(Double.self) {
            wrappedValue = "\(double)"
        } else if container.decodeNil() {
            wrappedValue = nil
        }
        else {
            throw DecodingError.typeMismatch(String.self, .init(codingPath: container.codingPath, debugDescription: "Could not decode incoming value to String. It is not a type of String, Int or Double."))
        }
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
    init() {
        self.wrappedValue = nil
    }
}
