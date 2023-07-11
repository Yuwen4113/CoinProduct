//
//  File.swift
//  CoinProject
//
//  Created by 0000 on 2023/7/11.
//

import Foundation
import UIKit
import JGProgressHUD

class LoadingUtils {
    static var shared = LoadingUtils()
    private let hud = JGProgressHUD()

    func doStartLoading(view: UIView, text: String) {
        self.hud.textLabel.text = text
        self.hud.show(in: view)
    }

    func doStopLoading() {
        self.hud.dismiss()
    }
}
