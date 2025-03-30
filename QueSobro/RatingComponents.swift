//
//  RatingComponents.swift
//  QueSobro
//
//  Created by Alumno on 29/03/25.
//

import Foundation
// RatingComponents.swift
import SwiftUI

// Componente para mostrar calificación con estrellas (solo lectura)
struct StarsRatingView: View {
    let rating: Int
    let size: CGFloat
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundColor(star <= rating ? .yellow : .gray.opacity(0.3))
            }
        }
    }
}

// Componente para seleccionar calificación con estrellas
struct StarsRatingSelector: View {
    @Binding var rating: Int
    let maxRating = 5
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(1...maxRating, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.title)
                    .foregroundColor(star <= rating ? .yellow : .gray)
                    .onTapGesture {
                        rating = star
                    }
            }
        }
    }
}
