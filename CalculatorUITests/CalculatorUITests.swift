//
//  CalculatorUITests.swift
//  CalculatorUITests
//
//  Created by Barry Bryant on 4/23/17.
//  Copyright © 2017 b3sk. All rights reserved.
//

import XCTest
@testable import Calculator

class CalculatorUITests: XCTestCase {

    private var app :XCUIApplication? = nil
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
//        app = XCUIApplication()
//        app?.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func testDecimalFirst() {
//        XCTAssert(app != nil, "No app in UITest")
//        app!.buttons["."].tap()
//
//        XCTAssert(app!.staticTexts["0."].exists == true, "Did not Find expected result")
//    }
//    
//    func testMultiDecimalInput() {
//        XCTAssert(app != nil, "No app in UITest")
//        app!.buttons["7"].tap()
//        app!.buttons["."].tap()
//        app!.buttons["3"].tap()
//        app!.buttons["."].tap()
//        app!.buttons["6"].tap()
//
//        XCTAssert(app!.staticTexts["7.36"].exists == true, "Did not Find expected result")
//    }
    

    
}
