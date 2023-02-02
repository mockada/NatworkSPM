//
//  SessionCore.swift
//  
//
//  Created by Jade Silveira on 02/02/23.
//

import Foundation

public protocol SessionCoreProtocol {
    var session: URLSessionProtocol { get }
    var securitySessionEnabled: Bool { get set }
    var securitySession: SecuritySession? { get set }
}

open class SessionCore: SessionCoreProtocol {
    public var session: URLSessionProtocol {
        if let securitySession = securitySession, securitySessionEnabled {
            return createURLSessionWithSslEnabled(domain: securitySession.currentDomain,
                                                  expectedDomain: securitySession.expectedDomain)
        }
        return createURLSessionWithSslDisabled()
    }
    public var securitySessionEnabled: Bool = false
    public var securitySession: SecuritySession?
    
    public init() { }
}

private extension SessionCore {
    func createURLSessionWithSslEnabled(
        domain: String,
        expectedDomain: String,
        sessionDelegate: URLSessionDelegate? = nil
    ) -> URLSessionProtocol {
        guard let sessionDelegate = sessionDelegate else {
            return createURLSessionWithSslDisabled()
        }
        let configuration = URLSessionConfiguration.default
        let isExpectedDomain = domain.contains(expectedDomain)
        let delegate = isExpectedDomain ? sessionDelegate : nil
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
    
    func createURLSessionWithSslDisabled() -> URLSessionProtocol {
        URLSession(configuration: .default)
    }
}
