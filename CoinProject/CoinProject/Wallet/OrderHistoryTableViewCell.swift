//
//  OrderHistoryTableViewCell.swift
//  CoinProject
//
//  Created by 0000 on 2023/7/6.
//

import UIKit

class OrderHistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var orderAmountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buyButton.layer.cornerRadius = 10
        statusView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
