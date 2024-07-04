//
//  RequestProvider.swift
//  YCNetwork

import Foundation

public class YCNetwork {
    private let urlSession: URLSession
    private var token: String?
    private var log: Bool
    
    public init(urlSession: URLSession = .shared, token: String? = nil, log: Bool = false) {
        self.urlSession = urlSession
        self.token = token
        self.log = log
    }
    
    public func request<T>(_ method: YCHttpMethod, url: URL, body: [String: Any]? = nil, resultType: T.Type) async throws -> T where T: Decodable {
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        request.httpMethod = method.rawValue

        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if let token = token {
            request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw YCNetworkError.invalidResponse
            }
            
            if log, let responseString = String(data: data, encoding: .utf8) {
                debugPrint("⚠️ Response: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    return result
                } catch {
                    if log {
                        debugPrint("⚠️ Decoding Error: \(error)")
                    }
                    throw YCNetworkError.decodingError
                }
            case 400...499:
                throw YCNetworkError.badRequest
            case 500...599:
                throw YCNetworkError.serverError
            default:
                throw YCNetworkError.unknown
            }
        } catch {
            if (error as NSError).domain == NSURLErrorDomain && (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw YCNetworkError.noInternet
            } else {
                throw error
            }
        }
    }
}
