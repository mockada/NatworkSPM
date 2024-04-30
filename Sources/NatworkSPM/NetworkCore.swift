//
//  NetworkCore.swift
//  
//
//  Created by Jade Silveira on 01/12/21.
//

import Foundation

public protocol NetworkCoreProtocol {
    func fetchDecodedDataWithURL<T: Decodable>(
        endpoint: EndpointProtocol,
        resultType: T.Type,
        completion: @escaping (Result<T, ApiError>) -> Void
    )
    func fetchNoContentWithURL(
        endpoint: EndpointProtocol,
        completion: @escaping (Result<NoContentResponse, ApiError>) -> Void
    )
    func fetchDecodedDataWithQueryParamRequest<T: Decodable>(
        endpoint: EndpointProtocol,
        resultType: T.Type,
        completion: @escaping (Result<T, ApiError>) -> Void
    )
    func fetchNoContentWithQueryParamRequest(
        endpoint: EndpointProtocol,
        completion: @escaping (Result<NoContentResponse, ApiError>) -> Void
    )
    func fetchDecodedDataWithBodyRequest<T: Decodable>(
        endpoint: EndpointProtocol,
        resultType: T.Type,
        completion: @escaping (Result<T, ApiError>) -> Void
    )
    func fetchNoContentWithBodyRequest(
        endpoint: EndpointProtocol,
        completion: @escaping (Result<NoContentResponse, ApiError>) -> Void
    )
    func fetchDataWithURL(
        endpoint: EndpointProtocol,
        completion: @escaping (Result<Data, ApiError>) -> Void
    )
    func fetchDecodedDataWithURLAsync<T: Decodable>(
        endpoint: EndpointProtocol,
        resultType: T.Type) async -> Result<T, ApiError>
}

open class NetworkCore: NetworkCoreProtocol {
    private let sessionCore: SessionCoreProtocol
    private let queue: DispatchQueueProtocol
    private let requestFactory: RequestFactoryProtocol.Type
    private let callbackHandler: CallbackHandlerProtocol
    
    public init(sessionCore: SessionCoreProtocol = SessionCore(),
                callbackQueue: DispatchQueueProtocol = DispatchQueue.main,
                requestFactory: RequestFactoryProtocol.Type = RequestFactory.self,
                callbackHandler: CallbackHandlerProtocol = CallbackHandler()) {
        self.sessionCore = sessionCore
        self.queue = callbackQueue
        self.requestFactory = requestFactory
        self.callbackHandler = callbackHandler
    }
    
    public func fetchDecodedDataWithURL<T: Decodable>(
        endpoint: EndpointProtocol,
        resultType: T.Type,
        completion: @escaping (Result<T, ApiError>) -> Void
    ) {
        guard let url = requestFactory.makeURL(endpoint: endpoint) else {
            completion(.failure(.urlParse))
            return
        }
        sessionCore.session.fetchData(with: url) { [queue, callbackHandler] data, response, error in
            queue.callAsync {
                callbackHandler.handleContent(
                    endpoint: endpoint,
                    resultType: resultType,
                    data: data,
                    response: response,
                    error: error,
                    completion: completion)
            }
        }
    }
    
    public func fetchNoContentWithURL(
        endpoint: EndpointProtocol,
        completion: @escaping (Result<NoContentResponse, ApiError>) -> Void
    ) {
        guard let url = requestFactory.makeURL(endpoint: endpoint) else {
            completion(.failure(.urlParse))
            return
        }
        sessionCore.session.fetchData(with: url) { [queue, callbackHandler] data, response, error in
            queue.callAsync {
                callbackHandler.handleNoContent(
                    endpoint: endpoint,
                    data: data,
                    response: response,
                    error: error,
                    completion: completion)
            }
        }
    }
    
    public func fetchDecodedDataWithQueryParamRequest<T: Decodable>(
        endpoint: EndpointProtocol,
        resultType: T.Type,
        completion: @escaping (Result<T, ApiError>) -> Void
    ) {
        guard let request = requestFactory.makeRequestWithQueryParam(endpoint: endpoint) else {
            completion(.failure(.urlParse))
            return
        }
        sessionCore.session.fetchData(with: request) { [queue, callbackHandler] data, response, error in
            queue.callAsync {
                callbackHandler.handleContent(
                    endpoint: endpoint,
                    resultType: resultType,
                    data: data,
                    response: response,
                    error: error,
                    completion: completion)
            }
        }
    }
    
    public func fetchNoContentWithQueryParamRequest(
        endpoint: EndpointProtocol,
        completion: @escaping (Result<NoContentResponse, ApiError>) -> Void
    ) {
        guard let request = requestFactory.makeRequestWithQueryParam(endpoint: endpoint) else {
            completion(.failure(.urlParse))
            return
        }
        sessionCore.session.fetchData(with: request) { [queue, callbackHandler] data, response, error in
            queue.callAsync {
                callbackHandler.handleNoContent(
                    endpoint: endpoint,
                    data: data,
                    response: response,
                    error: error,
                    completion: completion)
            }
        }
    }
    
    public func fetchDecodedDataWithBodyRequest<T: Decodable>(
        endpoint: EndpointProtocol,
        resultType: T.Type,
        completion: @escaping (Result<T, ApiError>) -> Void
    ) {
        guard let request = requestFactory.makeRequestWithBody(endpoint: endpoint) else {
            completion(.failure(.urlParse))
            return
        }
        sessionCore.session.fetchData(with: request) { [queue, callbackHandler] data, response, error in
            queue.callAsync {
                callbackHandler.handleContent(
                    endpoint: endpoint,
                    resultType: resultType,
                    data: data,
                    response: response,
                    error: error,
                    completion: completion)
            }
        }
    }
    
    public func fetchNoContentWithBodyRequest(
        endpoint: EndpointProtocol,
        completion: @escaping (Result<NoContentResponse, ApiError>) -> Void
    ) {
        guard let request = requestFactory.makeRequestWithBody(endpoint: endpoint) else {
            completion(.failure(.urlParse))
            return
        }
        sessionCore.session.fetchData(with: request) { [queue, callbackHandler] data, response, error in
            queue.callAsync {
                callbackHandler.handleNoContent(
                    endpoint: endpoint,
                    data: data,
                    response: response,
                    error: error,
                    completion: completion)
            }
        }
    }
    
    public func fetchDataWithURL(
        endpoint: EndpointProtocol,
        completion: @escaping (Result<Data, ApiError>) -> Void
    ) {
        guard let url = requestFactory.makeURL(endpoint: endpoint) else {
            completion(.failure(.urlParse))
            return
        }
        sessionCore.session.fetchData(with: url) { [queue, callbackHandler] data, response, error in
            queue.callAsync {
                callbackHandler.handleDataContent(
                    endpoint: endpoint,
                    data: data,
                    response: response,
                    error: error,
                    completion: completion)
            }
        }
    }
    
    public func fetchDecodedDataWithURLAsync<T: Decodable>(
        endpoint: EndpointProtocol,
        resultType: T.Type) async -> Result<T, ApiError> {
            guard let url = requestFactory.makeURL(endpoint: endpoint) else {
                return .failure(.urlParse)
            }
            do {
                let data = try await sessionCore.session.fetchDataAsync(with: url)
                let result = callbackHandler.handleAsyncContent(endpoint: endpoint,
                                                                resultType: resultType,
                                                                data: data)
                return result
            } catch (let error) {
                let error = callbackHandler.handleAsyncError(error)
                return .failure(error)
            }
    }
}
