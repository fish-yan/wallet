//
//  Wallet.swift
//  Wallet
//
//  Created by 薛焱 on 2023/4/19.
//

import UIKit
import web3swift
import Web3Core

public class EVMWalletTool: NSObject {

    static func create(password: String, count: Int = 12) throws -> String {
        let bitsOfEntropy = count / 12 * 128
        guard let mnemonic = try BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy, language: .english) else {
            throw AbstractKeystoreError.noEntropyError
        }
        return try importWallet(mnemonic: mnemonic, password: password)
    }

    static func importWallet(mnemonic: String, password: String) throws -> String {
        guard let keystore = try BIP32Keystore(mnemonics: mnemonic, password: password) else {
            throw AbstractKeystoreError.noEntropyError
        }
        try KeystoreManager.addKeystore(keystore)
        guard let address = keystore.addresses?.first?.address else {
            throw AbstractKeystoreError.invalidAccountError
        }
        return address
    }

    static func importWallet(privateKey: String, password: String) throws -> String {
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let dataKey = Data.fromHex(formattedKey) else {
            throw AbstractKeystoreError.aesError
        }
        guard let keystore = try EthereumKeystoreV3(privateKey: dataKey, password: password) else {
            throw AbstractKeystoreError.noEntropyError
        }
        try KeystoreManager.addKeystore(keystore)
        guard let address = keystore.addresses?.first?.address else {
            throw AbstractKeystoreError.invalidAccountError
        }
        return address
    }

    static func importWallet(keystoreData: Data, password: String) throws -> String {
        guard let keystore = BIP32Keystore(keystoreData) else {
            throw AbstractKeystoreError.noEntropyError
        }
        try KeystoreManager.addKeystore(keystore)
        guard let address = keystore.addresses?.first?.address else {
            throw AbstractKeystoreError.invalidAccountError
        }
        return address
    }
}
