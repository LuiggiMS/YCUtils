//
//  File.swift
//  
//
//  Created by Daniel Minaya on 5/07/24.
//

import Foundation

struct UploadedImageResponse: Codable {
    let data: DataImageResponse
}

struct DataImageResponse: Codable {
    let link: String
}
