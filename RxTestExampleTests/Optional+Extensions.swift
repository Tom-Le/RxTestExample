//
//  Optional+Extensions.swift
//  RxTestExample
//
//  Created by Son on 5/31/17.
//  Copyright © 2017 Son Le. All rights reserved.
//

import Foundation

extension Optional {

    enum Error: Swift.Error, LocalizedError {
        case unexpectedNil

        var errorDescription: String? {
            switch self {
            case .unexpectedNil:
                return "Unexpected nil"
            }
        }
    }

    func unwrap() throws -> Wrapped {
        guard let value = self else { throw Error.unexpectedNil }
        return value
    }
}
