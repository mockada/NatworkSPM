//
//  Encodable+Extension.swift
//  
//
//  Created by Jade on 02/09/22.
//

extension Encodable {
    func encode(to container: inout SingleValueEncodingContainer) throws {
        try container.encode(self)
    }
}
