//
//  GraphView.swift
//  calculator_leishman
//
//  Created by Alexander Leishman on 10/13/15.
//  Copyright © 2015 Alexander Leishman. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    
    //////////////////////
    // Public Properties
    //////////////////////

    // Generic function mapping x to y (f(x)).
    var graphFunction: (Double -> Double)?
    
    /////////////////////
    // Private Properties
    //////////////////////
    
    private let axesDrawer = AxesDrawer()

    @IBInspectable
    private var scale: CGFloat = 1 {
        didSet {
            axesDrawer.contentScaleFactor = contentScaleFactor
            setNeedsDisplay()
            pointsPerUnit = scale * 20
        }
    }
    
    @IBInspectable
    private var pointsPerUnit: CGFloat = 20
    
    // todo, move these into a single data structure for more robust didSet behavior
    private var yTranslation: CGFloat = 0
    private var xTranslation: CGFloat = 0 { didSet { setNeedsDisplay() } }
    
    private var origin: CGPoint {
        return CGPoint(x: bounds.midX + xTranslation, y: bounds.midY + yTranslation)
    }
    
    
    /////////////
    // Draw Rect
    /////////////
    
    override func drawRect(rect: CGRect) {
        axesDrawer.drawAxesInRect(bounds, origin: origin, pointsPerUnit: pointsPerUnit)
        drawGraph()
    }
    
    ///////////////////
    // Event Handlers
    ///////////////////
    
    func handleZoom(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .Changed || recognizer.state == .Ended {
            scale *= recognizer.scale
            recognizer.scale = 1.0
        }
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .Changed || recognizer.state == .Ended {
            let translation = recognizer.translationInView(self)
            yTranslation += translation.y
            xTranslation += translation.x
            recognizer.setTranslation(CGPointZero, inView: self)
        }
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .Ended {
            let location = recognizer.locationInView(self)
            xTranslation = location.x - bounds.midX
            yTranslation = location.y - bounds.midY
        }
    }
    
    
    //////////////////////
    // Private Functions
    /////////////////////
    
    
    // draw f(x)
    private func drawGraph() {
        
        // return if there is no graphFunction
        if graphFunction == nil {
            return
        }
        
        // define path for f(x)
        let path = UIBezierPath()
        
        // set initial point of path
        path.moveToPoint(CGPoint(x:CGFloat(0), y: calculateYDisp(CGFloat(0))))
        
        // iterate through all pixel values (xDisp) to get yDisp and draw line from previous point to new point
        for i in 1...Int(bounds.maxX) {
            let xDisp = CGFloat(i)
            let yDisp = calculateYDisp(xDisp)
            path.addLineToPoint(CGPoint(x: xDisp, y: yDisp))
        }
        path.lineWidth = 3.0
        path.stroke()
    }
    
    // calculate Pixel value of f(x)
    private func calculateYDisp(xDisp: CGFloat) -> CGFloat {
        let xReal = (xDisp - origin.x) / pointsPerUnit
        let yReal = graphFunction!(Double(xReal))
        if !yReal.isNormal {
            return CGFloat(0)
        }
        return -CGFloat(yReal) * pointsPerUnit + origin.y
    }
}
