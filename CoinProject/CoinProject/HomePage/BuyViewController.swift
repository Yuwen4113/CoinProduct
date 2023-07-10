//
//  BuyViewController.swift
//  CoinProject
//
//  Created by 0000 on 2023/7/4.
//

import UIKit

class BuyViewController: UIViewController {
    var currencyPair: TradingPair?
    var isSell: Bool?
    var currencySellBid: Double = 0
    var currencySellPrice: Double = 0
    var accountBalances: [Account] = []
    
    @IBOutlet weak var maxButton: UIButton!
    @IBOutlet weak var changeStatusButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coinTypeLabel: UILabel!
    @IBOutlet weak var exchangeLabel: UILabel!
    @IBOutlet weak var coinImageView: UIImageView!
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var exchangeTextField: UITextField!
    @IBOutlet weak var twdTextField: UITextField!
    @IBOutlet weak var exchangeTitleLabel: UILabel!
    @IBOutlet weak var costTitleLabel: UILabel!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var buySellButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exchangeTextField.isEnabled = false
        exchangeTextField.textColor = .gray
        twdTextField.isEnabled = true
        twdTextField.textColor = .black
        exchangeTextField.delegate = self
        twdTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isSell == false {
            maxButton.isHidden = true
            noticeLabel.text = ""
            titleLabel.text = "買入 \(currencyPair!.baseCurrency)"
            exchangeTitleLabel.text = "買入"
            costTitleLabel.text = "花費"
            buySellButton.setTitle("買入", for: .normal)
        } else {
            fetchAccounts { accounts in
                //                print(self.accountBalances[0].balance)
                for account in accounts {
                    if account.currency == self.currencyPair?.baseCurrency {
                        self.accountBalances.append(account)
                    }
                }
                DispatchQueue.main.async {
                    //                    String(format: "%.8f",(Double(self.accountBalances[0].balance) ?? 0))
                    self.noticeLabel.text = "可用餘額：" + String(format: "%.8f",(Double(self.accountBalances[0].balance) ?? 0))
                    + " \(self.currencyPair!.baseCurrency)"
                }
            }
            maxButton.isHidden = false
            titleLabel.text = "賣出 \(currencyPair!.baseCurrency)"
            exchangeTitleLabel.text = "賣出"
            costTitleLabel.text = "獲得"
            buySellButton.setTitle("賣出", for: .normal)
        }
        coinNameLabel.text = "\(currencyPair!.baseCurrency)"
        if currencyPair?.baseCurrency == "BTC" {
            coinImageView.image = UIImage(named: "btc")
        }
        if currencyPair?.baseCurrency == "USDT" {
            coinImageView.image = UIImage(named: "usdt")
        }
        if currencyPair?.baseCurrency == "LINK" {
            coinImageView.image = UIImage(named: "link")
        }
        
