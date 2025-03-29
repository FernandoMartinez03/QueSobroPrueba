//
//  storeView.swift
//  QueSobro
//
//  Created by Alumno on 29/03/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ComercioHomeView: View {
    @State private var comercioData: ComercioData?
    @State private var productos: [Producto] = []
    @State private var isLoading = true
    @State private var showAddProduct = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Para logout
    @Binding var isAuthenticated: Bool
    
    // Colores de la app
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08) // Rojo del logo
    let backgroundColor = Color(white: 0.97)
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: primaryColor))
                        .scaleEffect(1.5)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Header con información del comercio
                            ComercioHeaderView(comercioData: comercioData)
                            
                            // Sección de productos disponibles
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Text("Paquetes Disponibles")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(primaryColor)
                                    
                                    Spacer()
                                    
                                    // Botón para agregar nuevo producto
                                    Button(action: {
                                        showAddProduct = true
                                    }) {
                                        HStack {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(.white)
                                            Text("Nuevo")
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 8)
                                        .background(primaryColor)
                                        .cornerRadius(20)
                                    }
                                }
                                .padding(.horizontal)
                                
                                if productos.isEmpty {
                                    // Mensaje cuando no hay productos
                                    EmptyProductsView()
                                } else {
                                    // Lista de productos
                                    ForEach(productos) { producto in
                                        ProductoItemView(
                                            producto: producto,
                                            onDelete: {
                                                eliminarProducto(producto)
                                            }
                                        )
                                    }
                                }
                            }
                            
                            // Sección informativa
                            InfoSectionView()
                            
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Mi Comercio")
            .navigationBarItems(trailing: Button(action: {
                logout()
            }) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(primaryColor)
            })
            .sheet(isPresented: $showAddProduct) {
                // Recargar productos cuando se cierra la vista
                loadProductos()
            } content: {
                if let comercioID = comercioData?.id {
                    AddProductoView(comercioID: comercioID)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Aviso"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                loadComercioData()
            }
        }.navigationBarBackButtonHidden(true)
    } 
    
    // Cargar los datos del comercio
    func loadComercioData() {
        isLoading = true
        
        guard let userID = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        
        // Obtener el ID del comercio desde el usuario
        db.collection("users").document("usr_\(userID)").getDocument { userDocument, error in
            if let error = error {
                alertMessage = "Error al cargar datos: \(error.localizedDescription)"
                showAlert = true
                isLoading = false
                return
            }
            
            guard let userDocument = userDocument, userDocument.exists,
                  let comercioID = userDocument.data()?["comercioID"] as? String else {
                alertMessage = "No se encontró información del comercio"
                showAlert = true
                isLoading = false
                return
            }
            
            // Obtener los datos del comercio
            db.collection("comercios").document(comercioID).getDocument { document, error in
                if let error = error {
                    alertMessage = "Error al cargar datos: \(error.localizedDescription)"
                    showAlert = true
                    isLoading = false
                    return
                }
                
                guard let document = document, document.exists,
                      let data = document.data() else {
                    alertMessage = "No se encontró información del comercio"
                    showAlert = true
                    isLoading = false
                    return
                }
                
                // Mapear datos del comercio
                let id = document.documentID
                let nombre = data["nombre"] as? String ?? ""
                let direccion = data["direccion"] as? String ?? ""
                let ciudad = data["ciudad"] as? String ?? ""
                let calificacionPromedio = data["calificacionPromedio"] as? Double ?? 0.0
                let tipoComida = data["tipoComida"] as? [String] ?? []
                let horario = data["horario"] as? [String: String] ?? [:]
                
                self.comercioData = ComercioData(
                    id: id,
                    nombre: nombre,
                    direccion: direccion,
                    ciudad: ciudad,
                    calificacionPromedio: calificacionPromedio,
                    tipoComida: tipoComida,
                    horario: horario
                )
                
                // Cargar los productos
                loadProductos()
            }
        }
    }
    
    // Cargar los productos del comercio
    func loadProductos() {
        guard let comercioID = comercioData?.id else {
            isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        
        // Obtener los packs del comercio
        db.collection("comercios").document(comercioID).collection("packs").getDocuments { snapshot, error in
            if let error = error {
                alertMessage = "Error al cargar productos: \(error.localizedDescription)"
                showAlert = true
                isLoading = false
                return
            }
            
            var nuevosProductos: [Producto] = []
            
            for document in snapshot?.documents ?? [] {
                let data = document.data()
                let id = document.documentID
                let nombre = data["nombre"] as? String ?? ""
                let descripcion = data["descripcion"] as? String ?? ""
                let cantidadDisponible = data["cantidadDisponible"] as? Int ?? 0
                let precio = data["precio"] as? Double ?? 0.0
                let precioOriginal = data["precioOriginal"] as? Double ?? 0.0
                let imageURL = data["imagenURL"] as? String ?? ""
                let etiquetas = data["etiquetas"] as? [String] ?? []
                let fechaDisponible = (data["fechaDisponible"] as? Timestamp)?.dateValue() ?? Date()
                let venceEn = (data["venceEn"] as? Timestamp)?.dateValue() ?? Date().addingTimeInterval(86400) // Default 24 horas
                
                // Solo agregar productos que no hayan expirado
                if venceEn > Date() {
                    let producto = Producto(
                        id: id,
                        nombre: nombre,
                        descripcion: descripcion,
                        cantidadDisponible: cantidadDisponible,
                        precio: precio,
                        precioOriginal: precioOriginal,
                        imageURL: imageURL,
                        etiquetas: etiquetas,
                        fechaDisponible: fechaDisponible,
                        venceEn: venceEn
                    )
                    
                    nuevosProductos.append(producto)
                } else {
                    // Eliminar productos expirados automáticamente
                    db.collection("comercios").document(comercioID).collection("packs").document(id).delete()
                }
            }
            
            // Ordenar productos por fecha más reciente
            self.productos = nuevosProductos.sorted { $0.fechaDisponible > $1.fechaDisponible }
            
            isLoading = false
        }
    }
    
    // Eliminar un producto
    func eliminarProducto(_ producto: Producto) {
        guard let comercioID = comercioData?.id else { return }
        
        let db = Firestore.firestore()
        db.collection("comercios").document(comercioID).collection("packs").document(producto.id).delete { error in
            if let error = error {
                alertMessage = "Error al eliminar el producto: \(error.localizedDescription)"
                showAlert = true
            } else {
                // Eliminar el producto de la lista local
                productos.removeAll { $0.id == producto.id }
                
                alertMessage = "Producto eliminado correctamente"
                showAlert = true
            }
        }
    }
    
    // Cerrar sesión
    func logout() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
        } catch {
            alertMessage = "Error al cerrar sesión: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

// Vista para cuando no hay productos
struct EmptyProductsView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "cube.box")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No tienes paquetes disponibles")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("Agrega paquetes para combatir el desperdicio")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
}

// Vista previa
struct ComercioHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ComercioHomeView(isAuthenticated: .constant(true))
    }
}
