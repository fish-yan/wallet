//
//  BaseNavigationController.swift
//  Wallet
//
//  Created by 薛焱 on 2023/4/17.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
    }

}
