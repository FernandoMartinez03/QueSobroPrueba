//
//  RegistrationView.swift
//  QueSobro
//
//  Created by Fernando Martínez on 29/03/25.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegistrationView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var currentStep = 1
    
    // Tipo de usuario
    @State private var tipoUsuario: UserType = .cliente
    
    // Para el proceso de registro
    @State private var isRegistering = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var registroExitoso = false
    
    // Para la navegación
    @Environment(\.presentationMode) var presentationMode
    
    // Colores de la app - usando los mismos de LoginView
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08) // Rojo del logo
    let backgroundColor = Color(white: 0.97)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack {
                    if currentStep == 1 {
                        Step1View(tipoUsuario: $tipoUsuario, currentStep: $currentStep)
                            .transition(.opacity)
                    } else {
                        if tipoUsuario == .cliente {
                            ClienteRegistrationView(
                                nombre: $name,
                                correo: $email,
                                password: $password,
                                confirmPassword: $confirmPassword,
                                tipoUsuario: tipoUsuario,
                                isRegistering: $isRegistering,
                                showAlert: $showAlert,
                                alertMessage: $alertMessage,
                                registroExitoso: $registroExitoso,
                                presentationMode: presentationMode
                            )
                            .transition(.opacity)
                        } else {
                            ComercioRegistrationView(
                                nombre: $name,
                                correo: $email,
                                password: $password,
                                confirmPassword: $confirmPassword,
                                tipoUsuario: tipoUsuario,
                                isRegistering: $isRegistering,
                                showAlert: $showAlert,
                                alertMessage: $alertMessage,
                                registroExitoso: $registroExitoso,
                                presentationMode: presentationMode
                            )
                            .transition(.opacity)
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(currentStep > 1)
            .navigationBarItems(leading: currentStep > 1 ? Button(action: {
                withAnimation {
                    currentStep = 1
                }
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(primaryColor)
                    Text("Volver")
                        .foregroundColor(primaryColor)
                }
            } : nil)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(registroExitoso ? "Éxito" : "Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if registroExitoso {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
            
            // Overlay de carga
            if isRegistering {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            Text("Creando cuenta...")
                                .foregroundColor(.white)
                                .padding(.top, 10)
                        }
                    )
                    .zIndex(1)
            }
        }
    }
}

// STEP 1: User Information
struct Step1View: View {
    @Binding var tipoUsuario: UserType
    @Binding var currentStep: Int
    
    // Colores de la app
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08) // Rojo del logo
    let backgroundColor = Color(white: 0.97)
    
    var body: some View {
        VStack(spacing: 30) {
            // Logo
            Image("logoHD")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .padding(.vertical, 10)
                
            Text("¿Cómo quieres usar Qué Sobró?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(primaryColor)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
            
            VStack(spacing: 20) {
                // Cliente
                Button(action: {
                    tipoUsuario = .cliente
                    withAnimation {
                        currentStep = 2
                    }
                }) {
                    VStack(spacing: 10) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                        Text("Cliente")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .frame(width: 150, height: 150)
                    .foregroundColor(.white)
                    .background(primaryColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: primaryColor.opacity(0.4), radius: 5, x: 0, y: 5)
                }
                
                // Comercio
                Button(action: {
                    tipoUsuario = .comercio
                    withAnimation {
                        currentStep = 2
                    }
                }) {
                    VStack(spacing: 10) {
                        Image(systemName: "bag.fill")
                            .font(.system(size: 40))
                        Text("Comercio")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .frame(width: 150, height: 150)
                    .foregroundColor(.white)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.green.opacity(0.4), radius: 5, x: 0, y: 5)
                }
            }
            
            Spacer()
            
            // Mensaje eco-amigable
            VStack {
                Text("Comprometidos con el ODS 12")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("Producción y consumo responsables")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 20)
        }
        .padding()
    }
}

struct ClienteRegistrationView: View {
    @Binding var nombre: String
    @Binding var correo: String
    @Binding var password: String
    @Binding var confirmPassword: String
    let tipoUsuario: UserType
    
    @Binding var isRegistering: Bool
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    @Binding var registroExitoso: Bool
    
    let presentationMode: Binding<PresentationMode>
    
    @State private var ciudadSeleccionada = "Monterrey"
    
    let ciudades = ["Monterrey", "Guadalajara", "Chihuahua", "Ciudad de México"]
    
