//
//  MainAppView.swift
//  QueSobro
//
//  Created by Fernando Martínez on 29/03/25.
//

import Foundation
import SwiftUI

struct MainAppView: View {
    // Define the categories in the desired order
    let categories = ["Pastelerías", "Comida Rápida", "Restaurantes", "Cafeterías"]
    
    var body: some View {
        ZStack {
            // Recuerda, .leading ayuda a poner izq.
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
                
                //Aquî van los restaurantes más cercanos:
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<6) { index in
                            RestaurantView(
                                category: "Cerca de ti"
                            )
                        }
                    }
                }
                
                // Aquî van las categorîas
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(categories, id: \.self) { category in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(category)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(0..<6) { _ in
                                            RestaurantView(category: category)
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
    }
}

struct RestaurantView: View {
    let category: String // Add category to customize each restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 150, height: 100)
                .background(
                    Image("restaurant-placeholder")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 100)
                        .clipped()
                        .cornerRadius(10)
                )
            
            Text("Restaurante") // Display category for demo
                .font(.headline)
            
            // Rating Stars
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    Image(systemName: index < 3 ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.system(size: 12))
                }
            }
            
            // Distance (static for now)
            Text("2.5 km")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
    }
}
// Pasteleria
// Comida Rápida
// Restaurantes
// Cafeterîas
