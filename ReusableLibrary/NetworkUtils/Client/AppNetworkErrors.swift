//
//  AppNetworkErrors.swift
//
//

import Foundation

/// Error enum for handling the request formation

enum AppAPIError: Error {
    case buildableFailure
    case noData
    
    var value: String {
        switch self {
        case .buildableFailure: return "No able to form buildable"
        case .noData: return "No data returned from API"
        }
    }
}

/// Enum for handling api result
enum AppAPIResult<T: Codable> {
    case success(T)
    case failure(AppAPIServiceError?)
}

struct AppAPIServiceError {
    let message: String
    let erorrCode: Int?
    init(message: String, errorCode: Int?) {
        self.message = message
        self.erorrCode = errorCode
    }
}

