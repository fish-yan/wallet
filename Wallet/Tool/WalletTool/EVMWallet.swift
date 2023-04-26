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

    func create(password: String, count: Int = 12) throws {
        let bitsOfEntropy = count / 12 * 128
        guard let mnemonic = try BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy, language: .english) else {
            throw AbstractKeystoreError.noEntropyError
        }
        try importWallet(mnemonic: mnemonic, password: password)
    }

    func importWallet(mnemonic: String, password: String) throws {
        guard let keystore = try BIP32Keystore(mnemonics: mnemonic, password: password) else {
            throw AbstractKeystoreError.noEntropyError
        }
        try KeystoreManager.addKeystore(keystore)
    }

    func importWallet(privateKey: String, password: String) throws {
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let dataKey = Data.fromHex(formattedKey) else {
            throw AbstractKeystoreError.aesError
        }
        guard let keystore = try EthereumKeystoreV3(privateKey: dataKey, password: password) else {
            throw AbstractKeystoreError.noEntropyError
        }
        try KeystoreManager.addKeystore(keystore)
    }

    func importWallet(keystoreData: Data, password: String) throws {
        guard let keystore = BIP32Keystore(keystoreData) else {
            throw AbstractKeystoreError.noEntropyError
        }
        try KeystoreManager.addKeystore(keystore)
    }

//    func privateKey(_ password: String) -> Data? {
//        guard let address = address else {
//            return nil
//        }
//        return try? keystore.UNSAFE_getPrivateKeyData(password: password, account: address)
//    }

//    func publicKey(_ privateKey: Data) -> Data? {
//        return SECP256K1.privateToPublic(privateKey: privateKey, compressed: true)
//    }
}
