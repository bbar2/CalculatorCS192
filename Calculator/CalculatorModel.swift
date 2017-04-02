//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Barry Bryant on 3/30/17.
//  Copyright © 2017 b3sk. All rights reserved.
//

import Foundation

struct CalculatorModel {
    
    // Heart of calculator is this enum and it's associated types
    private enum Operation {
        case constant(Double)   // associated value is double
        case unaryOp((Double)->Double) // func that takes one input
        case binaryOp((Double, Double)->Double) // func that takes two inputs
        case equals
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        func perform(with secondOperand:Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }

    private var accumulator: Double?
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    // second heart is this table utilizing the Operation enum, and its funcs and closures
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "C": Operation.constant(0.0),
        "√": Operation.unaryOp(sqrt),
        "cos":Operation.unaryOp(cos),
        // Example progression showing simplification of closure syntax using type inference and default $ arguments
        "✕" :Operation.binaryOp({ (op1:Double, op2:Double) -> Double in
            return op1 * op2 }),    // Full Sytax
        "÷" :Operation.binaryOp({ (op1, op2) in return op1 / op2 }),    // type inference dumps the type info for input params and return value
        "+" :Operation.binaryOp({ (op1, op2) in op1 + op2 }),           // eliminate the return key word
        "-" :Operation.binaryOp({ $0 - $1 } ),                          // Substitue default $ arguments ($0, $1, ..)
        "±" :Operation.unaryOp({ -$0 }),
        "sq" :Operation.unaryOp({ $0 * $0 }),
        "=" : Operation.equals
    ]
    
    mutating func setOperand(_ operand: Double){
        accumulator = operand
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            //accumulator = pendingBinaryOperation!.perform(with:accumulator!)
            accumulator = pendingBinaryOperation!.function(pendingBinaryOperation!.firstOperand, accumulator!)
        }
    }
    
    mutating func performOperation(_ symbol: String){
        print("performOperation \(symbol)")

        if let operation = operations[symbol] {
            switch (operation) {
            case .constant(let value):
                accumulator = value
                
            case .unaryOp(let unaryFunc):
                if accumulator != nil {
                    accumulator = unaryFunc(accumulator!)
                }
                
            case .binaryOp(let binaryFunc):
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: binaryFunc, firstOperand: accumulator!)
                    accumulator = nil // prevents display from changing
                }

            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    
}
