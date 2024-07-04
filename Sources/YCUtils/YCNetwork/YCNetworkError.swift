//
//  YCNetworkError.swift
//  YCNetwork

import Foundation

public enum YCNetworkError: Error, Equatable {
    case invalidResponse
    case badRequest
    case serverError
    case unknown
    case noInternet
    case requestFailed(statusCode: Int)
    case decodingError
    
    public static func == (lhs: YCNetworkError, rhs: YCNetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidResponse, .invalidResponse),
             (.badRequest, .badRequest),
             (.serverError, .serverError),
             (.unknown, .unknown),
             (.noInternet, .noInternet),
             (.decodingError, .decodingError):
            return true
        case let (.requestFailed(statusCode1), .requestFailed(statusCode2)):
            return statusCode1 == statusCode2
        default:
            return false
        }
    }
}
