//
//  DispatchQueue+Extension.swift
//
//
//  Created by Jade Silveira on 01/12/21.
//

import Foundation

extension DispatchQueue: DispatchQueueProtocol {
    public func callAsync(group: DispatchGroup? = nil,
        qos: DispatchQoS = .unspecified,
        flags: DispatchWorkItemFlags = [],
        execute work: @escaping () -> Void
    ) {
        async(group: group, qos: qos, flags: flags, execute: work)
    }
}