    // Colores de la app
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08) // Rojo del logo
    let backgroundColor = Color(white: 0.97)

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Logo
                Image("queSobroLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .padding(.vertical, 10)
                
                // Cliente
                Text("Cliente")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(primaryColor)
                
                // Nombre
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                    TextField("Nombre completo", text: $nombre)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Correo
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.gray)
                    TextField("Correo electrónico", text: $correo)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                .padding(.horizontal)
                
                // Contraseña
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                    SecureField("Contraseña", text: $password)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Confirmar contraseña
                HStack {
                    Image(systemName: "lock.shield")
                        .foregroundColor(.gray)
                    SecureField("Confirmar contraseña", text: $confirmPassword)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Ciudad
                VStack(alignment: .leading, spacing: 5) {
                    Text("Ubicación")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.orange)
                        Text(ciudadSeleccionada)
                            .font(.body)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Picker("Ciudad", selection: $ciudadSeleccionada) {
                            ForEach(ciudades, id: \.self) { ciudad in
                                Text(ciudad).tag(ciudad)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal)
                
                // Botón de registro
                Button(action: {
                    registerUser(ciudad: ciudadSeleccionada)
                }) {
                    Text("Crear cuenta")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(primaryColor)
                        .cornerRadius(12)
                        .shadow(color: primaryColor.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .disabled(isRegistering)
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
    
    func registerUser(ciudad: String) {
        // Validación básica
        guard !nombre.isEmpty, !correo.isEmpty, !password.isEmpty else {
            alertMessage = "Por favor completa todos los campos"
            showAlert = true
            return
        }
        
        guard password == confirmPassword else {
            alertMessage = "Las contraseñas no coinciden"
            showAlert = true
            return
        }
        
        guard password.count >= 6 else {
            alertMessage = "La contraseña debe tener al menos 6 caracteres"
            showAlert = true
            return
        }
        
        isRegistering = true
        
        // Crear usuario en Firebase Auth
        Auth.auth().createUser(withEmail: correo, password: password) { result, error in
            if let error = error {
                isRegistering = false
                alertMessage = error.localizedDescription
                showAlert = true
                return
            }
            
            // Registro exitoso - Guardar información adicional en Firestore
            if let userID = result?.user.uid {
                let db = Firestore.firestore()
                
                // Crear el objeto usuario
                let user = User(
                    id: nil,
                    nombre: nombre,
                    correo: correo,
                    tipo: tipoUsuario,
                    ciudad: ciudad,
                    createdAt: Date(),
                    favoritos: [],
                    historial: [],
                    pedidosActivos: []
                )
                
                // Convertir a diccionario para Firestore
                let userData = user.toFirestore()
                
                // Guardar en Firestore
                db.collection("users").document("usr_\(userID)").setData(userData) { error in
                    isRegistering = false
                    
                    if let error = error {
                        // Error al guardar en Firestore
                        alertMessage = "Error al guardar datos: \(error.localizedDescription)"
                        showAlert = true
                        
                        // Eliminar la cuenta de Auth si falla Firestore
                        try? Auth.auth().currentUser?.delete()
                    } else {
                        // Registro completado exitosamente
                        registroExitoso = true
                        alertMessage = "¡Cuenta creada con éxito! Ya puedes iniciar sesión."
                        showAlert = true
                    }
                }
            }
        }
    }
}

struct ComercioRegistrationView: View {
    @Binding var nombre: String
    @Binding var correo: String
    @Binding var password: String
    @Binding var confirmPassword: String
    let tipoUsuario: UserType
    
    @Binding var isRegistering: Bool
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    @Binding var registroExitoso: Bool
    
    let presentationMode: Binding<PresentationMode>
    
    @State private var direccion: String = ""
    @State private var ciudadSeleccionada = "Monterrey"
    @State private var tipoComidaSeleccionada = "Pastelería"
    
    let ciudades = ["Monterrey", "Guadalajara", "Chihuahua", "Ciudad de México"]
    let tiposComida = ["Pastelería", "Cafetería", "Restaurante", "Comida Rápida"]
    
    // Colores de la app
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08) // Rojo del logo
    let backgroundColor = Color(white: 0.97)

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Logo
                Image("queSobroLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .padding(.vertical, 10)
                
                // Comercio
                Text("Comercio")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(primaryColor)
                
                // Nombre del comercio
                HStack {
                    Image(systemName: "building.2")
                        .foregroundColor(.gray)
                    TextField("Nombre del comercio", text: $nombre)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Correo
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.gray)
                    TextField("Correo electrónico", text: $correo)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                .padding(.horizontal)
                
                // Dirección
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.gray)
                    TextField("Dirección", text: $direccion)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Contraseña
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                    SecureField("Contraseña", text: $password)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Confirmar contraseña
                HStack {
                    Image(systemName: "lock.shield")
                        .foregroundColor(.gray)
                    SecureField("Confirmar contraseña", text: $confirmPassword)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 15) {
                    // Tipo de comida
                    Text("Tipo de comida")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "fork.knife")
                            .foregroundColor(.orange)
                        Text(tipoComidaSeleccionada)
                            .font(.body)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Picker("Tipo de comida", selection: $tipoComidaSeleccionada) {
                            ForEach(tiposComida, id: \.self) { tipoComida in
                                Text(tipoComida).tag(tipoComida)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 3)
                    
                    // Ubicación
                    Text("Ubicación")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.orange)
                        Text(ciudadSeleccionada)
                            .font(.body)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Picker("Ciudad", selection: $ciudadSeleccionada) {
                            ForEach(ciudades, id: \.self) { ciudad in
                                Text(ciudad).tag(ciudad)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal)
                
                // Botón de registro
                Button(action: {
                    registerComercio(ciudad: ciudadSeleccionada, tipoComida: tipoComidaSeleccionada)
                }) {
                    Text("Crear cuenta")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(primaryColor)
                        .cornerRadius(12)
                        .shadow(color: primaryColor.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .disabled(isRegistering)
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func registerComercio(ciudad: String, tipoComida: String) {
        // Validación básica
        guard !nombre.isEmpty, !correo.isEmpty, !password.isEmpty, !direccion.isEmpty else {
            alertMessage = "Por favor completa todos los campos"
            showAlert = true
            return
        }
        
        guard password == confirmPassword else {
            alertMessage = "Las contraseñas no coinciden"
            showAlert = true
            return
        }
        
        guard password.count >= 6 else {
            alertMessage = "La contraseña debe tener al menos 6 caracteres"
            showAlert = true
            return
        }
        
        isRegistering = true
        
        // Crear usuario en Firebase Auth
        Auth.auth().createUser(withEmail: correo, password: password) { result, error in
            if let error = error {
                isRegistering = false
                alertMessage = error.localizedDescription
                showAlert = true
                return
            }
            
            // Registro exitoso - Guardar información adicional en Firestore
            if let userID = result?.user.uid {
                let db = Firestore.firestore()
                
                // Crear el objeto usuario
                let user = User(
                    id: nil,
                    nombre: nombre,
                    correo: correo,
                    tipo: tipoUsuario,
                    ciudad: ciudad,
                    createdAt: Date(),
                    favoritos: [],
                    historial: [],
                    pedidosActivos: []
                )
                
                // Preparar datos de usuario
                let userData = user.toFirestore()
                
                // Crear documento de usuario
                db.collection("users").document("usr_\(userID)").setData(userData) { error in
                    if let error = error {
                        isRegistering = false
                        alertMessage = "Error al guardar datos de usuario: \(error.localizedDescription)"
                        showAlert = true
                        
                        // Eliminar la cuenta de Auth si falla Firestore
                        try? Auth.auth().currentUser?.delete()
                        return
                    }
                    
                    // Crear documento de comercio
                    let comercioData: [String: Any] = [
                        "nombre": nombre,
                        "direccion": direccion,
                        "ciudad": ciudad,
                        "tipoComida": [tipoComida],
                        "productosDisponibles": [],
                        "calificacionPromedio": 0.0,
                        "creadoEn": Timestamp(date: Date()),
                        "horario": [
                            "lunes": "08:00-20:00",
                            "martes": "08:00-20:00",
                            "miercoles": "08:00-20:00",
                            "jueves": "08:00-20:00",
                            "viernes": "08:00-20:00",
                            "sabado": "08:00-16:00",
                            "domingo": "Cerrado"
                        ]
                    ]
                    
                    // Generar ID para el comercio
                    let nuevoComercioRef = db.collection("comercios").document()
                    let comercioID = nuevoComercioRef.documentID
                    
                    // Guardar información del comercio
                    nuevoComercioRef.setData(comercioData) { error in
                        isRegistering = false
                        
                        if let error = error {
                            alertMessage = "Error al guardar datos del comercio: \(error.localizedDescription)"
                            showAlert = true
                            
                            // No eliminamos la cuenta porque al menos el usuario se guardó
                        } else {
                            // Actualizar referencia al comercio en el usuario
                            db.collection("users").document("usr_\(userID)").updateData([
                                "comercioID": comercioID
                            ])
                            
                            // Registro completado exitosamente
                            registroExitoso = true
                            alertMessage = "¡Cuenta creada con éxito! Ya puedes iniciar sesión."
                            showAlert = true
                        }
                    }
                }
            }
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
