//
//  GraphViewController.swift
//  calculator_leishman
//
//  Created by Alexander Leishman on 10/13/15.
//  Copyright © 2015 Alexander Leishman. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    var program: AnyObject = []

    
    
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "handleZoom:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "handlePan:"))
            graphView.addGestureRecognizer(UITapGestureRecognizer(target: graphView, action: "handleDoubleTap:"))
        }
    }

}


//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    