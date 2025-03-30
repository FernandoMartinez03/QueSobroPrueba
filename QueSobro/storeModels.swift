import Foundation
import FirebaseFirestore

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
    var comercioID: String  // Asegúrate de que este campo existe
    
    // Propiedades computadas
    var tiempoRestantePorcentaje: Double {
        let ahora = Date()
        let totalDuracion = venceEn.timeIntervalSince(fechaDisponible)
        let tiempoTranscurrido = ahora.timeIntervalSince(fechaDisponible)
        
        // Si el tiempo ya expiró
        if tiempoTranscurrido >= totalDuracion {
            return 0
        }
        
        let porcentaje = 1.0 - (tiempoTranscurrido / totalDuracion)
        return max(0, min(porcentaje, 1.0))
    }
    
    // Constructor desde Firestore
    init(id: String,
         nombre: String,
         descripcion: String,
         cantidadDisponible: Int,
         precio: Double,
         precioOriginal: Double,
         imageURL: String,
         etiquetas: [String],
         fechaDisponible: Date,
         venceEn: Date,
         comercioID: String) {
        
        self.id = id
        self.nombre = nombre
        self.descripcion = descripcion
        self.cantidadDisponible = cantidadDisponible
        self.precio = precio
        self.precioOriginal = precioOriginal
        self.imageURL = imageURL
        self.etiquetas = etiquetas
        self.fechaDisponible = fechaDisponible
        self.venceEn = venceEn
        self.comercioID = comercioID
    }
    
    // Constructor alternativo desde un documento de Firestore
    init(id: String, data: [String: Any], comercioID: String) {
        self.id = id
        self.nombre = data["nombre"] as? String ?? ""
        self.descripcion = data["descripcion"] as? String ?? ""
        self.cantidadDisponible = data["cantidadDisponible"] as? Int ?? 0
        self.precio = data["precio"] as? Double ?? 0.0
        self.precioOriginal = data["precioOriginal"] as? Double ?? 0.0
        self.imageURL = data["imagenURL"] as? String ?? ""
        self.etiquetas = data["etiquetas"] as? [String] ?? []
        
        if let fechaDisponibleTimestamp = data["fechaDisponible"] as? Timestamp {
            self.fechaDisponible = fechaDisponibleTimestamp.dateValue()
        } else {
            self.fechaDisponible = Date()
        }
        
        if let venceEnTimestamp = data["venceEn"] as? Timestamp {
            self.venceEn = venceEnTimestamp.dateValue()
        } else {
            self.venceEn = Date().addingTimeInterval(24 * 3600) // 24 horas por defecto
        }
        
        self.comercioID = comercioID
    }
}
