import SwiftUI

struct MainAppView: View {
    // Define the categories in the desired order
    let categories = ["Pastelerías", "Comida Rápida", "Restaurantes", "Cafeterías"]
    
    @StateObject private var viewModel = ComercioViewModel() // Use the ViewModel to manage commerces
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                // Parte superior
                Text("Dirección")
                    .font(.title) // Tîtulo es + grande!.
                    .fontWeight(.bold)
                    .padding(.top)
                
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                        .font(.headline)
                    Text("Cerca de ti")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                
                // Aquí van los restaurantes más cercanos:
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.comercios.prefix(6)) { comercio in
                            RestaurantView(comercio: comercio)
                        }
                    }
                }
                
                // Aquí van las categorías
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(categories, id: \.self) { category in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(category)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        // Fetch commerces for each category (tipoComida)
                                        ForEach(viewModel.comerciosForCategory(category).prefix(6)) { comercio in
                                            RestaurantView(comercio: comercio)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                Spacer() // Pushes content up
            }
            .padding()
        }
        .onAppear {
            viewModel.loadComercios() // Load commerces when the view appears
        }
    }
}

struct RestaurantView: View {
    let comercio: ComercioData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 150, height: 100)
                .background(
                    Image("restaurant-placeholder") // Placeholder image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 100)
                        .clipped()
                        .cornerRadius(10)
                )
            
            Text(comercio.nombre) // Display the name of the restaurant
                .font(.headline)
            
            // Rating Stars
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    Image(systemName: index < Int(comercio.calificacionPromedio) ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.system(size: 12))
                }
            }
            
            // Business Hours (Display the schedule)
            VStack(alignment: .leading, spacing: 2) {
                Text("Horario:")
                    .font(.caption)
                    .foregroundColor(.gray)
                ForEach(comercio.horario.keys.sorted(), id: \.self) { day in
                    Text("\(day): \(comercio.horario[day] ?? "Cerrado")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Distance (static for now)
            Text("2.5 km")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
    }
}
