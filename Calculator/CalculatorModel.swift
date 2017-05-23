//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Barry Bryant on 3/30/17.
//  Copyright © 2017 b3sk. All rights reserved.
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
    
    /// Model variable dictionary
    // this violates assigmnet 2, rqmt 1: No additional public API for model
    var variableList:Dictionary<String, Double>? = nil
    
    /// Reset the model to it's boot up state
    mutating func  clearModel()
    {
        actionList.removeAll()
        variableList?.removeAll()
        variableList = nil;
    }
    
    /// Result of most recent operation
    var result: Double? {
        get {
            return evaluate(using: variableList).result
        }
    }
    
    /// Return true if in the middle of a binary operation.
    var resultIsPending: Bool  {
        get {
            return evaluate(using: variableList).isPending
        }
    }
    
    /// Sequence of steps that lead to the numeric output of CalculatorModel
    var description: String? {
        get {
            return evaluate(using: variableList).description
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
    
    // this violates assigmnet 2, rqmt 1: No additional public API for model
    mutating func setVariableValue(_ varName:String, _ varValue:Double)
    {
        if variableList == nil {
            variableList = [String: Double]()
        }
        variableList![varName] = varValue
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
                // If variable not found in dictionary, assume it's zero
                a1Model.setOperand(variable:variableName, value:variables?[variableName] ?? 0)
                
            case .operation( let operationSymbol):
                a1Model.performOperation(operationSymbol)
            }
        }
        return (a1Model.result, a1Model.resultIsPending, a1Model.description ?? "")
    }
    
}
