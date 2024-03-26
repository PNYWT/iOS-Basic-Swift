//
//  ProjectSoftwareTestTests.swift
//  ProjectSoftwareTestTests
//
//  Created by CallmeOni on 10/3/2567 BE.
//

import XCTest
@testable import ProjectSoftwareTest

// ทดสอบตาม requirements
final class ProjectSoftwareTestTests: XCTestCase {
    
    var registerManagement: Register!
    var messageCallBack: StatusRegister?
    
    override func setUp() {
        super.setUp()
        registerManagement = Register()
        registerManagement.alertAlert = { message in
            self.messageCallBack = message
        }
    }
    
    override func tearDown() { // clear variable
        UserDefaults.standard.removeObject(forKey: Register.AccountList)
        registerManagement = nil
        super.tearDown()
    }
    
    // ทดสอบค่าว่าง
    /*
     case FailUsernameEmpty = "Username is Empty."
     case FailPasswordEmpty = "Password is Empty."
     case FailConfirmPasswordEmpty = "Comfirm password is Empty."
     */
    func testCreateAccountWithEmptyUsername() throws {
        registerManagement.createAccount(username: "", password: "TestPassword123!", confirmPassword: "TestPassword123!")
        XCTAssertEqual(messageCallBack, .FailUsernameEmpty)
        
        registerManagement.createAccount(username: "TestNewUser", password: "", confirmPassword: "TestPassword123!")
        XCTAssertEqual(messageCallBack, .FailPasswordEmpty)
        
        registerManagement.createAccount(username: "TestNewUser", password: "TestPassword123!", confirmPassword: "")
        XCTAssertEqual(messageCallBack, .FailConfirmPasswordEmpty)
    }
    
    /*
     case FailUsernameCharecters = "Please Input username 8-16 characters."
     case FailPasswordCharecters = "Please Input password 14-16 characters."
     */
    func testCharactersNotEnough() throws {
        registerManagement.createAccount(username: "Test", password: "TestPassword123!", confirmPassword: "TestPassword123!")
        XCTAssertEqual(messageCallBack, .FailUsernameCharecters)
        
        registerManagement.createAccount(username: "TestNewUser", password: "TestPass", confirmPassword: "TestPassword123!")
        XCTAssertEqual(messageCallBack, .FailPasswordCharecters)
    }
    
    // ทดสอบรหัสผ่านไม่แข็งแรง
    /*
     case FailPasswordnotStrong = "Password is not strong."
     */
    func testCreateAccountWithWeakPassword() throws {
        registerManagement.createAccount(username: "TestNewUser", password: "password123456", confirmPassword: "password123456")
        XCTAssertEqual(messageCallBack, .FailPasswordnotStrong)
    }
    
    // ทดสอบรหัสผ่านที่ไม่ตรงกัน
    /*
     case FailPasswordnotMatch = "Password is not match."
     */
    func testCreateAccountWithNonMatchingPasswords() throws {
        registerManagement.createAccount(username: "TestNewUser", password: "TestPassword123!", confirmPassword: "WrongPassword123!")
        XCTAssertEqual(messageCallBack, .FailPasswordnotMatch)
    }
    
    //ทดสอบชื่อผู้ใช้ที่มีอยู่แล้ว
    /*
     case FailAlreadyhaveAccount = "You already have account."
     */
    func testCreateAccountWithExistingUsername() throws {
        let existingAccount = AllAccountModel(username: "ExistingUser", password: "StrongPassword123!")
        let existingAccounts = [existingAccount]
        if let data = try? JSONEncoder().encode(existingAccounts) {
            UserDefaults.standard.set(data, forKey: Register.AccountList)
        }
        
        registerManagement.createAccount(username: "ExistingUser", password: "StrongPassword123!", confirmPassword: "StrongPassword123!")
        XCTAssertEqual(messageCallBack, .FailAlreadyhaveAccount)
    }
    
    // ทดสอบสร้างบัญชีสำเร็จ
    /*
     case Success = "Create Account Success."
     */
    func testCreateAccountSuccessfully() throws {
        registerManagement.createAccount(username: "TestNewUser", password: "StrongPassword123!", confirmPassword: "StrongPassword123!")
        XCTAssertEqual(messageCallBack, .Success)
    }
    
    func testPerformanceExample() throws {
        // วัดประสิทธิภาพของโค้ดบล็อกนี้
        self.measure {
            registerManagement.createAccount(username: "PerfTestUser", password: "StrongPassword123!", confirmPassword: "StrongPassword123!")
        }
    }
}
