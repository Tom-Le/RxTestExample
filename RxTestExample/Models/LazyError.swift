//
//  LazyError.swift
//  RxTestExample
//
//  Created by Son on 5/29/17.
//  Copyright © 2017 Son Le. All rights reserved.
//

import Foundation

struct LazyError: Error {

    let message: String

    var localizedDescription: String {
        return "<Error: \(message)>"
    }

}
