//
//  WalletManager.swift
//  Wallet
//
//  Created by 薛焱 on 2023/4/19.
//

import UIKit
import web3swift
import Web3Core

let globalPassword = "88888888"

public class WalletManager: NSObject, Codable {

    private static var walletPath: String {
        let usr = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return usr + "/wallet"
    }

    static var share: WalletManager {
        if let data = FileManager.default.contents(atPath: walletPath) {
            do {
                let manager = try JSONDecoder().decode(WalletManager.self, from: data)
                return manager
            } catch let error {
                print(error)
            }
        }
        return WalletManager()
    }

    var activeWallet: Wallet? {
        if let wallet = wallets.first(where: { $0.id == activeWalletId }) {
            return wallet
        } else if let wallet = wallets.first {
            activeWalletId = wallet.id
            return wallet
        } else {
            return nil
        }
    }

    var wallets: [Wallet] = []

    private var activeWalletId: String?

    func active(with walletId: String) {
        activeWalletId = walletId
        save()
    }

    func add(_ wallet: Wallet) {
        wallets.append(wallet)
        if activeWalletId == nil {
            activeWalletId = wallet.id
        }
        save()
    }

    func delete(_ walletId: String) {
        wallets.removeFirst(where: { $0.id == walletId })
        if walletId == activeWalletId {
            activeWalletId = wallets.first?.id
        }
        save()
    }

    func update(_ wallet: Wallet) {
        guard let oldWallet = find(wallet.id) else { return }
        wallets.replace([oldWallet], with: [wallet])
        save()
    }

    func find(_ walletId: String) -> Wallet? {
        return wallets.first(where: { $0.id == walletId})
    }

    func save() {
        let data = try? JSONEncoder().encode(self)
        FileManager.default.createFile(atPath: WalletManager.walletPath, contents: data)
    }
}

public class Wallet: NSObject, Codable {
    var name: String = "" {
        didSet {
           id = (name + address).md5()
        }
    }

    private(set) var id: String = ""

    var address: String = "" {
        didSet{
            id = (name + address).md5()
        }
    }

    var keystore: AbstractKeystore? {
        if let ethAddress = EthereumAddress(from: address) {
            return KeystoreManager.share?.walletForAddress(ethAddress)
        }
        return nil
    }

    var tokens: [TokenModel] = []
}

