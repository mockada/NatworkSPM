//
//  URLSession+Extension.swift
//  
//
//  Created by Jade Silveira on 01/12/21.
//

import Foundation

extension URLSession: URLSessionProtocol {
    public func fetchData(with url: URL, completionHandler: @escaping URLSessionCompletion) {
        let task: URLSessionDataTask = dataTask(with: url, completionHandler: completionHandler)
        task.resume()
    }
    public func fetchData(with urlRequest: URLRequest, completionHandler: @escaping URLSessionCompletion) {
        let task: URLSessionDataTask = dataTask(with: urlRequest, completionHandler: completionHandler)
        task.resume()
    }
    public func fetchDataAsync(with url: URL) async throws -> (Data, URLResponse)? {
        if #available(macOS 12.0, *) {
            if #available(iOS 15.0, *) {
                return try await data(from: url)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
