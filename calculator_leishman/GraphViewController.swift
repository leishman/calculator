//
//  GraphViewController.swift
//  calculator_leishman
//
//  Created by Alexander Leishman on 10/13/15.
//  Copyright © 2015 Alexander Leishman. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    @IBOutlet weak var equationDescription: UILabel!
    
    var graphFunction: (Double -> Double)?
    var equationString: String = " "
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "handleZoom:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "handlePan:"))

            // declare recognizer outside of argument in order to set required number of taps
            // not sure if this is the best way to do this, but I did not like dragging the touch event onto UI builder
            // I prefer keeping this logic in the same place
            let doubleTapRecognizer = UITapGestureRecognizer(target: graphView, action: "handleDoubleTap:")
            doubleTapRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doubleTapRecognizer)
            
            if graphFunction != nil {
                graphView.graphFunction = graphFunction!
            }
            
            equationDescription.text! = equationString
            
            
        }
    }
}


    