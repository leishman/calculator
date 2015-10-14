//
//  ViewController.swift
//  calculator_leishman
//
//  Created by Alexander Leishman on 9/23/15.
//  Copyright © 2015 Alexander Leishman. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    

    @IBOutlet weak var numericDisplay: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pendingLabel: UILabel!

    var userInMiddleOfNumber = false
    
    
    // getter and setter for value in main calculator display (label element)
    var displayValue: Double {
        get {
            return Double(numericDisplay.text!)!
        }
        
        set {
            // setting value here each time is inefficient but
            // I didn't want to add an initializer to this class because I don't understand initializer intricacies well enough just yet
            numberFormatter.maximumFractionDigits = 6
            numberFormatter.minimumIntegerDigits = 1
            return numericDisplay.text = numberFormatter.stringFromNumber(newValue)
        }
    }
    
    var numberFormatter = NSNumberFormatter()


    // Event handler for touching a digit or a decimal point button
    @IBAction func touchButton(sender: UIButton) {
        let digit = sender.currentTitle!
        if userInMiddleOfNumber {
            let currentText = numericDisplay.text!
            
            // prevent multiple decimal points from being entered
            if (digit == "." && currentText.rangeOfString(".") != nil) {
                return
            }

            numericDisplay.text = currentText + digit
        } else {
            numericDisplay.text = digit
        }
        userInMiddleOfNumber = true
    }

    // initialize brain for calculator to maintain state and perform arithmetic logic
    // class found in ./CalculatorBrain.swift
    var brain = CalculatorBrain()
    
    // Event handler that executes when touching an operation button
    @IBAction func performOperation(sender: UIButton) {
        
        // if user has entered digits before pressing operation button, send the operation to the brain
        // and set userInMiddleOfNumber to false
        if userInMiddleOfNumber {
            brain.setOperand(displayValue)
            userInMiddleOfNumber = false
        }

        if let mathSymbol = sender.currentTitle {
            brain.performOperation(mathSymbol)
        }

        rerender()
    }

    // Event handler for clear press
    @IBAction func clearButton(sender: UIButton) {
        displayValue = 0.0
        brain.clearState()
        brain.clearVariables()
        userInMiddleOfNumber = false
        rerender()
    }
    
    // Event handler for undo button press
    @IBAction func undoButton(sender: UIButton) {
        let text = numericDisplay.text!

        if userInMiddleOfNumber {
            if text.characters.count <= 1 {
                displayValue = 0.0
                userInMiddleOfNumber = false
            } else {
                numericDisplay.text! = text.substringToIndex(text.endIndex.predecessor())
            }
        } else {
            brain.undo()
            rerender()
        }

    }

    @IBAction func setVariable(sender: UIButton) {
        brain.setVariable("M", value: displayValue)
        rerender()
        userInMiddleOfNumber = false
    }
    
    @IBAction func variableEntered(sender: UIButton) {
        brain.setOperand(sender.currentTitle!)
        rerender()
        userInMiddleOfNumber = false
    }
    
    private func rerender() {
        displayValue = brain.result
        descriptionLabel.text = brain.description
        pendingLabel.text = brain.isPartialResult ? " ... " : "  = "
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destinationvc: UIViewController? = segue.destinationViewController
        if let navcon = destinationvc as? UINavigationController {
            destinationvc = navcon.visibleViewController
        }
        if let graphvc = destinationvc as? GraphViewController {
            // set equation description
            graphvc.equationString = brain.description
                
            // pass closure to GraphViewController
            graphvc.graphFunction = {(num: Double) -> Double in
                self.brain.setVariable("M", value: num)
                return self.brain.result
            }

        }
    }
    
}

