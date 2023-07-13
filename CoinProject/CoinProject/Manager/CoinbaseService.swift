import Foundation
import Lottie

final class CoinbaseService {
    
    static let shared = CoinbaseService()
    
    private init() {}
    
}

extension CoinbaseService {
    
    func fetchAccounts(completion: @escaping ([Account]) -> Void, errorHandle: @escaping (() -> Void) = {}) {
        getApiResponse(api: .accounts,
                       authRequired: true, requestPath: "/accounts", httpMethod: .GET) { (accounts: [Account]) in
            completion(accounts)
        }errorHandle: {
            errorHandle()
        }
    }
    
    func fetchTradingPairs(completion: @escaping ([TradingPair]) -> Void,
                           errorHandle: @escaping (() -> Void) = {}) {
        getApiResponse(api: .allTradingPairs,
                       authRequired: false) { (tradingPairs: [TradingPair]) in
            completion(tradingPairs)
        }errorHandle: {
            errorHandle()
        }
    }
    
    func fetchUserProfile(completion: @escaping (Profile) -> Void,
                          errorHandle: @escaping (() -> Void) = {}) {
        getApiResponse(api: .profile,
                       authRequired: true, requestPath: "/profiles?active", httpMethod: .GET) { (profiles: [Profile]) in
            guard let profile = profiles.first else { return }
            completion(profile)
        }errorHandle: {
            errorHandle()
        }
    }
    
    func fetchProductStats(productID: String,
                           completion: @escaping (ProductStats) -> Void,
                           errorHandle: @escaping (() -> Void) = {}) {
        getApiResponse(api: .productStats(productID: productID),
                       authRequired: false) { (productStats: ProductStats) in
            completion(productStats)
        }errorHandle: {
            errorHandle()
        }
    }
    
    func fetchCurrencyDetail(currencyID: String, completion: @escaping (CurrencyInfo) -> Void,
                             errorHandle: @escaping (() -> Void) = {}) {
        getApiResponse(api: .currencyDetail(currencyID: currencyID),
                       authRequired: false) { (currencyInfo: CurrencyInfo) in
            completion(currencyInfo)
        }errorHandle: {
            errorHandle()
        }
    }
    // 1D => granularity = 3600
    // 1W => granularity = 3600
    // 1M => granularity = 86400
    // 3M => granularity = 86400
    func fetchProductCandles(productID: String, granularity: String, start: String, end: String, completion: @escaping ([[Double]]) -> Void,
                             errorHandle: @escaping (() -> Void) = {}) {
        getApiResponse(api: .allCandles(productID: productID, granularity: granularity, start: start, end: end), authRequired: false) { (candles: [[Double]]) in
            completion(candles)
        }errorHandle: {
            errorHandle()
        }
    }
    
    func fetchProductOrders(productID: String, status: String = "done", limit: Int = 5, completion: @escaping ([Order]) -> Void,
                            errorHandle: @escaping (() -> Void) = {}) {
        getApiResponse(api: .allOrders(limit: limit, status: status, productID: productID),
                       authRequired: true, requestPath: "/orders?limit=5&status=done&product_id=\(productID)", httpMethod: .GET) { (orders: [Order]) in
            completion(orders)
        }errorHandle: {
            errorHandle()
        }
    }
    func fetchAllOrders(
        productID: String,
        status: String = "done",
        limit: Int = 100,
        completion: @escaping ([Order]) -> Void,
        errorHandle: @escaping (() -> Void) = {}) {
            getApiResponse(api: .allOrders(limit: limit, status: status, productID: productID),
                           authRequired: true, requestPath: "/orders?limit=100&status=done&product_id=\(productID)", httpMethod: .GET) { (orders: [Order]) in
                completion(orders)
            }errorHandle: {
                errorHandle()
            }
        }
    
    
    //    func fetchCurrencyRate(base: String, currency: String, completion: @escaping (Double) -> Void) {
    //        getApiResponse(api: .prices(currencyPair: "\(base)-\(currency)"), authRequired: false) { (priceInfo: Price) in
    //            let rate = Double(priceInfo.data.amount) ?? 0
    //            completion(rate)
    //        }
    //    }
    func fetchCurrencyRate(currency: String, completion: @escaping (Double) -> Void,
                           errorHandle: @escaping (() -> Void) = {}) {
        getApiResponse(api: .exchangeRateInCurrency(currency: currency), authRequired: false) { (allRates: ExchangeRates) in
            let rate = Double(allRates.data.rates["TWD"] ?? "0") ?? 0
            completion(rate)
        }errorHandle: {
            errorHandle()
        }
    }
    
    func fetchCurrencyRate(completion: @escaping (Double) -> Void,
                           errorHandle: @escaping (() -> Void) = {}) {
        getApiResponse(api: .exchangeRate, authRequired: false) { (allRates: ExchangeRates) in
            let rate = Double(allRates.data.rates["TWD"] ?? "0") ?? 0
            completion(rate)
        }errorHandle: {
            errorHandle()
        }
    }
    
    func createOrders(size: String, side: String, productId: String, completion: @escaping (String) -> Void,
                      errorHandle: @escaping (() -> Void) = {}) {
        //        let body = "{\"price\": \"\(price)\", \"size\": \"\(size)\", \"side\": \"\(side)\", \"product_id\": \"\(productId)\", \"time_in_force\": \"FOK\"}"
        
        let body = "{\"type\": \"market\", \"size\": \"\(size)\", \"side\": \"\(side)\", \"product_id\": \"\(productId)\", \"time_in_force\": \"FOK\"}"
        
        getApiResponse(
            api: .createOrders,
            authRequired: true,
            requestPath: "/orders",
            httpMethod: .POST,
            body: body,
            parameters: body
        ) { (order: Order) in
            print(order)
            completion(order.id ?? "0")
        }errorHandle: {
            errorHandle()
        }
    }
    
    func getOneOrder(id: String, completion: @escaping (Order) -> Void,
                     errorHandle: @escaping (() -> Void) = {}) {
        getApiResponse(api: .getOneOrder(id: id), authRequired: true, requestPath: "/orders/\(id)") { (order: Order) in
            completion(order)
        }errorHandle: {
            errorHandle()
        }
    }
    
    func callAnimation(animationView: LottieAnimationView, fileName: String) {
        if let animation = LottieAnimation.named(fileName) {
            animationView.animation = animation
        } else {
            DotLottieFile.named(fileName) { [animationView] result in
                guard case Result.success(let lottie) = result else { return }
                animationView.loadAnimation(from: lottie)
            }
        }
    }
    
    
}

extension Double {
    func formattedWithSeparator() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.groupingSeparator = ","
        return numberFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    
    
    func formattedWith8Separator() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 8
        numberFormatter.groupingSeparator = ","
        return numberFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}



