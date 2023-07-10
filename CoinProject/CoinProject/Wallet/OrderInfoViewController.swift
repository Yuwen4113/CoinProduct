//
//  OrderInfoViewController.swift
//  CoinProject
//
//  Created by 0000 on 2023/7/9.
//

import UIKit

class OrderInfoViewController: UIViewController {
    var data: Order?

    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var doneAtLabel: UILabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var uniPriceLabel: UILabel!
    @IBOutlet weak var costPriceLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let orderTimeString = data?.createdAt
            let updateTimeString = data?.doneAt
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
            
            if let date = dateFormatter.date(from: orderTimeString ?? "") {
                let taiwanTimeZone = TimeZone(abbreviation: "GMT+8")
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = taiwanTimeZone
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                let taiwanDate = dateFormatter.string(from: date)
                self.doneAtLabel.text = taiwanDate
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
            
            
        if let sizeString = data?.size, let executedValueString = data?.executedValue, let productID = data?.productID {
            if let size = Double(sizeString), let executedValue = Double(executedValueString) {
                self.sizeLabel.text = String(format: "%.8f", size) + " \(productID)"
                self.uniPriceLabel.text = "USD$ " + String(format: "%.8f", executedValue / size)
                self.costPriceLabel.text = "USD$ " + String(format: "%.8f", executedValue)
            } else {
                self.sizeLabel.text = "Invalid size"
                self.uniPriceLabel.text = "Invalid price"
                self.costPriceLabel.text = "Invalid price"
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    @IBAction func didBackButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
