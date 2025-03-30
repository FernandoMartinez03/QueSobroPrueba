//
//  OrderHistoryView.swift
//  QueSobro
//
//  Created by Alumno on 29/03/25.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct OrderHistoryView: View {
    @StateObject private var viewModel = OrderHistoryViewModel()
    
    // Colores de la app
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08) // Rojo del logo
    let backgroundColor = Color(white: 0.97) // Fondo claro
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                if viewModel.isLoading {
                    // Vista de carga
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: primaryColor))
                            .scaleEffect(1.5)
                        Text("Cargando pedidos...")
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                    }
                } else if viewModel.orders.isEmpty {
                    // Vista cuando no hay pedidos
                    VStack(spacing: 20) {
                        Image(systemName: "bag")
                            .font(.system(size: 70))
                            .foregroundColor(.gray)
                        
                        Text("No tienes pedidos")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        Text("Tus pedidos aparecerán aquí")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    // Lista de pedidos
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.orders) { order in
                                OrderCard(
                                    order: order,
                                    showReviewSheet: { viewModel.orderToReview = order },
                                    onReviewCompleted: { viewModel.loadOrders() }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                }
            }
            .navigationTitle("Mis Pedidos")
            .sheet(item: $viewModel.orderToReview) { order in
                ReviewSheetView(
                    order: order,
                    onReviewSubmitted: {
                        viewModel.orderToReview = nil
                        viewModel.loadOrders()
                    }
                )
            }
            .onAppear {
                viewModel.loadOrders()
            }
        }
    }
}

// Tarjeta de pedido
struct OrderCard: View {
    let order: Order
    let showReviewSheet: () -> Void
    let onReviewCompleted: () -> Void
    
