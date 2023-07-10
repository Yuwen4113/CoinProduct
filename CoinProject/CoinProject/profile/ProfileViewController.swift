//
//  ProfileViewController.swift
//  CoinProject
//
//  Created by 0000 on 2023/7/7.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileIdLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authButton.layer.cornerRadius = 10
        authButton.layer.shadowColor = UIColor.gray.cgColor
        authButton.layer.shadowOpacity = 0.5
        authButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        authButton.layer.shadowRadius = 4
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CoinbaseService.shared.fetchUserProfile() { profile in
            DispatchQueue.main.async {
                self.profileNameLabel.text = profile.name
                self.profileIdLabel.text = profile.userId
                if profile.active == true {
                    self.authButton.setTitle("身份驗證成功", for: .normal)
                } else {
                    self.authButton.setTitle("身份驗證失敗", for: .normal)
                }
            }
        }
    }

}
