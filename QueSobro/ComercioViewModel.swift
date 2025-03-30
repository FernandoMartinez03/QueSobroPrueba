import FirebaseFirestore
import SwiftUI

// Definición de la estructura ComercioData
struct ComercioData: Identifiable {
    var id: String
    var nombre: String
    var direccion: String
    var ciudad: String
    var calificacionPromedio: Double
    var tipoComida: [String]
    var horario: [String: String]
    var imageURL: String
    var reviewsCount: Int
}

class ComercioViewModel: ObservableObject {
    @Published var comercios: [ComercioData] = []
    
    init() {
        loadComercios()
    }
    
    // Load comercios from Firestore
    func loadComercios() {
        let db = Firestore.firestore()
        
        db.collection("comercios").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching comercios: \(error.localizedDescription)")
                return
            }
            
            var comerciosArray: [ComercioData] = []
            
            for document in snapshot?.documents ?? [] {
                let data = document.data()
                let id = document.documentID
                
                let nombre = data["nombre"] as? String ?? ""
                let direccion = data["direccion"] as? String ?? ""
                let ciudad = data["ciudad"] as? String ?? ""
                let calificacionPromedio = data["calificacionPromedio"] as? Double ?? 0.0
                let tipoComida = data["tipoComida"] as? [String] ?? []
                let horario = data["horario"] as? [String: String] ?? [:]
                let imageURL = data["imageURL"] as? String ?? ""
                let reviewsCount = data["reviewsCount"] as? Int ?? 0
                
                let comercio = ComercioData(
                    id: id,
                    nombre: nombre,
                    direccion: direccion,
                    ciudad: ciudad,
                    calificacionPromedio: calificacionPromedio,
                    tipoComida: tipoComida,
                    horario: horario,
                    imageURL: imageURL,
                    reviewsCount: reviewsCount
                )
                
                comerciosArray.append(comercio)
            }
            
            self.comercios = comerciosArray
        }
    }
}


