//
//  SimulatedPaymentHandler.swift
//  QueSobro
//
//  Created by Alumno on 29/03/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// Clase para simular pagos (reemplazo de Apple Pay para pruebas)
class SimulatedPaymentHandler {
    // Callbacks para diferentes eventos
    var onPaymentSuccess: (() -> Void)?
    var onPaymentError: ((Error) -> Void)?
    
    // Mostrar una interfaz de pago simulada
    func processPayment(
        producto: Producto,
        cantidad: Int,
        completion: @escaping (Bool, String) -> Void
    ) {
        // Verificar si hay un usuario autenticado
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false, "Debes iniciar sesión para realizar un pedido")
            return
        }
        
        // Verificar la disponibilidad del producto
        guard cantidad <= producto.cantidadDisponible else {
            completion(false, "No hay suficientes productos disponibles")
            return
        }
        
        // Crear datos del pedido
        let db = Firestore.firestore()
        let totalPagado = Double(cantidad) * producto.precio
        
        // Datos del pedido
        let orderData: [String: Any] = [
            "comercioID": producto.comercioID,
            "packID": producto.id,
            "userID": userID,
            "cantidad": cantidad,
            "totalPagado": totalPagado,
            "fechaPedido": Timestamp(date: Date()),
            "estado": "activo",
            "metodoPago": "Simulado",
            "horaRecoger": "17:00 - 18:00" // Esto podría ser configurable
        ]
        
        // Guardar el pedido en Firestore
        db.collection("pedidos").addDocument(data: orderData) { error in
            if let error = error {
                completion(false, "Error al guardar el pedido: \(error.localizedDescription)")
                return
            }
            
            // Actualizar la cantidad disponible del producto
            self.updateProductStock(
                comercioID: producto.comercioID,
                productoID: producto.id,
                cantidadComprada: cantidad
            ) { success, message in
                completion(success, message)
            }
        }
    }
    
    // Actualizar el stock del producto
    private func updateProductStock(
        comercioID: String,
        productoID: String,
        cantidadComprada: Int,
        completion: @escaping (Bool, String) -> Void
    ) {
        let db = Firestore.firestore()
        let productRef = db.collection("comercios").document(comercioID).collection("packs").document(productoID)
        
        // Obtener primero la información actual del producto
        productRef.getDocument { (document, error) in
            if let error = error {
                completion(false, "Error al obtener información del producto: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data(),
                  let cantidadDisponible = data["cantidadDisponible"] as? Int else {
                completion(false, "No se encontró información del producto")
                return
            }
            
            // Calcular la nueva cantidad y actualizar
            let nuevaCantidad = max(0, cantidadDisponible - cantidadComprada)
            
            productRef.updateData([
                "cantidadDisponible": nuevaCantidad
            ]) { error in
                if let error = error {
                    completion(false, "Error al actualizar el stock: \(error.localizedDescription)")
                } else {
                    completion(true, "¡Pedido realizado con éxito!")
                }
            }
        }
    }
}
