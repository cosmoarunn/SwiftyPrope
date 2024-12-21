//
//  UncaughtExceptionHandler.swift
//  PAndE
//
//  Created by ARUN PANNEERSELVAM on 12/12/2024.
//

import Foundation
import CryptoKit


open class ExceptionHandler {
    
    init() {
        PropeSingleton.shared.register(self)
    }
    
   
}


