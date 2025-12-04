//
//  FuturaeSampleAppUITestsLaunchTests.swift
//  FuturaeSampleAppUITests
//
//  Created by Dimitrios Tsigouris on 11/25/25.
//
import XCTest

final class FuturaeSampleAppUITestsLaunchTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchSDKAndNavigation() throws {
        let app = XCUIApplication()
        
        // Interruption monitor
        addUIInterruptionMonitor(withDescription: "System Alerts") { alert in
            if alert.buttons["Allow"].exists {
                alert.buttons["Allow"].tap()
                return true
            }
            if alert.buttons["Allow While Using App"].exists {
                alert.buttons["Allow While Using App"].tap()
                return true
            }
            return false
        }
        
        print("🟩 Launching app…")
        app.launch()

        print("🟩 Tapping to dismiss dialogs…")
        app.tap()

        print("🟩 Typing SDK ID…")
        let sdkIdField = app.textFields["text_field_sdk_id"]
        if (sdkIdField.value as? String)?.isEmpty ?? true {
            sdkIdField.tap()
            sdkIdField.typeText(UUID().uuidString)
            app.keyboards.buttons["Return"].tap()
        }

        print("🟩 Typing SDK Key…")
        let sdkKeyField = app.textFields["text_field_sdk_key"]
        if (sdkKeyField.value as? String)?.isEmpty ?? true {
            sdkKeyField.tap()
            sdkKeyField.typeText("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
            app.keyboards.buttons["Return"].tap()
        }

        print("🟩 Typing Base URL…")
        let sdkBaseUrlField = app.textFields["text_field_base_url"]
        let currentBaseUrl = (sdkBaseUrlField.value as? String) ?? ""

        if currentBaseUrl == "http://" || currentBaseUrl.isEmpty {
            sdkBaseUrlField.tap()
            sdkBaseUrlField.typeText("api.futurae.com")
            app.keyboards.buttons["Return"].tap()
        }


        print("🟩 Scrolling…")
        app.swipeUp()
        app.swipeUp()
        app.swipeUp()

        print("🟩 Waiting for Submit button…")
        let launchButton = app.buttons["Submit"]
        let exists = NSPredicate(format: "exists == true && isHittable == true")
        expectation(for: exists, evaluatedWith: launchButton)
        waitForExpectations(timeout: 5)

        print("🟩 Submit button found, tapping…")
        launchButton.tap()

        print("🟩 Going to More tab…")
        let moreButton = app.tabBars.buttons.matching(identifier: "More").firstMatch
        XCTAssertTrue(moreButton.exists)
        moreButton.tap()

        print("🟩 Opening Settings…")
        let settingsCell = app.staticTexts["Settings"]
        XCTAssertTrue(settingsCell.exists)
        settingsCell.tap()

        print("🟩 Opening Debug Utilities…")
        let sdkFunctions = app.staticTexts["Debug Utilities"]
        XCTAssertTrue(sdkFunctions.exists)
        sdkFunctions.tap()

        print("🟩 Checking jailbreak…")
        let jbStatus = app.buttons["Check Jailbreak Status"]
        XCTAssertTrue(jbStatus.exists)
        jbStatus.tap()

        print("🟩 Test completed successfully.")

    }

}
