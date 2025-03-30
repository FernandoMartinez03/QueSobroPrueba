//
//  ComercioPedidosView.swift
//  QueSobro
//
//  Created by Alumno on 29/03/25.
//
import SwiftUI
import FirebaseFirestore

struct ComercioPedidosView: View {
    let comercioID: String
    let comercioName: String
    @StateObject private var viewModel = ComercioPedidosViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    // Colores de la app
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08) // Rojo del logo
    let backgroundColor = Color(white: 0.97) // Fondo claro
    
    var body: some View {
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
            } else if viewModel.pedidos.isEmpty {
                // Vista cuando no hay pedidos
                VStack(spacing: 20) {
                    Image(systemName: "bag")
                        .font(.system(size: 70))
                        .foregroundColor(.gray)
                    
                    Text("No hay pedidos pendientes")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    
                    Text("Los pedidos realizados a tu comercio aparecerán aquí")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
            } else {
                // Lista de pedidos
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.pedidos) { pedido in
                            ComercioPedidoCard(
                                pedido: pedido,
                                onCompletarPedido: {
                                    viewModel.completarPedido(pedidoID: pedido.id)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
            }
        }
        .navigationTitle("Pedidos Pendientes")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Aviso"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            viewModel.loadPedidos(comercioID: comercioID)
        }
    }
}

// Tarjeta de pedido para comercio
struct ComercioPedidoCard: View {
    let pedido: ComercioPedidoModel
    let onCompletarPedido: () -> Void
    
    // Colores de la app
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08) // Rojo del logo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Encabezado
            HStack {
                // Indicador de estado
                Text(pedido.estado.capitalized)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(estadoColor)
                    .cornerRadius(15)
                
                Spacer()
                
                // Fecha
                Text(pedido.formattedDate)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            // Información del cliente y producto
            VStack(alignment: .leading, spacing: 12) {
                // Información del producto
                HStack(spacing: 15) {
                    // Imagen del producto (placeholder)
                    if let productoImageURL = pedido.productoImageURL, !productoImageURL.isEmpty {
                        AsyncImage(url: URL(string: productoImageURL)) { phase in
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
                                Text(pedido.productoName.prefix(1))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                    }
                    
                    // Datos del producto
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pedido.productoName)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        HStack {
                            Text("\(pedido.cantidad) \(pedido.cantidad > 1 ? "unidades" : "unidad")")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text("$\(String(format: "%.2f", pedido.totalPagado))")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(primaryColor)
                        }
                    }
                }
                
                // Información del cliente
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "person.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Text("Cliente: \(pedido.nombreCliente)")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Text("Método: \(pedido.metodoPago)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // Información de recogida
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hora de recogida:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text(pedido.horaRecoger)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    // Botón de completar (solo para pedidos activos)
                    if pedido.estado.lowercased() == "activo" {
                        Button(action: onCompletarPedido) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Completar")
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
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Color según el estado
    var estadoColor: Color {
        switch pedido.estado.lowercased() {
        case "activo", "pendiente":
            return .blue
        case "completado":
            return .green
        case "cancelado":
            return .red
        default:
            return .gray
        }
    }
}

// ViewModel para la vista de pedidos del comercio
class ComercioPedidosViewModel: ObservableObject {
    @Published var pedidos: [ComercioPedidoModel] = []
    @Published var isLoading = true
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    func loadPedidos(comercioID: String) {
        isLoading = true
        pedidos.removeAll()
        
        let db = Firestore.firestore()
        db.collection("pedidos")
            .whereField("comercioID", isEqualTo: comercioID)
            .whereField("estado", isEqualTo: "activo")  // Solo pedidos activos
            .order(by: "fechaPedido", descending: true)
            .getDocuments { snapshot, error in
                self.isLoading = false
                
                if let error = error {
                    print("Error loading pedidos: \(error.localizedDescription)")
                    self.alertMessage = "Error al cargar pedidos: \(error.localizedDescription)"
                    self.showAlert = true
                    return
                }
                
                var newPedidos: [ComercioPedidoModel] = []
                let group = DispatchGroup()
                
                for document in snapshot?.documents ?? [] {
                    group.enter()
                    
                    let pedidoData = document.data()
                    let pedidoID = document.documentID
                    
                    // Extraer datos básicos del pedido
                    let userID = pedidoData["userID"] as? String ?? ""
                    let packID = pedidoData["packID"] as? String ?? ""
                    let cantidad = pedidoData["cantidad"] as? Int ?? 0
                    let totalPagado = pedidoData["totalPagado"] as? Double ?? 0.0
                    let fechaPedido = (pedidoData["fechaPedido"] as? Timestamp)?.dateValue() ?? Date()
                    let estado = pedidoData["estado"] as? String ?? "activo"
                    let metodoPago = pedidoData["metodoPago"] as? String ?? "Desconocido"
                    let horaRecoger = pedidoData["horaRecoger"] as? String ?? "N/A"
                    
                    // Cargar información del producto
                    db.collection("comercios").document(comercioID).collection("packs").document(packID).getDocument { productoSnapshot, productoError in
                        let productoName = productoSnapshot?.data()?["nombre"] as? String ?? "Producto"
                        let productoImageURL = productoSnapshot?.data()?["imagenURL"] as? String
                        
                        // Cargar información del usuario
                        db.collection("users").document(userID).getDocument { userSnapshot, userError in
                            // Extraer nombre del cliente o usar valor por defecto
                            let nombreCliente = userSnapshot?.data()?["nombre"] as? String ?? "Cliente"
                            
                            // Crear modelo de pedido
                            let pedido = ComercioPedidoModel(
                                id: pedidoID,
                                userID: userID,
                                nombreCliente: nombreCliente,
                                comercioID: comercioID,
                                packID: packID,
                                productoName: productoName,
                                productoImageURL: productoImageURL,
                                cantidad: cantidad,
                                totalPagado: totalPagado,
                                fechaPedido: fechaPedido,
                                estado: estado,
                                metodoPago: metodoPago,
                                horaRecoger: horaRecoger
                            )
                            
                            newPedidos.append(pedido)
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    self.pedidos = newPedidos.sorted { $0.fechaPedido > $1.fechaPedido }
                }
            }
    }
    
    func completarPedido(pedidoID: String) {
        isLoading = true
        
        let db = Firestore.firestore()
        db.collection("pedidos").document(pedidoID).updateData([
            "estado": "completado"
        ]) { error in
            self.isLoading = false
            
            if let error = error {
                self.alertMessage = "Error al completar el pedido: \(error.localizedDescription)"
                self.showAlert = true
            } else {
                // Actualizar la lista de pedidos
                if let index = self.pedidos.firstIndex(where: { $0.id == pedidoID }) {
                    self.pedidos.remove(at: index)
                }
                
                self.alertMessage = "Pedido completado con éxito"
                self.showAlert = true
            }
        }
    }
}

// Modelo de pedido para comercio
struct ComercioPedidoModel: Identifiable {
    let id: String
    let userID: String
    let nombreCliente: String
    let comercioID: String
    let packID: String
    let productoName: String
    let productoImageURL: String?
    let cantidad: Int
    let totalPagado: Double
    let fechaPedido: Date
    let estado: String
    let metodoPago: String
    let horaRecoger: String
    
    // Propiedades computadas
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: fechaPedido)
    }
}
