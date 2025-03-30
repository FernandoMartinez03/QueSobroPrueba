//
//  productItemView.swift
//  QueSobro
//
//  Created by Alumno on 29/03/25.
//

import SwiftUI

struct ProductoItemView: View {
    let producto: Producto
    let comercioID: String
    let onDelete: () -> Void
    
    @State private var showEditSheet = false
    
    // Colores de la app
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08) // Rojo del logo
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                // Imagen del producto
                if producto.imageURL.isEmpty {
                    // Placeholder si no hay imagen
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title)
                                .foregroundColor(.gray)
                        )
                } else {
                    // Cargar imagen desde URL
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
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        case .failure:
                            Image(systemName: "photo")
                                .font(.title)
                                .foregroundColor(.gray)
                                .frame(width: 80, height: 80)
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
                        .fontWeight(.bold)
                    
                    Text(producto.descripcion)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    // Precios
                    HStack {
                        Text("$\(String(format: "%.2f", producto.precio))")
                            .font(.headline)
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
                    HStack {
                        ForEach(producto.etiquetas.prefix(2), id: \.self) { etiqueta in
                            Text(etiqueta)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(primaryColor.opacity(0.1))
                                .foregroundColor(primaryColor)
                                .cornerRadius(3)
                        }
                        
                        Spacer()
                        
                        // Inventario
                        Text("\(producto.cantidadDisponible) disponibles")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(3)
                    }
                }
                .padding(.leading, 5)
            }
            
            // Barra de tiempo disponible
            VStack(alignment: .leading, spacing: 2) {
                Text("Disponible hasta:")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack {
                    timeRemainingProgressBar
                    
                    Text(tiempoRestanteFormateado)
                        .font(.caption)
                        .foregroundColor(tiempoRestanteColor)
                }
            }
            .padding(.top, 5)
            
            Divider()
                .padding(.vertical, 5)
            
            // Botones de acción
            HStack {
                Spacer()
                
                // Botón de editar
                Button(action: {
                    showEditSheet = true
                }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Editar")
                    }
                    .font(.caption)
                    .foregroundColor(primaryColor)
                }
                
                Spacer()
                
                // Divider vertical
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 20)
                
                Spacer()
                
                // Botón de eliminar
                Button(action: onDelete) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Eliminar")
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        .sheet(isPresented: $showEditSheet) {
            // Mostrar la ventana de edición cuando se presiona el botón
            AddProductoView(
                comercioID: comercioID,
                isEditMode: true,
                productoID: producto.id,
                productoExistente: producto
            )
        }
    }
    
    // Barra de progreso para el tiempo restante
    private var timeRemainingProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Fondo
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 6)
                    .cornerRadius(3)
                
                // Progreso
                Rectangle()
                    .fill(tiempoRestanteColor)
                    .frame(width: max(0, min(geometry.size.width * CGFloat(producto.tiempoRestantePorcentaje), geometry.size.width)), height: 6)
                    .cornerRadius(3)
            }
        }
        .frame(height: 6)
    }
    
    // Color basado en el tiempo restante
    private var tiempoRestanteColor: Color {
        if producto.tiempoRestantePorcentaje > 0.6 {
            return .green
        } else if producto.tiempoRestantePorcentaje > 0.3 {
            return .orange
        } else {
            return .red
        }
    }
    
    // Formato del tiempo restante
    private var tiempoRestanteFormateado: String {
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
