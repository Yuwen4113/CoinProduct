import Foundation

struct Order: Codable {
    let size, productID: String?
    let side, type: String?
    let createdAt: String?
    let fillFees, filledSize, executedValue: String?
    let status: String?
    let fundingCurrency: String?
    let postOnly, settled: Bool?
    let profileID, doneAt, doneReason, marketType, price, timeInForce, id: String?
    
    enum CodingKeys: String, CodingKey {
        case id, price, size
        case productID = "product_id"
        case profileID = "profile_id"
        case side, type
        case timeInForce = "time_in_force"
        case postOnly = "post_only"
        case createdAt = "created_at"
        case doneAt = "done_at"
        case doneReason = "done_reason"
        case fillFees = "fill_fees"
        case filledSize = "filled_size"
        case executedValue = "executed_value"
        case marketType = "market_type"
        case status, settled
        case fundingCurrency = "funding_currency"
    }
}
