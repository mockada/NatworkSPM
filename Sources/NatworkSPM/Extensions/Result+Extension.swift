//
//  Result+Extension.swift
//  
//
//  Created by Jade Silveira on 02/02/23.
//

public extension Result where Success == Void {
    static var success: Self { .success(()) }
}
