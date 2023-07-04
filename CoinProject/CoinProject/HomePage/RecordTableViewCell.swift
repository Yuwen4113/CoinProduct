//
//  RecordTableViewCell.swift
//  CoinProject
//
//  Created by 0000 on 2023/6/29.
//

import UIKit

class RecordTableViewCell: UITableViewCell {
    
    @IBOutlet weak var buyShowLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var buyCoinTypeLabel: UILabel!
    @IBOutlet weak var orderStatusView: UIView!
    @IBOutlet weak var orderStatusLabel: UILabel!
    @IBOutlet weak var buyCoinPriceLabel: UILabel!
    @IBOutlet weak var buyUSDPriceLabel: UILabel!
    @IBOutlet weak var buyView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        buyView.layer.cornerRadius = 5
        orderStatusView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
