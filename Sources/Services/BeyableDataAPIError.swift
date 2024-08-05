//
//  BeyableDataAPIError.swift
//
//
//  Created by Ouamassi Brahim on 25/01/2024.
//

import Foundation
/// Handle Api Errors
public enum BeyableDataAPIError: Error, LocalizedError {
    case urlError(URLError)
    case responseError(Int)
    ///Error occured when decoding json to object
    case decodingError(DecodingError)
    case encodingError(Error)
    ///Other errors
    case anyError
    /// Description of the error
    var localizedDescription: String {
        switch self {
        case .urlError(let error):
            return error.localizedDescription
        case .decodingError(let error):
            return error.localizedDescription
        case .responseError(let error):
            return "Bad response code: \(error)"
        case .anyError:
            return "Unknown error has ocurred"
        case .encodingError(_):
            return "Error Encoding"
        }
    }
}

