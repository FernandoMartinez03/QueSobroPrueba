//
//  QueSobroApp.swift
//  QueSobro
//
//  Created by Fernando Martínez on 28/03/25.
//

import SwiftUI
import SwiftData
import FirebaseCore // firebase para back

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}


@main
struct QueSobroApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
