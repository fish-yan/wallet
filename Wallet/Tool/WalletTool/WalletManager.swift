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

    @discardableResult
    func active(with walletId: String) -> Bool {
        activeWalletId = walletId
        return save()
    }

    @discardableResult
    func add(_ wallet: Wallet) -> Bool {
        if wallets.contains(where: {$0.id == wallet.id}) {
            print("wallet is exist")
            return false
        }
        wallets.append(wallet)
        if activeWalletId == nil {
            activeWalletId = wallet.id
        }
        return save()
    }

    @discardableResult
    func delete(_ walletId: String) -> Bool {
        guard let _ = wallets.removeFirst(where: { $0.id == walletId }) else {
            print("wallet not exist")
            return false
        }
        if walletId == activeWalletId {
            activeWalletId = wallets.first?.id
        }
        return save()
    }

    @discardableResult
    func update(_ wallet: Wallet) -> Bool {
        guard let oldWallet = find(wallet.id) else { return false }
        wallets.replace([oldWallet], with: [wallet])
        return save()
    }

    func find(_ walletId: String) -> Wallet? {
        return wallets.first(where: { $0.id == walletId})
    }

    @discardableResult
    func save() -> Bool {
        let data = try? JSONEncoder().encode(self)
        return FileManager.default.createFile(atPath: WalletManager.walletPath, contents: data)
    }
}

public class Wallet: NSObject, Codable {
    private(set) var id: String = ""

    var name: String = ""

    var address: String = ""

    var keystore: AbstractKeystore? {
        if let ethAddress = EthereumAddress(from: address) {
            return KeystoreManager.share?.walletForAddress(ethAddress)
        }
        return nil
    }

    var tokens: [TokenModel] = []

    private override init() { }

    init(_ name: String, address: String) {
        super.init()
        self.name = name
        self.address = address
        self.id = (name + address).md5()
    }
}

