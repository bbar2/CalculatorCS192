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

    private var accumulator: (value: Double?, description: String?)
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    var result: Double? {
        get {
            return accumulator.value
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
        accumulator.value = operand
        if accumulator.description != nil {
            accumulator.description! += " \(operand)"
        } else {
            accumulator.description = String(operand)
        }
        print("setOperand: \(accumulator.description!)")
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator.value != nil {
            accumulator.value = pendingBinaryOperation!.perform(with:accumulator.value!)
        }
    }
    
    mutating func performOperation(_ symbol: String){

        if let operation = operations[symbol] {
            switch (operation) {
            case .constant(let value):
                accumulator.value = value
                
            case .unaryOp(let unaryFunc):
                if accumulator.value != nil {
                    accumulator.value = unaryFunc(accumulator.value!)
                    accumulator.description = symbol + "(" + accumulator.description! + ")"
                }
                
            case .binaryOp(let binaryFunc):
                if pendingBinaryOperation != nil {
                    performPendingBinaryOperation()
                }
                if accumulator.value != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: binaryFunc, firstOperand: accumulator.value!)
                    accumulator.value = nil // prevents display from changing
                }
                accumulator.description! += " \(symbol)"

            case .equals:
                performPendingBinaryOperation()
                pendingBinaryOperation = nil    // not so sure about this
                accumulator.description = ""    // not sure about this
            }
        }
        if let msg = accumulator.description {
            print("performOperation: \(msg)")
        }
    }
    
    
}
