//
//  ApplePayButton.swift
//  QueSobro
//
//  Created by Alumno on 29/03/25.
//

import Foundation
import SwiftUI
import PassKit

// Un botón personalizado con estilo Apple Pay
struct ApplePayButton: View {
    let action: () -> Void
    let isDisabled: Bool
    
    init(action: @escaping () -> Void, isDisabled: Bool = false) {
        self.action = action
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "applelogo")
                    .foregroundColor(.white)
                Text("Pagar")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(isDisabled ? Color.gray : Color.black)
            .cornerRadius(10)
        }
        .disabled(isDisabled || !ApplePayHandler.applePayAvailable())
    }
}

// Vista de la hoja de compra con Apple Pay
import SwiftUI

// Vista para comprar un producto (ahora con pago simulado)
struct ProductPurchaseView: View {
    let producto: Producto
    
    @State private var cantidad = 1
    @State private var isProcessing = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var orderSuccess = false
    @Binding var isPresented: Bool
    
    // Colores
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08)
    
    // Calculamos el total a pagar
    var totalPrice: Double {
        return Double(cantidad) * producto.precio
    }
    
    // Formateamos el precio
    var formattedTotalPrice: String {
        return String(format: "$%.2f", totalPrice)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Título
            HStack {
                Text("Realizar pedido")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
            }
            .padding(.bottom)
            
            // Imagen y detalles del producto
            HStack(alignment: .top, spacing: 15) {
                // Imagen del producto
                if producto.imageURL.isEmpty {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
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
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                // Información del producto
                VStack(alignment: .leading, spacing: 5) {
                    Text(producto.nombre)
                        .font(.headline)
                    
                    Text(producto.descripcion)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    HStack {
                        Text("Precio: $\(String(format: "%.2f", producto.precio))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.bottom)
            
            // Selector de cantidad
            VStack(spacing: 10) {
                Text("Cantidad")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Button(action: {
                        if cantidad > 1 {
                            cantidad -= 1
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(cantidad > 1 ? primaryColor : .gray)
                            .font(.title2)
                    }
                    .disabled(cantidad <= 1)
                    
                    Text("\(cantidad)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(width: 40)
                    
                    Button(action: {
                        if cantidad < producto.cantidadDisponible {
                            cantidad += 1
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(cantidad < producto.cantidadDisponible ? primaryColor : .gray)
                            .font(.title2)
                    }
                    .disabled(cantidad >= producto.cantidadDisponible)
                }
                
                Text("Disponibles: \(producto.cantidadDisponible)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom)
            
            // Resumen de precios
            VStack(spacing: 10) {
                HStack {
                    Text("Subtotal")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", totalPrice))")
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                HStack {
                    Text("Total a pagar")
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text(formattedTotalPrice)
                        .fontWeight(.bold)
                        .foregroundColor(primaryColor)
                }
            }
            .padding(.bottom)
            
            // Botón de pago simulado
            Button(action: {
                processSimulatedPayment()
            }) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "creditcard.fill")
                            .foregroundColor(.white)
                        Text("Pagar \(formattedTotalPrice)")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isProcessing ? Color.gray : primaryColor)
                .cornerRadius(10)
            }
            .disabled(isProcessing)
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(orderSuccess ? "Éxito" : "Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if orderSuccess {
                        isPresented = false
                    }
                }
            )
        }
    }
    
    func processSimulatedPayment() {
        isProcessing = true
        
        // Simular un tiempo de procesamiento
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Crear instancia del manejador de pagos simulados
            let paymentHandler = SimulatedPaymentHandler()
            
            // Procesar el pago simulado
            paymentHandler.processPayment(
                producto: producto,
                cantidad: cantidad
            ) { success, message in
                isProcessing = false
                alertMessage = message
                orderSuccess = success
                showAlert = true
            }
        }
    }
}
    
    // Función para procesar el pago
    /*
    func processPayment() {
        isProcessing = true
        
        let orderManager = OrderManager()
        
        orderManager.processOrderWithApplePay(
            producto: producto,
            cantidad: cantidad
        ) { success, message in
            isProcessing = false
            alertMessage = message
            orderSuccess = success
            showAlert = true
        }
    }
}
*/

// Preview para el botón de Apple Pay
struct ApplePayButton_Previews: PreviewProvider {
    static var previews: some View {
        ApplePayButton(action: {
            print("Apple Pay tapped")
        })
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
