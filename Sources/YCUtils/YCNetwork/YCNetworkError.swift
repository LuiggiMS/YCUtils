//
//  YCNetworkError.swift
//  YCNetwork

import Foundation

public enum YCNetworkError: Error, Equatable {
    case invalidResponse      // Invalid or unexpected response from the server.
    case decodingError        // Error occurred while decoding the response data.
    case badRequest           // The server rejected the request due to a client error (status code 4xx).
    case serverError          // The server encountered an error while processing the request (status code 5xx).
    case noInternet           // The device is not connected to the internet.
    case unknown              // An unknown or unexpected error occurred.
    
    public static func == (lhs: YCNetworkError, rhs: YCNetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidResponse, .invalidResponse),
            (.decodingError, .decodingError),
            (.badRequest, .badRequest),
            (.serverError, .serverError),
            (.noInternet, .noInternet),
            (.unknown, .unknown):
            return true
        default:
            return false
        }
    }
}
