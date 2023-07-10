//
//  ViewController.swift
//  CoinProject
//
//  Created by 0000 on 2023/6/28.
//

import UIKit
import MJRefresh

class ViewController: UIViewController {
    var USDPairs: [TradingPair] = []
    var chineseUSDPairs: [String] = []
    var fluctuateRateAvgPrice: [String: (Double, Double)] = [:]
    var usdTradingPairs: [(String, String)] = []
    var accountTotalBalance: Double = 0
    var usdRate: Double = 0
//    var accounts: [Account] = []
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(headerRefresh))
        tableView.mj_header = header
        tableView.contentInsetAdjustmentBehavior = .never
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.accountTotalBalance = 0
        callCurrencyApi {
            self.fetchCurrencyRate {[weak self] rate in
                self?.usdRate = rate
                self?.getUSDPairsProductFluctRateAvgPrice {
                    self?.getAccountsTotalBalance() {
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    @objc func headerRefresh() {
            self.tableView!.reloadData()
            self.tableView.mj_header?.endRefreshing()
        }
    
    func callCurrencyApi(completion: (() -> Void)? = nil) {
        CoinbaseService.shared.getApiResponse(api: CoinbaseApi.allTradingPairs,
                                              authRequired: false) { [weak self] (products: [TradingPair]) in
            self?.USDPairs = products.filter { currencyPair in
                return String(currencyPair.id.suffix(3)) == "USD" && currencyPair.auctionMode  == false && currencyPair.status == "online"
            }
            completion?()
        }
    }
    
    func getUSDPairsProductFluctRateAvgPrice(completion: (() -> Void)? = nil) {
        fluctuateRateAvgPrice = [:]
        let group = DispatchGroup()
        
        
        for productID in USDPairs {
            group.enter()
            
            CoinbaseService.shared.fetchProductStats(productID: productID.id) { [weak self] productStats in
                let lastPrice = productStats.last
                let openPrice = productStats.open
                
                if let lastPrice = Double(lastPrice),
                   let openPrice = Double(openPrice),
                   let highPrice = Double(productStats.high),
                   let lowPrice = Double(productStats.low)
                {
                    let flucRate = (lastPrice - openPrice) / lastPrice * 100
                    let avgPrice = (highPrice + lowPrice) / 2
                    
                    self?.fluctuateRateAvgPrice.updateValue((flucRate, avgPrice), forKey: productID.id)
                    
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion?()
        }
    }
    
    func fetchCurrencyRate(completion: @escaping (Double) -> Void) {
        CoinbaseService.shared.getApiResponse(api: .exchangeRate, authRequired: false) { (allRates: ExchangeRates) in
            let rate = Double(allRates.data.rates["TWD"] ?? "0") ?? 0
            completion(rate)
        }
    }
    
    func getAccountsTotalBalance(completion: @escaping () -> Void) {
        CoinbaseService.shared.fetchAccounts { [weak self] accounts in
//            self?.accounts = accounts
//            for account in accounts {
//                self?.accountTotalBalance += Double(account.balance) ?? 0
//                
//            }
            
            var totalBalance = 0.0
            
            let group = DispatchGroup()
            
            accounts.forEach { account in
                group.enter()
                
                CoinbaseService.shared.fetchCurrencyRate(currency: account.currency) { rate in
                    totalBalance += (Double(account.balance) ?? 0.0) * rate
                    group.leave()
                }
            }
            
//            self?.accountTotalBalance = Double(accounts.first { $0.currency == "USD" }?.balance ?? "") ?? 0
          
            group.notify(queue: .main) {
                self?.accountTotalBalance = totalBalance
                completion()
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + USDPairs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for: indexPath) as! ImageTableViewCell
            cell.price = String(format: "%.2f",self.accountTotalBalance)
            return cell
        case 1...USDPairs.count:
            let USDPair = USDPairs[indexPath.row - 1]
            let coinRate = fluctuateRateAvgPrice[USDPair.id]
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoinTableViewCell", for: indexPath) as! CoinTableViewCell
            if coinRate!.0 >= 0 {
                cell.isUpRate = true
                cell.coinIncreaseLabel.textColor = .systemGreen
            } else {
                cell.isUpRate = false
                cell.coinIncreaseLabel.textColor = .red
            }
            cell.lineChartView.isUserInteractionEnabled = false
            cell.setChartView()
            cell.coinRateLabel.text = String(format: "%.2f", coinRate!.1 * usdRate)
            cell.coinIncreaseLabel.text = String(format: "%.2f", coinRate!.0) + "%"
            cell.coinNameLabel.text = USDPairs[indexPath.row - 1].baseCurrency
            if USDPairs[indexPath.row - 1].baseCurrency == "BCH" {
                cell.coinChineseLabel.text = "比特幣現金"
                cell.coinIconImageView.image = UIImage(named: "bch")
            }
            
            if USDPair.baseCurrency == "BTC" {
                cell.coinChineseLabel.text = "比特幣"
                cell.coinIconImageView.image = UIImage(named: "btc")
            }
            
            if USDPair.baseCurrency == "USDT" {
                cell.coinChineseLabel.text = "泰達幣"
                cell.coinIconImageView.image = UIImage(named: "usdt")
            }
            
            if USDPair.baseCurrency == "LINK" {
                cell.coinChineseLabel.text = "LINK幣"
                cell.coinIconImageView.image = UIImage(named: "link")
            }
            
            return cell
        default:
            fatalError("Unexpected row in table view")
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screen = UIScreen.main.bounds
        let screenWidth = screen.size.width
        var screenHeight = screen.size.height
        if indexPath.row == 0 {
            screenHeight = 330
            return screenHeight
        } else {
            return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= 1 && indexPath.row <= USDPairs.count {
            let selectedCurrencyPair = USDPairs[indexPath.row - 1]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyboard.instantiateViewController(withIdentifier: "HomePageDetailViewController") as! HomePageDetailViewController
            nextViewController.currencyPair = selectedCurrencyPair
            navigationController?.pushViewController(nextViewController, animated: true)
        }
    }


}
