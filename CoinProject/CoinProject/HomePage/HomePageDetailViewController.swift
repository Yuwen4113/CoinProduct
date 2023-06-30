//
//  HomePageDetailViewController.swift
//  CoinProject
//
//  Created by 0000 on 2023/6/29.
//

import UIKit

class HomePageDetailViewController: UIViewController {
    var currencyPair: CurrencyPair?
    var currencyChineseName: String = ""
    
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
        tableView.dataSource = self
        tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    @IBAction func didBackButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension HomePageDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChartViewTableViewCell", for: indexPath) as! ChartViewTableViewCell
            return cell
        case 1...2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordTableViewCell", for: indexPath) as! RecordTableViewCell
            return cell
        default:
            fatalError("Unexpected row in table view")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
