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
    public var session: URLSessionProtocol { getSession() }
    public var securitySessionEnabled: Bool = false
    public var securitySession: SecuritySession?
    
    private var expectedDomain: String = ""
    private var configuration: URLSessionConfiguration = URLSessionConfiguration.default
    private var sessionDelegate: URLSessionProtocol = URLSession(configuration: .default)
    
    public init() { }
    
    public init(expectedDomain: String,
                configuration: URLSessionConfiguration,
                sessionDelegate: URLSessionProtocol) {
        self.expectedDomain = expectedDomain
        self.configuration = configuration
        self.sessionDelegate = sessionDelegate
    }
}

private extension SessionCore {
    func createURLSessionWithSslEnabled(calledDomain: String) -> URLSessionProtocol {
        let configuration = URLSessionConfiguration.default
        let isExpectedDomain = calledDomain.contains(expectedDomain)
        let delegate = isExpectedDomain ? sessionDelegate : nil
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
    
    func getSession() -> URLSessionProtocol {
        guard let securitySession = securitySession, securitySessionEnabled else {
            return sessionDelegate
        }
        return createURLSessionWithSslEnabled(calledDomain: securitySession.currentDomain)
    }
}
