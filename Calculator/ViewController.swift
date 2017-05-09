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

    private var userIsTyping = false

    /// Calculator display shows current operand or result of previous operation.
    @IBOutlet weak var display: UILabel! // ! optional will auto unwrap everyplace

    /// Steps leading to result shown in display.
    @IBOutlet weak var currentEquation: UILabel!
    
    /// Show value in memory in this label
    @IBOutlet weak var memoryDisplay: UILabel!
    
    /// View state for trig buttons - invert in second mode
    private var secondMode : Bool?
    
    @IBOutlet weak var sinButton: UIButton!
    @IBOutlet weak var cosButton: UIButton!
    @IBOutlet weak var tanButton: UIButton!
    
    // Computed property - just simply a different way of interacting with the var "display"
    private var displayValue : Double {
        get{
            return Double(display.text!)!
        }

        set{
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 6
            display.text = formatter.string(from: NSNumber(value:newValue)) ?? "Not a Number"
        }
    }
    
    @IBAction func clearCalc(_ sender: UIButton) {
        model.clearModel()
        displayValue = 0
        currentEquation.text = "Ready for Input"
        
        let inSecondMode = secondMode ?? false
        if inSecondMode {
            secondOp(sender)
            secondMode = false
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
                    displayValue = 0
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
    
    /// When an operation button is pressed, send operands and operations to the model.  Update display and currentEquation from model results
    @IBAction func performOperation(_ sender: UIButton) {
        
        if userIsTyping{
            model.setOperand(displayValue)
            userIsTyping = false
        }
        
        if let calcOperator = sender.currentTitle {
            model.performOperation(calcOperator)
        }
        
        displayValue = model.result ?? 0    // for nil model results, default display to 0

        assert(model.equation != nil, "Error model.equation = nil in performOperation")
        if (model.resultIsPending) {
            currentEquation.text = model.equation! + " ..."
        } else {
            currentEquation.text = model.equation! + " ="
        }
    }

    /// redefine key operations based on secondMode.
    /// e.g. Switch between sin, cos, tan; and asin, acos, atan
    @IBAction func secondOp(_ sender: Any) {
    
        let inSecondMode = secondMode ?? false

        if inSecondMode {
            sinButton.setTitle("sin", for: .normal)
            cosButton.setTitle("cos", for: .normal)
            tanButton.setTitle("tan", for: .normal)
            secondMode = false
        } else {
            sinButton.setTitle("sin⁻¹", for: .normal)
            cosButton.setTitle("cos⁻¹", for: .normal)
            tanButton.setTitle("tan⁻¹", for: .normal)
            secondMode = true
        }
    }
}

