//
//  RequestFactory.swift
//  
//
//  Created by Jade Silveira on 02/02/23.
//

import Foundation

public protocol RequestFactoryProtocol {
    static func makeURL(endpoint: EndpointProtocol) -> URL?
    static func makeRequestWithBody(endpoint: EndpointProtocol) -> URLRequest?
    static func makeRequestWithQueryParam(endpoint: EndpointProtocol) -> URLRequest?
}

open class RequestFactory: RequestFactoryProtocol {
    public static func makeURL(endpoint: EndpointProtocol) -> URL? {
        guard var urlComponents = URLComponents(string: endpoint.host) else { return nil }
        urlComponents.path = endpoint.path
        urlComponents.queryItems = endpoint.params.toQueryItems()
        return urlComponents.url
    }
    
    public static func makeRequestWithBody(endpoint: EndpointProtocol) -> URLRequest? {
        guard var urlComponents = URLComponents(string: endpoint.host) else { return nil }
        urlComponents.path = endpoint.path
        
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.cachePolicy = endpoint.cachePolicy
        request.httpBody = try? JSONSerialization.data(withJSONObject: endpoint.params)
        
        for header in endpoint.headers {
            request.addValue(header.value as? String ?? "", forHTTPHeaderField: header.key)
        }
        return request
    }
    
    public static func makeRequestWithQueryParam(endpoint: EndpointProtocol) -> URLRequest? {
        guard var urlComponents = URLComponents(string: endpoint.host) else { return nil }
        urlComponents.path = endpoint.path
        urlComponents.queryItems = endpoint.params.toQueryItems()
        
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.cachePolicy = endpoint.cachePolicy
        
        for header in endpoint.headers {
            request.addValue(header.value as? String ?? "", forHTTPHeaderField: header.key)
        }
        return request
    }
}
