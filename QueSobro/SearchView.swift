import SwiftUI
import FirebaseFirestore

struct SearchView: View {
    @State private var searchText = ""
    @StateObject private var viewModel = SearchViewModel()
    
    // Colores de la app
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08) // Rojo del logo
    let backgroundColor = Color(white: 0.97) // Fondo claro
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Barra de búsqueda personalizada
                    SearchBarView(searchText: $searchText, viewModel: viewModel, primaryColor: primaryColor)
                    
                    // Contenido principal
                    SearchContentView(searchText: searchText, viewModel: viewModel, primaryColor: primaryColor)
                }
            }
            .navigationTitle("Buscar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Componente de la barra de búsqueda
struct SearchBarView: View {
    @Binding var searchText: String
    @ObservedObject var viewModel: SearchViewModel
    let primaryColor: Color
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Buscar comercios o comida...", text: $searchText)
                    .foregroundColor(.primary)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: searchText) { newValue in
                        if !newValue.isEmpty && newValue.count >= 2 {
                            viewModel.search(query: newValue)
                        } else if newValue.isEmpty {
                            viewModel.clearResults()
                        }
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        viewModel.clearResults()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

// Componente para el contenido principal
struct SearchContentView: View {
    let searchText: String
    @ObservedObject var viewModel: SearchViewModel
    let primaryColor: Color
    
    var body: some View {
        if viewModel.isSearching {
            SearchLoadingView(primaryColor: primaryColor)
        } else if searchText.isEmpty {
            EmptySearchView(viewModel: viewModel, primaryColor: primaryColor)
        } else if viewModel.searchResults.isEmpty && !viewModel.isSearching && !searchText.isEmpty {
            NoResultsView(searchText: searchText)
        } else {
            SearchResultsListView(viewModel: viewModel, primaryColor: primaryColor)
        }
    }
}

// Vista de carga
struct SearchLoadingView: View {
    let primaryColor: Color
    
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: primaryColor))
                .scaleEffect(1.5)
            Text("Buscando...")
                .foregroundColor(.gray)
                .padding(.top, 10)
            Spacer()
        }
    }
}

// Vista cuando no hay búsqueda
struct EmptySearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    let primaryColor: Color
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 70))
                .foregroundColor(.gray.opacity(0.7))
            
            Text("Busca por nombre de comercio, tipo de comida o plato")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
            
            Spacer()
            
            // Secciones de categorías populares
            CategoriesView(viewModel: viewModel, primaryColor: primaryColor)
        }
    }
}

// Vista de categorías
struct CategoriesView: View {
    @ObservedObject var viewModel: SearchViewModel
    let primaryColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Categorías populares")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(viewModel.popularCategories, id: \.self) { category in
                        CategoryButton(
                            title: category,
                            icon: viewModel.iconForCategory(category),
                            color: primaryColor,
                            action: {
                                viewModel.setSearchQuery(category)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 20)
    }
}

// Vista sin resultados
struct NoResultsView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 70))
                .foregroundColor(.gray.opacity(0.7))
            
            Text("No se encontraron resultados para \"\(searchText)\"")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
            
            Text("Intenta con otra búsqueda o categoría")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

// Vista de resultados
struct SearchResultsListView: View {
    @ObservedObject var viewModel: SearchViewModel
    let primaryColor: Color
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.searchResults) { comercio in
                    NavigationLink(destination: RestaurantDetailView(comercio: comercio.toComercioData(), comercioID: comercio.id)) {
                        SearchResultCard(comercio: comercio, primaryColor: primaryColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }
}

// Tarjeta de resultado de búsqueda
struct SearchResultCard: View {
    let comercio: ComercioSearchResult
    let primaryColor: Color
    
    var body: some View {
        HStack(spacing: 15) {
            // Imagen del comercio
            ComercioImageView(imageURL: comercio.imageURL, nombre: comercio.nombre, primaryColor: primaryColor)
            
            // Información del comercio
            ComercioInfoView(comercio: comercio, primaryColor: primaryColor)
            
            Spacer()
            
            // Flecha de navegación
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// Vista de la imagen del comercio
struct ComercioImageView: View {
    let imageURL: String?
    let nombre: String
    let primaryColor: Color
    
    var body: some View {
        Group {
            if let imageURL = imageURL, !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    case .failure:
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(nombre.prefix(1))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                    @unknown default:
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 80, height: 80)
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(primaryColor)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(nombre.prefix(1))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
            }
        }
    }
}

// Vista de la información del comercio
struct ComercioInfoView: View {
    let comercio: ComercioSearchResult
    let primaryColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(comercio.nombre)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 12))
                Text(String(format: "%.1f", comercio.calificacion))
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text("(\(comercio.reviewsCount) reseñas)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(comercio.direccion)
                .font(.caption)
                .foregroundColor(.gray)
            
            // Mostrar categorías
            CategoriasTags(categorias: comercio.categorias, primaryColor: primaryColor)
        }
    }
}

