//
//  SecuritySession.swift
//  
//
//  Created by Jade Silveira on 02/02/23.
//

import Foundation

public struct SecuritySession {
    let currentDomain: String
    let expectedDomain: String
    let sessionDelegate: URLSessionDelegate
}
