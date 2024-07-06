//
//  RequestProvider.swift
//  YCNetwork

import Foundation

// Use Case
protocol YCNetworkUseCases {
    func request<T>(_ method: YCHttpMethod, url: URL, body: [String: Any]?, resultType: T.Type) async throws -> T where T: Decodable
    func request(_ method: YCHttpMethod, url: URL, body: [String: Any]?) async throws
    func upload<T>(data: Data, url: URL, mimeType: String, fileName: String, resultType: T.Type) async throws -> T where T: Decodable
}

public class YCNetwork: YCNetworkUseCases {
    private let urlSession: URLSession
    private var token: String?
    private var log: Bool
    
    public init(urlSession: URLSession = .shared, log: Bool = false) {
        self.urlSession = urlSession
        self.log = log
    }
    
    public func setToken(_ token: String) {
        self.token = token
    }
    
    public func request<T>(_ method: YCHttpMethod, url: URL, body: [String: Any]? = nil, resultType: T.Type) async throws -> T where T: Decodable {
        let request = try makeRequest(method, url: url, body: body)
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            return try handleResponse(data, response, resultType: resultType)
        } catch {
            if (error as NSError).domain == NSURLErrorDomain && (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw YCNetworkError.noInternet
            } else {
                if log {
                    print("[YCNetwork] ⚠️ Error: \(error)")
                }
                throw error
            }
        }
    }
        
    public func request(_ method: YCHttpMethod, url: URL, body: [String: Any]? = nil) async throws {
        let request = try makeRequest(method, url: url, body: body)
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            _ = try handleResponse(data, response, resultType: YCEmptyResponse.self)
        } catch {
            if (error as NSError).domain == NSURLErrorDomain && (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw YCNetworkError.noInternet
            } else {
                if log {
                    print("[YCNetwork] ⚠️ Error: \(error)")
                }
                throw error
            }
        }
    }
    
    public func upload<T>(data: Data, url: URL, mimeType: String, fileName: String = UUID().uuidString, resultType: T.Type) async throws -> T where T: Decodable {
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        
        let body = createMultipartBody(data: data, boundary: boundary, mimeType: mimeType, fileName: fileName)
        request.httpBody = body
        
        do {
            let (data, response) = try await urlSession.upload(for: request, from: body)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw YCNetworkError.invalidResponse
            }
            
            let responseString = String(data: data, encoding: .utf8)
            logRequest(url, statusCode: httpResponse.statusCode, body: nil, responseString: responseString)
            
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(T.self, from: data)
                    return response
                } catch {
                    throw YCNetworkError.decodingError
                }
            } else {
                throw YCNetworkError.unknown
            }
        } catch {
            if log {
                print("[YCNetwork] ⚠️ Error: \(error)")
            }
            throw error
        }
    }
    
}

extension YCNetwork {
    
    private func makeRequest(_ method: YCHttpMethod, url: URL, body: [String: Any]?) throws -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        request.httpMethod = method.rawValue
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if let token = token {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    private func handleResponse<T>(_ data: Data, _ response: URLResponse, resultType: T.Type) throws -> T where T: Decodable {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw YCNetworkError.invalidResponse
        }
        
        let responseString = String(data: data, encoding: .utf8)
        logRequest(response.url!, statusCode: httpResponse.statusCode, body: nil, responseString: responseString)
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                return result
            } catch {
                if log {
                    print("[YCNetwork] ⚠️ Decoding Error: \(error)")
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
    }
    
    private func logRequest(_ url: URL, statusCode: Int, body: [String: Any]?, responseString: String?) {
        guard log else { return }
        
        print("[YCNetwork] ⚠️ Url: \(url) - Status Code: \(statusCode)")
        
        if let body = body {
            print("[YCNetwork] ⚠️ Body: \(body)")
        }
        
        if let responseString = responseString {
            print("[YCNetwork] ⚠️ Response:\n\(responseString)")
        }
    }
   
    private func createMultipartBody(data: Data, boundary: String, mimeType: String, fileName: String) -> Data {
        var body = Data()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName).jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}

private struct YCEmptyResponse: Decodable {}
