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
        sessionCore.session.fetchData(with: url) { data, response, error in
            self.queue.callAsync {
                let sessionResult: URLSessionResult = .init(data: data,
                                                            response: response,
                                                            error: error)
                self.callbackHandler.handleContent(endpoint: endpoint,
                                            resultType: resultType,
                                            sessionResult: sessionResult,
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
        sessionCore.session.fetchData(with: url) { data, response, error in
            self.queue.callAsync {
                self.callbackHandler.handleNoContent(endpoint: endpoint,
                                              sessionResult: URLSessionResult(data: data,
                                                                              response: response,
                                                                              error: error),
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
        sessionCore.session.fetchData(with: request) { data, response, error in
            self.queue.callAsync {
                let sessionResult: URLSessionResult = .init(data: data,
                                                            response: response,
                                                            error: error)
                self.callbackHandler.handleContent(endpoint: endpoint,
                                            resultType: resultType,
                                            sessionResult: sessionResult,
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
        sessionCore.session.fetchData(with: request) { data, response, error in
            self.queue.callAsync {
                self.callbackHandler.handleNoContent(endpoint: endpoint,
                                              sessionResult: URLSessionResult(data: data,
                                                                              response: response,
                                                                              error: error),
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
        sessionCore.session.fetchData(with: request) { data, response, error in
            self.queue.callAsync {
                let sessionResult: URLSessionResult = .init(data: data,
                                                            response: response,
                                                            error: error)
                self.callbackHandler.handleContent(endpoint: endpoint,
                                            resultType: resultType,
                                            sessionResult: sessionResult,
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
        sessionCore.session.fetchData(with: request) { data, response, error in
            self.queue.callAsync {
                let sessionResult: URLSessionResult = .init(data: data,
                                                            response: response,
                                                            error: error)
                self.callbackHandler.handleNoContent(endpoint: endpoint,
                                              sessionResult: sessionResult,
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
        sessionCore.session.fetchData(with: url) { data, response, error in
            self.queue.callAsync {
                let sessionResult: URLSessionResult = .init(data: data,
                                                            response: response,
                                                            error: error)
                self.callbackHandler.handleDataContent(endpoint: endpoint,
                                                sessionResult: sessionResult,
                                                completion: completion)
            }
        }
    }
}
