//
//  storeHeader.swift
//  QueSobro
//
//  Created by Alumno on 29/03/25.
//

import SwiftUI

struct ComercioHeaderView: View {
    let comercioData: ComercioData?
    
    // Colores de la app
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08)
    
    var body: some View {
        VStack(spacing: 15) {
            // Información básica
            HStack(alignment: .top, spacing: 15) {
                // Logo o imagen del comercio (círculo placeholder)
                Circle()
                    .fill(primaryColor)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(String(comercioData?.nombre.prefix(1) ?? ""))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                // Detalles del comercio
                VStack(alignment: .leading, spacing: 4) {
                    Text(comercioData?.nombre ?? "Comercio")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", comercioData?.calificacionPromedio ?? 0.0))
                        Text("(\(Int.random(in: 10...100)) reseñas)")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.gray)
                            .font(.caption)
                        Text(comercioData?.direccion ?? "Dirección")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Etiquetas de tipo de comida
                    HStack {
                        ForEach(comercioData?.tipoComida.prefix(2) ?? [], id: \.self) { tipo in
                            Text(tipo)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(primaryColor.opacity(0.1))
                                .foregroundColor(primaryColor)
                                .cornerRadius(5)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Botones de acciones rápidas
            HStack(spacing: 15) {
                // Botón de estadísticas
                VStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.title3)
                    Text("Estadísticas")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .foregroundColor(primaryColor)
                
                // Botón de pedidos
                VStack {
                    Image(systemName: "bag.fill")
                        .font(.title3)
                    Text("Pedidos")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .foregroundColor(primaryColor)
                
                // Botón de perfil
                VStack {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                    Text("Ajustes")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .foregroundColor(primaryColor)
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}

struct InfoSectionView: View {
    // Colores de la app
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08) // Rojo del logo
    
    var body: some View {
        VStack(spacing: 10) {
            Text("¡Combate el desperdicio alimentario!")
                .font(.headline)
                .foregroundColor(primaryColor)
            
            Text("Cada año se desperdician más de 1.000 millones de toneladas de alimentos a nivel mundial. Con Qué Sobró, estás contribuyendo a reducir este impacto.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("ODS 12: Producción y consumo responsables")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}
