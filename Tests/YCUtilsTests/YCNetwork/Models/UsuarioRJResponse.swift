//
//  RJResponse.swift
//  LDMSNetwork_Tests
//
//  Created by Daniel Minaya on 12/04/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

// MARK: - RJResponse
struct UsuarioRJResponse: Codable {
    let results: Results
}

// MARK: - Results
struct Results: Codable {
    let usuario: Int
    let supervision: Supervision
    let nombres, apellidos, numeroDocumento, numeroCelular: String
    let correo, fechaRegistro: String
    let urlImagen: String
    let bautizo: Bool
    let categoria, tipoDocumento: Int

    enum CodingKeys: String, CodingKey {
        case usuario, supervision, nombres, apellidos
        case numeroDocumento = "numero_documento"
        case numeroCelular = "numero_celular"
        case correo
        case fechaRegistro = "fecha_registro"
        case urlImagen = "url_imagen"
        case bautizo, categoria
        case tipoDocumento = "tipo_documento"
    }
}

// MARK: - Supervision
struct Supervision: Codable {
    let id: Int
    let nombre: String
    let logoURL: String
    let red: Int

    enum CodingKeys: String, CodingKey {
        case id, nombre
        case logoURL = "logo_url"
        case red
    }
}

// MARK: - RJResponse
struct UpdateImageResponse: Codable {
    let response: String
    let mensaje: String
}
