//
//  AddProductView.swift
//  QueSobro
//
//  Created by Alumno on 29/03/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct AddProductoView: View {
    let comercioID: String
    
    @Environment(\.presentationMode) var presentationMode
    
    // Datos del producto
    @State private var nombre: String = ""
    @State private var descripcion: String = ""
    @State private var precio: String = ""
    @State private var precioOriginal: String = ""
    @State private var cantidad: String = "1"
    @State private var horasDisponible: Double = 24 // Por defecto 24 horas
    
    // Estados
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Colores de la app
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08) // Rojo del logo
    let backgroundColor = Color(white: 0.97)
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Formulario simplificado
                        VStack(spacing: 15) {
                            // Nombre
                            TextField("Nombre del paquete", text: $nombre)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            
                            // Descripción
                            TextField("Descripción (contenido del paquete)", text: $descripcion)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            
                            // Precios
                            HStack {
                                // Precio con descuento
                                VStack(alignment: .leading) {
                                    Text("Precio (con descuento)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    TextField("$", text: $precio)
                                        .keyboardType(.decimalPad)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                }
                                
                                // Precio original
                                VStack(alignment: .leading) {
                                    Text("Precio original")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    TextField("$", text: $precioOriginal)
                                        .keyboardType(.decimalPad)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                }
                            }
                            
                            // Cantidad
                            TextField("Cantidad disponible", text: $cantidad)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            
                            // Tiempo disponible simplificado
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Disponible por: \(Int(horasDisponible)) horas")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Slider(value: $horasDisponible, in: 1...48, step: 1)
                                    .accentColor(primaryColor)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                        
                        // Botón de guardar
                        Button(action: saveProduct) {
                            Text("Guardar Paquete")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(primaryColor)
                                .cornerRadius(10)
                                .shadow(color: primaryColor.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                        .disabled(isLoading)
                    }
                    .padding(.vertical)
                }
                
                // Overlay de carga
                if isLoading {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .overlay(
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                                Text("Guardando producto...")
                                    .foregroundColor(.white)
                                    .padding(.top, 10)
                            }
                        )
                }
            }
            .navigationTitle("Nuevo Paquete")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancelar") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Aviso"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if alertMessage.contains("éxito") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
        }
    }
    
    // Función simplificada para guardar el producto
    func saveProduct() {
        // Validación básica
        guard !nombre.isEmpty, !descripcion.isEmpty else {
            alertMessage = "Por favor completa los campos obligatorios"
            showAlert = true
            return
        }
        
        guard let precioValue = Double(precio), precioValue > 0 else {
            alertMessage = "Por favor ingresa un precio válido"
            showAlert = true
            return
        }
        
        isLoading = true
        
        let db = Firestore.firestore()
        
        // Fechas
        let fechaDisponible = Date()
        let venceEn = fechaDisponible.addingTimeInterval(Double(horasDisponible) * 3600)
        
        // Datos básicos del producto
        let productoData: [String: Any] = [
            "nombre": nombre,
            "descripcion": descripcion,
            "precio": Double(precio) ?? 0.0,
            "precioOriginal": Double(precioOriginal) ?? Double(precio) ?? 0.0,
            "cantidadDisponible": Int(cantidad) ?? 1,
            "imagenURL": "",
            "etiquetas": [],
            "fechaDisponible": Timestamp(date: fechaDisponible),
            "venceEn": Timestamp(date: venceEn),
            "comercioID": comercioID
        ]
        
        // Guardar en Firestore
        db.collection("comercios").document(comercioID).collection("packs").addDocument(data: productoData) { error in
            isLoading = false
            
            if let error = error {
                alertMessage = "Error al guardar: \(error.localizedDescription)"
                showAlert = true
            } else {
                alertMessage = "¡Producto guardado con éxito!"
                showAlert = true
            }
        }
    }
}
