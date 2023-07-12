//
//  ImageTableViewCell.swift
//  CoinProject
//
//  Created by 0000 on 2023/6/28.
//

import UIKit
import Kingfisher
import iCarousel
class ImageTableViewCell: UITableViewCell {
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var PriceLabel: UILabel!
    @IBOutlet weak var carousel: iCarousel!
    var price: String = "" {
        didSet {
            PriceLabel.text = "NT$\(price)"
        }
    }
    var photos: [String] = []
    var timer: Timer?
    var correntCellIndex = 0
    var webArray: [String]? = ["https://ethereum.org/zh-tw/", "https://coinmarketcap.com/zh-tw/currencies/solana/", "https://www.wantgoo.com/global/btc", "https://ethereum.org/zh-tw/"]
    var imageArray: [String] = ["https://img.onl/p3VxJE", "https://img.onl/v7ZGJ", "https://img.onl/H7T2R2", "https://img.onl/nYS3Zv"]
    override func awakeFromNib() {
        super.awakeFromNib()
        carousel.delegate = self
        carousel.dataSource = self
        carousel.type = .linear
        carousel.isPagingEnabled = true
        pageControl.numberOfPages = carousel.numberOfItems
        pageControl.currentPage = 0
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(autoScrollBanner), userInfo: nil, repeats: true)

    }
    @objc func autoScrollBanner() {
            carousel.scrollToItem(at: carousel.currentItemIndex + 1, animated: true)
        }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func didEyeButtonTapped(_ sender: Any) {
        if eyeButton.isSelected {
            eyeButton.isSelected = false
            PriceLabel.text = "NT$\(price)"
            eyeButton.setImage(UIImage(named: "eye-open"), for: .normal)
        } else {
            eyeButton.isSelected = true
            PriceLabel.text = "NT$ ***** "
            eyeButton.setImage(UIImage(named: "eye-close"), for: .normal)
        }
    }
    
}

extension ImageTableViewCell: iCarouselDelegate, iCarouselDataSource {
    func numberOfItems(in carousel: iCarousel) -> Int {
        imageArray.count
    }

    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let itemImageView = UIImageView(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: UIScreen.main.bounds.width,
                                                      height: carousel.bounds.height))
        let url = URL(string: imageArray[index])
        itemImageView.kf.setImage(with: url)
        return itemImageView
    }

    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == .wrap {
            return 1
        }
        return value
    }

    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        pageControl.currentPage = carousel.currentItemIndex
    }
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {

            if let urlString = webArray?[index] {
                if let url = URL(string: urlString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    
}
