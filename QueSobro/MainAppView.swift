import SwiftUI

struct MainAppView: View {
    // Define the categories in the desired order
    let categories = ["Pastelería", "Comida Rápida", "Restaurantes", "Cafeterías"]
    
    @StateObject private var viewModel = ComercioViewModel() // Use the ViewModel to manage commerces
    
    // Colores de la app
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08) // Rojo del logo
    let backgroundColor = Color(white: 0.97)
    let accentColor = Color.blue
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Parte superior
                        VStack(alignment: .leading, spacing: 8) {
                            Text("¡Bienvenido a QueSobro!")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "location.fill")
                                    .foregroundColor(accentColor)
                                    .font(.headline)
                                Text("Cerca de ti")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 8)
                        
                        // Comercios destacados
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Destacados")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(primaryColor)
                                
                                Spacer()
                                
                                Button(action: {
                                    // Action to view all
                                }) {
                                    Text("Ver todos")
                                        .font(.subheadline)
                                        .foregroundColor(primaryColor)
                                }
                            }
                            
                            // Scrollable row of featured restaurants
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.comercios.prefix(5)) { comercio in
                                        RestaurantView(comercio: comercio, comercioID: comercio.id)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        
                        // Categorías
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Explora por categorías")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(primaryColor)
                            
                            ForEach(categories, id: \.self) { category in
                                CategorySection(
                                    categoryName: category,
                                    comercios: viewModel.comerciosForCategory(category),
                                    primaryColor: primaryColor
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Sección de categoría
struct CategorySection: View {
    let categoryName: String
    let comercios: [ComercioData]
    let primaryColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(categoryName)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if comercios.count > 3 {
                    Button(action: {
                        // Action to view all in this category
                    }) {
                        Text("Ver más")
                            .font(.caption)
                            .foregroundColor(primaryColor)
                    }
                }
            }
            
            if comercios.isEmpty {
                Text("No hay comercios en esta categoría")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.vertical, 10)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(comercios) { comercio in
                            RestaurantView(comercio: comercio, comercioID: comercio.id)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Divider()
                .padding(.top, 4)
        }
    }
}

// Restaurant view con estilo mejorado
// Restaurant view con imagen desde Firebase
struct RestaurantView: View {
    let comercio: ComercioData
    let comercioID: String
    
    // Color scheme
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08)
    let backgroundColor = Color.white
    let shadowColor = Color.black.opacity(0.1)
    
    var body: some View {
        NavigationLink(destination: RestaurantDetailView(comercio: comercio, comercioID: comercioID)) {
            VStack(alignment: .leading, spacing: 6) {
                // Imagen del restaurante desde URL
                ZStack(alignment: .topTrailing) {
                    if comercio.imageURL.isEmpty {
                        // Placeholder si no hay imagen
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 150, height: 100)
                            .cornerRadius(12)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white.opacity(0.8))
                            )
                    } else {
                        // Cargar imagen desde URL
                        AsyncImage(url: URL(string: comercio.imageURL)) { phase in
                            switch phase {
                            case .empty:
                                // Estado de carga
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 150, height: 100)
                                    .cornerRadius(12)
                                    .overlay(
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                            .scaleEffect(0.7)
                                    )
                            case .success(let image):
                                // Imagen cargada exitosamente
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 150, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            case .failure:
                                // Error al cargar la imagen
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 150, height: 100)
                                    .cornerRadius(12)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .font(.system(size: 24))
                                            .foregroundColor(.white.opacity(0.8))
                                    )
                            @unknown default:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 150, height: 100)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    
                    // Etiqueta de categoría principal
                    if let firstCategory = comercio.tipoComida.first {
                        Text(firstCategory)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(8)
                    }
                }
                
                // Información del restaurante
                VStack(alignment: .leading, spacing: 4) {
                    Text(comercio.nombre)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                        
                        Text(comercio.direccion)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 4) {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 10))
                            
                            Text(String(format: "%.1f", comercio.calificacionPromedio))
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        
                        // Mostrar el número de reseñas
                        Text("(\(comercio.reviewsCount))")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        // Horario si está disponible
                        if let horaHoy = obtenerHorarioHoy(comercio.horario) {
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text(horaHoy)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .frame(width: 150)
            .background(backgroundColor)
            .cornerRadius(12)
            .shadow(color: shadowColor, radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle()) // Para evitar efectos visuales no deseados
    }
    
    // Helper para obtener el horario del día actual
    private func obtenerHorarioHoy(_ horario: [String: String]) -> String? {
        let diasSemana = ["domingo", "lunes", "martes", "miércoles", "jueves", "viernes", "sábado"]
        let calendar = Calendar.current
        let diaActual = calendar.component(.weekday, from: Date()) - 1 // 0 es domingo
        
        if diaActual >= 0 && diaActual < diasSemana.count {
            return horario[diasSemana[diaActual]]
        }
        
        return nil
    }
}

// Vista previa
struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
    }
}

// Extension del ViewModel (incluida para completitud)
extension ComercioViewModel {
    func comerciosForCategory(_ category: String) -> [ComercioData] {
        return comercios.filter { comercio in
            comercio.tipoComida.contains(category)
        }
    }
}
