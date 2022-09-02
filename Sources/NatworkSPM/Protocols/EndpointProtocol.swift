//
//  EndpointProtocol.swift
//  NatworkSPM
//
//  Created by Jade Silveira on 01/12/21.
//

import Foundation

public protocol EndpointProtocol {
    var host: String { get }
    var path: String { get }
    var headers: [EndpointHeader] { get }
    var paramsDict: [String: Any] { get }
    var params: AnyEncodable { get }
    var paramsDTO: Encodable { get set }
    var method: EndpointMethod { get }
    var decodingStrategy: JSONDecoder.KeyDecodingStrategy { get }
}

public extension EndpointProtocol {
    var url: String { host.appending(path) }
    var headers: [EndpointHeader] { [] }
    var paramsDict: [String: Any] { [:] }
    var params: AnyEncodable { AnyEncodable(paramsDTO) }
}
