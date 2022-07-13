//
//  EndpointHeader.swift
//  NetworkCore
//
//  Created by Jade Silveira on 20/12/21.
//

public struct EndpointHeader {
    public let value: String
    public let field: String
    
    public init(value: String, field: String) {
        self.value = value
        self.field = field
    }
}
