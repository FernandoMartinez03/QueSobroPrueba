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
   
            SearchView() //Aqui se cambiará hacia la otra pantalla supongo
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Buscar")
                }
            
            MapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Mapa")
                }
            
            // Historial de pedidos
            OrderHistoryView()
                .tabItem {
                    Image(systemName: "bag.fill")
                    Text("Pedidos")
                }
                .tag(1)
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
