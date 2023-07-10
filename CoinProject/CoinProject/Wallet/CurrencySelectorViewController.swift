//
//  CurrencySelectorViewController.swift
//  CoinProject
//
//  Created by 0000 on 2023/7/6.
//

import UIKit
import Kingfisher

class CurrencySelectorViewController: UIViewController {
    var setSelectedCurrency: ((String) -> Void)?
    var selectedCurrency: String = ""
    var accountPairs: [Account] = []
    var allCurrencyAccount = Account(id: "", currency: "所有幣種", balance: "", hold: "", available: "", profileID: "", tradingEnabled: true)
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAccountsTotalBalance {
            print(self.accountPairs.count)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func getIconUrl(imageView: UIImageView, for coinCode: String) {
        let lowercased = coinCode.lowercased()
        let coinIconUrl = "https://cryptoicons.org/api/icon/\(lowercased)/200"
        imageView.kf.setImage(with: URL(string: coinIconUrl))
    }
    
    func getAccountsTotalBalance(completion: @escaping () -> Void) {
        CoinbaseService.shared.fetchAccounts { [weak self] accounts in
            self?.accountPairs = accounts
            self?.accountPairs.insert(self!.allCurrencyAccount, at: 0)
            completion()
        }
    }
    
    @IBAction func didCloseButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CurrencySelectorViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountPairs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyTypeTableViewCell", for: indexPath) as! CurrencyTypeTableViewCell
        let accountPair = accountPairs[indexPath.row]
        if accountPair.currency == "所有幣種" {
            cell.currencyImageView.image = UIImage(named: "coins 1")
        } else {
            self.getIconUrl(imageView: cell.currencyImageView, for: accountPair.currency)
        }
        cell.currencyNameLabel.text = accountPair.currency
        
        if accountPair.currency + "-USD" == self.selectedCurrency ||
            self.selectedCurrency == ""  && indexPath.row == 0 {
            cell.chooseImageView.isHidden = false
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedData = accountPairs[indexPath.row].currency
        if selectedData == "所有幣種" {
            self.setSelectedCurrency?("")
        } else {
            self.setSelectedCurrency?(selectedData + "-USD")
        }
        self.dismiss(animated: true)
    }
    
}
