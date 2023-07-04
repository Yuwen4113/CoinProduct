import Foundation

struct ExchangeRates: Codable {
    let data: DataClass
}

struct DataClass: Codable {
    let currency: String
    let rates: [String: String]
}
