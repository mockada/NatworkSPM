//
//  SessionProtocol.swift
//  NetworkCore
//
//  Created by Jade Silveira on 01/12/21.
//

import Foundation

public typealias URLSessionCompletion = (Data?, URLResponse?, Error?) -> Void

public protocol URLSessionProtocol: URLSessionDelegate {
    func fetchData(with url: URL, completionHandler: @escaping URLSessionCompletion)
    func fetchData(with urlRequest: URLRequest, completionHandler: @escaping URLSessionCompletion)
    func fetchDataAsync(with url: URL) async throws -> (Data, URLResponse)?
}
