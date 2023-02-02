//
//  NetworkHelper.swift
//  
//
//  Created by Jade Silveira on 02/02/23.
//

import Foundation

public protocol NetworkHelperProtocol {
    static func decodeData<T: Decodable>(data: Data, decodingStrategy: JSONDecoder.KeyDecodingStrategy) -> T?
    static func verifyError(sessionResult: URLSessionResult) -> ApiError?
}

public enum NetworkHelper: NetworkHelperProtocol {
    public static func decodeData<T: Decodable>(data: Data, decodingStrategy: JSONDecoder.KeyDecodingStrategy) -> T? {
        try? JSONDecoder(keyDecodingStrategy: decodingStrategy).decode(T.self, from: data)
    }
    
    public static func verifyError(sessionResult: URLSessionResult) -> ApiError? {
        if let error = sessionResult.error {
            return .server(error: error)
        }
        guard let httpResponse = sessionResult.response as? HTTPURLResponse else {
            return .nilResponse
        }
        let statusCode = StatusCode.getType(code: httpResponse.statusCode)
        return statusCode != .success ? .statusCode(code: statusCode) : nil
    }
}
