//
//  TodoResponse.swift
//  LDMSNetwork_Tests
//
//  Created by Daniel Minaya on 12/04/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

struct TodoResponse: Codable, Equatable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId = "userId"
        case id = "id"
        case title = "title"
        case completed = "completed"
    }
}
