//
//  ReviewSheetView.swift
//  QueSobro
//
//  Created by Alumno on 29/03/25.
//
import SwiftUI
import FirebaseFirestore

struct ReviewSheetView: View {
    let order: Order
    let onReviewSubmitted: () -> Void
    
    @State private var rating = 0
    @State private var comment = ""
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Colores de la app
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08) // Rojo del logo
    let backgroundColor = Color(white: 0.97) // Fondo claro
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Información del comercio
                        VStack(spacing: 10) {
                            // Imagen del comercio
                            if let comercioImageURL = order.comercioImageURL, !comercioImageURL.isEmpty {
                                AsyncImage(url: URL(string: comercioImageURL)) { phase in
                                    switch phase {
                                    case .empty:
                                        Circle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 100, height: 100)
                                            .overlay(ProgressView())
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    case .failure:
                                        Circle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 100, height: 100)
                                            .overlay(
                                                Text(order.comercioName.prefix(1))
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                            )
                                    @unknown default:
                                        Circle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 100, height: 100)
                                            .overlay(
                                                Text(order.comercioName.prefix(1))
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                            )
                                    }
                                }
                            } else {
                                Circle()
                                    .fill(primaryColor)
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Text(order.comercioName.prefix(1))
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    )
                            }
                            
                            Text(order.comercioName)
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text(order.productoName)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // Selector de calificación
                        VStack(spacing: 12) {
                            Text("¿Cómo calificarías tu experiencia?")
                                .font(.headline)
                            
                            StarsRatingSelector(rating: $rating)
                                .padding(.vertical, 10)
                        }
                        
                        // Comentario
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Comentario (opcional)")
                                .font(.headline)
                            
                            TextEditor(text: $comment)
                                .frame(minHeight: 120)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Botón de enviar
                        Button(action: submitReview) {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .foregroundColor(.white)
                            } else {
                                Text("Enviar reseña")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(rating == 0 || isSubmitting)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(rating == 0 ? Color.gray : primaryColor)
                        .cornerRadius(10)
                        .padding(.top, 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("Dejar una reseña")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancelar") {
                onReviewSubmitted()
            })
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(isSubmitting ? "Procesando" : "Aviso"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if !isSubmitting {
                            onReviewSubmitted()
                        }
                    }
                )
            }
        }
    }
    
    func submitReview() {
        // Validación
        guard rating > 0 else {
            alertMessage = "Por favor selecciona una calificación con estrellas"
            showAlert = true
            return
        }
        
        isSubmitting = true
        
        // Actualizar pedido con la reseña
        let db = Firestore.firestore()
        db.collection("pedidos").document(order.id).updateData([
            "hasReview": true,
            "rating": rating,
            "reviewComment": comment,
            "estado": "completado" // Marcar como completado al dejar reseña
        ]) { error in
            if let error = error {
                isSubmitting = false
                alertMessage = "Error al guardar la reseña: \(error.localizedDescription)"
                showAlert = true
                return
            }
            
            // Actualizar la calificación promedio del comercio
            updateComercioRating(db: db)
        }
    }
    
    func updateComercioRating(db: Firestore) {
        // Obtener todas las reseñas del comercio
        db.collection("pedidos")
            .whereField("comercioID", isEqualTo: order.comercioID)
            .whereField("hasReview", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    isSubmitting = false
                    alertMessage = "Error al actualizar calificación: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                
                // Calcular el promedio de calificaciones
                var totalRating = 0
                var reviewCount = 0
                
                for document in snapshot?.documents ?? [] {
                    if let rating = document.data()["rating"] as? Int, rating > 0 {
                        totalRating += rating
                        reviewCount += 1
                    }
                }
                
                let averageRating = reviewCount > 0 ? Double(totalRating) / Double(reviewCount) : 0.0
                
                // Actualizar el documento del comercio
                db.collection("comercios").document(order.comercioID).updateData([
                    "calificacionPromedio": averageRating,
                    "reviewsCount": reviewCount
                ]) { error in
                    isSubmitting = false
                    
                    if let error = error {
                        alertMessage = "Error al actualizar comercio: \(error.localizedDescription)"
                    } else {
                        alertMessage = "¡Gracias por tu reseña!"
                    }
                    
                    showAlert = true
                }
            }
    }
}


