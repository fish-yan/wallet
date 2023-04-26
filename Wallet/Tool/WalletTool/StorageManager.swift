//
//  Storage.swift
//  Wallet
//
//  Created by 薛焱 on 2023/4/21.
//

import UIKit
import web3swift
import Web3Core

public class StorageManager: NSObject {
    static let share = StorageManager()

    var storagePath: String {
        let usr = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return usr + "/keystore"
    }

    func saveKeystore(_ keystore: EthereumKeystoreV3) {
        if let data = try? keystore.serialize(),
           let address = keystore.addresses?.first?.address {
            FileManager.default.createFile(atPath: "\(storagePath)/\(address)", contents: data)
        }
    }
}
