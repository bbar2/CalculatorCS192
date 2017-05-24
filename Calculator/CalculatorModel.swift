//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Barry Bryant on 3/30/17.
//  Copyright © 2017 b3sk. All rights reserved.
//
//  This is the model for assignment 2. Implements the actionList, undo, variables kept in model, and evaluate.
//  Uses a private instance of the assignment 1 model with one modification.
//  - Added one method mutating func setOperand(variable named:String, value:Double) to the private
//    assignment 1 model, which is not exposed publicly from this model.
//

import Foundation

struct CalculatorModel {

    // Private Members
    
    /// The user can either set an operand, variable or request an operation.
    private enum ActionType {
        case operand(Double)
        case variable(String)
        case operation(String)
    }
    
    /// Store up all actions in this list - will get executed by evaluate()
    private var actionList = [ActionType]()

    // Non-Private API - default is internal = public within module
    
    /// Reset the model to it's boot up state
    mutating func  clearModel()
    {
        actionList.removeAll()
    }
    
    /// Result of most recent operation - evaluating all variables as 0
    var result: Double? {
        get {
            return evaluate().result
        }
    }
    
    /// Return true if in the middle of a binary operation
    var resultIsPending: Bool  {
        get {
            return evaluate().isPending
        }
    }
    
    /// Sequence of steps that lead to the numeric output of CalculatorModel
    var description: String? {
        get {
            return evaluate().description
        }
    }
    
    mutating func setOperand(_ operand: Double)
    {
        actionList.append(ActionType.operand(operand))
    }

    /// Allow input of variables by storing the display value into the Variable Dictionary, with the key=named
    mutating func setOperand(variable named: String)
    {
        actionList.append(ActionType.variable(named))
    }
    
    mutating func performOperation(_ symbol: String)
    {
        actionList.append(ActionType.operation(symbol))
    }

    mutating func undo()
    {
        if !actionList.isEmpty{
        actionList.removeLast()
        }
    }
    
    func evaluate(using variables: Dictionary<String,Double>? = nil)
        -> (result: Double?, isPending: Bool, description: String)
    {
        // Instantiate an assignment 1 model for each call to evaluate
        var a1Model = A1CalculatorModel()
        
        // Loop through the ActionList and call the assignment 1 calculator
        for action in actionList
        {
            switch action
            {
            case .operand( let operand):
                a1Model.setOperand(operand)
                
            case .variable(let variableName):
                // If variable not found in dictionary, evaluate with 0
                a1Model.setOperand(variable:variableName, value:variables?[variableName] ?? 0)
                
            case .operation( let operationSymbol):
                a1Model.performOperation(operationSymbol)
            }
        }
        return (a1Model.result, a1Model.resultIsPending, a1Model.description ?? "")
    }
    
}
