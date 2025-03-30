import SwiftUI
import FirebaseFirestore

struct RestaurantDetailView: View {
    let comercio: ComercioData
    let comercioID: String
    
    @State private var productos: [Producto] = []
    @State private var isLoading = true
    
    // Color scheme to match existing aesthetic
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08) // Rojo similar al que usas en otras vistas
    let backgroundColor = Color(white: 0.97) // Fondo claro como en otras vistas
    let accentColor = Color.blue // Color para acentos
    
    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header image
                    // Actualización para el encabezado de RestaurantDetailView
                    // Reemplaza la sección del header image en RestaurantDetailView con este código:

                    // Header image con imagen desde URL
                    ZStack(alignment: .bottom) {
                        if comercio.imageURL.isEmpty {
                            // Placeholder si no hay imagen
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 200)
                        } else {
                            // Cargar imagen desde URL
                            AsyncImage(url: URL(string: comercio.imageURL)) { phase in
                                switch phase {
                                case .empty:
                                    // Estado de carga
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 200)
                                        .overlay(
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(1.5)
                                        )
                                case .success(let image):
                                    // Imagen cargada exitosamente
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 200)
                                        .clipped()
                                case .failure:
                                    // Error al cargar la imagen
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 200)
                                        .overlay(
                                            VStack {
                                                Image(systemName: "photo")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(.white.opacity(0.8))
                                                Text("No se pudo cargar la imagen")
                                                    .foregroundColor(.white.opacity(0.8))
                                                    .padding(.top, 8)
                                            }
                                        )
                                @unknown default:
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 200)
                                }
                            }
                        }
                        
                        // Overlay with restaurant name
                        VStack(alignment: .leading) {
                            Text(comercio.nombre)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("\(String(format: "%.1f", comercio.calificacionPromedio))")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Text("(\(comercio.reviewsCount) reseñas)")
                                    .foregroundColor(.white.opacity(0.8))
                                    .font(.footnote)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                            startPoint: .bottom,
                            endPoint: .top
                        ))
                    }
                    
                    // Restaurant info
                    VStack(alignment: .leading, spacing: 16) {
                        // Direction
                        HStack(spacing: 10) {
                            Image(systemName: "location.fill")
                                .foregroundColor(accentColor)
                            
                            VStack(alignment: .leading) {
                                Text("Dirección")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(comercio.direccion)
                                    .font(.subheadline)
                            }
                        }
                        .padding(.top, 4)
                        
                        Divider()
                        
                        // Food types
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Tipo de comida")
                                .font(.headline)
                                .foregroundColor(primaryColor)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(comercio.tipoComida, id: \.self) { tipo in
                                        Text(tipo)
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(primaryColor.opacity(0.1))
                                            .foregroundColor(primaryColor)
                                            .cornerRadius(15)
                                    }
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Business hours
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Horario")
                                .font(.headline)
                                .foregroundColor(primaryColor)
                            
                            ForEach(getOrderedDays(), id: \.self) { day in
                                if let hours = comercio.horario[day] {
                                    HStack {
                                        Text(capitalizeDayName(day))
                                            .font(.subheadline)
                                            .frame(width: 100, alignment: .leading)
                                        
                                        Text(hours)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Available products
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Paquetes disponibles")
                                    .font(.headline)
                                    .foregroundColor(primaryColor)
                                
                                Spacer()
                                
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(0.7)
                                }
                            }
                            
                            if !isLoading && productos.isEmpty {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 10) {
                                        Image(systemName: "cube.box")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                        
                                        Text("No hay paquetes disponibles")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 20)
                            } else if !isLoading {
                                ForEach(productos) { producto in
                                    ProductCardView(producto: producto, comercioID: comercioID)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle(comercio.nombre)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadProductos()
        }
    }
    
    // Helper function to load products
    private func loadProductos() {
        isLoading = true
        
        let db = Firestore.firestore()
        db.collection("comercios").document(comercioID).collection("packs")
            .whereField("venceEn", isGreaterThan: Timestamp(date: Date()))
            .getDocuments { snapshot, error in
                isLoading = false
                
                if let error = error {
                    print("Error loading products: \(error.localizedDescription)")
                    return
                }
                
                if let snapshot = snapshot {
                    var newProductos: [Producto] = []
                    
                    for document in snapshot.documents {
                        let data = document.data()
                        let id = document.documentID
                        
                        // Convert Firestore data to Producto
                        let producto = Producto(id: id, data: data, comercioID: comercioID)
                        newProductos.append(producto)
                    }
                    
                    productos = newProductos.sorted { $0.fechaDisponible > $1.fechaDisponible }
                }
            }
    }
    
    // Helper function to get days in order
    private func getOrderedDays() -> [String] {
        let daysOrder = ["lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo"]
        return daysOrder.filter { comercio.horario.keys.contains($0) }
    }
    
    // Helper function to capitalize day names
    private func capitalizeDayName(_ day: String) -> String {
        let firstChar = day.prefix(1).uppercased()
        let restOfTheString = day.dropFirst()
        return firstChar + restOfTheString
    }
}