    // Colores de la app
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08) // Rojo del logo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Encabezado
            HStack {
                // Indicador de estado
                Text(order.statusText)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(order.statusColor)
                    .cornerRadius(15)
                
                Spacer()
                
                // Fecha
                Text(order.formattedDate)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            // Información del comercio
            HStack(alignment: .top, spacing: 12) {
                // Imagen del comercio
                if let comercioImageURL = order.comercioImageURL, !comercioImageURL.isEmpty {
                    AsyncImage(url: URL(string: comercioImageURL)) { phase in
                        switch phase {
                        case .empty:
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 60, height: 60)
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        case .failure:
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 60, height: 60)
                                .overlay(Image(systemName: "photo"))
                        @unknown default:
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 60, height: 60)
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text(order.comercioName.prefix(1))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                }
                
                // Información principal
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.comercioName)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(order.productoName)
                        .font(.subheadline)
                    
                    HStack {
                        Text("\(order.cantidad) \(order.cantidad > 1 ? "unidades" : "unidad")")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("$\(String(format: "%.2f", order.totalPagado))")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(primaryColor)
                    }
                }
            }
            
            // Información adicional
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Recoger:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(order.horaRecoger)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                // Botón de reseña o mostrar estrellas
                if order.hasReview {
                    // Mostrar calificación
                    StarsRatingView(rating: order.rating, size: 15)
                } else if order.estado == "completado" {
                    // Botón para dejar una reseña
                    Button(action: showReviewSheet) {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("Dejar reseña")
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundColor(.white)
                        .background(primaryColor)
                        .cornerRadius(15)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// ViewModel para la vista de historial de pedidos
class OrderHistoryViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading = true
    @Published var orderToReview: Order? = nil
    
    func loadOrders() {
        isLoading = true
        
        guard let userID = Auth.auth().currentUser?.uid else {
            isLoading = false
            print("Error: No hay usuario autenticado")
            return
        }
        
        print("Buscando pedidos para el usuario: \(userID)")
        
        let db = Firestore.firestore()
        
        // Primero, imprimir todos los pedidos disponibles para depurar
        db.collection("pedidos").getDocuments { allSnapshot, allError in
            print("Total de pedidos en la base de datos: \(allSnapshot?.documents.count ?? 0)")
            
            // Imprimir los userIDs de todos los pedidos
            for doc in allSnapshot?.documents ?? [] {
                let docData = doc.data()
                if let docUserID = docData["userID"] as? String {
                    print("Pedido \(doc.documentID) - userID: '\(docUserID)'")
                }
            }
            
            // Ahora obtener todos los pedidos y filtrar manualmente
            db.collection("pedidos")
                .order(by: "fechaPedido", descending: true)
                .getDocuments { snapshot, error in
                    self.isLoading = false
                    
                    if let error = error {
                        print("Error loading orders: \(error.localizedDescription)")
                        return
                    }
                    
                    print("Total de pedidos cargados: \(snapshot?.documents.count ?? 0)")
                    
                    var newOrders: [Order] = []
                    let group = DispatchGroup()
                    
                    for document in snapshot?.documents ?? [] {
                        group.enter()
                        
                        let orderData = document.data()
                        let orderID = document.documentID
                        let docUserID = orderData["userID"] as? String ?? ""
                        
                        // Verificar si el pedido pertenece al usuario actual (comparando de forma flexible)
                        if docUserID.lowercased() == userID.lowercased() || docUserID.trimmingCharacters(in: .whitespacesAndNewlines) == userID {
                            print("Procesando pedido: \(orderID) para usuario \(docUserID)")
                            
                            // Extraer datos básicos del pedido
                            let comercioID = orderData["comercioID"] as? String ?? ""
                            let packID = orderData["packID"] as? String ?? ""
                            let cantidad = orderData["cantidad"] as? Int ?? 0
                            let totalPagado = orderData["totalPagado"] as? Double ?? 0.0
                            let fechaPedido = (orderData["fechaPedido"] as? Timestamp)?.dateValue() ?? Date()
                            let estado = orderData["estado"] as? String ?? "activo"
                            let metodoPago = orderData["metodoPago"] as? String ?? "Desconocido"
                            let horaRecoger = orderData["horaRecoger"] as? String ?? "N/A"
                            
                            // Obtener información sobre la reseña
                            let hasReview = orderData["hasReview"] as? Bool ?? false
                            let rating = orderData["rating"] as? Int ?? 0
                            let reviewComment = orderData["reviewComment"] as? String ?? ""
                            
                            // Cargar información del comercio
                            db.collection("comercios").document(comercioID).getDocument { comercioSnapshot, comercioError in
                                if let comercioError = comercioError {
                                    print("Error al cargar datos del comercio \(comercioID): \(comercioError.localizedDescription)")
                                }
                                
                                let comercioName = comercioSnapshot?.data()?["nombre"] as? String ?? "Comercio"
                                let comercioImageURL = comercioSnapshot?.data()?["imageURL"] as? String
                                
                                // Cargar información del producto
                                db.collection("comercios").document(comercioID).collection("packs").document(packID).getDocument { productoSnapshot, productoError in
                                    if let productoError = productoError {
                                        print("Error al cargar datos del producto \(packID): \(productoError.localizedDescription)")
                                    }
                                    
                                    let productoName = productoSnapshot?.data()?["nombre"] as? String ?? "Producto"
                                    let productoImageURL = productoSnapshot?.data()?["imagenURL"] as? String
                                    
                                    // Crear objeto Order
                                    let order = Order(
                                        id: orderID,
                                        userID: docUserID,
                                        comercioID: comercioID,
                                        comercioName: comercioName,
                                        comercioImageURL: comercioImageURL,
                                        packID: packID,
                                        productoName: productoName,
                                        productoImageURL: productoImageURL,
                                        cantidad: cantidad,
                                        totalPagado: totalPagado,
                                        fechaPedido: fechaPedido,
                                        estado: estado,
                                        metodoPago: metodoPago,
                                        horaRecoger: horaRecoger,
                                        hasReview: hasReview,
                                        rating: rating,
                                        reviewComment: reviewComment
                                    )
                                    
                                    newOrders.append(order)
                                    print("Pedido añadido: \(orderID), producto: \(productoName)")
                                    group.leave()
                                }
                            }
                        } else {
                            // Si no coincide el userID, salir del grupo
                            print("Ignorando pedido \(orderID) porque pertenece a \(docUserID), no a \(userID)")
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) {
                        self.orders = newOrders.sorted { $0.fechaPedido > $1.fechaPedido }
                        print("Se cargaron \(newOrders.count) pedidos correctamente")
                    }
                }
        }
    }
}


// Modelo de pedido
struct Order: Identifiable {
    let id: String
    let userID: String
    let comercioID: String
    let comercioName: String
    let comercioImageURL: String?
    let packID: String
    let productoName: String
    let productoImageURL: String?
    let cantidad: Int
    let totalPagado: Double
    let fechaPedido: Date
    let estado: String
    let metodoPago: String
    let horaRecoger: String
    let hasReview: Bool
    let rating: Int
    let reviewComment: String
    
    // Propiedades computadas
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: fechaPedido)
    }
    
    var statusText: String {
        switch estado.lowercased() {
        case "activo": return "Pendiente"
        case "completado": return "Completado"
        case "cancelado": return "Cancelado"
        default: return estado.capitalized
        }
    }
    
    var statusColor: Color {
        switch estado.lowercased() {
        case "activo": return .blue
        case "completado": return .green
        case "cancelado": return .red
        default: return .gray
        }
    }
}
