//
//  ViewController.swift
//  Calculator
//
//  Created by Barry Bryant on 3/25/17.
//  Copyright © 2017 b3sk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel! // yes its an optional, but I will auto unwrap everyplace.
    var userIsTyping = false

    var displayValue : Double {
        get{
            return Double(display.text!)!
        }
        
        set{
            display.text = String(newValue)
        }
    }

    private var model = CalculatorModel()
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsTyping {
            let textCurrentlyInDisplay = display.text!
            if (digit == "." && textCurrentlyInDisplay.contains("."))
            {
                return  // don't add two decimal places - make an error sound
            }
            display.text = textCurrentlyInDisplay + digit
            
        } else {
            userIsTyping = true
            display.text = digit
        }
        
    }
    
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
    
//    @IBAction func setBinaryOperation(_ sender: UIButton) {
//        if userIsTyping{
//        //    model.setBinaryOperation(sender.currentTitle)
//            model.setOperand(displayValue)
//            userIsTyping = false
//        }
//        
//    }
    
}

