//
//  Dictionary+Extension.swift
//  
//
//  Created by Jade Silveira on 02/02/23.
//

import Foundation

extension Dictionary {
    func toQueryItems() -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        for param in self {
            let queryItem: URLQueryItem = .init(name: param.key as? String ?? "",
                                                value: param.value as? String ?? "")
            queryItems.append(queryItem)
        }
        return queryItems
    }
}
