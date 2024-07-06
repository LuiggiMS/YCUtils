//
//  File.swift
//  
//
//  Created by Daniel Minaya on 4/07/24.
//

import Foundation
import XCTest
@testable import YCUtils

class NetworkingTests: XCTestCase {
    let networkService = YCNetwork(log: true)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetTodoRequest() async throws {
        // Arrange
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!
        let expectedResult = TodoResponse(userId: 1, id: 1, title: "delectus aut autem", completed: false)
        
        // Act
        let result: TodoResponse = try await networkService.request(.get, url: url, resultType: TodoResponse.self)

        // Assert
        XCTAssertEqual(result, expectedResult)
    }
    
    func testGetPokemonRequest() async throws {
        // Arrange
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon/pikachu")!
        let expectedResult = PokemonResponse(id: 25, name: "pikachu", height: 4)
        
        // Act
        let result = try await networkService.request(.get, url: url, resultType: PokemonResponse.self)

        // Assert
        XCTAssertEqual(result, expectedResult)
    }
    
    func testGetUsuarioRJRequest() async throws {
        // Arrange
        let token = "Token 27d255009411fd276ed086fcb3d02b53a98671de"
        let networkService = YCNetwork(log: true)
        networkService.setToken(token)
        let url = URL(string: "http://red-jovenes.yadux.com/api-app/miembro-info/")!
        let body: [String: Any] = ["usuario_id": 4]

        // Act
        do {
            let result = try await networkService.request(.post, url: url, body: body, resultType: UsuarioRJResponse.self)
            // Assert
            XCTAssertEqual(result.results.nombres, "Daniel")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testDecodingError() async throws {
        // Arrange
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!
        let expectedResult = YCNetworkError.decodingError
        
        // Act
        do {
            _ = try await networkService.request(.get, url: url, resultType: FailResponse.self)
        } catch {
            // Assert
            if let networkError = error as? YCNetworkError {
                switch networkError {
                case expectedResult:
                    XCTAssertTrue(true)
                default:
                    XCTFail("Expected decodingError, but got \(networkError)")
                }
            } else {
                XCTFail("Expected YCNetworkError, but got \(error)")
            }
        }
    }
    
    func testServerError() async throws {
        // Arrange
        let url = URL(string: "https://english-club-production.up.railway.app/docszz#/")!
        let expectedResult = YCNetworkError.serverError
        
        // Act
        do {
            _ = try await networkService.request(.get, url: url, resultType: FailResponse.self)
        } catch {
            // Assert
            if let networkError = error as? YCNetworkError {
                switch networkError {
                case expectedResult:
                    XCTAssertTrue(true)
                default:
                    XCTFail("Expected decodingError, but got \(networkError)")
                }
            } else {
                XCTFail("Expected YCNetworkError, but got \(error)")
            }
        }
    }
    
    func testBadRequestError() async throws {
        // Arrange
        let token = "badToken"
        let networkService = YCNetwork(log: true)
        networkService.setToken(token)
        let url = URL(string: "http://red-jovenes.yadux.com/api-app/miembro-info/")!
        let expectedResult = YCNetworkError.badRequest

        // Act
        do {
            _ = try await networkService.request(.post, url: url, resultType: UsuarioRJResponse.self)
        } catch {
            // Assert
            if let networkError = error as? YCNetworkError {
                switch networkError {
                case expectedResult:
                    XCTAssertTrue(true)
                default:
                    XCTFail("Expected barRequestError, but got \(networkError)")
                }
            } else {
                XCTFail("Expected YCNetworkError, but got \(error)")
            }
        }
    }
    
    func testNoInternetError() async throws {
        // Test only with off Internet
        // Arrange
//        let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!
//        let expectedResult = YCNetworkError.noInternet
//        
//        // Act
//        do {
//            _ = try await networkService.request(.get, url: url, resultType: FailResponse.self)
//        } catch {
//            // Assert
//            if let networkError = error as? YCNetworkError {
//                switch networkError {
//                case expectedResult:
//                    XCTAssertTrue(true)
//                default:
//                    XCTFail("Expected noInternetError, but got \(networkError)")
//                }
//            } else {
//                XCTFail("Expected YCNetworkError, but got \(error)")
//            }
//        }
        
        // Default: Test only with on Internet
        XCTAssert(true)
    }
    
    func testUploadImage() async throws {
        // Arrange
        let token = "Client-ID 07a8a87dd43c7a0"
        let url = URL(string: "https://api.imgur.com/3/upload")!
        let expectedInitialURLResult = "https://i.imgur.com"
        let mimeType = "image/jpeg"
        let networkService = YCNetwork(log: true)
        networkService.setToken(token)
        guard let bundleUrl = Bundle.module.url(forResource: "swift-logo", withExtension: "png"),
        let imageData = try? Data(contentsOf: bundleUrl) else {
            XCTFail("Failed to load test image")
            return
        }

        // Act
        let result = try await networkService.upload(data: imageData, url: url, mimeType: mimeType, resultType: UploadedImageResponse.self)
        
        // Assert
        XCTAssertNotNil(result.data.link)
        XCTAssertTrue(result.data.link.contains(expectedInitialURLResult))
    }
    
}