// Vista de etiquetas de categorías
struct CategoriasTags: View {
    let categorias: [String]
    let primaryColor: Color
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(categorias.prefix(3), id: \.self) { categoria in
                    Text(categoria)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(primaryColor.opacity(0.2))
                        .foregroundColor(primaryColor)
                        .cornerRadius(10)
                }
                
                if categorias.count > 3 {
                    Text("+\(categorias.count - 3)")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.gray)
                        .cornerRadius(10)
                }
            }
        }
    }
}

// Botón de categoría
struct CategoryButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(width: 80, height: 80)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

// ViewModel para la búsqueda
class SearchViewModel: ObservableObject {
    @Published var searchResults: [ComercioSearchResult] = []
    @Published var isSearching = false
    @Published var popularCategories = ["Comida Mexicana", "Postres", "Bebidas", "Desayunos", "Vegetariana", "Italiana"]
    @Published var searchQuery = ""
    
    private var db = Firestore.firestore()
    
    func setSearchQuery(_ query: String) {
        searchQuery = query
        search(query: query)
    }
    
    func search(query: String) {
        guard !query.isEmpty else { return }
        
        isSearching = true
        searchResults.removeAll()
        
        // Convertir consulta a minúsculas para búsqueda insensible a mayúsculas
        let queryLowercase = query.lowercased()
        
        // Buscar en comercios
        db.collection("comercios").getDocuments { snapshot, error in
            if let error = error {
                print("Error searching: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isSearching = false
                }
                return
            }
            
            var results: [ComercioSearchResult] = []
            
            for document in snapshot?.documents ?? [] {
                let data = document.data()
                let id = document.documentID
                let nombre = data["nombre"] as? String ?? ""
                let direccion = data["direccion"] as? String ?? ""
                let ciudad = data["ciudad"] as? String ?? ""
                let calificacion = data["calificacionPromedio"] as? Double ?? 0.0
                let reviewsCount = data["reviewsCount"] as? Int ?? 0
                let imageURL = data["imageURL"] as? String
                let categorias = data["tipoComida"] as? [String] ?? []
                
                // Buscar coincidencias en varios campos
                if nombre.lowercased().contains(queryLowercase) ||
                   self.anyCategory(categorias, contains: queryLowercase) ||
                   direccion.lowercased().contains(queryLowercase) ||
                   ciudad.lowercased().contains(queryLowercase) {
                    
                    let result = ComercioSearchResult(
                        id: id,
                        nombre: nombre,
                        direccion: direccion,
                        ciudad: ciudad,
                        imageURL: imageURL,
                        calificacion: calificacion,
                        reviewsCount: reviewsCount,
                        categorias: categorias
                    )
                    
                    results.append(result)
                }
            }
            
            DispatchQueue.main.async {
                self.searchResults = results
                self.isSearching = false
            }
        }
    }

    
    func clearResults() {
        searchResults.removeAll()
    }
    
    // Verificar si alguna categoría coincide con la consulta
    private func anyCategory(_ categories: [String], contains query: String) -> Bool {
        return categories.first(where: { $0.lowercased().contains(query) }) != nil
    }
    
    // Obtener icono para categoría
    func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case let cat where cat.contains("mexicana"):
            return "flame.fill"
        case let cat where cat.contains("postres"):
            return "birthday.cake.fill"
        case let cat where cat.contains("bebidas"):
            return "cup.and.saucer.fill"
        case let cat where cat.contains("desayunos"):
            return "sun.and.horizon.fill"
        case let cat where cat.contains("vegetariana"):
            return "leaf.fill"
        case let cat where cat.contains("italiana"):
            return "fork.knife"
        default:
            return "bag.fill"
        }
    }
}

// Modelo de resultado de búsqueda
struct ComercioSearchResult: Identifiable {
    let id: String
    let nombre: String
    let direccion: String
    let ciudad: String
    let imageURL: String?
    let calificacion: Double
    let reviewsCount: Int
    let categorias: [String]
    
    // Método para convertir a ComercioData
    func toComercioData() -> ComercioData {
        return ComercioData(
            id: id,
            nombre: nombre,
            direccion: direccion,
            ciudad: ciudad,
            calificacionPromedio: calificacion,
            tipoComida: categorias,
            horario: [:], // Horario vacío por defecto
            imageURL: imageURL ?? "", // Se asegura que no sea nil
            reviewsCount: reviewsCount
        )
    }
}
