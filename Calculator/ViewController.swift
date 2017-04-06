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

    // IS this Weak var to avoid an ownership loop with the model which puts results in the display.
    @IBOutlet weak var display: UILabel! // ! - yes its an optional, but I will auto unwrap everyplace.

    // Computed property - just simply a different way of interacting with the var "display"
    var displayValue : Double {
        get{
            return Double(display.text!)!
        }
        
        set{
            display.text = String(newValue)
        }
    }

    // process numeric inputs - no interaction with model as number is built up
    @IBAction func touchDigit(_ sender: UIButton) {

        let digit = sender.currentTitle!
        let currentText = display.text!

        switch digit
        {
        case ".":   // add preceeding 0 if first digit is decimal place
            if userIsTyping == false {
                display.text = "0."
                userIsTyping = true
            } else if currentText.contains("."){
                // indicate error - shake screen or beep
                return
            }
            else {
                display.text = currentText + digit
            }
            
        case "⌫":   // Don't do anything if first char is a backspace
            if userIsTyping == false{
                return   // do nothing if first char is a backspace
            } else {
                let newText = currentText.substring(to: currentText.index(before: currentText.endIndex))
                if newText.characters.count > 0 {
                    display.text = newText
                } else {
                    display.text = "0"
                    userIsTyping = false
                }
            }
            break;
            
        default:    // normal case is process the numeric digit
            if userIsTyping {
                display.text = currentText + digit
            } else {
                display.text = digit
                userIsTyping = true
            }
        }
    }
    
    
    // When an operation button is pressed, send operands and operations to the model
    @IBAction func performOperation(_ sender: UIButton) {
        
        if userIsTyping{
            model.setOperand(displayValue)
            userIsTyping = false
        }
        userIsTyping = false;
        
        if let calcOperator = sender.currentTitle {
            model.performOperation(calcOperator)
        }
        
        if let result = model.result{
            displayValue = result
        }
    }
    
    
}

