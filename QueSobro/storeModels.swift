//
//  storeModels.swift
//  QueSobro
//
//  Created by Alumno on 29/03/25.
//

import Foundation
import FirebaseFirestore

// Modelo para datos del comercio
struct ComercioData: Identifiable {
    var id: String
    var nombre: String
    var direccion: String
    var ciudad: String
    var calificacionPromedio: Double
    var tipoComida: [String]
    var horario: [String: String]
}

// Modelo para productos/paquetes
struct Producto: Identifiable {
    var id: String
    var nombre: String
    var descripcion: String
    var cantidadDisponible: Int
    var precio: Double
    var precioOriginal: Double
    var imageURL: String
    var etiquetas: [String]
    var fechaDisponible: Date
    var venceEn: Date
    
    // Calcular tiempo restante en porcentaje (0-1)
    var tiempoRestantePorcentaje: Double {
        let tiempoTotal = venceEn.timeIntervalSince(fechaDisponible)
        let tiempoTranscurrido = Date().timeIntervalSince(fechaDisponible)
        let porcentaje = 1 - (tiempoTranscurrido / tiempoTotal)
        return max(0, min(1, porcentaje)) // Asegurar que esté entre 0 y 1
    }
    
    // Verificar si el producto ha expirado
    var haExpirado: Bool {
        return Date() > venceEn
    }
}
