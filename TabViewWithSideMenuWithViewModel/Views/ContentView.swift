//
//  ContentView.swift
//  TabViewWithSlideMenu
//
//  Created by rfsouto on 16/2/24.
//

import SwiftUI

struct ContentView: View {

    @State private var viewModel = ContentViewModel()
    
    
    var body: some View {
        ZStack {
            TabView(selection: Binding(
                get: { viewModel.option },
                set: { selectedOption in viewModel.option = selectedOption }
            )) {
            // Variante B (sustituye la línea de arriba, Binding manual = variante A):
            // TabView(selection: $viewModel.option) {
                Color(red: 216/255, green: 67/255, blue: 82/255) // Rojo
                    .tabItem {
                        Image(systemName: "circle.fill")
                        Text("First")
                    }
                    .tag(BarOptions.firstTab)
                Color(red: 251/255, green: 176/255, blue: 59/255) // Amarillo
                    .tabItem {
                        Image(systemName: "circle.fill")
                        Text("Second")
                    }
                    .tag(BarOptions.secondTab)
                Color(red: 63/255, green: 143/255, blue: 204/255) // Azul
                    .tabItem {
                        Image(systemName: "circle.fill")
                        Text("Third")
                    }
                    .tag(BarOptions.thirdTab)
                Color(red: 40/255, green: 167/255, blue: 71/255) // Verde
                    .tabItem {
                        Image(systemName: "circle.fill")
                        Text("Menu")
                    }
                    .tag(BarOptions.menuButton)
            }
            SlideMenuView(
                width: 300,
                isOpen: viewModel.isMenuOpen,
                onMenuClose: { viewModel.isMenuOpen.toggle() })
        }
    }
}

#Preview {
    ContentView()
}
