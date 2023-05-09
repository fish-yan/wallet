//
//  TokenModel.swift
//  Wallet
//
//  Created by 薛焱 on 2023/4/27.
//

import UIKit
import web3swift
import Web3Core
import BigInt

public enum TokenType: Int, Codable {
    case native = 0
    case erc20
}

public protocol TokenProtocol: NSObjectProtocol, Codable {
    func transfer(to: String, amount: String, password: String) async throws -> String
}

public class TokenModel: NSObject, TokenProtocol {

    var type: TokenType = .native

    var contract: String?

    var chain: ChainModel?

    public func transfer(to: String, amount: String, password: String) async throws -> String {
        guard let wallet = WalletManager.share.activeWallet else {
            throw Web3Error.walletError
        }
        guard let keystore = wallet.keystore else {
            throw Web3Error.walletError
        }
        guard let chain else {
            throw Web3Error.nodeError(desc: "chain error")
        }
        guard let url = URL(string: chain.rpcUrl) else {
            throw Web3Error.nodeError(desc: "rpc url error")
        }
        guard  let fromAddress = EthereumAddress(wallet.address) else {
            throw Web3Error.walletError
        }
        guard let toAddress = EthereumAddress(to) else {
            throw Web3Error.inputError(desc: "to address not valid")
        }
        guard let value = Utilities.parseToBigUInt(amount, units: .ether) else {
            throw Web3Error.inputError(desc: "amount not valid")
        }
        let provider = try await Web3HttpProvider(url: url, network: .Custom(networkID: BigUInt(chain.chainId)))
        let web3 = Web3(provider: provider)

        switch type {
        case .native:
            return try await transferNative(from: fromAddress, to: toAddress, value: value, password: password, web3: web3, keystore: keystore)
        case .erc20:
            return try await transferERC20(from: fromAddress, to: toAddress, amount: amount, password: password, web3: web3)
        }
    }

    func transferNative(from: EthereumAddress, to: EthereumAddress, value: BigUInt, password: String, web3: Web3, keystore: AbstractKeystore) async throws -> String {
        var transaction: CodableTransaction = .emptyTransaction
        transaction.chainID = web3.provider.network?.chainID
        transaction.value = value
        transaction.from = from
        transaction.to = to
        transaction.data = "这是数据阿".data(using: .utf8)!

        let policyResolver = PolicyResolver(provider: web3.provider)
        try await policyResolver.resolveAll(for: &transaction)

        try transaction.sign(privateKey: keystore.UNSAFE_getPrivateKeyData(password: password, account: from))
        guard let data = transaction.encode() else {
            throw Web3Error.transactionSerializationError
        }
        let result = try await web3.eth.send(raw: data)
        return result.hash
    }

    func transferERC20(from: EthereumAddress, to: EthereumAddress, amount: String, password: String, web3: Web3) async throws -> String {
        guard let contract,
              let contractAddress = EthereumAddress(contract) else {
            throw Web3Error.inputError(desc: "contract address error")
        }
        web3.addKeystoreManager(KeystoreManager.share)
        let erc20 = ERC20(web3: web3, provider: web3.provider, address: contractAddress)
        let opti = try await erc20.transfer(from: from, to: to, amount: amount)
        let result = try await opti.writeToChain(password: password)
        return result.hash
    }
}
