

import Foundation
import Starscream

class WebsocketService {


//    func doCalcDate() {
//        let currentDate = Date()
//        let calendar = Calendar.current
//
//        var dateComponents = DateComponents()
//        dateComponents.month = -3
//
//        let nextDate = calendar.date(byAdding: dateComponents, to: currentDate)
//        nextDate?.timeIntervalSince1970
//    }

    static let shared = WebsocketService()

    private init() {}

    var socket: WebSocket!
    var realTimeData: (([String]) -> ())?
    var string: String = ""
    
    func connect(string: String) {
        var request = URLRequest(url: URL(string: "wss://ws-feed.exchange.coinbase.com")!)
        
        self.string = string
        
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }

    func send(string: String) {
        socket.write(string: string)
    }

    func disconnect() {
        socket.disconnect()
        //socket.delegate = nil
    }
}

// MARK: Websocket Delegate

extension WebsocketService: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            // subscribe to channel
            let subscriptionMessage = """
                {
                    "type": "subscribe",
                    "product_ids": [
                        "\(self.string)"
                    ],
                    "channels": ["ticker_batch"]
                }
            """
            socket.write(string: subscriptionMessage)

            print("websocket is connected: \(headers)")

        case .disconnected(let reason, let code):
            // Unsubscribe from the ticker batch channel
            let unsubscribeMessage = """
                {
                    "type": "unsubscribe",
                    "product_ids": [
                        "\(self.string)"
                    ],
                    "channels": ["ticker_batch"]
                }
            """
            socket.write(string: unsubscribeMessage)

            print("WebSocket is disconnected: \(reason) with code: \(code)")

        case .text(let string):
            if let data = string.data(using: .utf8) {
                    do {
                        print(string)
                        let decoder = JSONDecoder()
                        let tickerMessage = try decoder.decode(TickerMessage.self, from: data)
                        let realTimeBid = tickerMessage.bestBid
                        let realTimeAsk = tickerMessage.bestAsk
                        self.realTimeData!([realTimeBid, realTimeAsk])
                        print("Received price: \(tickerMessage)")
                    } catch {
                        print("Failed to decode ticker message: \(error)")
                    }
                }
            // Process received data
        case .binary(let data):
            print("Received data: \(data.count)")
            // Process received data
        case .ping:
            break
        case .pong:
            break
        case .viabilityChanged:
            break
        case .reconnectSuggested:
            break
        case .cancelled:
            break
        case .error(let error):
            handleError(error)
        }
    }

    func handleError(_ error: Error?) {
        if let error = error as? WSError {
            print("Websocket encountered an error: \(error.message)")
        } else if let error = error {
            print("Websocket encountered an error: \(error.localizedDescription)")
        } else {
            print("Websocket encountered an error")
        }
    }
}
