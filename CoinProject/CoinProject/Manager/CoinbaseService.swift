import Foundation

final class CoinbaseService {
    
    static let shared = CoinbaseService()
    
    private init() {}
    
}

extension CoinbaseService {
    
    func fetchAccounts(completion: @escaping ([Account]) -> Void) {
        getApiResponse(api: .accounts,
                       authRequired: true, requestPath: "/accounts", httpMethod: .GET) { (accounts: [Account]) in
            completion(accounts)
        }
    }
    
    func fetchTradingPairs(completion: @escaping ([TradingPair]) -> Void) {
        getApiResponse(api: .allTradingPairs,
                       authRequired: false) { (tradingPairs: [TradingPair]) in
            completion(tradingPairs)
        }
    }
    
    func fetchUserProfile(completion: @escaping (Profile) -> Void) {
        getApiResponse(api: .profile,
                       authRequired: true, requestPath: "/profiles?active", httpMethod: .GET) { (profiles: [Profile]) in
            guard let profile = profiles.first else { return }
            completion(profile)
        }
    }
    
    func fetchProductStats(productID: String,
                           completion: @escaping (ProductStats) -> Void) {
        getApiResponse(api: .productStats(productID: productID),
                       authRequired: false) { (productStats: ProductStats) in
            completion(productStats)
        }
    }
    
    func fetchCurrencyDetail(currencyID: String, completion: @escaping (CurrencyInfo) -> Void) {
        getApiResponse(api: .currencyDetail(currencyID: currencyID),
                       authRequired: false) { (currencyInfo: CurrencyInfo) in
            completion(currencyInfo)
        }
    }
    // 1D => granularity = 3600
    // 1W => granularity = 3600
    // 1M => granularity = 86400
    // 3M => granularity = 86400
    func fetchProductCandles(productID: String, granularity: String, start: String, end: String, completion: @escaping ([[Double]]) -> Void) {
        getApiResponse(api: .allCandles(productID: productID, granularity: granularity, start: start, end: end), authRequired: false) { (candles: [[Double]]) in
            completion(candles)
        }
    }
    
    func fetchProductOrders(productID: String, status: String = "done", limit: Int = 5, completion: @escaping ([Order]) -> Void) {
        getApiResponse(api: .allOrders(limit: limit, status: status, productID: productID),
                       authRequired: true, requestPath: "/orders?limit=5&status=done&product_id=\(productID)", httpMethod: .GET) { (orders: [Order]) in
            completion(orders)
        }
    }
    
//    func fetchCurrencyRate(base: String, currency: String, completion: @escaping (Double) -> Void) {
//        getApiResponse(api: .prices(currencyPair: "\(base)-\(currency)"), authRequired: false) { (priceInfo: Price) in
//            let rate = Double(priceInfo.data.amount) ?? 0
//            completion(rate)
//        }
//    }
    func fetchCurrencyRate(completion: @escaping (Double) -> Void) {
            getApiResponse(api: .exchangeRate, authRequired: false) { (allRates: ExchangeRates) in
                let rate = Double(allRates.data.rates["TWD"] ?? "0") ?? 0
                completion(rate)
            }
        }

}
