//
//  KeystoreManagerExtension.swift
//  Wallet
//
//  Created by 薛焱 on 2023/4/26.
//

import UIKit
import web3swift
import Web3Core

enum StorageError: Error {
    case keystoreExists
    case writeFailed
}

public extension KeystoreManager {

    static var storagePath: String {
        let usr = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return usr + "/keystore"
    }

    static func addKeystore(_ keystore: EthereumKeystoreV3) throws {
        if let data = try keystore.serialize(),
           let address = keystore.addresses?.first?.address {
            try save(at: "\(storagePath)/\(address)", data: data)
        }
    }

    static func addKeystore(_ keystore: BIP32Keystore) throws {
        if let data = try keystore.serialize(),
           let address = keystore.addresses?.first?.address {
            try save(at: "\(storagePath)/\(address)", data: data)
        }
    }

    private static func save(at path: String, data: Data) throws {
        if !FileManager.default.fileExists(atPath: storagePath) {
            try FileManager.default.createDirectory(atPath: storagePath, withIntermediateDirectories: false)
        }
        if FileManager.default.fileExists(atPath: path) {
            throw StorageError.keystoreExists
        }
        let success = FileManager.default.createFile(atPath: path, contents: data)
        if !success {
            throw StorageError.writeFailed
        }
    }

    static var share: KeystoreManager? {
        return KeystoreManager.managerForPath(storagePath, scanForHDwallets: true)
    }
}

