//
//  ChainManager.swift
//  Wallet
//
//  Created by 薛焱 on 2023/4/19.
//

import UIKit
import HandyJSON

public class ChainManager: NSObject {

    static let manager = ChainManager()

    var chainList: [ChainModel] = []

    private override init() {
        super.init()
        chainListFromLocal()
    }

    private func chainListFromLocal() {
        if let path = Bundle.main.path(forResource: "chains", ofType: "json"),
           let data = FileManager.default.contents(atPath: path),
           let chain = try? JSONDecoder().decode(ChainListModel.self, from: data) {
            chainList = chain.chainList
        }
    }
}
