import XCTest

/// Mide, tras arrancar y tras 3 pulsaciones de "Incrementar", cuántas veces se construyen
/// ContentViewModel (@Observable), ObservableProbe (@Observable) y ObjectProbe (ObservableObject), todos en @State.
/// Si existe RESULT_FILE (TEST_RUNNER_RESULT_FILE en xcodebuild), añade ahí una línea.
final class StateClassesUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func testInitCountsOfStateClasses() {
        let app = XCUIApplication()
        app.launch()

        let ids = ["initCount": "inits: ", "obsCount": "obs: ", "objCount": "obj: "]
        let button = app.buttons["incrementButton"]
        XCTAssertTrue(app.staticTexts["initCount"].waitForExistence(timeout: 10), "No aparecen los contadores")

        func settled() -> [String: Int] { ids.mapValues { _ in -1 }.merging(readSettled(ids, app)) { $1 } }
        let atLaunch = settled()
        for i in 1...3 {
            button.tap()
            XCTAssertTrue(waitUntil { button.label == "Incrementar (\(i))" }, "La pulsación \(i) no se registró")
        }
        let after = settled()

        func fmt(_ k: String) -> String { "\(atLaunch[k] ?? -1)->\(after[k] ?? -1)" }
        let line = "\(UIDevice.current.systemVersion) contentVM=\(fmt("initCount")) observableProbe=\(fmt("obsCount")) objectProbe=\(fmt("objCount"))"
        print("STATECLASSES \(line)")
        if let path = ProcessInfo.processInfo.environment["RESULT_FILE"],
           let data = (line + "\n").data(using: .utf8) {
            if let handle = FileHandle(forWritingAtPath: path) {
                handle.seekToEndOfFile()
                handle.write(data)
                handle.closeFile()
            } else {
                FileManager.default.createFile(atPath: path, contents: data)
            }
        }
    }

    /// Lee los contadores y espera a que todos se mantengan estables ~1 s.
    private func readSettled(_ ids: [String: String], _ app: XCUIApplication) -> [String: Int] {
        func read() -> [String: Int] {
            var out: [String: Int] = [:]
            for (id, prefix) in ids {
                out[id] = Int(app.staticTexts[id].label.replacingOccurrences(of: prefix, with: "")) ?? -1
            }
            return out
        }
        var last = read()
        var stableSince = Date()
        let deadline = Date().addingTimeInterval(10)
        while Date() < deadline {
            let now = read()
            if now != last {
                last = now
                stableSince = Date()
            } else if Date().timeIntervalSince(stableSince) >= 1 {
                break
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        return last
    }

    private func waitUntil(timeout: TimeInterval = 5, _ condition: () -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        return condition()
    }
}
