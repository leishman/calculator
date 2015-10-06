//
//  CalculatorBrain.swift
//  calculator_leishman
//
//  Created by Alexander Leishman on 9/23/15.
//  Copyright © 2015 Alexander Leishman. All rights reserved.
//

import Foundation

class CalculatorBrain {
    ////////////////////////
    // Property Declarations
    ////////////////////////

    var result: Double {
        get {
            return accumulator
        }
    }

    private var pending: PendingBinaryOperationInfo?
    private var accumulator = 0.0
    
    // String describing calculations before any pending binary operator
    private var firstOperandString = " "

    // String describing calculations after a pending binary operator
    // this is necssary for displaying the proper description in situations like: "5+5√√√" This will result in a description 5 + √(√(√(5)))"
    // the additional square roots will only get added to the part of the description after the pending '+' operator
    private var secondOperandString = " "
    
    // description is the concatenation of two separate strings, shown above the caluclator display
    var description: String {
        get {
            return firstOperandString + secondOperandString
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    // string value of accumulator
    private var accumulatorString: String {
        get {
            return numberFormatter.stringFromNumber(accumulator)!
        }
    }
    
    // Number formatter
    var numberFormatter = NSNumberFormatter()

    
    // Struct to store state of any pending operation
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var secondOperandString: String // contains string describing second operand (which could be the result of multiple unary operations (e.g. 5 + cos(cos(tan(5))))
    }
    
    private var operations: Dictionary<String, Operation> = [
        // Constants
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        
        // Unary Operators
        "±": Operation.Unary({-$0}),
        "sin": Operation.Unary({sin($0)}),
        "cos": Operation.Unary({cos($0)}),
        "tan": Operation.Unary({tan($0)}),
        "√": Operation.Unary({sqrt($0)}),
        "∛": Operation.Unary({pow($0, 1.0/3)}),
        "x²": Operation.Unary({pow($0, 2.0)}),
        "x³": Operation.Unary({pow($0, 3.0)}),
        
        // Binary Operators
        "+": Operation.Binary({$0 + $1}),
        "-": Operation.Binary({$0 - $1}),
        "×": Operation.Binary({$0 * $1}),
        "÷": Operation.Binary({$0 / $1}),
        
        // Random
        "rand": Operation.Random,
        
        // Equals
        "=": Operation.Equals,
    ]
    
    private enum Operation {
        case Constant(Double)
        case Unary(Double -> Double)
        case Binary((Double, Double) -> Double)
        case Random
        case Equals
    }
    

    private var internalProgram =  [AnyObject]()
    typealias PropertyList = AnyObject
    
    // program of calculator containing sequence of operators and operands (stored as array)
    // setter will loop through program and revaluate
    var program: PropertyList {
        get {
            return internalProgram
        }
        
        set {
            clearState()
            if let arrayOfOps = newValue as? [AnyObject]{
                // loop through and execute program
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation  = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    
    // declare dictionary to store variables and their values
    var variableNames: [String:Double] = [:]
    
    
    /////////////////////////////////
    // Class initializer
    //////////////////////////////
    init() {
        // settings for number formatter
        numberFormatter.maximumFractionDigits = 6
    }
    
    //////////////////////////////
    // Internal Method Definitions
    ///////////////////////////////
    
    func performOperation(op: String) {
        
        internalProgram.append(op)
        if let operation = operations[op] {
            switch operation {
            case .Constant(let value):
                handleConstantOperation(op, value: value)
            case .Unary(let function):
                handleUnaryOperation(op, function: function)
            case .Binary(let function):
                handleBinaryOperation(op, function: function)
            case .Random:
                handleRandomOperation()
            case .Equals:
                handleEqualOperation()
            }
            // No default needed because cases are exhaustive here
        } else {
            
            handleConstantOperation(op, value: variableNames[op] ?? 0.0)
        }
    }
    
    // called when user presses a numeric button
    func setOperand(number: Double) {
        internalProgram.append(number)
        accumulator = number
        if pending == nil {
            firstOperandString = accumulatorString
        } else {
            secondOperandString = accumulatorString
        }
    }

    // overload setOperand method by allowing string input for variables
    func setOperand(variableName: String) {
        performOperation(variableName)
    }
    
    func setVariable(name: String, value: Double) {
        variableNames[name] = value
        program = internalProgram
        
    }
    
    
    // called when a user presses the C button
    func clearState() {
        internalProgram.removeAll()
        accumulator = 0.0
        pending = nil
        firstOperandString = " "
        secondOperandString = " "
    }
    
    func clearVariables() {
        variableNames.removeAll()
    }
    
    func undo() {
        
        if internalProgram.count > 0 {
            internalProgram.removeLast()
        }
        program = internalProgram
    }
    
    
    /////////////////////////////
    // Private Method Definitions
    //////////////////////////////
    
    
    // Handle constant operation
    // Special case here is that the user presses a constant after
    private func handleConstantOperation(op: String, value: Double) {
        accumulator = value
        if !isPartialResult {
            firstOperandString = " " + op
            secondOperandString = " "
        } else {
            secondOperandString = " " + op
        }
    }
    
    // Handle a Unary operation
    private func handleUnaryOperation(op: String, function: Double -> Double) {
        if !isPartialResult {
            if description == "  " {
                firstOperandString = "\(op)(\(accumulatorString))"
            } else {
                firstOperandString = "\(op)(\(description))"
            }
            secondOperandString = " " // maybe not necessary
        } else {
            if secondOperandString == " " {
                secondOperandString = "\(op)(\(accumulatorString))"
            } else {
                secondOperandString = "\(op)(\(secondOperandString))"
            }
        }
        accumulator = function(accumulator)
    }
    
    // Handle binary operation
    private func handleBinaryOperation(op: String, function: (Double, Double) -> Double) {
        
         if isPartialResult {
            firstOperandString += " \(accumulatorString) \(op) "
            secondOperandString = " "
         } else {
            firstOperandString += "\(secondOperandString) \(op) "
        }
        
        executePendingBinaryOperation()
        pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator, secondOperandString: "")
    }
    
    // Generate a random decimal value between 0 and 1 and display in firstOperandString or secondOperandString
    private func handleRandomOperation() {
        let randValue = Double(arc4random()) / Double(UINT32_MAX)
        accumulator = randValue
        if !isPartialResult {
            firstOperandString = " \(accumulatorString)"
            secondOperandString = " "
        } else {
            secondOperandString = " \(accumulatorString)"
        }
    }
    
    // Handle Equal "operation"
    private func handleEqualOperation() {
        
        if isPartialResult && secondOperandString == " " {
            secondOperandString = accumulatorString
        }
        executePendingBinaryOperation()
    }
    
    private func executePendingBinaryOperation() {
        if isPartialResult {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
}