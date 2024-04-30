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
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<T, ApiError>) -> Void
    )
    func handleDataContent(
        endpoint: EndpointProtocol,
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<Data, ApiError>) -> Void
    )
    func handleNoContent(
        endpoint: EndpointProtocol,
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<NoContentResponse, ApiError>) -> Void
    )
    func handleAsyncContent<T: Decodable>(
        endpoint: EndpointProtocol,
        resultType: T.Type,
        data: (Data, URLResponse)?) -> Result<T, ApiError>
    func handleAsyncError(_ error: Error) -> ApiError
}

open class CallbackHandler: CallbackHandlerProtocol {
    private let networkHelper: NetworkHelperProtocol.Type
    
    public init(networkHelper: NetworkHelperProtocol.Type = NetworkHelper.self) {
        self.networkHelper = networkHelper
    }
    
    public func handleContent<T: Decodable>(
        endpoint: EndpointProtocol,
        resultType: T.Type,
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<T, ApiError>) -> Void
    ) {
        if let foundError = networkHelper.verifyError(response: response, error: error) {
            completion(.failure(foundError))
            return
        }
        guard let unwrappedData = data else {
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
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<Data, ApiError>) -> Void
    ) {
        if let foundError = networkHelper.verifyError(response: response, error: error) {
            completion(.failure(foundError))
            return
        }
        guard let unwrappedData = data else {
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
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<NoContentResponse, ApiError>) -> Void
    ) {
        if let foundError = networkHelper.verifyError(response: response, error: error) {
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
    
    public func handleAsyncContent<T: Decodable>(
        endpoint: EndpointProtocol,
        resultType: T.Type,
        data: (Data, URLResponse)?) -> Result<T, ApiError> {
        if let foundError = networkHelper.verifyError(response: data?.1) {
            return .failure(foundError)
        }
        guard let unwrappedData = data else {
            return .failure(.nilData)
        }
        guard !unwrappedData.0.isEmpty else {
            return .failure(.noContent)
        }
        let decodedData: T? = networkHelper.decodeData(data: unwrappedData.0, decodingStrategy: endpoint.decodingStrategy)
            
        guard let unwrappedDecodedData = decodedData else {
            return .failure(.jsonParse)
        }
        return .success(unwrappedDecodedData)
    }
    
    public func handleAsyncError(_ error: Error) -> ApiError {
        networkHelper.verifyAsyncError(error)
    }
}
