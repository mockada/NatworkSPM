//
//  Dictionary+Extension.swift
//  
//
//  Created by Jade Silveira on 02/02/23.
//

import Foundation

extension Dictionary {
    func toQueryItems() -> [URLQueryItem] {
        self.map { .init(name: $0.key as? String ?? "", value: $0.value as? String ?? "") }
    }
}
