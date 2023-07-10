//
//  CurrencyTypeTableViewCell.swift
//  CoinProject
//
//  Created by 0000 on 2023/7/6.
//

import UIKit

class CurrencyTypeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var currencyImageView: UIImageView!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var chooseImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        chooseImageView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
//        chooseImageView.isHidden = selected ? false : true
    }

}
