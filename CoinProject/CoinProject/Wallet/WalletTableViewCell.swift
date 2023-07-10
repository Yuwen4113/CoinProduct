//
//  WalletTableViewCell.swift
//  CoinProject
//
//  Created by 0000 on 2023/7/6.
//

import UIKit

class WalletTableViewCell: UITableViewCell {

    @IBOutlet weak var coinImage: UIImageView!
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var coinSizeLabel: UILabel!
    @IBOutlet weak var coinAmountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
