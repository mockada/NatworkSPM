//
//  RequestFactory.swift
//  
//
//  Created by Jade Silveira on 02/02/23.
//

import Foundation

public protocol RequestFactoryProtocol {
    static func makeRequest(endpoint: EndpointProtocol) -> URLRequest?
}

public enum RequestFactory: RequestFactoryProtocol {
    public static func makeRequest(endpoint: EndpointProtocol) -> URLRequest? {
        guard let url = URL(string: endpoint.url) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpBody = try? JSONSerialization.data(withJSONObject: endpoint.params)
        
        for header in endpoint.headers {
            request.addValue(header.value as? String ?? "", forHTTPHeaderField: header.key)
        }
        return request
    }
}
