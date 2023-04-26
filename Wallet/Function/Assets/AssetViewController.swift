//
//  AssetViewController.swift
//  Wallet
//
//  Created by 薛焱 on 2023/4/17.
//

import UIKit
import web3swift
import Web3Core

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
        btn.setTitle("Get Wallet Info", for: .normal)
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
        let manager = ChainManager.manager
        print(manager.chainList)
    }

    func setupUI() {
        title = "Asset"
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubviews([textView, importBtn, infoLabel, walletBtn])
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
            make.bottom.equalToSuperview().offset(-50)
        }
    }

    @objc func importAction() {

        guard let text = textView.text else {
            return
        }
        let wallet = EVMWallet()
        DispatchQueue.global().async {
            try? wallet.importWallet(mnemonic: text, password: globalPassword)

        }
    }

    @objc func getWalletInfoAction() {
        Task {
            if let ethAddress = ethAddress,
               let keystoreManager = KeystoreManager.share,
               let url = URL(string: "https://scoville-rpc.chiliz.com/"),
               let provider = try? await Web3HttpProvider(url: url, network: .Goerli, keystoreManager: keystoreManager) {
                let web3 = Web3(provider: provider)
                if let value = try? await web3.eth.getBalance(for: ethAddress) {
                    let price = Utilities.formatToPrecision(value)
                    print("price:",price)
                }
                if let value = try? await web3.eth.gasPrice() {
                    let gas = Utilities.formatToPrecision(value)
                    print("gas:", gas)
                }
                var transaction: CodableTransaction = .emptyTransaction
                let value = Utilities.parseToBigUInt("0.00001", units: .ether)
                transaction.value = value!
                transaction.chainID = 88880
                transaction.gasLimit = 21_000
                let toAddress = EthereumAddress(from: "0xE24aa36Cc8bf41b0b8378809aCc8d11a35EF4E9f")
                transaction.to = toAddress!
                do {
                    transaction.gasPrice = try await web3.eth.gasPrice()
                    transaction.nonce = try await web3.eth.getTransactionCount(for: ethAddress)
                    try transaction.sign(privateKey: keystoreManager.UNSAFE_getPrivateKeyData(password: "88888888a", account: ethAddress))
                    print(transaction)
                    let result = try await web3.eth.send(raw: transaction.encode()!)
                    print("hash==", result.hash)
                } catch let error {
                    print(error)
                }
            }
        }
    }

    @objc func erc20() {

        Task {
            if let url = URL(string: "https://goerli.blockpi.network/v1/rpc/public"),
               let keystoreManager = KeystoreManager.share,
               let ethAddress = keystoreManager.addresses?.first,
               let provider = try? await Web3HttpProvider(url: url, network: .Goerli, keystoreManager: keystoreManager) {
                let web3 = Web3(provider: provider)
                if let value = try? await web3.eth.getBalance(for: ethAddress) {
                    let price = Utilities.formatToPrecision(value)
                    print("price:",price)
                }
                if let value = try? await web3.eth.gasPrice() {
                    let gas = Utilities.formatToPrecision(value)
                    print("gas:", gas)
                }
                
                let value = Utilities.parseToBigUInt("0.00001", decimals: 8)!
                let toAddress = EthereumAddress(from: "0xE24aa36Cc8bf41b0b8378809aCc8d11a35EF4E9f")!
                let contractAddress = EthereumAddress(from: "0x18ec87cf170e2a5cd8fbda57008f0b9ebfac6eb9")!

                let ethContract = try! EthereumContract(Web3.Utils.erc20ABI, at: contractAddress)

                let transfer = ethContract.method("transfer", parameters: [toAddress, value], extraData: Data())



                let erc20 = ERC20(web3: web3, provider: provider, address: contractAddress)
                let opti = try! await erc20.transfer(from: ethAddress, to: toAddress, amount: "0.001")
                let result = try! await opti.writeToChain(password: globalPassword)
                print(result)

                var transaction: CodableTransaction = .emptyTransaction
                transaction.from = ethAddress
                transaction.chainID = 5
//                transaction.gasLimit = 21_000
                transaction.data = transfer!
                transaction.to = EthereumAddress(from: "0x18ec87cf170e2a5cd8fbda57008f0b9ebfac6eb9")!

                do {
//                    transaction.gasPrice = try await web3.eth.gasPrice()
                    transaction.nonce = try await web3.eth.getTransactionCount(for: ethAddress)
                    try transaction.sign(privateKey: keystoreManager.UNSAFE_getPrivateKeyData(password: globalPassword, account: ethAddress))
                    print(transaction)
                    let result = try await web3.eth.send(raw: transaction.encode()!)
                    print(result.hash)
                } catch let error {
                    print(error)
                }
                

            }
        }
    }

}

extension Utilities {
    static func publicToBtcAddress(_ publicKey: Data) -> String {
        let prefix = Data([0x30])
        let payload = try! RIPEMD160.hash(message: publicKey.sha256())
        let checksum = (prefix + payload).sha256().sha256().prefix(4)
        return Array(prefix + payload + checksum).base58EncodedString
    }
}