        coinTypeLabel.text = "1 \(currencyPair!.baseCurrency) ="
        twdTextField.text = "0"
        exchangeTextField.text = "0"
        WebsocketService.shared.realTimeData = { [self] array in
            self.currencySellBid = (Double(array[1]) ?? 0)
            self.currencySellPrice = (Double(array[0]) ?? 0)
            if twdTextField.isEnabled == true {
                if isSell == false {
                    exchangeTextField.text =
                    String(format: "%.8f",(Double(twdTextField.text!) ?? 0) / self.currencySellBid)
                } else {
                    exchangeTextField.text =
                    String(format: "%.8f",(Double(twdTextField.text!) ?? 0) / self.currencySellPrice)
                }
            } else {
                if isSell == false {
                    twdTextField.text =
                    String(format: "%.8f",(Double(exchangeTextField.text!) ?? 0) * self.currencySellBid)
                } else {
                    twdTextField.text =
                    String(format: "%.8f",(Double(exchangeTextField.text!) ?? 0) * self.currencySellPrice)
                }
            }
            
            DispatchQueue.main.async {
                if self.isSell == false {
                    self.exchangeLabel?.text = String(self.currencySellBid)
                } else {
                    self.exchangeLabel?.text = String(self.currencySellPrice)
                }
            }
        }
        WebsocketService.shared.connect(string: "\(currencyPair?.baseCurrency ?? "")-USD" )
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        WebsocketService.shared.disconnect()
    }
    @IBAction func didCloseButtonTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func didChangeStatusButtonTapped(_ sender: Any) {
        if changeStatusButton.isSelected {
            changeStatusButton.isSelected = false
            exchangeTextField.isEnabled = false
            exchangeTextField.textColor = .gray
            twdTextField.isEnabled = true
            twdTextField.textColor = .black
            exchangeTitleLabel.textColor = .gray
            costTitleLabel.textColor = .black
        } else {
            changeStatusButton.isSelected = true
            exchangeTextField.isEnabled = true
            exchangeTextField.textColor = .black
            twdTextField.isEnabled = false
            twdTextField.textColor = .gray
            exchangeTitleLabel.textColor = .black
            costTitleLabel.textColor = .gray
        }
    }
    
    
    @IBAction func didMaxButtonTapped(_ sender: Any) {
        self.exchangeTextField.text = String(format: "%.8f",(Double(self.accountBalances[0].balance) ?? 0))
        changeStatusButton.isSelected = true
        exchangeTextField.isEnabled = true
        exchangeTextField.textColor = .black
        twdTextField.isEnabled = false
        twdTextField.textColor = .gray
        exchangeTitleLabel.textColor = .black
        costTitleLabel.textColor = .gray
        
    }
    
    
    
    @IBAction func didBuyButtonTapped(_ sender: Any) {
        
        CoinbaseService.shared.createOrders(
            size: self.exchangeTextField.text ?? "0",
            side: (isSell! ? "sell" : "buy"),
            productId: "\(self.currencyPair?.baseCurrency ?? "")-USD") { orderId in
                print(orderId)
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let nextViewController = storyboard.instantiateViewController(withIdentifier: "OrderDetailViewController") as! OrderDetailViewController
                    nextViewController.currencyPair = self.currencyPair
                    nextViewController.exchangeText = self.exchangeTextField.text ?? ""
                    nextViewController.orderId = orderId
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.navigationController?.pushViewController(nextViewController, animated: true)
                    }
                }
            }
    }
    
    func fetchAccounts(completion: @escaping ([Account]) -> Void) {
        CoinbaseService.shared.getApiResponse(api: .accounts,
                                              authRequired: true, requestPath: "/accounts", httpMethod: .GET) { (accounts: [Account]) in
            completion(accounts)
        }
    }
    
}

extension BuyViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if twdTextField.isEnabled == true {
            if isSell == false {
                exchangeTextField.text =
                String(format: "%.8f",(Double(twdTextField.text!) ?? 0) / self.currencySellBid)
            } else {
                exchangeTextField.text =
                String(format: "%.8f",(Double(twdTextField.text!) ?? 0) / self.currencySellPrice)
            }
        } else {
            if isSell == false {
                twdTextField.text =
                String(format: "%.8f",(Double(exchangeTextField.text!) ?? 0) * self.currencySellBid)
            } else {
                twdTextField.text =
                String(format: "%.8f",(Double(exchangeTextField.text!) ?? 0) * self.currencySellPrice)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == twdTextField {
            let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            if isSell == false {
                exchangeTextField.text = String(format: "%.8f", (Double(newText) ?? 0) / self.currencySellBid)
            } else {
                exchangeTextField.text = String(format: "%.8f", (Double(newText) ?? 0) / self.currencySellPrice)
            }
        } else if textField == exchangeTextField {
            let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            if isSell == false {
                twdTextField.text = String(format: "%.8f", (Double(newText) ?? 0) * self.currencySellBid)
            } else {
                twdTextField.text = String(format: "%.8f", (Double(newText) ?? 0) * self.currencySellPrice)
            }
        }
        return true
    }
}
