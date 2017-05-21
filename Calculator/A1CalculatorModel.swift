//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Barry Bryant on 3/30/17.
//  Copyright © 2017 b3sk. All rights reserved.
//

import Foundation

/// Calculator "brain" from assignment 1
struct A1CalculatorModel {

    // Non-Private API - default is internal = public within module
    
    /// Reset the model to it's boot up state
    mutating func  clearModel()
    {
        accumulator = nil
        internalDescription = nil
        pendingBinaryOperation = nil
        secondOperandShowing = false
        variable = nil
    }
    
    /// Result of most recent operation
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    /// Return true if in the middle of a binary operation.
    var resultIsPending: Bool  {
        get {
            return pendingBinaryOperation != nil;
        }
    }
    
    /// Sequence of steps that lead to the numeric output of CalculatorModel
    var description: String? {
        get {
            if resultIsPending && !secondOperandShowing {
                return internalDescription! + " " +
                    pendingBinaryOperation!.pendingOperationString
            } else {
                return internalDescription
            }
        }
    }
    
    /// Put an operand in the accumulator. Called by:
    ///  1. viewController just before calling performOperation.  
    ///     performOperation will update internalDescription 
    ///     differently depending on the Operation enum.
    ///  2. model.performOperation(symbol.constant) to load accumulator 
    ///     with a constant
    mutating func setOperand(_ operand: Double)
    {
        accumulator = operand
        
        if !resultIsPending {
            internalDescription = nil
            secondOperandShowing = false
        }
    }

    /// Addition for assignment 2, so equation can show a variable.
    /// Note that this is modeled after performOperation's case .constant by putting a symbol in the equation and number in the accumulator.
    mutating func setOperand(variable named:String, value:Double)
    {
        setOperand(value)
        if resultIsPending {
            // if in middle of binary operation
            if let currentDescription = internalDescription {
                internalDescription = currentDescription +
                    " " + pendingBinaryOperation!.pendingOperationString +
                    " " + named
                secondOperandShowing = true
            }
        } else {
            internalDescription = named
            secondOperandShowing = false
        }
    }

    /// Perform a calculator operation. Up to two operands may be available in
    /// accumulator and pendingBinaryOperation.firstOperand
    mutating func performOperation(_ symbol: String){
        
        if let operation = operations[symbol] {
            switch (operation) {
                
            // No operands - set the accumulator = to the associated value from the operations:Dictionary
            case .constant(let value):
                setOperand(value)
                if resultIsPending {
                    // if in middle of binary operation
                    if let currentDescription = internalDescription {
                        internalDescription = currentDescription +
                            " " + pendingBinaryOperation!.pendingOperationString +
                            " " + symbol
                        secondOperandShowing = true
                    }
                } else {
                    internalDescription = symbol
                    secondOperandShowing = false
                }
                
            // no operand - perform the noOperandFunc from the operations:Dictionary using no operand
            case .zeroOp(let noOperandFunc):
                accumulator = noOperandFunc()
                
                if resultIsPending {
                    // if in middle of binary operation, noOperandFunc is second operand
                    // operating on the current operand only
                    if (internalDescription != nil) {
                        internalDescription! +=
                            " " + pendingBinaryOperation!.pendingOperationString +
                            " " + symbol
                        secondOperandShowing = true
                    }
                } else {
                    // if no pending binary op, noOperandFunc loads accumulator
                    internalDescription = symbol
                    secondOperandShowing = false
                }
                
            // one operand - perform the unaryFunc from the operations:Dictionary using the accumulator as the one operand
            case .unaryOp(let unaryFunc):
                let singleOperand = accumulator ?? 0
                let operandDescription = internalDescription ?? calculatorString(singleOperand)
                accumulator = unaryFunc(singleOperand)
                
                if resultIsPending {
                    // if in middle of binary operation, unaryOp is
                    // operating on the current operand only
                    internalDescription = operandDescription +
                        " " + pendingBinaryOperation!.pendingOperationString +
                        " " + symbol + "(" + calculatorString(singleOperand) + ")"
                    secondOperandShowing = true
                } else {
                    // if no pending binary op, unaryOp is operating on
                    // equation that lead to current accumulator
                    internalDescription = symbol + "(" + operandDescription + ")"
                    secondOperandShowing = false
                }
                
            // Save first operand and binaryFunc from the operations:Dictionary.
            // Second operand will come later via Operation.equals
            case .binaryOp(let binaryFunc):
                
                var firstOperand = accumulator ?? 0
                
                // Execute any already pending operations.  e.g. 3 + 2 + 2
                if resultIsPending {
                    performPendingBinaryOperation() // updates accumulator and .internalDescription
                    firstOperand = accumulator!
                }
                
                // If necessary, initialize the accumulator internalDescription
                if internalDescription == nil {
                    internalDescription = calculatorString(firstOperand)
                    secondOperandShowing = false
                }
                
                // Save the accumulator and binaryFunc in pendingBinaryOperation var
                pendingBinaryOperation = PendingBinaryOperation(
                    pendingFunction: binaryFunc,
                    pendingOperationString: symbol,
                    firstOperand: firstOperand)
                
                // constants or Operation.unaryOp will show the second operand prior to Operation.equals
                secondOperandShowing = false
                
            // Execute a pending binary operation
            case .equals:
                if resultIsPending {
                    performPendingBinaryOperation()
                    pendingBinaryOperation = nil
                    secondOperandShowing = false
                } else {
                    let operand = accumulator ?? 0
                    internalDescription = calculatorString(operand)
                }
            }
        }
    }
    