// Product card view
import SwiftUI

// Vista de tarjeta de producto con botón para compra simulada
struct ProductCardView: View {
    let producto: Producto
    let comercioID: String
    
    @State private var showPurchaseSheet = false
    
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Contenido principal: imagen y detalles
            HStack(alignment: .top, spacing: 12) {
                // Imagen del producto
                if producto.imageURL.isEmpty {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                } else {
                    AsyncImage(url: URL(string: producto.imageURL)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 80, height: 80)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        case .failure:
                            Image(systemName: "photo")
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                                .frame(width: 80, height: 80)
                        }
                    }
                }
                
                // Información del producto
                VStack(alignment: .leading, spacing: 4) {
                    Text(producto.nombre)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(producto.descripcion)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    // Precios
                    HStack {
                        Text("$\(String(format: "%.2f", producto.precio))")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(primaryColor)
                        
                        Text("$\(String(format: "%.2f", producto.precioOriginal))")
                            .font(.caption)
                            .strikethrough()
                            .foregroundColor(.gray)
                        
                        Text("\(Int((1 - producto.precio / producto.precioOriginal) * 100))% OFF")
                            .font(.caption)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(3)
                    }
                    
                    // Etiquetas
                    if !producto.etiquetas.isEmpty {
                        HStack {
                            ForEach(producto.etiquetas.prefix(2), id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(primaryColor.opacity(0.1))
                                    .foregroundColor(primaryColor)
                                    .cornerRadius(3)
                            }
                        }
                    }
                }
                .padding(.leading, 4)
            }
            
            // Disponibilidad de tiempo
            VStack(alignment: .leading, spacing: 4) {
                Text("Disponible hasta:")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack {
                    // Barra de progreso
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Fondo
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                                .cornerRadius(3)
                            
                            // Progreso
                            Rectangle()
                                .fill(timeRemainingColor(for: producto))
                                .frame(
                                    width: max(0, min(geometry.size.width * CGFloat(producto.tiempoRestantePorcentaje), geometry.size.width)),
                                    height: 6
                                )
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 6)
                    
                    // Texto de tiempo restante
                    Text(formatTimeRemaining(for: producto))
                        .font(.caption)
                        .foregroundColor(timeRemainingColor(for: producto))
                }
            }
            
            // Botón de comprar
            Button(action: {
                showPurchaseSheet = true
            }) {
                HStack {
                    Spacer()
                    
                    Text("Comprar ahora")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.vertical, 10)
                .background(producto.cantidadDisponible > 0 ? primaryColor : Color.gray)
                .cornerRadius(10)
            }
            .disabled(producto.cantidadDisponible < 1)
            .sheet(isPresented: $showPurchaseSheet) {
                // Mostrar vista de compra con pago simulado
                ProductPurchaseView(
                    producto: producto,
                    isPresented: $showPurchaseSheet
                )
            }
            
            Divider()
        }
        .padding(.vertical, 8)
    }
    
    // Función auxiliar para obtener el color según el tiempo restante
    private func timeRemainingColor(for producto: Producto) -> Color {
        if producto.tiempoRestantePorcentaje > 0.6 {
            return .green
        } else if producto.tiempoRestantePorcentaje > 0.3 {
            return .orange
        } else {
            return .red
        }
    }
    
    // Función auxiliar para formatear el tiempo restante
    private func formatTimeRemaining(for producto: Producto) -> String {
        let ahora = Date()
        let segundosRestantes = producto.venceEn.timeIntervalSince(ahora)
        
        if segundosRestantes <= 0 {
            return "Expirado"
        }
        
        let horasRestantes = Int(segundosRestantes / 3600)
        let minutosRestantes = Int((segundosRestantes.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if horasRestantes > 24 {
            let diasRestantes = horasRestantes / 24
            return "\(diasRestantes) día\(diasRestantes > 1 ? "s" : "")"
        } else if horasRestantes > 0 {
            return "\(horasRestantes)h \(minutosRestantes)m"
        } else {
            return "\(minutosRestantes) minutos"
        }
    }
}
    
    // Helper for time remaining color
    private func timeRemainingColor(for producto: Producto) -> Color {
        if producto.tiempoRestantePorcentaje > 0.6 {
            return .green
        } else if producto.tiempoRestantePorcentaje > 0.3 {
            return .orange
        } else {
            return .red
        }
    }
    
    // Helper to format time remaining
    private func formatTimeRemaining(for producto: Producto) -> String {
        let ahora = Date()
        let segundosRestantes = producto.venceEn.timeIntervalSince(ahora)
        
        if segundosRestantes <= 0 {
            return "Expirado"
        }
        
        let horasRestantes = Int(segundosRestantes / 3600)
        let minutosRestantes = Int((segundosRestantes.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if horasRestantes > 24 {
            let diasRestantes = horasRestantes / 24
            return "\(diasRestantes) día\(diasRestantes > 1 ? "s" : "")"
        } else if horasRestantes > 0 {
            return "\(horasRestantes)h \(minutosRestantes)m"
        } else {
            return "\(minutosRestantes) minutos"
        }
    }

