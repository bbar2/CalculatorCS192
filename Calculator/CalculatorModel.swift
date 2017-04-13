//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Barry Bryant on 3/30/17.
//  Copyright © 2017 b3sk. All rights reserved.
//

import Foundation

struct CalculatorModel {
    
    /// Heart of calculator is this enum and it's associated types
    private enum Operation {
        case constant(Double)                   // associated value is double
        case zeroOp(()->Double)                 // func that takes no
        case unaryOp((Double)->Double)          // func that takes one input
        case binaryOp((Double, Double)->Double) // func that takes two inputs
        case equals                             // execute a pending binaryOp
    }

    /// secondOperatnShowing is True if accumulator.description has pending operation, and is showing a second operand.
    /// Using an Operation.constant for the second operand, or Operation.unaryOp on the second operand
    /// will result in accumulator.description showing the second operand prior to receiving an Operation.equals operation.
    private var accumulator: (value: Double?, description: String?, secondOperandShowing :Bool?)


    /// Numeric of CalculatorModel
    var result: Double? {
        get {
            return accumulator.value
        }
    }

    /// Sequence of steps that lead to the numeric output of CalculatorModel
    var equation: String? {
        get {
            if resultIsPending && !accumulator.secondOperandShowing!{
                return accumulator.description! + " " +
                    pendingBinaryOperation!.pendingOperationString
            } else {
                return accumulator.description
            }
        }
    }
    
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

    public mutating func  clearModel() {
        accumulator.value = nil
        accumulator.description = nil
        pendingBinaryOperation = nil
        accumulator.secondOperandShowing = nil
    }
    
    /// Update accumulator.value with result of binary func stored in pendingBinaryOperation.pendingFunction,
    /// using pendingBinaryOperation.firstOperand and accumulator.value as second operand
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator.value != nil {
            if accumulator.description != nil && accumulator.secondOperandShowing != nil && !accumulator.secondOperandShowing! {
                accumulator.description! += " " + pendingBinaryOperation!.pendingOperationString + " " + calculatorString(accumulator.value!)
            }
            accumulator.value = pendingBinaryOperation!.perform(with:accumulator.value!)
        }
    }

    /// Return true if pendingFunction and Operator are stored in pendingBinaryOperation member.
    var resultIsPending: Bool  {
        get {
            return pendingBinaryOperation != nil;
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
    
    /// When an operand is required, the viewController calls setOperand just 
    /// before calling performOperation.  performOperation will update
    /// accumulator.description differently depending on the Operation enum.
    mutating func setOperand(_ operand: Double){

        accumulator.value = operand
        
        if !resultIsPending {
            accumulator.description = nil
            accumulator.secondOperandShowing = false
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
                    if let currentDescription = accumulator.description {
                        accumulator.description = currentDescription +
                            " " + pendingBinaryOperation!.pendingOperationString +
                            " " + symbol
                        accumulator.secondOperandShowing = true
                    }
                } else {
                    accumulator.description = symbol
                    accumulator.secondOperandShowing = false
                }
                
            // no operand - perform the noOperandFunc from the operations:Dictionary using no operand
            case .zeroOp(let noOperandFunc):
                accumulator.value = noOperandFunc()
                
                if resultIsPending {
                    // if in middle of binary operation, noOperandFunc is second operand
                    // operating on the current operand only
                    if (accumulator.description != nil) {
                        accumulator.description! +=
                            " " + pendingBinaryOperation!.pendingOperationString +
                            " " + symbol
                        accumulator.secondOperandShowing = true
                    }
                } else {
                    // if no pending binary op, noOperandFunc loads accumulator
                    accumulator.description = symbol
                    accumulator.secondOperandShowing = false
                }
                
            // one operand - perform the unaryFunc from the operations:Dictionary using the accumulator as the one operand
            case .unaryOp(let unaryFunc):
                let singleOperand = accumulator.value ?? 0
                let operandDescription = accumulator.description ?? calculatorString(singleOperand)
                accumulator.value = unaryFunc(singleOperand)
                
                if resultIsPending {
                    // if in middle of binary operation, unaryOp is
                    // operating on the current operand only
                    accumulator.description = operandDescription +
                        " " + pendingBinaryOperation!.pendingOperationString +
                        " " + symbol + "(" + calculatorString(singleOperand) + ")"
                    accumulator.secondOperandShowing = true
                } else {
                    // if no pending binary op, unaryOp is operating on
                    // equation that lead to current accumulator
                    accumulator.description = symbol + "(" + operandDescription + ")"
                    accumulator.secondOperandShowing = false
                    }

            // Save first operand and binaryFunc from the operations:Dictionary.
            // Second operand will come later via Operation.equals
            case .binaryOp(let binaryFunc):

                var firstOperand = accumulator.value ?? 0
                
                // Execute any already pending operations.  e.g. 3 + 2 + 2
                if resultIsPending {
                    performPendingBinaryOperation() // updates accumulator.value and .description
                    firstOperand = accumulator.value!
                }
                
                // If necessary, initialize the accumulator description
                if accumulator.description == nil {
                    accumulator.description = calculatorString(firstOperand)
                    accumulator.secondOperandShowing = false
                }
                
                // Save the accumulator.value and binaryFunc in pendingBinaryOperation var
                pendingBinaryOperation = PendingBinaryOperation(
                    pendingFunction: binaryFunc,
                    pendingOperationString: symbol,
                    firstOperand: firstOperand)
                
                // constants or Operation.unaryOp will show the second operand prior to Operation.equals
                accumulator.secondOperandShowing = false
                
            // Execute a pending binary operation
            case .equals:
                if resultIsPending {
                    performPendingBinaryOperation()
                    pendingBinaryOperation = nil
                    accumulator.secondOperandShowing = false
                }
            }
        }
    }
    
}
