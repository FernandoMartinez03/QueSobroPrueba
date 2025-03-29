//
//  UserModels.swift
//  QueSobro
//
//  Created by Fernando Martínez on 29/03/25.
//

import Foundation
import FirebaseFirestore

// Enumeración para los tipos de usuario
enum UserType: String, Codable {
    case cliente = "cliente"
    case comercio = "comercio"
}

// Modelo principal de usuario
struct User: Identifiable, Codable {
    var id: String?
    var nombre: String
    var correo: String
    var tipo: UserType
    var ciudad: String
    var createdAt: Date
    var favoritos: [String]
    var historial: [String]
    var pedidosActivos: [String]
    
    // Campos opcionales según tipo de usuario
    var telefono: String?
    var fotoPerfil: String?
    
    // Campos específicos para comercios
    var esComercio: Bool {
        return tipo == .comercio
    }
    
    // Campos específicos para clientes
    var esCliente: Bool {
        return tipo == .cliente
    }
    
    // Para codificación/decodificación personalizada
    enum CodingKeys: String, CodingKey {
        case id
        case nombre
        case correo
        case tipo
        case ciudad
        case createdAt = "creadoEn"
        case favoritos
        case historial
        case pedidosActivos
        case telefono
        case fotoPerfil
    }
    
    // Método para crear un usuario a partir de un documento de Firestore
    static func fromFirestore(document: DocumentSnapshot) -> User? {
        guard let data = document.data() else {
            return nil
        }
        
        let id = document.documentID
        let nombre = data["nombre"] as? String ?? ""
        let correo = data["correo"] as? String ?? ""
        let tipoStr = data["tipo"] as? String ?? "cliente"
        let tipo = UserType(rawValue: tipoStr) ?? .cliente
        let ciudad = data["ciudad"] as? String ?? ""
        let createdAt = (data["creadoEn"] as? Timestamp)?.dateValue() ?? Date()
        let favoritos = data["favoritos"] as? [String] ?? []
        let historial = data["historial"] as? [String] ?? []
        let pedidosActivos = data["pedidosActivos"] as? [String] ?? []
        let telefono = data["telefono"] as? String
        let fotoPerfil = data["fotoPerfil"] as? String
        
        return User(
            id: id,
            nombre: nombre,
            correo: correo,
            tipo: tipo,
            ciudad: ciudad,
            createdAt: createdAt,
            favoritos: favoritos,
            historial: historial,
            pedidosActivos: pedidosActivos,
            telefono: telefono,
            fotoPerfil: fotoPerfil
        )
    }
    
    // Método para convertir a diccionario para Firestore
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            "nombre": nombre,
            "correo": correo,
            "tipo": tipo.rawValue,
            "ciudad": ciudad,
            "creadoEn": Timestamp(date: createdAt),
            "favoritos": favoritos,
            "historial": historial,
            "pedidosActivos": pedidosActivos
        ]
        
        if let telefono = telefono {
            data["telefono"] = telefono
        }
        
        if let fotoPerfil = fotoPerfil {
            data["fotoPerfil"] = fotoPerfil
        }
        
        return data
    }
}

// Modelo para la información de pedido en el historial
struct PedidoResumen: Identifiable, Codable {
    var id: String
    var comercioID: String
    var nombreComercio: String?
    var fecha: Date
    var total: Double
    var estado: String
    
    // Método para crear un pedido resumen a partir de un documento de Firestore
    static func fromFirestore(document: DocumentSnapshot, nombreComercio: String? = nil) -> PedidoResumen? {
        guard let data = document.data() else {
            return nil
        }
        
        let id = document.documentID
        guard let comercioID = data["comercioID"] as? String,
              let fecha = (data["fechaPedido"] as? Timestamp)?.dateValue(),
              let total = data["totalPagado"] as? Double,
              let estado = data["estado"] as? String else {
            return nil
        }
        
        return PedidoResumen(
            id: id,
            comercioID: comercioID,
            nombreComercio: nombreComercio,
            fecha: fecha,
            total: total,
            estado: estado
        )
    }
}

// Modelo para comercio favorito
struct ComercioFavorito: Identifiable, Codable {
    var id: String
    var nombre: String
    var calificacionPromedio: Double
    var tipoComida: [String]
    var direccion: String
    
    // Método para crear un comercio favorito a partir de un documento de Firestore
    static func fromFirestore(document: DocumentSnapshot) -> ComercioFavorito? {
        guard let data = document.data() else {
            return nil
        }
        
        let id = document.documentID
        guard let nombre = data["nombre"] as? String,
              let calificacionPromedio = data["calificacionPromedio"] as? Double,
              let direccion = data["direccion"] as? String else {
            return nil
        }
        
        let tipoComida = data["tipoComida"] as? [String] ?? []
        
        return ComercioFavorito(
            id: id,
            nombre: nombre,
            calificacionPromedio: calificacionPromedio,
            tipoComida: tipoComida,
            direccion: direccion
        )
    }
}
