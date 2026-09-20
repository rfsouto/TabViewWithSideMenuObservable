import XCTest

/// Mide cuántas veces se construye ContentViewModel tras arrancar y tras 3 pulsaciones de "Incrementar".
/// Si existe la variable de entorno RESULT_FILE (TEST_RUNNER_RESULT_FILE en xcodebuild), añade ahí una línea.
final class InitCountUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func testInitCountAfterLaunchAndThreeTaps() {
        let app = XCUIApplication()
        app.launch()

        let label = app.staticTexts["initCount"]
        let button = app.buttons["incrementButton"]
        XCTAssertTrue(label.waitForExistence(timeout: 10), "No aparece el contador inits")
        let afterLaunch = settledCount(label)

        for i in 1...3 {
            button.tap()
            XCTAssertTrue(waitUntil { button.label == "Incrementar (\(i))" }, "La pulsación \(i) no se registró")
        }
        let afterThreeTaps = settledCount(label)

        let line = "\(UIDevice.current.systemVersion) launch=\(afterLaunch) after3taps=\(afterThreeTaps)"
        print("INITCOUNT \(line)")
        XCTContext.runActivity(named: "INITCOUNT \(line)") { _ in }
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

    /// Lee "inits: K" y espera a que el valor se mantenga estable durante ~1 s.
    private func settledCount(_ label: XCUIElement) -> Int {
        var last = -1
        var stableSince = Date()
        let deadline = Date().addingTimeInterval(10)
        while Date() < deadline {
            let value = Int(label.label.replacingOccurrences(of: "inits: ", with: "")) ?? -1
            if value != last {
                last = value
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
