//
//  ViewController.swift
//  CoinProject
//
//  Created by 0000 on 2023/6/28.
//

import UIKit

class ViewController: UIViewController {
    var USDPairs: [CurrencyPair] = []
    var chineseUSDPairs: [String] = []
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        callCurrencyApi()
    }
    func callCurrencyApi(completion: (() -> Void)? = nil) {
        CoinbaseService.shared.getApiResponse(api: CoinbaseApi.products,
                                              authRequired: false) { [weak self] (products: [CurrencyPair]) in
            self?.USDPairs = products.filter { currencyPair in
                return String(currencyPair.id.suffix(3)) == "USD"
            }
            completion?()
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
            return cell
        case 1...USDPairs.count:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoinTableViewCell", for: indexPath) as! CoinTableViewCell
            cell.coinNameLabel.text = USDPairs[indexPath.row - 1].baseCurrency
            cell.coinRateLabel.text = USDPairs[indexPath.row - 1].minMarketFunds
            if USDPairs[indexPath.row - 1].baseCurrency == "BCH" {
                cell.coinChineseLabel.text = "比特幣現金"
                cell.coinIconImageView.image = UIImage(named: "bch")
            }
            if USDPairs[indexPath.row - 1].baseCurrency == "BTC" {
                cell.coinChineseLabel.text = "比特幣"
                cell.coinIconImageView.image = UIImage(named: "btc")
            }
            if USDPairs[indexPath.row - 1].baseCurrency == "USDT" {
                cell.coinChineseLabel.text = "泰達幣"
                cell.coinIconImageView.image = UIImage(named: "usdt")
            }
            if USDPairs[indexPath.row - 1].baseCurrency == "LINK" {
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
