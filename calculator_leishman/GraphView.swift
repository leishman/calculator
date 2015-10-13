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
    
    var axesDrawer = AxesDrawer()

    @IBInspectable
    var scale: CGFloat = 1 {
        didSet {
            axesDrawer.contentScaleFactor = contentScaleFactor
            setNeedsDisplay()
            pointsPerUnit = scale * 20
        }
    }
    
    @IBInspectable
    var pointsPerUnit: CGFloat = 20
    
    // todo, move these into a single data structure for more robust didSet behavior
    var yTranslation: CGFloat = 0
    var xTranslation: CGFloat = 0 { didSet { setNeedsDisplay() } }
    
    var origin: CGPoint {
        return CGPoint(x: bounds.midX + xTranslation, y: bounds.midY + yTranslation)
    }
    
    override func drawRect(rect: CGRect) {
        print("draw Rect")
        axesDrawer.drawAxesInRect(bounds, origin: origin, pointsPerUnit: pointsPerUnit)
    }

    
    // Event Handlers
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
        recognizer.numberOfTapsRequired = 2
        if recognizer.state == .Ended {
            let location = recognizer.locationInView(self)
            xTranslation = location.x - bounds.midX
            yTranslation = location.y - bounds.midY
        }
    }
}
