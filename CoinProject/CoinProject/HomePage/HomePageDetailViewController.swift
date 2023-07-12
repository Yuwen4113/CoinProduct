//
//  HomePageDetailViewController.swift
//  CoinProject
//
//  Created by 0000 on 2023/6/29.
//

import UIKit
import MJRefresh
import Lottie
class HomePageDetailViewController: UIViewController, UIViewControllerTransitioningDelegate {
    var isSell: Bool = true
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
    var oneDayCandleLogCalcArray: [Double] = []
    var oneWeekCandleLogCalcArray: [Double] = []
    var oneMonthCandleLogCalcArray: [Double] = []
    var threeMonthCandleLogCalcArray: [Double] = []
    var oneYearCandleLogCalcArray: [Double] = []
    var allCandleLogCalcArray: [Double] = []
    
    
    var realTimeByPriceLabel: UILabel?
    var currencySellPriceLabel: UILabel?
    
    
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buyButton.layer.cornerRadius = 3
        sellButton.layer.cornerRadius = 3
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
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(headerRefresh))
        tableView.mj_header = header
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
        buyButton.isHidden = true
        sellButton.isHidden = true
        callAnimation(animationView: animationView, fileName: "charts")
        animationView.loopMode = .autoReverse
        animationView.play()
        animationView.isHidden = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        WebsocketService.shared.realTimeData = { array in
            self.currencySellBid = (Double(array[1]) ?? 0)
            self.currencySellPrice = (Double(array[0]) ?? 0)
            DispatchQueue.main.async {
                self.realTimeByPriceLabel?.text = self.currencySellBid.formattedWithSeparator()
                self.currencySellPriceLabel?.text = self.currencySellPrice.formattedWithSeparator()
            }
        }
        WebsocketService.shared.connect(string: "\(currencyPair?.baseCurrency ?? "")-USD" )
        
        let group = DispatchGroup()
        let calendar = Calendar.current
        
        group.enter()
        fetchProductOrders(productID: currencyPair?.id ?? "") { [weak self] orders in
            self?.orders = orders
            group.leave()
        }errorHandle: {
            group.leave()
        }
        
        let fetchData: (String, String, String, String, @escaping ([[Double]]) -> Void) -> Void = { productID, granularity, start, end, completion in
            group.enter()
            self.fetchProductCandles(productID: productID, granularity: granularity, start: start, end: end) { candles in
                completion(candles)
                group.leave()
            }errorHandle: {
                group.leave()
            }
        }
        DispatchQueue.global().async { [self] in
            fetchData(self.currencyPair?.id ?? "", "3600", "\(Int(calendar.date(byAdding: .day, value: -1, to: Date())!.timeIntervalSince1970))", "\(Int(Date().timeIntervalSince1970))") { [weak self] candles in
                self?.oneDayCandleCalcArray = candles.map { ($0[1] + $0[2]) / 2 }.reversed()
                self?.oneDayCandleTimeArray = candles.map { $0[0] }.reversed()
                self?.oneDayCandleLogCalcArray = self?.oneDayCandleCalcArray.map { log2($0 + 2) } ?? []
            }
            
            
            fetchData(currencyPair?.id ?? "", "3600", "\(Int(calendar.date(byAdding: .day, value: -7, to: Date())!.timeIntervalSince1970))", "\(Int(Date().timeIntervalSince1970))") { [weak self] candles in
                self?.oneWeekCandleCalcArray = candles.map { ($0[1] + $0[2]) / 2 }.reversed()
                self?.oneWeekCandleTimeArray = candles.map { $0[0] }.reversed()
                self?.oneWeekCandleLogCalcArray = self?.oneWeekCandleCalcArray.map { log2($0 + 2) } ?? []
                
            }
            
            fetchData(currencyPair?.id ?? "", "86400", "\(Int(calendar.date(byAdding: .month, value: -1, to: Date())!.timeIntervalSince1970))", "\(Int(Date().timeIntervalSince1970))") { [weak self] candles in
                self?.oneMonthCandleCalcArray = candles.map { ($0[1] + $0[2]) / 2 }.reversed()
                self?.oneMonthCandleTimeArray = candles.map { $0[0] }.reversed()
                self?.oneMonthCandleLogCalcArray = self?.oneMonthCandleCalcArray.map { log2($0 + 2) } ?? []
            }
            
            fetchData(currencyPair?.id ?? "", "86400", "\(Int(calendar.date(byAdding: .month, value: -3, to: Date())!.timeIntervalSince1970))", "\(Int(Date().timeIntervalSince1970))") { [weak self] candles in
                self?.threeMonthCandleCalcArray = candles.map { ($0[1] + $0[2]) / 2 }.reversed()
                self?.threeMonthCandleTimeArray = candles.map { $0[0] }.reversed()
                self?.threeMonthCandleLogCalcArray = self?.threeMonthCandleCalcArray.map { log2($0 + 2) } ?? []
            }
            
            fetchData(currencyPair?.id ?? "", "86400", "\(Int(calendar.date(byAdding: .day, value: -300, to: Date())!.timeIntervalSince1970))", "\(Int(Date().timeIntervalSince1970))") { [weak self] candles in
                self?.oneYearCandleCalcArray = candles.map { ($0[1] + $0[2]) / 2 }
                self?.oneYearCandleTimeArray = candles.map { $0[0] }
                
                let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: Date())!
                fetchData(self?.currencyPair?.id ?? "", "86400", "\(Int(oneYearAgo.timeIntervalSince1970))", "\(Int(calendar.date(byAdding: .day, value: -301, to: Date())!.timeIntervalSince1970))") { [weak self] candles in
                    self?.oneYearCandleCalcArray.append(contentsOf: candles.map { ($0[1] + $0[2]) / 2 })
                    self?.oneYearCandleTimeArray.append(contentsOf: candles.map { $0[0] })
                    
                    self?.oneYearCandleCalcArray.reverse()
                    self?.oneYearCandleTimeArray.reverse()
                    self?.oneYearCandleLogCalcArray = self?.oneYearCandleCalcArray.map { log2($0 + 2) } ?? []
                }
            }
            
            let queue = DispatchQueue(label: "apiQueue", qos: .userInteractive, attributes: .concurrent)
            let interval: TimeInterval = 0
            
            var date = Date()
            var array = [[Double]]()
            var candlesTemp = [[Double]]()
            var index: Int = 0
            
            let semaphore = DispatchSemaphore(value: 0)
            repeat {
                let threeHundredDaysAgo = calendar.date(byAdding: .day, value: -300, to: date)!
                queue.asyncAfter(deadline: .now() + interval * Double(index)) {
//                    fetchData(self.currencyPair?.id ?? "", "86400", "\(Int(threeHundredDaysAgo.timeIntervalSince1970))", "\(Int(date.timeIntervalSince1970))") { candles in
                    CoinbaseService.shared.fetchProductCandles(productID: self.currencyPair?.id ?? "", granularity: "86400", start: "\(Int(threeHundredDaysAgo.timeIntervalSince1970))", end: "\(Int(date.timeIntervalSince1970))") { candles in
                        candlesTemp = candles
                        array += candlesTemp
                        date = threeHundredDaysAgo
                        index += 1
                        semaphore.signal()
                    } errorHandle: {
                        semaphore.signal()
                    }
                }
                
                semaphore.wait()
                
            } while(candlesTemp.count != 0)
            
            self.allCandleCalcArray = array.map { ($0[1] + $0[2]) / 2 }.reversed()
            self.allCandleTimeArray = array.map { $0[0] }.reversed()
            self.allCandleLogCalcArray = self.allCandleCalcArray.map { log2($0 + 2) } ?? []

            
            group.notify(queue: DispatchQueue.main) {
                DispatchQueue.main.async {
//                    print(allCandleCalcArray.count)
                    self.tableView.dataSource = self
                    self.tableView.delegate = self
                    self.animationView.stop()
                    self.animationView.isHidden = true
                    self.tableView.reloadData()
                    buyButton.isHidden = false
                    sellButton.isHidden = false
                    
                }
            }
        }
        
    }
    
    @objc func headerRefresh() {
        self.tableView.reloadData()
        self.tableView.mj_header?.endRefreshing()
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
        WebsocketService.shared.disconnect()
    }
    
    @IBAction func didBuyButtonTapped(_ sender: Any) {
        isSell = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let targetViewController = storyboard.instantiateViewController(withIdentifier: "BuyViewController") as? BuyViewController {
            targetViewController.currencyPair = self.currencyPair
            targetViewController.isSell = self.isSell
            
            let nv = UINavigationController(rootViewController: targetViewController)
            
            nv.modalPresentationStyle = .custom
            nv.transitioningDelegate = self
            nv.navigationBar.isHidden = true
            
            present(nv, animated: true, completion: nil)
        }
    }
    
    @IBAction func didSellButtonTapped(_ sender: Any) {
        isSell = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let targetViewController = storyboard.instantiateViewController(withIdentifier: "BuyViewController") as? BuyViewController {
            targetViewController.currencyPair = self.currencyPair
            targetViewController.isSell = self.isSell
            
            let nv = UINavigationController(rootViewController: targetViewController)
            
            nv.modalPresentationStyle = .custom
            nv.transitioningDelegate = self
            nv.navigationBar.isHidden = true
            
            present(nv, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func didBackButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func fetchProductOrders(productID: String, status: String = "done", limit: Int = 5, completion: @escaping ([Order]) -> Void,
                            errorHandle: @escaping (() -> Void) = {}) {
        CoinbaseService.shared.getApiResponse(api: .allOrders(limit: limit, status: status, productID: productID),
                                              authRequired: true, requestPath: "/orders?limit=5&status=done&product_id=\(productID)", httpMethod: .GET) { (orders: [Order]) in
            
            completion(orders)
        }errorHandle: {
            errorHandle()
        }
    }
    
    // 1D => granularity = 3600
    // 1W => granularity = 3600
    // 1M => granularity = 86400
    // 3M => granularity = 86400
    func fetchProductCandles(productID: String, granularity: String, start: String, end: String, completion: @escaping ([[Double]]) -> Void, errorHandle: @escaping (() -> Void) = {}) {
        CoinbaseService.shared.getApiResponse(api: .allCandles(productID: productID, granularity: granularity, start: start, end: end), authRequired: false) { (candles: [[Double]]) in
            completion(candles)
        }errorHandle: {
            errorHandle()
        }
    }
    
}

extension HomePageDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if orders.count == 0 {
            return 2
        } else {
            return 1 + orders.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChartViewTableViewCell", for: indexPath) as! ChartViewTableViewCell
            self.realTimeByPriceLabel = cell.realTimeByPriceLabel
            self.currencySellPriceLabel = cell.realTimeSellPriceLabel
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
            cell.oneDayCandleLogCalcArray = oneDayCandleLogCalcArray
            cell.oneWeekCandleLogCalcArray = oneWeekCandleLogCalcArray
            cell.oneMonthCandleLogCalcArray = oneMonthCandleLogCalcArray
            cell.threeMonthCandleLogCalcArray = threeMonthCandleLogCalcArray
            cell.oneYearCandleLogCalcArray = oneYearCandleLogCalcArray
            cell.allCandleLogCalcArray = allCandleLogCalcArray
            cell.setChartView(dataArray: oneMonthCandleCalcArray)
            return cell
            
        default:
            if orders.count == 0 {
                let emptyCell = tableView.dequeueReusableCell(withIdentifier: "NoDataTableViewCell", for: indexPath) as! NoDataTableViewCell
                return emptyCell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecordTableViewCell", for: indexPath) as! RecordTableViewCell
                
                if orders[indexPath.row - 1].side == "buy" {
                    cell.buyCoinTypeLabel.text = "購入 \(currencyPair!.baseCurrency)"
                    cell.buyShowLabel.text = "BUY"
                    cell.buyView.backgroundColor = .systemBrown
                } else {
                    cell.buyCoinTypeLabel.text = "賣出 \(currencyPair!.baseCurrency)"
                    cell.buyShowLabel.text = "SELL"
                    cell.buyView.backgroundColor = .orange
                }
                
                if orders[indexPath.row - 1].status == "done" {
                    cell.orderStatusLabel.text = "成功"
                } else {
                    cell.orderStatusLabel.text = "失敗"
                }
                cell.buyCoinPriceLabel.text = "USD$ " + (Double(orders[indexPath.row - 1].executedValue ?? "0")?.formattedWithSeparator() ?? "0")
                let dateString = orders[indexPath.row - 1].doneAt!
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
                
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
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
