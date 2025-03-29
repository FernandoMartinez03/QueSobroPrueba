import FirebaseFirestore
import SwiftUI

class ComercioViewModel: ObservableObject {
    @Published var comercios: [ComercioData] = []
    
    init() {
        loadComercios()
    }
    
    // Load commerces from Firestore
    func loadComercios() {
        let db = Firestore.firestore()
        
        db.collection("comercios").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching commerces: \(error.localizedDescription)")
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
                let horario = data["horario"] as? [String: String] ?? [:] // Map business hours
                
                let comercio = ComercioData(
                    id: id,
                    nombre: nombre,
                    direccion: direccion,
                    ciudad: ciudad,
                    calificacionPromedio: calificacionPromedio,
                    tipoComida: tipoComida,
                    horario: horario
                )
                
                comerciosArray.append(comercio)
            }
            
            self.comercios = comerciosArray
        }
    }
    
    // Filter commerces by category
    func comerciosForCategory(_ category: String) -> [ComercioData] {
        return comercios.filter { $0.tipoComida.contains(category) } // Filter by food type
    }
}

