//
//  ViewController.swift
//  Calculator
//
//  Created by Barry Bryant on 3/25/17.
//  Copyright © 2017 b3sk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Controller instantiates the model
    private var model = CalculatorModel()

    var userIsTyping = false

    /// Calculator display shows current operand or result of previous operation.
    @IBOutlet weak var display: UILabel! // ! - yes its an optional, but I will auto unwrap everyplace.

    /// Simulated paper tape showing steps leading to result shown in display.
    @IBOutlet weak var paperTape: UILabel!
    
    // Computed property - just simply a different way of interacting with the var "display"
    var displayValue : Double {
        get{
            return Double(display.text!)!
        }
        
        set{
            display.text = String(newValue)
        }
    }

    /// process numeric inputs - no interaction with model as number is built up
    @IBAction func touchDigit(_ sender: UIButton) {

        let digit = sender.currentTitle!
        let currentText = display.text!

        switch digit
        {
        case ".":
            if userIsTyping == false {
                // add preceeding 0 if first digit is decimal place
                display.text = "0."
                userIsTyping = true
            } else if currentText.contains("."){
                // indicate error - shake screen or beep
                return
            }
            else {
                display.text = currentText + "."
            }
            
        case "⌫":
            if userIsTyping == false{
                return   // do nothing if first char is a backspace
            } else {
                let newText = currentText.substring(to: currentText.index(before: currentText.endIndex))
                if newText.characters.count > 0 {
                    display.text = newText
                } else {
                    // last char removed -- start over
                    display.text = "0"
                    userIsTyping = false
                }
            }
            break;
            
        default:    // Process the numeric digit
            if userIsTyping {
                display.text = currentText + digit
            } else {
                display.text = digit
                userIsTyping = true
            }
        }
    }
    
    
    /// When an operation button is pressed, send operands and operations to the model
    @IBAction func performOperation(_ sender: UIButton) {
        
        if userIsTyping{
            model.setOperand(displayValue)
            userIsTyping = false
        }
        
        if let calcOperator = sender.currentTitle {
            model.performOperation(calcOperator)
        } else {
            print ("performOperation - nil currentTitle")
        }
        
        displayValue = model.result ?? 0    // for nil model results, default display to 0
        
        if let equation = model.equation {
            if (model.resultIsPending) {
                paperTape.text = equation + " ..."
            } else {
                paperTape.text = equation + " ="
            }
        } else {
            paperTape.text = "nothin happinin man"
        }
    }
}

