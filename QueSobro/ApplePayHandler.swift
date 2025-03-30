//
//  ApplePayHandler.swift
//  QueSobro
//
//  Created by Alumno on 29/03/25.
//

import Foundation
import SwiftUI
import PassKit

// Clase para manejar las operaciones de Apple Pay
class ApplePayHandler: NSObject, PKPaymentAuthorizationControllerDelegate {
    // Callbacks para diferentes eventos
    var onPaymentSuccess: ((PKPayment) -> Void)?
    var onPaymentError: ((Error) -> Void)?
    var onPaymentCancellation: (() -> Void)?
    
    // Verificar si Apple Pay está disponible en el dispositivo
    static func applePayAvailable() -> Bool {
        return PKPaymentAuthorizationController.canMakePayments()
    }
    
    // Constructor con callbacks opcionales
    init(
        onPaymentSuccess: ((PKPayment) -> Void)? = nil,
        onPaymentError: ((Error) -> Void)? = nil,
        onPaymentCancellation: (() -> Void)? = nil
    ) {
        self.onPaymentSuccess = onPaymentSuccess
        self.onPaymentError = onPaymentError
        self.onPaymentCancellation = onPaymentCancellation
    }
    
    // Crear una solicitud de pago con Apple Pay
    func createPaymentRequest(
        productName: String,
        quantity: Int,
        price: Double
    ) -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.tuempresa.quesobro" // Reemplazar con tu identificador real
        request.supportedNetworks = [.masterCard, .visa, .amex]
        request.merchantCapabilities = .capability3DS
        request.countryCode = "MX" // Código de país (México)
        request.currencyCode = "MXN" // Código de moneda (Peso mexicano)
        
        // Calcular el total
        let total = price * Double(quantity)
        
        // Añadir el detalle del producto
        let productItem = PKPaymentSummaryItem(
            label: "\(quantity) x \(productName)",
            amount: NSDecimalNumber(value: total)
        )
        
        // Total final
        let totalItem = PKPaymentSummaryItem(
            label: "QueSobro",
            amount: NSDecimalNumber(value: total)
        )
        
        request.paymentSummaryItems = [productItem, totalItem]
        
        return request
    }
    
    // Procesar el pago con Apple Pay
    func processPayment(
        productName: String,
        quantity: Int,
        price: Double
    ) {
        let request = createPaymentRequest(
            productName: productName,
            quantity: quantity,
            price: price
        )
        
        let controller = PKPaymentAuthorizationController(paymentRequest: request)
        controller.delegate = self
        
        controller.present(completion: { (presented: Bool) in
            if !presented {
                let error = NSError(
                    domain: "ApplePayError",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "No se pudo presentar Apple Pay"]
                )
                self.onPaymentError?(error)
            }
        })
    }
    
    // MARK: - PKPaymentAuthorizationControllerDelegate
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Aquí es donde normalmente procesarías el pago con tu servidor
        // Por ahora, simulamos un pago exitoso
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.onPaymentSuccess?(payment)
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        }
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            // El controlador se ha cerrado
        }
    }
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectShippingMethod shippingMethod: PKShippingMethod, handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        completion(PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: []))
    }
    
    func paymentAuthorizationControllerWillAuthorizePayment(_ controller: PKPaymentAuthorizationController) {
        // Preparación antes de la autorización
    }
}
