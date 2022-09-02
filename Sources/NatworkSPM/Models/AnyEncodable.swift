//
//  AnyEncodable.swift
//  NatworkSPM
//
//  Created by Jade on 02/09/22.
//

public struct AnyEncodable: Encodable {
    private let value: Encodable
    
    public init(_ value: Encodable) {
        self.value = value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try value.encode(to: &container)
    }
}
