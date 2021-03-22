//
//  NetworkError.swift
//
//  Created by Thomas Woodfin on 03/07/21.
//

import Foundation

enum NetworkError: Error {
    
    case authenticationFailure
    case decodeModelFailure(error: Error)
    case emptyServerResponse
    case invalidServerResponse(errorResponse: ErrorResponse)
    case invalidURL
    case networkFailure(error: Error)
}

extension NetworkError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailure:
            return "Authentication failed"
        case .decodeModelFailure(let error):
            return "Failed to decode model with error description: \(error.localizedDescription)"
        case .emptyServerResponse:
            return "Empty response from server"
        case .invalidServerResponse(let errorResponse):
            var invalidServerResponse = "Invalid server response."
            invalidServerResponse += errorResponse.statusCode != nil ? " Status Code: \(errorResponse.statusCode!)": ""
            return invalidServerResponse
        case .invalidURL:
            return "Invalid URL"
        case .networkFailure(let error):
            return "Network failure with error description: \(error.localizedDescription)"
        }
    }
}
