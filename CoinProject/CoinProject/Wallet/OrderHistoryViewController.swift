//
//  OrderHistoryViewController.swift
//  CoinProject
//
//  Created by 0000 on 2023/7/6.
//

import UIKit

class OrderHistoryViewController: UIViewController, UIViewControllerTransitioningDelegate {
    var selectedCurrency: String = "" {
        didSet{
            LoadingUtils.shared.doStartLoading(view: self.view, text: "Loading")
            DispatchQueue.main.async {
                if self.selectedCurrency != ""{
                    self.selectedButoon.setTitle("\(self.selectedCurrency) ▼", for: .normal)
                } else {
                    self.selectedButoon.setTitle("全部幣種 ▼", for: .normal)
                }
                self.allOrders = []
                self.tableView.reloadData()
            }
            CoinbaseService.shared.fetchAllOrders(productID: selectedCurrency) { orders in
                let filteredOrders = orders.compactMap { $0 }
                self.allOrders = filteredOrders
                DispatchQueue.main.sync {
//                    if self.selectedCurrency != ""{
//                        self.selectedButoon.setTitle("\(self.selectedCurrency) ▼", for: .normal)
//                    } else {
//                        self.selectedButoon.setTitle("全部幣種 ▼", for: .normal)
//                    }
                    LoadingUtils.shared.doStopLoading()
                    self.tableView.reloadData()
                }
            } errorHandle: {
                self.allOrders = []
                DispatchQueue.main.sync {
                    let alertController = UIAlertController(title: "500 Internal server error", message: "系統維護中，請稍後再試", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
//                    self.selectedButoon.setTitle("\(self.selectedCurrency) ▼", for: .normal)
                    LoadingUtils.shared.doStopLoading()
                    self.tableView.reloadData()
                }
            }
        }
    }
    var allOrders: [Order] = []
    
    @IBOutlet weak var selectedButoon: UIButton!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        let emptyBackButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = emptyBackButton
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        LoadingUtils.shared.doStartLoading(view: self.view, text: "Loading")
        CoinbaseService.shared.fetchAllOrders(productID: selectedCurrency) { orders in
            let filteredOrders = orders.compactMap { $0 }
            self.allOrders = filteredOrders
            DispatchQueue.main.sync {
                LoadingUtils.shared.doStopLoading()
                self.tableView.reloadData()
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    
    @IBAction func didBackButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func didSelectButtonTapped(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let targetViewController = storyboard.instantiateViewController(withIdentifier: "CurrencySelectorViewController") as? CurrencySelectorViewController {
            //   targetViewController.currencyPair = self.currencyPair
            //   targetViewController.isSell = self.isSell
            targetViewController.modalPresentationStyle = .custom
            targetViewController.transitioningDelegate = self
            targetViewController.selectedCurrency = self.selectedCurrency
            targetViewController.setSelectedCurrency = { selectedData in
                self.selectedCurrency = selectedData
            }
            present(targetViewController, animated: true, completion: nil)
        }
    }
    
}

extension OrderHistoryViewController {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfHeightPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension OrderHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allOrders.isEmpty {
            return 1
        } else {
            return allOrders.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if allOrders.isEmpty {
               let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataCell", for: indexPath)
               return cell
           } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderHistoryTableViewCell", for: indexPath) as! OrderHistoryTableViewCell
            let order = allOrders[indexPath.row]
            if order.side == "buy" {
                cell.buyButton.setTitle("BUY", for: .normal)
                cell.buyButton.backgroundColor = .systemBrown
                cell.currencyNameLabel.text = "購入 \(order.productID?.dropLast(4) ?? "")"
            } else {
                cell.buyButton.setTitle("SELL", for: .normal)
                cell.buyButton.backgroundColor = .orange
                cell.currencyNameLabel.text = "賣出 \(order.productID?.dropLast(4) ?? "")"
            }
            
            if order.status == "done" {
                cell.statusLabel.text = "成功"
            } else {
                cell.statusLabel.text = "失敗"
            }
            
            cell.orderAmountLabel.text = "USD$ " + (Double(order.executedValue ?? "0")?.formattedWithSeparator() ?? "0")
            
            let dateString = order.doneAt!
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "OrderInfoViewController") as!  OrderInfoViewController
        nextViewController.data = allOrders[indexPath.row]
        navigationController?.pushViewController(nextViewController, animated: true)
        }
}

class HalfHeightPresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return CGRect.zero }
        
        let halfHeight = containerView.bounds.height / 2
        return CGRect(x: 0, y: containerView.bounds.height - halfHeight, width: containerView.bounds.width, height: halfHeight)
    }
}

