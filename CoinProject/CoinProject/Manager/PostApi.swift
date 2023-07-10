//
//  PostApi.swift
//  CoinProject
//
//  Created by 0000 on 2023/7/5.
//

import Foundation
func createOrders(price: String, size: String, side: String, productId: String) {
    let orderPath = "/orders"
    let orderData: [String: Any] = [
        //拿socket資料
        "price": "\(price)",
        //買的數量 拿exchangeTextField.test 資料
        "size": "\(size)",
        // 買賣方式 buy or sell
        "side": "\(side)",
        // 幣種
        "product_id": "\(productId)",
        "time_in_force": "FOK"
    ]
    //    let timestamp = String(Date().timeIntervalSince1970)
    //    let message = timestamp + "POST" + orderPath + jsonString(from: orderData)
    //    let headers = getAuthHeaders(timestamp: timestamp, message: message)
    
    let apiUrl = "https://api-public.sandbox.pro.coinbase.com"
    guard let url = URL(string: apiUrl + orderPath) else {
        print("Invalid URL")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    //    request.allHTTPHeaderFields = headers
    let timestampSignature = CoinbaseService.shared.getTimestampSignature(requestPath: orderPath,
                                                                          method: "POST",
                                                                          body: jsonString(from: orderData))
    
    request.addValue(apiKey.accessKey, forHTTPHeaderField: "cb-access-key")
    request.addValue(apiKey.accessPassphrase, forHTTPHeaderField: "cb-access-passphrase")
    request.addValue(timestampSignature.0, forHTTPHeaderField: "cb-access-timestamp")
    request.addValue(timestampSignature.1, forHTTPHeaderField: "cb-access-sign")
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: orderData)
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            return
        }
        
        if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            print("Response: \(json)")
            // 在這裡處理回應數據
        }
    }
    
    task.resume()
}

func getAuthHeaders(timestamp: String, message: String) -> [String: String] {
    
    let headers: [String: String] = [
        "Timestamp": timestamp,
        "Message": message,
    ]
    return headers
}

func jsonString(from object: Any) -> String {
    if let data = try? JSONSerialization.data(withJSONObject: object, options: []),
       let jsonString = String(data: data, encoding: .utf8) {
        return jsonString
    }
    return ""
}

