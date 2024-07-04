//
//  PokemonResponse.swift
//  YCNetwork_Tests
//
//  Created by Daniel Minaya on 29/05/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

struct PokemonResponse: Codable, Equatable {
    let id: Int
    let name: String
    let height: Int
}
