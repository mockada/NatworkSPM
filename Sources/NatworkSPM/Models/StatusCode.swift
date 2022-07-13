//
//  StatusCode.swift
//  NetworkCore
//
//  Created by Jade Silveira on 01/12/21.
//

public enum StatusCode: Equatable {
    case informational
    case success
    case redirection
    case clientError
    case serverError
    case undefined
    
    public static func getType(code: Int) -> Self {
        switch code {
        case 100..<200:
            return .informational
        case 200..<300:
            return .success
        case 300..<400:
            return .redirection
        case 400..<500:
            return .clientError
        case 500..<600:
            return .serverError
        default:
            return .undefined
        }
    }
}
