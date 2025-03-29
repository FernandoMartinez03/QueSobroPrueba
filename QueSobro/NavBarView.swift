//
//  NavBarView.swift
//  QueSobro
//
//  Created by Fernando Martínez on 29/03/25.
//

import Foundation
import SwiftUI


struct NavBarView: View {
    var body: some View {
        TabView {
            MainAppView()
                .tabItem {
                    Image("queSobroLogo") // 50-50px
                }
   
            MainAppView() //Aqui se cambiará hacia la otra pantalla supongo
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Buscar")
                }
            
            MainAppView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Mapa")
                }
            
            MainAppView()
                .tabItem {
                    Image(systemName: "tray.full")
                    Text("Pedidos")
                }
        }
        .navigationBarBackButtonHidden(true)
    }
}


struct Navbar_Previews: PreviewProvider {
    static var previews: some View {
        NavBarView()
    }
}

// 50 - 50 px tamaño para ref de logo!