    /// Private stuff below ///

    /// Optional Dictionary will hold variable operand - added via setOperand
    private var variable :[String: Double]?

    /// Heart of calculator is this enum and it's associated types
    private enum Operation {
        case constant(Double)                   // associated value is double
        case zeroOp(()->Double)                 // func that takes no
        case unaryOp((Double)->Double)          // func that takes one input
        case binaryOp((Double, Double)->Double) // func that takes two inputs
        case equals                             // execute a pending binaryOp
    }

    private var accumulator:Double?

    private var internalDescription: String?

    /// Using an Operation.constant for the second operand, or Operation.unaryOp on the second operand
    /// will result in internalDescription showing the second operand prior to receiving an Operation.equals operation.
    /// secondOperandShowing is True if internalDescription has pending operation, and is showing a second operand.
    private var secondOperandShowing = false
    
    
    /// Structure of local storage for first operand and pendingFunction, used
    /// while second operand is built by viewController.
    private struct PendingBinaryOperation {
        let pendingFunction: (Double, Double) -> Double         // This is what will perform the work
        let pendingOperationString: String                      // Human readable piece of equation
        let firstOperand: Double
        func perform(with secondOperand:Double) -> Double {
            return pendingFunction(firstOperand, secondOperand)
        }
    }

    /// local storage for first operand and pendingFunction
    private var pendingBinaryOperation: PendingBinaryOperation?

    /// Update accumulator with result of binary func stored in pendingBinaryOperation.pendingFunction,
    /// using pendingBinaryOperation.firstOperand and accumulator as second operand
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            if internalDescription != nil && !secondOperandShowing {
                internalDescription! += " " + pendingBinaryOperation!.pendingOperationString + " " + calculatorString(accumulator!)
            }
            accumulator = pendingBinaryOperation!.perform(with:accumulator!)
        }
    }

    /// second heart of CalculatorModel is this table utilizing the Operation enum, and its funcs
    /// and closures
    private var operations: Dictionary<String, Operation> = [
        "π": .constant(Double.pi),
        "e": .constant(M_E),
        "rnd": .zeroOp({Double(arc4random()) / Double(UInt32.max)}),
        "sin": .unaryOp(sin),
        "cos": .unaryOp(cos),
        "tan": .unaryOp(tan),
        "sin⁻¹": .unaryOp(asin),
        "cos⁻¹": .unaryOp(acos),
        "tan⁻¹": .unaryOp(atan),
        "x⁻¹": .unaryOp({ 1 / $0}),
        "±" : .unaryOp({ -$0 }),
        "x²" : .unaryOp({ $0 * $0 }),
        "√": .unaryOp(sqrt),
        // Example progression showing simplification of closure syntax using
        // type inference and default $ arguments
//        "✕" : .binaryOp({ (op1:Double, op2:Double) -> Double in
//            return op1 * op2 }),    // Full Sytax
        "÷" : .binaryOp({ (op1, op2) in return op1 / op2 }),    // type inference dumps type info for input params and return value
        "+" : .binaryOp({ (op1, op2) in op1 + op2 }),           // eliminate the return key word
        "-" : .binaryOp({ $0 - $1 }),                          // Substitue default $ arguments ($0, $1, ..)
        "✕" : .binaryOp(*),           // Kind of tricky - Basic operators are actaully funcs that take two doubles and return one.
        "xʸ": .binaryOp {pow($0, $1)},                          // ending closure syntax - can omit the () if closure is last param.
        "=" : .equals
    ]
    
    /// Format used for operand strings - seems like a view thing
    private func calculatorString(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        return formatter.string(from: NSNumber(value:number)) ?? "Not A Number"
    }
    
    
}
