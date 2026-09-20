//
//  TabViewWithSideMenuWithViewModelApp.swift
//  TabViewWithSideMenuWithViewModel
//
//  Created by rfsouto on 6/3/24.
//

import SwiftUI

@main
struct TabViewWithSideMenuWithViewModelApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// Experimento: el contador fuerza que RootView reevalúe su body y vuelva a construir ContentView().
/// `inits` muestra cuántas veces se ha construido ContentViewModel (se refresca 4 veces por segundo).
struct RootView: View {
    @State private var counter = 0

    var body: some View {
        let content = ContentView()
        VStack(spacing: 0) {
            HStack {
                Button("Incrementar (\(counter))") { counter += 1 }
                    .accessibilityIdentifier("incrementButton")
                TimelineView(.periodic(from: .now, by: 0.25)) { _ in
                    Text("inits: \(ContentViewModel.initCount)")
                        .accessibilityIdentifier("initCount")
                }
            }
            .padding()
            content
        }
    }
}
