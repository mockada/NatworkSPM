//
//  EndpointProtocol.swift
//  NetworkCore
//
//  Created by Jade Silveira on 01/12/21.
//

import Foundation

public protocol EndpointProtocol {
    var host: String { get }
    var path: String { get }
    var headers: [EndpointHeader] { get }
    var params: [String: Any] { get }
    var method: EndpointMethod { get }
    var decodingStrategy: JSONDecoder.KeyDecodingStrategy { get }
}

public extension EndpointProtocol {
    var url: String {
        host.appending(path)
    }
    var headers: [EndpointHeader] { [] }
    var params: [String: Any] { [:] }
}
