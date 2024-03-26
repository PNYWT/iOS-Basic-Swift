//
//  ProjectSoftwareTestUITests.swift
//  ProjectSoftwareTestUITests
//
//  Created by CallmeOni on 10/3/2567 BE.
//

import XCTest

enum StatusRegister:String {
    case FailAlreadyhaveAccount = "You already have account."
    case Success = "Create Account Success."
}

final class ProjectSoftwareTestUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
    }

    private func fillInRegistrationForm(username: String, password: String, confirmPassword: String, app: XCUIApplication) {
        let usernameTextField = app.textFields["usernameTextField"]
        let passwordTextField = app.secureTextFields["passwordTextField"]
        let cPasswordTextField = app.secureTextFields["cPasswordTextField"]
        
        usernameTextField.tap()
        usernameTextField.typeText(username)

        passwordTextField.tap()
        passwordTextField.typeText(password)
        
        cPasswordTextField.tap()
        cPasswordTextField.typeText(confirmPassword)
        
        dismissKeyboardIfPresent(app: app)
        app.buttons["confirmButton"].tap()
    }

    private func dismissKeyboardIfPresent(app: XCUIApplication) {
        let screenCenter = app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5))
        screenCenter.tap()
    }
    
    private func dismissAlertIfPresent(app: XCUIApplication, alertCase: StatusRegister) {
        let alertExistsPredicate = NSPredicate(format: "exists == true")
        let alert = app.alerts.element
        expectation(for: alertExistsPredicate, evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        // ตรวจสอบข้อความใน alert
        if alert.exists {
            let expectedMessage = alertCase.rawValue
            let message = alert.staticTexts.element.label
            if message.contains(expectedMessage) {
                alert.buttons["OK"].tap()
            }
        }
    }


    func testCreateAccountSuccess() {
        let app = XCUIApplication()
        fillInRegistrationForm(username: "testNewUser", password: "testPassword123!", confirmPassword: "testPassword123!", app: app)
        dismissAlertIfPresent(app: app, alertCase: .Success)
        sleep(3)
    }
    
    func testCreateAccountWithExistingUsername() {
        let app = XCUIApplication()
        fillInRegistrationForm(username: "testNewUser", password: "testPassword123!", confirmPassword: "testPassword123!", app: app)
        
        dismissAlertIfPresent(app: app, alertCase: .FailAlreadyhaveAccount)
        
        fillInRegistrationForm(username: "testNewUser2", password: "testPassword123!", confirmPassword: "testPassword123!", app: app)
        
        dismissAlertIfPresent(app: app, alertCase: .Success)
        sleep(3)
    }
}
