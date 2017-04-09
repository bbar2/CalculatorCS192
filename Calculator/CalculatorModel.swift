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
        case clear                              // case in performOperation
        case constant(Double)                   // associated value is double
        case unaryOp((Double)->Double)          // func that takes one input
        case binaryOp((Double, Double)->Double) // func that takes two inputs
        case equals                             // execute a pending binaryOp
    }

    private var accumulator: (value: Double?, description: String?)

    /// Numeric of CalculatorModel
    var result: Double? {
        get {
            return accumulator.value
        }
    }

    var secondOperandShowing = false
    
    /// Sequence of steps that lead to the numeric output of CalculatorModel
    var equation: String? {
        get {
            if resultIsPending && !secondOperandShowing{
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
        let pendingFunction: (Double, Double) -> Double
        let pendingOperationString: String
        let firstOperand: Double
        func perform(with secondOperand:Double) -> Double {
            return pendingFunction(firstOperand, secondOperand)
        }
    }

    /// local storage for first operand and pendingFunction
    private var pendingBinaryOperation: PendingBinaryOperation?

    /// Update accumulator.value with result of binary func stored in pendingBinaryOperation, 
    /// using firstOperand also stored in pendingBinaryOperation and second operand as 
    /// current accumulator.value
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator.value != nil {
            if !secondOperandShowing {
                accumulator.description! += " " + pendingBinaryOperation!.pendingOperationString + " \(accumulator.value!)"
            }
            accumulator.value = pendingBinaryOperation!.perform(with:accumulator.value!)
        }
    }

    /// Return true if pendingFunction and Operator are stored in 
    /// pendingBinaryOperation member.
    var resultIsPending: Bool  {
        get {
            return pendingBinaryOperation != nil;
        }
    }
    
    /// second heart is this table utilizing the Operation enum, and its funcs 
    /// and closures
    private var operations: Dictionary<String, Operation> = [
        "π": .constant(Double.pi),
        "e": .constant(M_E),
        "C": .clear,
        "√": .unaryOp(sqrt),
        "cos": .unaryOp(cos),
        // Example progression showing simplification of closure syntax using 
        // type inference and default $ arguments
        "✕" : .binaryOp({ (op1:Double, op2:Double) -> Double in
            return op1 * op2 }),    // Full Sytax
        "÷" : .binaryOp({ (op1, op2) in return op1 / op2 }),    // type inference dumps type info for input params and return value
        "+" : .binaryOp({ (op1, op2) in op1 + op2 }),           // eliminate the return key word
        "-" : .binaryOp({ $0 - $1 } ),                          // Substitue default $ arguments ($0, $1, ..)
        "±" : .unaryOp({ -$0 }),
        "sq" : .unaryOp({ $0 * $0 }),
        "=" : .equals
    ]
    
    /// When an operand is required, the viewController calls setOperand just 
    /// before calling performOperation
    mutating func setOperand(_ operand: Double){
        accumulator.value = operand
    }
    
    /// Perform a calculator operation. Up to two operands may be available in
    /// accumulator and pendingBinaryOperation.firstOperand
    mutating func performOperation(_ symbol: String){

        if let operation = operations[symbol] {
            switch (operation) {
                
            case .clear:
                accumulator.value = nil
                accumulator.description = nil
                pendingBinaryOperation = nil
                
            // No operands - set the accumulator = to the associated value from the operations:Dictionary
            case .constant(let value):
                accumulator.value = value
                
            // one operand - perform the unaryFunc from the operations:Dictionary using the accumulator as the one operand
            case .unaryOp(let unaryFunc):
                if let singleOperand = accumulator.value
                {
                    let operandDescription = accumulator.description ?? "\(singleOperand)"
                    accumulator.value = unaryFunc(singleOperand)
              
                    if resultIsPending {
                        // if in middle of binary operation, unaryOp is 
                        // operating on the current operand only
                        accumulator.description = operandDescription +
                            " " + pendingBinaryOperation!.pendingOperationString +
                            " " + symbol + "(" + "\(singleOperand)" + ")"
                        secondOperandShowing = true
                    } else {
                        // if no pending binary op, unaryOp is operating on
                        // equation that lead to current accumulator
                        accumulator.description =
                            symbol + "(" + operandDescription + ")"
                    }
                }

            // Save first operand and binaryFunc from the operations:Dictionary.
            // Second operand comes via .equals
            case .binaryOp(let binaryFunc):

                if let firstOperand = accumulator.value
                {
                    // Execute any already pending operations.  e.g. 3 + 2 + 2
                    if resultIsPending {
                        performPendingBinaryOperation() // update accumulator.value and .description
                    }
                    
                    // Initialize the accumulator description
                    if accumulator.description == nil {
                        accumulator.description = "\(firstOperand)"
                    }

                    // Save the accumulator.value and binaryFunc in the 
                    // pendingBinaryOperation var
                    pendingBinaryOperation = PendingBinaryOperation(
                        pendingFunction: binaryFunc,
                        pendingOperationString: symbol,
                        firstOperand: accumulator.value!)
                    
                    secondOperandShowing = false
                }

            // Execute a pending binary operation
            case .equals:
                if resultIsPending {
                    performPendingBinaryOperation()
                    pendingBinaryOperation = nil
                }
            }
        }
    }
    
}
