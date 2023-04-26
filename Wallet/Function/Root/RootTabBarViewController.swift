//
//  RootTabBarViewController.swift
//  Wallet
//
//  Created by 薛焱 on 2023/4/17.
//

import UIKit

class RootTabBarViewController: UITabBarController {

    lazy var assetVC: BaseNavigationController = {
        let vc = AssetViewController()
        vc.tabBarItem = UITabBarItem(title: "Asset", image: nil, selectedImage: nil)
        let nav = BaseNavigationController(rootViewController: vc)
        return nav
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        addChild(assetVC)
    }

    private func setupTabBar() {
        self.tabBar.backgroundColor = .white
    }

}
