//
//  ChainModel.swift
//  Wallet
//
//  Created by 薛焱 on 2023/4/19.
//

import UIKit

struct ChainModel: Codable {
    var chainType: String = ""
    var chainId: Int = 0
    var rpcUrl: String = ""
    var icon: String = ""
    var name: String = ""
    var unit: String = ""
    var txExplorerUrl: String = ""
    var addressExplorerUrl: String = ""
}

struct ChainListModel: Codable {
    var chainList: [ChainModel] = []
}
