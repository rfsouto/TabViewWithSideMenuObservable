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

/// Experimento: el contador fuerza que RootView reevalúe su body y vuelva a construir ContentView()
/// y las dos sondas. `inits` cuenta ContentViewModel; `obs` y `obj` cuentan las clases de las sondas
/// (se refrescan 4 veces por segundo).
struct RootView: View {
    @State private var counter = 0

    var body: some View {
        let content = ContentView()
        let observableProbe = ObservableProbeView()
        let objectProbe = ObjectProbeView()
        VStack(spacing: 0) {
            HStack {
                Button("Incrementar (\(counter))") { counter += 1 }
                    .accessibilityIdentifier("incrementButton")
                TimelineView(.periodic(from: .now, by: 0.25)) { _ in
                    HStack {
                        Text("inits: \(ContentViewModel.initCount)")
                            .accessibilityIdentifier("initCount")
                        Text("obs: \(ObservableProbe.initCount)")
                            .accessibilityIdentifier("obsCount")
                        Text("obj: \(ObjectProbe.initCount)")
                            .accessibilityIdentifier("objCount")
                    }
                }
            }
            .padding()
            observableProbe
            objectProbe
            content
        }
    }
}

/// Sonda: `@State` con una clase `@Observable`.
@Observable
final class ObservableProbe {
    private(set) static var initCount = 0
    init() { Self.initCount += 1 }
}

/// Sonda: `@State` con una clase `ObservableObject` (no `@Observable`).
final class ObjectProbe: ObservableObject {
    private(set) static var initCount = 0
    init() { Self.initCount += 1 }
}

struct ObservableProbeView: View {
    @State private var model = ObservableProbe()
    var body: some View { Text("sonda @Observable").font(.caption2) }
}

struct ObjectProbeView: View {
    @State private var model = ObjectProbe()
    var body: some View { Text("sonda ObservableObject").font(.caption2) }
}
