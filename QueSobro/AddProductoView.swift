//
//  AddProductView.swift
//  QueSobro
//
//  Created by Alumno on 29/03/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

struct AddProductoView: View {
    let comercioID: String
    
    // Modo de edición
    let isEditMode: Bool
    let productoID: String?
    var productoExistente: Producto?
    
    @Environment(\.presentationMode) var presentationMode
    
    // Datos del producto
    @State private var nombre: String = ""
    @State private var descripcion: String = ""
    @State private var precio: String = ""
    @State private var precioOriginal: String = ""
    @State private var cantidad: String = "1"
    @State private var horasDisponible: Double = 24 // Por defecto 24 horas
    @State private var etiquetas: [String] = []
    
    // Estados para la imagen
    @State private var selectedImage: UIImage?
    @State private var imageURL: String = ""
    @State private var showImagePicker = false
    @State private var showCameraSheet = false
    @State private var imagePickerSource: ImagePickerSource = .photoLibrary
    @State private var isImageFromURL = false
    
    // Estados
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showEtiquetaSheet = false
    @State private var nuevaEtiqueta: String = ""
    
    // Colores de la app
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08) // Rojo del logo
    let backgroundColor = Color(white: 0.97)
    
    enum ImagePickerSource {
        case photoLibrary, camera
    }
    
    init(comercioID: String, isEditMode: Bool = false, productoID: String? = nil, productoExistente: Producto? = nil) {
        self.comercioID = comercioID
        self.isEditMode = isEditMode
        self.productoID = productoID
        self.productoExistente = productoExistente
        
        // Si estamos en modo edición y tenemos un producto existente, inicializamos los valores
        if let producto = productoExistente {
            _nombre = State(initialValue: producto.nombre)
            _descripcion = State(initialValue: producto.descripcion)
            _precio = State(initialValue: String(format: "%.2f", producto.precio))
            _precioOriginal = State(initialValue: String(format: "%.2f", producto.precioOriginal))
            _cantidad = State(initialValue: String(producto.cantidadDisponible))
            _imageURL = State(initialValue: producto.imageURL)
            _etiquetas = State(initialValue: producto.etiquetas)
            
            // Calcular horas disponibles restantes basado en la fecha de vencimiento
            if isEditMode {
                let ahora = Date()
                let tiempoRestante = producto.venceEn.timeIntervalSince(ahora)
                // Convertir segundos a horas (con un mínimo de 1 hora)
                _horasDisponible = State(initialValue: max(1, tiempoRestante / 3600))
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Sección de imagen
                        VStack(spacing: 15) {
                            // Vista previa de la imagen
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(10)
                                    .clipped()
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            } else if !imageURL.isEmpty {
                                // Si tenemos URL pero no imagen cargada
                                AsyncImage(url: URL(string: imageURL)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 200, height: 200)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 200, height: 200)
                                            .cornerRadius(10)
                                            .clipped()
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    case .failure:
                                        placeholderImage
                                    @unknown default:
                                        placeholderImage
                                    }
                                }
                            } else {
                                placeholderImage
                            }
                            
                            // Botones para seleccionar imagen
                            HStack(spacing: 20) {
                                Button(action: {
                                    imagePickerSource = .camera
                                    showCameraSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "camera")
                                        Text("Cámara")
                                    }
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                                }
                                
                                Button(action: {
                                    imagePickerSource = .photoLibrary
                                    showImagePicker = true
                                }) {
                                    HStack {
                                        Image(systemName: "photo.on.rectangle")
                                        Text("Galería")
                                    }
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Formulario del producto
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
                            
                            // Etiquetas
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Etiquetas")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showEtiquetaSheet = true
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(primaryColor)
                                    }
                                }
                                
                                // Mostrar etiquetas actuales
                                if !etiquetas.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(etiquetas, id: \.self) { etiqueta in
                                                HStack {
                                                    Text(etiqueta)
                                                        .font(.caption)
                                                        .padding(.leading, 8)
                                                    
                                                    Button(action: {
                                                        if let index = etiquetas.firstIndex(of: etiqueta) {
                                                            etiquetas.remove(at: index)
                                                        }
                                                    }) {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .font(.caption)
                                                            .foregroundColor(.gray)
                                                    }
                                                    .padding(.trailing, 8)
                                                }
                                                .padding(.vertical, 4)
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(15)
                                            }
                                        }
                                    }
                                } else {
                                    Text("Sin etiquetas")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.vertical, 8)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            
                            // Tiempo disponible
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
                            Text(isEditMode ? "Actualizar Paquete" : "Guardar Paquete")
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
                                Text(isEditMode ? "Actualizando producto..." : "Guardando producto...")
                                    .foregroundColor(.white)
                                    .padding(.top, 10)
                            }
                        )
                }
            }
            .navigationTitle(isEditMode ? "Editar Paquete" : "Nuevo Paquete")
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
            .sheet(isPresented: $showImagePicker) {
                ProductoImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showCameraSheet) {
                ProductoImagePicker(selectedImage: $selectedImage, sourceType: .camera)
            }
            .sheet(isPresented: $showEtiquetaSheet) {
                addEtiquetaView
            }
        }
    }
    
    // Vista para añadir etiquetas
    private var addEtiquetaView: some View {
        NavigationView {
            VStack {
                TextField("Nueva etiqueta", text: $nuevaEtiqueta)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding()
                
                Button(action: {
                    if !nuevaEtiqueta.isEmpty && !etiquetas.contains(nuevaEtiqueta) {
                        etiquetas.append(nuevaEtiqueta)
                        nuevaEtiqueta = ""
                    }
                }) {
                    Text("Agregar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(primaryColor)
                        .cornerRadius(10)
                }
                .disabled(nuevaEtiqueta.isEmpty)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Añadir Etiqueta")
            .navigationBarItems(trailing: Button("Cerrar") {
                showEtiquetaSheet = false
            })
        }
    }
    
    // Placeholder para imagen
    private var placeholderImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(width: 200, height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            VStack {
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                Text("Imagen del producto")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    // Función para guardar o actualizar el producto
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
        
        // Si hay una nueva imagen seleccionada, primero la subimos a Storage
        if let imageToUpload = selectedImage {
            uploadImage(image: imageToUpload) { result in
                switch result {
                case .success(let newImageURL):
                    // Una vez obtenida la URL de la imagen, guardamos el producto
                    self.saveProductToFirestore(imageURL: newImageURL)
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.alertMessage = "Error al subir imagen: \(error.localizedDescription)"
                        self.showAlert = true
                    }
                }
            }
        } else {
            // Si no hay nueva imagen, usamos la URL existente o una cadena vacía
            saveProductToFirestore(imageURL: imageURL)
        }
    }
    
    // Función para subir la imagen a Firebase Storage
    func uploadImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        // Comprimir la imagen para reducir el tamaño
        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error al comprimir la imagen"])))
            return
        }
        
        let storageRef = Storage.storage().reference()
        
        // Si estamos en modo edición y ya existe una imagen, podemos reutilizar la referencia
        let imageFileName: String
        if isEditMode && !imageURL.isEmpty && imageURL.contains("productos/") {
            // Extraer el nombre del archivo de la URL existente
            if let filename = imageURL.components(separatedBy: "productos/").last?.components(separatedBy: "?").first {
                imageFileName = filename
            } else {
                imageFileName = "\(UUID().uuidString).jpg"
            }
        } else {
            imageFileName = "\(UUID().uuidString).jpg"
        }
        
        let imageRef = storageRef.child("productos/\(imageFileName)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error al obtener URL de descarga"])))
                    return
                }
                
                completion(.success(downloadURL.absoluteString))
            }
        }
    }
    
    // Función para guardar o actualizar en Firestore
    func saveProductToFirestore(imageURL: String) {
        let db = Firestore.firestore()
        
        // Fechas
        let fechaDisponible = Date()
        let venceEn = fechaDisponible.addingTimeInterval(Double(horasDisponible) * 3600)
        
        // Datos básicos del producto
        var productoData: [String: Any] = [
            "nombre": nombre,
            "descripcion": descripcion,
            "precio": Double(precio) ?? 0.0,
            "precioOriginal": Double(precioOriginal) ?? Double(precio) ?? 0.0,
            "cantidadDisponible": Int(cantidad) ?? 1,
            "imagenURL": imageURL,
            "etiquetas": etiquetas,
            "fechaDisponible": Timestamp(date: fechaDisponible),
            "venceEn": Timestamp(date: venceEn),
            "comercioID": comercioID
        ]
        
        if !isEditMode {
            // Solo añadimos creadoEn para nuevos productos
            productoData["creadoEn"] = Timestamp(date: Date())
        }
        
        let productsCollection = db.collection("comercios").document(comercioID).collection("packs")
        
        if isEditMode, let productoID = productoID {
            // Actualizar producto existente
            productsCollection.document(productoID).updateData(productoData) { error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.alertMessage = "Error al actualizar: \(error.localizedDescription)"
                        self.showAlert = true
                    } else {
                        self.alertMessage = "¡Producto actualizado con éxito!"
                        self.showAlert = true
                    }
                }
            }
        } else {
            // Crear nuevo producto
            productsCollection.addDocument(data: productoData) { error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.alertMessage = "Error al guardar: \(error.localizedDescription)"
                        self.showAlert = true
                    } else {
                        self.alertMessage = "¡Producto guardado con éxito!"
                        self.showAlert = true
                    }
                }
            }
        }
    }
}

// Componente ImagePicker para seleccionar imágenes
struct ProductoImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ProductoImagePicker
        
        init(_ parent: ProductoImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
