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
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.buttons["7"].tap()
        app.buttons["8"].tap()
        app.buttons["✕"].tap()
        app.buttons["5"].tap()
        app.buttons["="].tap()
        
        let answer = app.staticTexts("78");
        
    }
    
}
