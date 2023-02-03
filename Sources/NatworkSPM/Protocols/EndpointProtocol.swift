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
    var headers: [String: Any] { get }
    var params: [String: Any] { get }
    var method: EndpointMethod { get }
    var decodingStrategy: JSONDecoder.KeyDecodingStrategy { get }
    var cachePolicy: URLRequest.CachePolicy { get set }
}

public extension EndpointProtocol {
    var url: String {
        host.appending(path)
    }
    var headers: [String: Any] { [:] }
    var params: [String: Any] { [:] }
    var decodingStrategy: JSONDecoder.KeyDecodingStrategy { .useDefaultKeys }
    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
}
