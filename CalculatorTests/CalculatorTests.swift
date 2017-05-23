//
//  CalculatorTests.swift
//  CalculatorTests
//
//  Created by Barry Bryant on 4/23/17.
//  Copyright © 2017 b3sk. All rights reserved.
//

import XCTest
@testable import Calculator

class CalculatorModelTests: XCTestCase {
    
    var model = CalculatorModel()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRequirement7a()
    {
        model.setOperand(7)
        model.performOperation("+")
        
        XCTAssert(model.description == "7 +", "Bad Description: \(model.description ?? "nil")")
        XCTAssert(model.resultIsPending == true, "Bad resultIsPending: \(model.resultIsPending)")
        XCTAssert(model.result == 7, "Bad Result: \(model.result!)")
    }

    func testRequirement7b()
    {
        model.setOperand(7)
        model.performOperation("+")
        model.setOperand(9)
        
        XCTAssert(model.description == "7 +", "Bad Description: \(model.description ?? "nil")")
        XCTAssert(model.resultIsPending == true, "Bad resultIsPending: \(model.resultIsPending)")
        XCTAssert(model.result == 9, "Bad Result: \(model.result!)")
    }

    func testRequirement7c()
    {
        model.setOperand(7)
        model.performOperation("+")
        model.setOperand(9)
        model.performOperation("=")
        
        XCTAssert(model.description == "7 + 9", "Bad Description: \(model.description ?? "nil")")
        XCTAssert(model.resultIsPending == false, "Bad resultIsPending: \(model.resultIsPending)")
        XCTAssert(model.result == 16, "Bad Result: \(model.result!)")
    }

    func testRequirement7d()
    {
        model.setOperand(7)
        model.performOperation("+")
        model.setOperand(9)
        model.performOperation("=")
        model.performOperation("√")
        
        XCTAssert(model.description == "√(7 + 9)", "Bad Description: \(model.description ?? "nil")")
        XCTAssert(model.resultIsPending == false, "Bad resultIsPending: \(model.resultIsPending)")
        XCTAssert(model.result == 4, "Bad Result: \(model.result!)")
    }

    func testRequirement7e()
    {
        model.setOperand(7)
        model.performOperation("+")
        model.setOperand(9)
        model.performOperation("=")
        model.performOperation("√")
        model.performOperation("+")
        model.setOperand(2)
        model.performOperation("=")
        
        XCTAssert(model.description == "√(7 + 9) + 2", "Bad Description: \(model.description ?? "nil")")
        XCTAssert(model.resultIsPending == false, "Bad resultIsPending: \(model.resultIsPending)")
        XCTAssert(model.result == 6, "Bad Result: \(model.result!)")
    }
    
    func testRequirement7f()
    {
        model.setOperand(7)
        model.performOperation("+")
        model.setOperand(9)
        model.performOperation("√")
        
        XCTAssert(model.description == "7 + √(9)", "Bad Description: \(model.description ?? "nil")")
        XCTAssert(model.resultIsPending == true, "Bad resultIsPending: \(model.resultIsPending)")
        XCTAssert(model.result == 3, "Bad Result: \(model.result!)")
    }
    
    func testRequirement7g()
    {
        model.setOperand(7)
        model.performOperation("+")
        model.setOperand(9)
        model.performOperation("√")
        model.performOperation("=")
        
        XCTAssert(model.description == "7 + √(9)", "Bad Description: \(model.description ?? "nil")")
        XCTAssert(model.resultIsPending == false, "Bad resultIsPending: \(model.resultIsPending)")
        XCTAssert(model.result == 10, "Bad Result: \(model.result!)")
    }
    
    func testRequirement7h()
    {
        model.setOperand(7)
        model.performOperation("+")
        model.setOperand(9)
        model.performOperation("=")
        model.performOperation("+")
        model.setOperand(6)
        model.performOperation("=")
        model.performOperation("+")
        model.setOperand(3)
        model.performOperation("=")
        
        XCTAssert(model.description == "7 + 9 + 6 + 3", "Bad Description: \(model.description ?? "nil")")
        XCTAssert(model.resultIsPending == false, "Bad resultIsPending: \(model.resultIsPending)")
        XCTAssert(model.result == 25, "Bad Result: \(model.result!)")
    }
    
