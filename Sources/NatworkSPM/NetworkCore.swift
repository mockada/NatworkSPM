//
//  NetworkCore.swift
//  
//
//  Created by Jade Silveira on 01/12/21.
//

import Foundation

public protocol NetworkCoreProtocol {
    /// Fetch a decodable data through an url text.
     
    /// - Parameters:
    ///    - urlText: The url text to be fetched. Ex: "www.yoururl.com/path/param=value"
    ///    - resultType: The type of the object that will be returned. Ex: ObjectModel.self
    ///    - decodingStrategy: The decoding strategy to be used: convertFromSnakeCase, useDefaultKeys or custom.
    ///    - completion: The block to be called when the operation is complete. The block will pass a object with the resultType provided on success, otherwise an `ApiError`.
    func fetchData<T: Decodable>(
        urlText: String,
        resultType: T.Type,
        decodingStrategy: JSONDecoder.KeyDecodingStrategy,
        completion: @escaping (Result<T, ApiError>) -> Void
    )
    /// Fetch a decodable data through an endpoint.
     
    /// - Parameters:
    ///    - endpoint: The endpoint implementation of EndpointProtocol to be fetched as URLRequest.
    ///    - resultType: The type of the object that will be returned. Ex: ObjectModel.self
    ///    - completion: The block to be called when the operation is complete. The block will pass a object with the resultType provided on success, otherwise an `ApiError`.
    func fetchData<T: Decodable>(
        endpoint: EndpointProtocol,
        resultType: T.Type,
        completion: @escaping (Result<T, ApiError>) -> Void
    )
    /// Fetch no content through an endpoint.
    
    /// - Parameters:
    ///    - endpoint: The endpoint implementation of EndpointProtocol to be fetched as URLRequest.
    ///    - completion: The block to be called when the operation is complete. The block will pass a NoContentResponse (Void) provided on success, otherwise an `ApiError`.
    func fetchNoContent(
        endpoint: EndpointProtocol,
        completion: @escaping (Result<NoContentResponse, ApiError>) -> Void
    )
    /// Fetch data through an url text.
     
    /// - Parameters:
    ///    - urlText: The url text to be fetched. Ex: "www.yoururl.com/path/param=value"
    ///    - completion: The block to be called when the operation is complete. The block will pass a data on success, otherwise an `ApiError`.
    func fetchData(
        urlText: String,
        completion: @escaping (Result<Data, ApiError>) -> Void
    )
}

public extension NetworkCoreProtocol {
    func fetchData<T: Decodable>(
        urlText: String,
        resultType: T.Type,
        decodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        completion: @escaping (Result<T, ApiError>) -> Void
    ) {
        fetchData(urlText: urlText, resultType: resultType, decodingStrategy: decodingStrategy, completion: completion)
    }
}

public final class NetworkCore: NetworkCoreProtocol {
    private let sessionCore: SessionCoreProtocol
    private let queue: DispatchQueueProtocol
    private let requestFactory: RequestFactoryProtocol.Type
    
    public init(sessionCore: SessionCoreProtocol = SessionCore(),
                callbackQueue: DispatchQueueProtocol = DispatchQueue.main,
                requestFactory: RequestFactoryProtocol.Type = RequestFactory.self) {
        self.sessionCore = sessionCore
        self.queue = callbackQueue
        self.requestFactory = requestFactory
    }
    
    public func fetchData<T: Decodable>(
        urlText: String,
        resultType: T.Type,
        decodingStrategy: JSONDecoder.KeyDecodingStrategy,
        completion: @escaping (Result<T, ApiError>) -> Void
    ) {
        guard let url = URL(string: urlText) else {
            completion(.failure(.urlParse))
            return
        }
        sessionCore.session.fetchData(with: url) { data, response, error in
            self.queue.callAsync {
                if let foundError = self.verifyError(data: data, response: response, error: error) {
                    completion(.failure(foundError))
                    return
                }
                guard let unwrappedData = data else {
                    completion(.failure(.nilData))
                    return
                }
                let decodedData: T? = self.decodeData(data: unwrappedData, decodingStrategy: decodingStrategy)
                guard let unwrappedDecodedData = decodedData else {
                    completion(.failure(.jsonParse))
                    return
                }
                completion(.success(unwrappedDecodedData))
            }
        }
    }
    
    public func fetchData<T: Decodable>(
        endpoint: EndpointProtocol,
        resultType: T.Type,
        completion: @escaping (Result<T, ApiError>) -> Void
    ) {
        guard let request = requestFactory.makeRequest(endpoint: endpoint) else {
            completion(.failure(.urlParse))
            return
        }
        sessionCore.session.fetchData(with: request) { data, response, error in
            self.queue.callAsync {
                if let foundError = self.verifyError(data: data, response: response, error: error) {
                    completion(.failure(foundError))
                    return
                }
                guard let unwrappedData = data else {
                    completion(.failure(.nilData))
                    return
                }
                guard unwrappedData.isEmpty else {
                    completion(.failure(.noContent))
                    return
                }
                let decodedData: T? = self.decodeData(data: unwrappedData, decodingStrategy: endpoint.decodingStrategy)
                guard let unwrappedDecodedData = decodedData else {
                    completion(.failure(.jsonParse))
                    return
                }
                completion(.success(unwrappedDecodedData))
            }
        }
    }
    
    public func fetchNoContent(
        endpoint: EndpointProtocol,
        completion: @escaping (Result<NoContentResponse, ApiError>) -> Void
    ) {
        guard let request = requestFactory.makeRequest(endpoint: endpoint) else {
            completion(.failure(.urlParse))
            return
        }
        sessionCore.session.fetchData(with: request) { data, response, error in
            self.queue.callAsync {
                if let foundError = self.verifyError(data: data, response: response, error: error) {
                    completion(.failure(foundError))
                    return
                }
                guard let unwrappedData = data else {
                    completion(.failure(.nilData))
                    return
                }
                guard unwrappedData.isEmpty else {
                    completion(.failure(.foundContent))
                    return
                }
                completion(.success)
            }
        }
    }
    
    public func fetchData(
        urlText: String,
        completion: @escaping (Result<Data, ApiError>) -> Void
    ) {
        guard let url = URL(string: urlText) else {
            completion(.failure(.urlParse))
            return
        }
        sessionCore.session.fetchData(with: url) { data, response, error in
            self.queue.callAsync {
                if let foundError = self.verifyError(data: data, response: response, error: error) {
                    completion(.failure(foundError))
                    return
                }
                guard let unwrappedData = data else {
                    completion(.failure(.nilData))
                    return
                }
                completion(.success(unwrappedData))
            }
        }
    }
}
    
private extension NetworkCore {
    func decodeData<T: Decodable>(data: Data, decodingStrategy: JSONDecoder.KeyDecodingStrategy) -> T? {
        try? JSONDecoder(keyDecodingStrategy: decodingStrategy).decode(T.self, from: data)
    }
    
    func verifyError(data: Data?, response: URLResponse?, error: Error?) -> ApiError? {
        if let error = error {
            return .server(error: error)
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            return .nilResponse
        }
        let statusCode = StatusCode.getType(code: httpResponse.statusCode)
        return statusCode != .success ? .statusCode(code: statusCode) : nil
    }
}
