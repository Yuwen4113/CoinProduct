//
//  WalletsViewController.swift
//  CoinProject
//
//  Created by 0000 on 2023/7/6.
//

import UIKit
import Kingfisher
import MJRefresh

class WalletsViewController: UIViewController {
    var accountTotalBalance: Double = 0
    var accountPairs: [Account] = []
    var fluctuateRateAvgPrice: [String: Double] = [:]
    var totalBalance: Int = 0
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var closeBalanceButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var price: Int = 0 {
        didSet {
            balanceLabel.text = "NT$ \(price)"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(headerRefresh))
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.getAccountsTotalBalance() {
            DispatchQueue.main.async {
                self.totalBalance = 0
                self.tableView.reloadData()
                DispatchQueue.main.async {
                    self.price = self.totalBalance
                }
            }
        }
    }
    
    func getIconUrl(imageView: UIImageView, for coinCode: String) {
        let lowercased = coinCode.lowercased()
        let coinIconUrl = "https://cryptoicons.org/api/icon/\(lowercased)/200"
        imageView.kf.setImage(with: URL(string: coinIconUrl))
    }
    
    @objc func headerRefresh() {
            self.tableView!.reloadData()
            self.tableView.mj_header?.endRefreshing()
        }
    
    func getAccountsTotalBalance(completion: @escaping () -> Void) {
        CoinbaseService.shared.fetchAccounts { [weak self] accounts in
            self?.accountPairs = accounts
            
            let group = DispatchGroup()
            
            accounts.forEach { account in
                group.enter()
                
                self?.fetchCurrencyRate(currency: account.currency) { rate in
                    self!.fluctuateRateAvgPrice.updateValue(rate, forKey: account.currency)
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                completion()
            }
        }
    }
    
    
    func fetchCurrencyRate(currency: String, completion: @escaping (Double) -> Void) {
        CoinbaseService.shared.getApiResponse(api: .exchangeRateInCurrency(currency: currency), authRequired: false) { (allRates: ExchangeRates) in
            let rate = Double(allRates.data.rates["TWD"] ?? "0") ?? 0
            completion(rate)
        }
    }
    
    func getUSDPairsProductFluctRateAvgPrice(completion: (() -> Void)? = nil) {
        fluctuateRateAvgPrice = [:]
        let group = DispatchGroup()
        
        for productCurrency in accountPairs {
            group.enter()
            
            CoinbaseService.shared.fetchProductStats(productID: productCurrency.currency + "-USD") { [weak self] productStats in
                
                if let highPrice = Double(productStats.high),
                   let lowPrice = Double(productStats.low)
                {
                    let avgPrice = (highPrice + lowPrice) / 2
                    
                    self?.fluctuateRateAvgPrice.updateValue((avgPrice), forKey: productCurrency.currency)
                    
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            completion?()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func didEyeButtonTapped(_ sender: Any) {
        if closeBalanceButton.isSelected {
            closeBalanceButton.isSelected = false
            balanceLabel.text = "NT$ \(price)"
            closeBalanceButton.setImage(UIImage(named: "eye-close"), for: .normal)
        } else {
            closeBalanceButton.isSelected = true
            balanceLabel.text = "NT$ ***** "
            closeBalanceButton.setImage(UIImage(named: "eye-open"), for: .normal)
        }
        
    }
    
    @IBAction func didOrdersHistoryButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "OrderHistoryViewController") as! OrderHistoryViewController
        navigationController?.pushViewController(nextViewController, animated: true)
    }
}

extension WalletsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountPairs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletTableViewCell", for: indexPath) as! WalletTableViewCell
        let accountPair = accountPairs[indexPath.row]
        let coinRate = fluctuateRateAvgPrice[accountPair.currency]
        
        cell.coinNameLabel.text = accountPair.currency
        self.getIconUrl(imageView: cell.coinImage, for: accountPair.currency)
        
        let coinNTBalance = Int((Double(accountPair.balance) ?? 0)  * Double(coinRate ?? 0))
        cell.coinSizeLabel.text = String(format: "%.8f", Double(accountPair.balance) ?? 0)
        cell.coinAmountLabel.text = "NT$ " + String(coinNTBalance)
        
        self.totalBalance += coinNTBalance
        print(accountPair.balance)
        print(self.totalBalance)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
