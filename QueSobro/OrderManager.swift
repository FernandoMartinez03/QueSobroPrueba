//
//  OrderManager.swift
//  QueSobro
//
//  Created by Alumno on 29/03/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PassKit

// Gestor para crear y guardar pedidos
class OrderManager {
    // Callbacks para diferentes eventos
    var onOrderSuccess: (() -> Void)?
    var onOrderError: ((Error) -> Void)?
    
    // Función para guardar un pedido en Firestore
    func saveOrder(
        comercioID: String,
        productoID: String,
        cantidadProducto: Int,
        precioProducto: Double,
        paymentMethod: String = "ApplePay",
        pickupTime: String = "17:00 - 18:00"
    ) {
        guard let userID = Auth.auth().currentUser?.uid else {
            let error = NSError(
                domain: "OrderError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "No se pudo identificar al usuario"]
            )
            onOrderError?(error)
            return
        }
        
        let db = Firestore.firestore()
        
        // Datos del pedido
        let orderData: [String: Any] = [
            "comercioID": comercioID,
            "packID": productoID,
            "userID": userID,
            "cantidad": cantidadProducto,
            "totalPagado": Double(cantidadProducto) * precioProducto,
            "fechaPedido": Timestamp(date: Date()),
            "estado": "activo",
            "metodoPago": paymentMethod,
            "horaRecoger": pickupTime
        ]
        
        // Guardar el pedido
        db.collection("pedidos").addDocument(data: orderData) { error in
            if let error = error {
                self.onOrderError?(error)
                return
            }
            
            // Actualizar la cantidad disponible del producto
            self.updateProductQuantity(
                comercioID: comercioID,
                productoID: productoID,
                cantidadComprada: cantidadProducto
            )
        }
    }
    
    // Función para actualizar la cantidad disponible del producto
    private func updateProductQuantity(
        comercioID: String,
        productoID: String,
        cantidadComprada: Int
    ) {
        let db = Firestore.firestore()
        
        // Primero obtenemos el producto para conocer su cantidad actual
        let productRef = db.collection("comercios").document(comercioID).collection("packs").document(productoID)
        
        productRef.getDocument { (document, error) in
            if let error = error {
                self.onOrderError?(error)
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data(),
                  let cantidadDisponible = data["cantidadDisponible"] as? Int else {
                let error = NSError(
                    domain: "OrderError",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "No se pudo obtener la información del producto"]
                )
                self.onOrderError?(error)
                return
            }
            
            // Calcular la nueva cantidad disponible
            let nuevaCantidad = max(0, cantidadDisponible - cantidadComprada)
            
            // Actualizar el producto
            productRef.updateData([
                "cantidadDisponible": nuevaCantidad
            ]) { error in
                if let error = error {
                    self.onOrderError?(error)
                    return
                }
                
                // Todo salió bien
                self.onOrderSuccess?()
            }
        }
    }
    
    // Función para procesar un pedido con Apple Pay
    func processOrderWithApplePay(
        producto: Producto,
        cantidad: Int,
        completion: @escaping (Bool, String) -> Void
    ) {
        // Si no hay usuario autenticado, mostrar error
        guard Auth.auth().currentUser != nil else {
            completion(false, "Debes iniciar sesión para realizar un pedido")
            return
        }
        
        // Verificar que hay suficiente cantidad disponible
        guard cantidad <= producto.cantidadDisponible else {
            completion(false, "No hay suficientes productos disponibles")
            return
        }
        
        // Configurar el handler de Apple Pay
        let applePayHandler = ApplePayHandler(
            onPaymentSuccess: { payment in
                // Al tener éxito el pago, guardar el pedido
                self.saveOrder(
                    comercioID: producto.comercioID,
                    productoID: producto.id,
                    cantidadProducto: cantidad,
                    precioProducto: producto.precio
                )
                
                // Configurar callbacks
                self.onOrderSuccess = {
                    completion(true, "¡Pedido realizado con éxito!")
                }
                
                self.onOrderError = { error in
                    completion(false, "Error al procesar el pedido: \(error.localizedDescription)")
                }
            },
            onPaymentError: { error in
                completion(false, "Error en el pago: \(error.localizedDescription)")
            },
            onPaymentCancellation: {
                completion(false, "Pago cancelado")
            }
        )
        
        // Procesar el pago
        applePayHandler.processPayment(
            productName: producto.nombre,
            quantity: cantidad,
            price: producto.precio
        )
    }
}