    func testRequirement7i()
    {
        model.setOperand(7)
        model.performOperation("+")
        model.setOperand(9)
        model.performOperation("=")
        model.performOperation("√")
        model.setOperand(6)
        model.performOperation("+")
        model.setOperand(3)
        model.performOperation("=")
        
        XCTAssert(model.description == "6 + 3", "Bad Description: \(model.description ?? "nil")")
        XCTAssert(model.resultIsPending == false, "Bad resultIsPending: \(model.resultIsPending)")
        XCTAssert(model.result == 9, "Bad Result: \(model.result!)")
    }
    
    func testRequirement7j()
    {
        model.setOperand(5)
        model.performOperation("+")
        model.setOperand(6)
        model.performOperation("=")
        model.setOperand(73)
        
        // although model.description is nil, the equation display is still showing "5 + 6 ="
        // For assignment 2, the description is not optional, so test updated to test for ""
        XCTAssert(model.description == nil || model.description == "", "Bad Description: \(model.description ?? "nil")")
        XCTAssert(model.resultIsPending == false, "Bad resultIsPending: \(model.resultIsPending)")
        XCTAssert(model.result == 73, "Bad Result: \(model.result!)")
    }
    
    func testRequirement7k()
    {
        model.setOperand(4)
        model.performOperation("✕")
        model.performOperation("π")
        model.performOperation("=")
        
        // although model.description is nil, the equation display is still showing "5 + 6 ="
        XCTAssert(model.description == "4 ✕ π", "Bad Description: \(model.description ?? "nil")")
        XCTAssert(model.resultIsPending == false, "Bad resultIsPending: \(model.resultIsPending)")
        XCTAssert(model.result! > 12.56637 && model.result! < 12.56638, "Bad Result: \(model.result!)")
    }
    
    func testRequirement8()
    {
        model.clearModel()
        
        // For assignment 2, the description is not optional, so test updated to test for ""
        XCTAssert(model.description == nil || model.description == "", "Bad Description: \(model.description ?? "nil")")
        XCTAssert(model.resultIsPending == false, "Bad resultIsPending: \(model.resultIsPending)")
        XCTAssert(model.result == nil, "Bad Result: \(model.result!)")
    }
    
    func testAssign2Requirement7e1()
    {
        model.clearModel()
        model.setOperand(9)
        model.performOperation("+")
        model.setOperand(variable: "M")
        model.performOperation("=")
        model.performOperation("√")

        XCTAssert(model.description == "√(9 + M)", "Bad Description: \(model.description ?? "nil")")
        XCTAssert(model.resultIsPending == false, "Bad resultIsPending: \(model.resultIsPending)")
        XCTAssert(model.result == 3, "Bad Result: \(model.result!)")
    }

    func testAssign2Requirement7e2()
    {
        model.clearModel()
        model.setOperand(9)
        model.performOperation("+")
        model.setOperand(variable: "M")
        model.performOperation("=")
        model.performOperation("√")

        model.setVariableValue("M", 7)
        XCTAssert(model.evaluate(using:model.variableList).result
            == 4, "Bad Result: \(model.result!)")
        
        XCTAssert(model.description == "√(9 + M)", "Bad Description: \(model.description ?? "nil")")
        XCTAssert(model.resultIsPending == false, "Bad resultIsPending: \(model.resultIsPending)")
    }
    
    func testAssign2Requirement7e3()
    {
        model.clearModel()
        model.setOperand(9)
        model.performOperation("+")
        model.setOperand(variable: "M")
        model.performOperation("=")
        model.performOperation("√")
        
        model.setVariableValue("M", 7)
        XCTAssert(model.evaluate(using:model.variableList).result
            == 4, "Bad Result: \(model.result!)")
        
        model.performOperation("+")
        model.setOperand(14)
        model.performOperation("=")

        XCTAssert(model.result == 18, "Bad Result: \(model.result!)")
        XCTAssert(model.description == "√(9 + M) + 14", "Bad Description: \(model.description ?? "nil")")
        XCTAssert(model.resultIsPending == false, "Bad resultIsPending: \(model.resultIsPending)")
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
