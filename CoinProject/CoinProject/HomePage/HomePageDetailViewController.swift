//
//  HomePageDetailViewController.swift
//  CoinProject
//
//  Created by 0000 on 2023/6/29.
//

import UIKit

class HomePageDetailViewController: UIViewController {
    var currencyPair: TradingPair?
    var currencyChineseName: String = ""
    var orders: [Order] = []
    var currencySellBid: Double = 0
    var currencySellPrice: Double = 0
    var oneDayCandleCalcArray: [Double] = []
    var oneWeekCandleCalcArray: [Double] = []
    var oneMonthCandleCalcArray: [Double] = []
    var threeMonthCandleCalcArray: [Double] = []
    var oneYearCandleCalcArray: [Double] = []
    var allCandleCalcArray: [Double] = []
    var oneDayCandleTimeArray: [TimeInterval] = []
    var oneWeekCandleTimeArray: [TimeInterval] = []
    var oneMonthCandleTimeArray: [TimeInterval] = []
    var threeMonthCandleTimeArray: [TimeInterval] = []
    var oneYearCandleTimeArray: [TimeInterval] = []
    var allCandleTimeArray: [TimeInterval] = []
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if currencyPair?.baseCurrency == "BCH" {
            coinNameLabel.text = "比特幣現金(\(currencyPair?.baseCurrency ?? ""))"
        }
        if currencyPair?.baseCurrency == "BTC" {
            coinNameLabel.text = "比特幣(\(currencyPair?.baseCurrency ?? ""))"
        }
        if currencyPair?.baseCurrency == "USDT" {
            coinNameLabel.text = "泰達幣(\(currencyPair?.baseCurrency ?? ""))"
        }
        if currencyPair?.baseCurrency == "LINK" {
            coinNameLabel.text = "LINK幣(\(currencyPair?.baseCurrency ?? ""))"
        }
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        fetchProductOrders(productID: currencyPair?.id ?? "") { [weak self] orders in
            self?.orders = orders
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        WebsocketService.shared.realTimeData = { array in
            self.currencySellBid = (Double(array[0]) ?? 0)
            self.currencySellPrice = (Double(array[1]) ?? 0)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        WebsocketService.shared.connect(string: "\(currencyPair?.baseCurrency ?? "")-USD" )
        
        let group = DispatchGroup()
        let calendar = Calendar.current

        let fetchData: (String, String, String, String, @escaping ([[Double]]) -> Void) -> Void = { productID, granularity, start, end, completion in
            group.enter()
            self.fetchProductCandles(productID: productID, granularity: granularity, start: start, end: end) { candles in
                completion(candles)
                group.leave()
            }
        }

        fetchData(currencyPair?.id ?? "", "3600", "\(Int(calendar.date(byAdding: .day, value: -1, to: Date())!.timeIntervalSince1970))", "\(Int(Date().timeIntervalSince1970))") { [weak self] candles in
            self?.oneDayCandleCalcArray = candles.map { ($0[1] + $0[2]) / 2 }.reversed()
            self?.oneDayCandleTimeArray = candles.map { $0[0] }.reversed()
        }

        fetchData(currencyPair?.id ?? "", "3600", "\(Int(calendar.date(byAdding: .day, value: -7, to: Date())!.timeIntervalSince1970))", "\(Int(Date().timeIntervalSince1970))") { [weak self] candles in
            self?.oneWeekCandleCalcArray = candles.map { ($0[1] + $0[2]) / 2 }.reversed()
            self?.oneWeekCandleTimeArray = candles.map { $0[0] }.reversed()
        }

        fetchData(currencyPair?.id ?? "", "86400", "\(Int(calendar.date(byAdding: .month, value: -1, to: Date())!.timeIntervalSince1970))", "\(Int(Date().timeIntervalSince1970))") { [weak self] candles in
            self?.oneMonthCandleCalcArray = candles.map { ($0[1] + $0[2]) / 2 }.reversed()
            self?.oneMonthCandleTimeArray = candles.map { $0[0] }.reversed()
        }

        fetchData(currencyPair?.id ?? "", "86400", "\(Int(calendar.date(byAdding: .month, value: -3, to: Date())!.timeIntervalSince1970))", "\(Int(Date().timeIntervalSince1970))") { [weak self] candles in
            self?.threeMonthCandleCalcArray = candles.map { ($0[1] + $0[2]) / 2 }.reversed()
            self?.threeMonthCandleTimeArray = candles.map { $0[0] }.reversed()
        }

        fetchData(currencyPair?.id ?? "", "86400", "\(Int(calendar.date(byAdding: .day, value: -300, to: Date())!.timeIntervalSince1970))", "\(Int(Date().timeIntervalSince1970))") { [weak self] candles in
            self?.oneYearCandleCalcArray = candles.map { ($0[1] + $0[2]) / 2 }.reversed()
            self?.oneYearCandleTimeArray = candles.map { $0[0] }.reversed()
            
            let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: Date())!
            fetchData(self?.currencyPair?.id ?? "", "86400", "\(Int(oneYearAgo.timeIntervalSince1970))", "\(Int(calendar.date(byAdding: .day, value: -300, to: Date())!.timeIntervalSince1970))") { [weak self] candles in
                self?.oneYearCandleCalcArray.append(contentsOf: candles.map { ($0[1] + $0[2]) / 2 }.reversed())
                self?.oneYearCandleTimeArray.append(contentsOf: candles.map { $0[0] }.reversed())
            }
        }

        group.enter()
        var date = Date()
        var array = [[Double]]()
        var candlesTemp = [[Double]]()
        var index: Int = 0

        let semaphore = DispatchSemaphore(value: 0)
        repeat {
            let threeHundredDaysAgo = calendar.date(byAdding: .day, value: -300, to: date)!

            fetchData(currencyPair?.id ?? "", "86400", "\(Int(threeHundredDaysAgo.timeIntervalSince1970))", "\(Int(date.timeIntervalSince1970))") { candles in
                candlesTemp = candles
                array += candlesTemp
                date = threeHundredDaysAgo
                index += 1
                semaphore.signal()
            }
            
            semaphore.wait()

        } while(candlesTemp.count != 0)

        self.allCandleCalcArray = array.map { ($0[1] + $0[2]) / 2 }.reversed()
        self.allCandleTimeArray = array.map { $0[0] }.reversed()
        group.leave()

        group.notify(queue: .main) {
            self.tableView.reloadData()
        }

        
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        WebsocketService.shared.disconnect()
    }
    @IBAction func didBackButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func fetchProductOrders(productID: String, status: String = "done", limit: Int = 5, completion: @escaping ([Order]) -> Void) {
        CoinbaseService.shared.getApiResponse(api: .allOrders(limit: limit, status: status, productID: productID),
                                              authRequired: true, requestPath: "/orders?limit=5&status=done&product_id=\(productID)", httpMethod: .GET) { (orders: [Order]) in
            completion(orders)
        }
    }
    
