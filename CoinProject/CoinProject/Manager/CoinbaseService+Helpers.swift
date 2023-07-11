
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import CryptoKit
let apiKey = ApiKeys()
extension CoinbaseService {
    func getTimestampSignature(requestPath: String,
                               method: String,
                               body: String) -> (String, String) {
        let date = Date().timeIntervalSince1970
        let cbAccessTimestamp = String(date)
        let secret = apiKey.apiKey
        let requestPath = requestPath
        let body = body
        let method = method
        let message = "\(cbAccessTimestamp)\(method)\(requestPath)\(body)"

        guard let keyData = Data(base64Encoded: secret) else {
            fatalError("Failed to decode secret as base64")
        }

        let hmac = HMAC<SHA256>.authenticationCode(for: Data(message.utf8), using: SymmetricKey(data: keyData))

        let cbAccessSign = hmac.withUnsafeBytes { macBytes -> String in
            let data = Data(macBytes)
            return data.base64EncodedString()
        }
        return (cbAccessTimestamp, cbAccessSign)
    }
    
    func getApiResponse<T: Codable>(api: CoinbaseApi,
                                    authRequired: Bool,
                                    requestPath: String = "",
                                    httpMethod: HttpMethod = .GET,
                                    body: String = "",
                                    parameters: String? = nil,
                                    completion: @escaping (T) -> Void,
                                    errorHandle: @escaping (() -> Void) = {}) {
        
        guard let url = URL(string: api.path) else {
            print("Invalid URL")
            return
        }
        // print("URL: \(url)")
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        if authRequired {
            let timestampSignature = getTimestampSignature(requestPath: requestPath,
                                                           method: httpMethod.rawValue,
                                                           body: body)
            
            request.addValue(apiKey.accessKey, forHTTPHeaderField: "cb-access-key")
            request.addValue(apiKey.accessPassphrase, forHTTPHeaderField: "cb-access-passphrase")
            request.addValue(timestampSignature.0, forHTTPHeaderField: "cb-access-timestamp")
            request.addValue(timestampSignature.1, forHTTPHeaderField: "cb-access-sign")
        }
        request.httpMethod = httpMethod.rawValue
        
        if let parameters = parameters, httpMethod == .POST {
            let postData = parameters.data(using: .utf8)
            request.httpBody = postData
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(T.self, from: data)
                // print("Response: \(response)")
//                print("-------------")
//                print(String(data: data, encoding: String.Encoding.utf8))
//                print("-------------")

                completion(response)
            } catch {
                print("-------------")
                print(String(data: data, encoding: String.Encoding.utf8))
                print("💌💌💌💌💌💌💌💌💌Error decoding data: \(error)")
                print("-------------")
                errorHandle()
            }
        }
        
        task.resume()
    }        
}
