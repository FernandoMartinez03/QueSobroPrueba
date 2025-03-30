import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import PhotosUI

struct ComercioHeaderView: View {
    var comercioData: ComercioData?
    
    @State private var showImageOptions = false
    @State private var showImagePicker = false
    @State private var showCameraSheet = false
    @State private var selectedImage: UIImage?
    @State private var isUploading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToPedidos = false
    
    // Colores de la app
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08) // Rojo del logo
    
    var body: some View {
        VStack(spacing: 0) {
            // Información del comercio
            VStack(spacing: 12) {
                // Avatar y datos principales
                HStack(alignment: .top, spacing: 15) {
                    // Imagen del comercio (clickable)
                    Button(action: {
                        showImageOptions = true
                    }) {
                        if let imageURL = comercioData?.imageURL, !imageURL.isEmpty {
                            // Mostrar imagen desde URL
                            AsyncImage(url: URL(string: imageURL)) { phase in
                                switch phase {
                                case .empty:
                                    CircularProfilePlaceholder(letter: String(comercioData?.nombre.prefix(1) ?? "P"))
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                case .failure:
                                    CircularProfilePlaceholder(letter: String(comercioData?.nombre.prefix(1) ?? "P"))
                                @unknown default:
                                    CircularProfilePlaceholder(letter: String(comercioData?.nombre.prefix(1) ?? "P"))
                                }
                            }
                        } else {
                            // Mostrar placeholder
                            CircularProfilePlaceholder(letter: String(comercioData?.nombre.prefix(1) ?? "P"))
                        }
                    }
                    .disabled(isUploading)
                    
                    // Información del comercio
                    VStack(alignment: .leading, spacing: 2) {
                        Text(comercioData?.nombre ?? "")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 12))
                            Text(String(format: "%.1f", comercioData?.calificacionPromedio ?? 0.0))
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text("(\(comercioData?.reviewsCount ?? 87) reseñas)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 10))
                            Text(comercioData?.direccion ?? "")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Text(comercioData?.ciudad ?? "")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        // Etiqueta de tipo de comida
                        if let firstCategory = comercioData?.tipoComida.first {
                            Text(firstCategory)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(primaryColor.opacity(0.2))
                                .foregroundColor(primaryColor)
                                .cornerRadius(10)
                                .padding(.top, 2)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            
            // Botones de acciones rápidas
            HStack(spacing: 0) {
                Spacer()
                
                // Estadísticas
                VStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 20))
                        .foregroundColor(primaryColor)
                    Text("Estadísticas")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(width: 100)
                
                Spacer()
                
                // Pedidos - Ahora con navegación
                NavigationLink(destination:
                    ComercioPedidosView(
                        comercioID: comercioData?.id ?? "",
                        comercioName: comercioData?.nombre ?? "Comercio"
                    )
                ) {
                    VStack {
                        Image(systemName: "bag.fill")
                            .font(.system(size: 20))
                            .foregroundColor(primaryColor)
                        Text("Pedidos")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 100)
                }
                
                Spacer()
                
                // Ajustes
                VStack {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20))
                        .foregroundColor(primaryColor)
                    Text("Ajustes")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(width: 100)
                
                Spacer()
            }
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .actionSheet(isPresented: $showImageOptions) {
            ActionSheet(
                title: Text("Cambiar foto"),
                message: Text("Selecciona de dónde quieres obtener la foto"),
                buttons: [
                    .default(Text("Tomar foto")) {
                        showCameraSheet = true
                    },
                    .default(Text("Seleccionar de la galería")) {
                        showImagePicker = true
                    },
                    .cancel(Text("Cancelar"))
                ]
            )
        }
        .sheet(isPresented: $showImagePicker) {
            ComercioImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
                .onDisappear {
                    if let image = selectedImage {
                        uploadComercioImage(image: image)
                    }
                }
        }
        .sheet(isPresented: $showCameraSheet) {
            ComercioImagePicker(selectedImage: $selectedImage, sourceType: .camera)
                .onDisappear {
                    if let image = selectedImage {
                        uploadComercioImage(image: image)
                    }
                }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Aviso"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .overlay(
            Group {
                if isUploading {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .overlay(
                            VStack {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Subiendo imagen...")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.top, 10)
                            }
                        )
                }
            }
        )
    }
    
    // Función para subir la imagen a Firebase Storage
    private func uploadComercioImage(image: UIImage) {
        guard let comercioID = comercioData?.id else {
            alertMessage = "No se pudo identificar el comercio"
            showAlert = true
            return
        }
        
        isUploading = true
        
        // Comprimir la imagen para reducir tamaño
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            isUploading = false
            alertMessage = "Error al procesar la imagen"
            showAlert = true
            return
        }
        
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("comercios/\(comercioID)/profile.jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Subir la imagen a Storage
        imageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                isUploading = false
                alertMessage = "Error al subir la imagen: \(error.localizedDescription)"
                showAlert = true
                return
            }
            
            // Obtener la URL de la imagen
            imageRef.downloadURL { url, error in
                isUploading = false
                
                if let error = error {
                    alertMessage = "Error al obtener la URL de la imagen: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                
                guard let downloadURL = url else {
                    alertMessage = "No se pudo obtener la URL de la imagen"
                    showAlert = true
                    return
                }
                
                // Actualizar la URL de la imagen en Firestore
                updateComercioImage(imageURL: downloadURL.absoluteString, comercioID: comercioID)
            }
        }
    }
    
    // Función para actualizar la URL de la imagen en Firestore
    private func updateComercioImage(imageURL: String, comercioID: String) {
        let db = Firestore.firestore()
        
        db.collection("comercios").document(comercioID).updateData([
            "imageURL": imageURL
        ]) { error in
            if let error = error {
                alertMessage = "Error al actualizar la información: \(error.localizedDescription)"
                showAlert = true
            } else {
                alertMessage = "Imagen actualizada con éxito"
                showAlert = true
            }
        }
    }
}

// Componente para mostrar un placeholder circular con la primera letra
struct CircularProfilePlaceholder: View {
    let letter: String
    
    // Color principal
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08)
    
    var body: some View {
        ZStack {
            Circle()
                .fill(primaryColor)
                .frame(width: 80, height: 80)
            
            Text(letter)
                .font(.system(size: 36))
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

// Componente ImagePicker para seleccionar imágenes
struct ComercioImagePicker: UIViewControllerRepresentable {
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
        let parent: ComercioImagePicker
        
        init(_ parent: ComercioImagePicker) {
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
