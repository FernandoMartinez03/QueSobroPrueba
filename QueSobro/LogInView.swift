//
//  LogInView.swift
//  QueSobro
//
//  Created by Alumno on 28/03/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    @State private var showAlert = false
    @State private var errorMessage = ""
    @State private var isAuthenticated = false
    @State private var navigateToStore = false
    @State private var navigateToMain = false
    @State private var userType = ""
    
    
    // Para la navegación
    @State private var navigateToHome = false
    
    // Colores de la app
    let primaryColor = Color(red: 0.85, green: 0.16, blue: 0.08) // Rojo del logo
    let backgroundColor = Color(white: 0.97)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Logo
                    Image("queSobroLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 160, height: 160)
                    
                    // Texto de bienvenida
                    Text("¡Bienvenido a Qué Sobró!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(primaryColor)
                    
                    Text("Combate el desperdicio alimentario")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                    
                    // Campos de entrada
                    VStack(spacing: 20) {
                        // Campo de email
                        TextField("Correo electrónico", text: $email)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        // Campo de contraseña
                        SecureField("Contraseña", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal, 20)
                    
                    // Botón de inicio de sesión
                    Button(action: {
                        login()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(primaryColor)
                                .frame(height: 55)
                            
                            if isLoggingIn {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Iniciar Sesión")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .disabled(isLoggingIn)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Botón de registro con NavigationLink
                    NavigationLink(destination: RegistrationView()) {
                        Text("¿No tienes cuenta? Regístrate aquí")
                            .foregroundColor(primaryColor)
                            .font(.subheadline)
                    }
                    .padding(.top, 5)
                    
                    Spacer()
                    
                    // Pie de página con mensaje eco-amigable
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
                
                // Navegación programática
                NavigationLink(
                    destination: ComercioHomeView(isAuthenticated: $isAuthenticated),
                    isActive: $navigateToStore,
                    label: { EmptyView() }
                )

                NavigationLink(
                    destination: NavBarView(),
                    isActive: $navigateToMain,
                    label: { EmptyView() }
                )
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    func login() {
        // Validación básica
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor completa todos los campos"
            showAlert = true
            return
        }
        
        isLoggingIn = true
        
        // Autenticación con Firebase
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoggingIn = false
            
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
                return
            }
            
            // Autenticación exitosa - Cargar datos del usuario desde Firestore
            if let userID = result?.user.uid {
                let db = Firestore.firestore()
                db.collection("users").document("usr_\(userID)").getDocument { document, error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                        showAlert = true
                        return
                    }
                    
                    // Verificar el tipo de usuario
                    if let document = document, document.exists {
                        if let userData = document.data(),
                           let tipo = userData["tipo"] as? String {
                            
                            // Navegar a la vista correspondiente según el tipo
                            if tipo == "comercio" {
                                self.navigateToStore = true
                            } else {
                                // Por defecto, asumimos que es cliente
                                self.navigateToMain = true
                            }
                        } else {
                            // Si no se puede determinar el tipo, ir a la vista principal
                            self.navigateToMain = true
                        }
                    } else {
                        // Si no existe el documento, ir a la vista principal
                        self.navigateToMain = true
                    }
                }
            }
        }
    }
}

// Vista de marcador de posición para la pantalla principal
struct HomeView: View {
    var body: some View {
        MainAppView()
    }
}

// Previsualización
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
