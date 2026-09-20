import XCTest

/// Pulsa "Menu" y comprueba que la pestaña seleccionada sigue siendo la anterior,
/// que el contenido visible es el de esa pestaña y que el menú lateral se abre. Sirve para las variantes A (Binding manual) y B ($viewModel.option).
final class MenuTabUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func testMenuKeepsPreviousTabAndOpensSideMenu() {
        let app = XCUIApplication()
        app.launch()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), "No aparece la barra de pestañas")
        let second = tabBar.buttons["Second"]
        let menu = tabBar.buttons["Menu"]
        let firstOption = app.staticTexts["Option 1"]

        XCTAssertTrue(waitUntil { !firstOption.exists || firstOption.frame.maxX <= 0 }, "El menú debería empezar cerrado")

        let contentIds = ["content-first", "content-second", "content-third", "content-menu"]
        func selectedTabs() -> [String] {
            ["First", "Second", "Third", "Menu"].filter { tabBar.buttons[$0].isSelected }
        }
        func visibleContents() -> [String] {
            contentIds.filter { app.otherElements[$0].exists }
        }

        second.tap()
        XCTAssertTrue(waitUntil { second.isSelected }, "Second debería quedar seleccionada")
        XCTAssertTrue(waitUntil { visibleContents() == ["content-second"] },
                      "Antes de pulsar Menu debería verse solo content-second, se ve \(visibleContents())")

        menu.tap()
        XCTAssertTrue(waitUntil { firstOption.exists && firstOption.frame.minX >= 0 }, "El menú lateral debería abrirse")
        XCTAssertTrue(waitUntil { second.isSelected }, "Tras pulsar Menu debe seguir seleccionada la pestaña anterior (Second); seleccionadas: \(selectedTabs()), contenido visible: \(visibleContents())")
        XCTAssertFalse(menu.isSelected, "La pestaña Menu no debe quedar seleccionada")
        XCTAssertTrue(waitUntil { visibleContents() == ["content-second"] },
                      "Tras pulsar Menu el contenido visible debe ser el de la pestaña anterior (content-second), se ve \(visibleContents())")
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
