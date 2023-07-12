//
//  OrderDetailViewController.swift
//  CoinProject
//
//  Created by 0000 on 2023/7/5.
//

import UIKit

class OrderDetailViewController: UIViewController {
    var currencyPair: TradingPair?
    var exchangeText: String = ""
    var orderId: String = ""
    var order: Order?
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var currencyCostLabel: UILabel!
    @IBOutlet weak var orderTimeLabel: UILabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var unitPriceLabel: UILabel!
    @IBOutlet weak var amountsPayableLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        buyButton.layer.cornerRadius = 5
    }
       
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        LoadingUtils.shared.doStartLoading(view: self.view, text: "Loading")
        DispatchQueue.main.async {
            CoinbaseService.shared.getOneOrder(id: self.orderId) { order in
                
                LoadingUtils.shared.doStopLoading()
                self.order = order
                DispatchQueue.main.async {
                    if order.side == "buy" {
                        self.buyButton.setTitle("BUY", for: .normal)
                        self.buyButton.backgroundColor = .systemBrown
                    } else {
                        self.buyButton.setTitle("SELL", for: .normal)
                        self.buyButton.backgroundColor = .orange
                    }
                    let orderTimeString = self.order?.createdAt
                    let updateTimeString = self.order?.doneAt
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
                    dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
                    
                    if let date = dateFormatter.date(from: orderTimeString ?? "") {
                        let taiwanTimeZone = TimeZone(abbreviation: "GMT+8")
                        let dateFormatter = DateFormatter()
                        dateFormatter.timeZone = taiwanTimeZone
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                        let taiwanDate = dateFormatter.string(from: date)
                        self.orderTimeLabel.text = taiwanDate
                    } else {
                        print("日期解析失敗")
                    }
                    
                    let updateTimeDateFormatter = DateFormatter()
                    updateTimeDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
                    updateTimeDateFormatter.timeZone = TimeZone(abbreviation: "GMT")
                    
                    if let updateTime = updateTimeDateFormatter.date(from: updateTimeString ?? "") {
                        let taiwanTimeZone = TimeZone(abbreviation: "GMT+8")
                        updateTimeDateFormatter.timeZone = taiwanTimeZone
                        updateTimeDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                        let taiwanDate = updateTimeDateFormatter.string(from: updateTime)
                        self.updateTimeLabel.text = taiwanDate
                    } else {
                        print("日期解析失敗")
                    }
                    var size = Double(self.order?.size ?? "0")
                    var executedValue = Double(self.order?.executedValue ?? "0")
                    var price = (executedValue ?? 0) / (size ?? 0)
                    var fillFees = Double(self.order?.fillFees ?? "0")
                    
                    self.currencyCostLabel.text = (Double(self.order?.size ?? "0")?.formattedWith8Separator() ?? "0") + "\(self.currencyPair!.baseCurrency)"
                    self.unitPriceLabel.text = "USD$ " + ((executedValue ?? 0) / (size ?? 0)).formattedWith8Separator()
                    self.amountsPayableLabel.text = "USD$ " + (executedValue ?? 0).formattedWith8Separator()
                }
            } errorHandle: {
                let alertController = UIAlertController(title: "500 Internal server error", message: "訂單加載中，請至確認資產頁面確認！", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func didBackButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func didCheckWalletButtonTapped(_ sender: Any) {

//        let tabBar = self.navigationController?.presentingViewController as? UITabBarController
//        tabBar?.selectedIndex = 1
//
//        self.navigationController?.dismiss(animated: false)
        
        let tabBar = self.navigationController?.presentingViewController as? UITabBarController

                tabBar?.selectedIndex = 1
                self.navigationController?.dismiss(animated: true)
                (tabBar?.viewControllers![0] as? UINavigationController)!.popToRootViewController(animated: false)
    }
}
