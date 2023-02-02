//
//  CallbackHandler.swift
//  
//
//  Created by Jade Silveira on 02/02/23.
//

import Foundation

public protocol CallbackHandlerProtocol {
    func handleContent<T: Decodable>(
        endpoint: EndpointProtocol,
        resultType: T.Type,
        sessionResult: URLSessionResult,
        completion: @escaping (Result<T, ApiError>) -> Void
    )
    func handleDataContent(
        endpoint: EndpointProtocol,
        sessionResult: URLSessionResult,
        completion: @escaping (Result<Data, ApiError>) -> Void
    )
    func handleNoContent(
        endpoint: EndpointProtocol,
        sessionResult: URLSessionResult,
        completion: @escaping (Result<NoContentResponse, ApiError>) -> Void
    )
}

open class CallbackHandler: CallbackHandlerProtocol {
    private let networkHelper: NetworkHelperProtocol.Type
    
    public init(networkHelper: NetworkHelperProtocol.Type = NetworkHelper.self) {
        self.networkHelper = networkHelper
    }
    
    public func handleContent<T: Decodable>(
        endpoint: EndpointProtocol,
        resultType: T.Type,
        sessionResult: URLSessionResult,
        completion: @escaping (Result<T, ApiError>) -> Void
    ) {
        if let foundError = networkHelper.verifyError(sessionResult: sessionResult) {
            completion(.failure(foundError))
            return
        }
        guard let unwrappedData = sessionResult.data else {
            completion(.failure(.nilData))
            return
        }
        guard !unwrappedData.isEmpty else {
            completion(.failure(.noContent))
            return
        }
        let decodedData: T? = networkHelper.decodeData(data: unwrappedData, decodingStrategy: endpoint.decodingStrategy)
        guard let unwrappedDecodedData = decodedData else {
            completion(.failure(.jsonParse))
            return
        }
        completion(.success(unwrappedDecodedData))
    }
    
    public func handleDataContent(
        endpoint: EndpointProtocol,
        sessionResult: URLSessionResult,
        completion: @escaping (Result<Data, ApiError>) -> Void
    ) {
        if let foundError = networkHelper.verifyError(sessionResult: sessionResult) {
            completion(.failure(foundError))
            return
        }
        guard let unwrappedData = sessionResult.data else {
            completion(.failure(.nilData))
            return
        }
        guard !unwrappedData.isEmpty else {
            completion(.failure(.noContent))
            return
        }
        completion(.success(unwrappedData))
    }
    
    public func handleNoContent(
        endpoint: EndpointProtocol,
        sessionResult: URLSessionResult,
        completion: @escaping (Result<NoContentResponse, ApiError>) -> Void
    ) {
        if let foundError = networkHelper.verifyError(sessionResult: sessionResult) {
            completion(.failure(foundError))
            return
        }
        guard let unwrappedData = sessionResult.data else {
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
