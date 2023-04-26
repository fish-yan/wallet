//
//  Wallet.swift
//  Wallet
//
//  Created by 薛焱 on 2023/4/19.
//

import UIKit
import web3swift
import Web3Core

public class EVMWallet: NSObject {
    var mnemonic: String?
    var privateKey: Data?
    var publicKey: Data?
    var address: EthereumAddress?

    private var queue = DispatchQueue(label: "wallet")

    init(chain: ChainModel) {
        super.init()
    }

    func create(password: String) {
        guard let mnemonic = try? BIP39.generateMnemonics(bitsOfEntropy: 256, language: .english) else {
            return
        }
        importWallet(mnemonic: mnemonic, password: password)
    }

    func importWallet(mnemonic: String, password: String) {
        self.mnemonic = mnemonic
        guard let walletAddress = try? BIP32Keystore(mnemonics: mnemonic, password: password) else {
            return
        }
        guard let address = walletAddress.addresses?.first else {
            return
        }
        self.address = address
        guard let privateKey = try? walletAddress.UNSAFE_getPrivateKeyData(password: password, account: address) else {
            return
        }
        self.privateKey = privateKey
        guard let pubKey = SECP256K1.privateToPublic(privateKey: privateKey, compressed: true) else {
            return
        }
        self.publicKey = pubKey
    }

    func importWallet(privateKey: String, password: String) {
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let dataKey = Data.fromHex(formattedKey) else {
            return
        }
        guard let keystore = try? EthereumKeystoreV3(privateKey: dataKey, password: password) else {
            return
        }
        let manager = KeystoreManager([keystore])
        guard let address = keystore.addresses?.first else {
            return
        }
        self.address = address
        guard let walletAddress = manager.addresses?.first?.address else {
            return
        }

    }
}