    // 1D => granularity = 3600
    // 1W => granularity = 3600
    // 1M => granularity = 86400
    // 3M => granularity = 86400
    func fetchProductCandles(productID: String, granularity: String, start: String, end: String, completion: @escaping ([[Double]]) -> Void) {
        CoinbaseService.shared.getApiResponse(api: .allCandles(productID: productID, granularity: granularity, start: start, end: end), authRequired: false) { (candles: [[Double]]) in
            completion(candles)
        }
    }
    
}

extension HomePageDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChartViewTableViewCell", for: indexPath) as! ChartViewTableViewCell
            cell.realTimeByPriceLabel.text = String(currencySellBid)
            cell.realTimeSellPriceLabel.text = String(currencySellPrice)
            cell.dayArray = oneDayCandleCalcArray
            cell.oneWeekArray = oneWeekCandleCalcArray
            cell.oneMonthArray = oneMonthCandleCalcArray
            cell.threeMonthArray = threeMonthCandleCalcArray
            cell.oneYearArray = oneYearCandleCalcArray
            cell.allArray = allCandleCalcArray
            cell.oneDayCandleTimeArray = oneDayCandleTimeArray
            cell.oneWeekCandleTimeArray = oneWeekCandleTimeArray
            cell.oneMonthCandleTimeArray = oneMonthCandleTimeArray
            cell.threeMonthCandleTimeArray = threeMonthCandleTimeArray
            cell.oneYearCandleTimeArray = oneYearCandleTimeArray
            cell.allCandleTimeArray = allCandleTimeArray
            return cell
        case 1...orders.count:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordTableViewCell", for: indexPath) as! RecordTableViewCell
            cell.buyCoinTypeLabel.text = "購入 \(currencyPair!.baseCurrency)"
            
            if orders[indexPath.row - 1].status == "done" {
                cell.orderStatusLabel.text = "成功"
            } else {
                cell.orderStatusLabel.text = "失敗"
            }
            
            cell.buyCoinPriceLabel.text = "USD$" + String(format: "%.2f", Double(orders[indexPath.row - 1].price) ?? 0)
            let dateString = orders[indexPath.row - 1].doneAt
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
            
            if let date = dateFormatter.date(from: dateString) {
                let taiwanTimeZone = TimeZone(abbreviation: "GMT+8")
                dateFormatter.timeZone = taiwanTimeZone
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                let taiwanDate = dateFormatter.string(from: date)
                cell.timeLabel.text = taiwanDate
            } else {
                print("日期解析失敗")
            }
            return cell
        default:
            fatalError("Unexpected row in table view")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
