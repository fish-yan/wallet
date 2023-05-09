//
//  AssetViewController.swift
//  Wallet
//
//  Created by 薛焱 on 2023/4/17.
//

import UIKit
import web3swift
import Web3Core
import MBProgressHUD

class AssetViewController: UIViewController {

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()

    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.text = "cry special tunnel clutch fade present logic snow need endless genre club"
        textView.backgroundColor = .systemGray6
        return textView
    }()

    lazy var importBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("import", for: .normal)
        btn.backgroundColor = .blue
        btn.addTarget(self, action: #selector(importAction), for: .touchUpInside)
        return btn
    }()

    lazy var walletBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("transfer", for: .normal)
        btn.backgroundColor = .blue
        btn.addTarget(self, action: #selector(getWalletInfoAction), for: .touchUpInside)
        return btn
    }()

    lazy var walletBtn1: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("erc20 transfer", for: .normal)
        btn.backgroundColor = .blue
        btn.addTarget(self, action: #selector(erc20), for: .touchUpInside)
        return btn
    }()

    lazy var infoLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        return lab
    }()

    var ethAddress: EthereumAddress?


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let manager = ChainManager.share
        print(manager.chainList)
    }

    func setupUI() {
        title = "Asset"
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubviews([textView, importBtn, infoLabel, walletBtn, walletBtn1])
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        textView.snp.makeConstraints { make in
            make.top.equalTo(50)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(100)
            make.width.equalToSuperview().offset(-40)
        }
        importBtn.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(self.importBtn.snp.bottom).offset(50)
            make.left.right.equalToSuperview().inset(20)
        }
        walletBtn.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        walletBtn1.snp.makeConstraints { make in
            make.top.equalTo(walletBtn.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-50)
        }
    }

    @objc func importAction() {
        guard let text = textView.text else {
            return
        }
        DispatchQueue.global().async {
            do {
                let address = try EVMWalletTool.importWallet(mnemonic: text, password: globalPassword)
                let wallet = Wallet("my wallet", address: address)

                let token1 = TokenModel()
                token1.chain = ChainManager.share.find(with: 88880)

                let token2 = TokenModel()
                token2.chain = ChainManager.share.find(with: 5)
                token2.type = .erc20
                token2.contract = "0x18ec87cf170e2a5cd8fbda57008f0b9ebfac6eb9"

                wallet.tokens = [token1, token2]

                WalletManager.share.add(wallet)
                
            } catch let error {
                print(error)
            }
        }
    }

    @objc func getWalletInfoAction() {
        Task {
            guard let wallet = WalletManager.share.activeWallet,
                  let token = wallet.tokens.first(where: {$0.chain?.chainId == 88880}) else {
                return
            }
            do {
                let hash = try await token.transfer(to: "0xE24aa36Cc8bf41b0b8378809aCc8d11a35EF4E9f", amount: "0.001", password: globalPassword)
                print("hash:", hash)
            } catch let error {
                print("error:", error)
            }
        }
    }

    @objc func erc20() {
        Task {
            do {
                guard let wallet = WalletManager.share.activeWallet,
                      let token = wallet.tokens.first(where: {$0.chain?.chainId == 5}) else {
                    return
                }
                let hash = try await token.transfer(to: "0xE24aa36Cc8bf41b0b8378809aCc8d11a35EF4E9f", amount: "0.001", password: globalPassword)
                print("hash:", hash)
            } catch let error {
                print("error:", error)
            }
        }
    }

}
