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
        
        app.launch()
        
        
        XCTAssertEqual(app.state, .runningForeground)

        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways
        add(attachment)

        print(app.debugDescription)
        
        app.tap()
        
        app.swipeUp()
        app.swipeUp()
        app.swipeUp()
        
        let launchButton = app.buttons["Submit"]

        if launchButton.waitForExistence(timeout: 5) {
            if launchButton.isHittable {
                launchButton.tap()
            }
        }

        
        let moreButton = app.tabBars.buttons.matching(identifier: "More").firstMatch
        XCTAssertTrue(moreButton.exists)
        moreButton.tap()
        
        let settingsCell = app.staticTexts["Settings"]
        XCTAssertTrue(settingsCell.exists)
        settingsCell.tap()
        
        let sdkFunctions = app.staticTexts["Debug Utilities"]
        XCTAssertTrue(sdkFunctions.exists)
        sdkFunctions.tap()
        
        let jbStatus = app.buttons["Check Jailbreak Status"]
        XCTAssertTrue(jbStatus.exists)
        jbStatus.tap()
    }

}
