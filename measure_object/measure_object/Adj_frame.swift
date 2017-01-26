//
//  Width_frame.swift
//  measure_object
//
//  Created by Ju Young Kim on 2017. 1. 9..
//  Copyright © 2017년 Ju Young Kim. All rights reserved.
//

import Foundation
import UIKit

class Adj_frame: UIView {
    
    var isResizingLR:Bool = false
    var isResizingUL:Bool = false
    var isResizingUR:Bool = false
    var isResizingLL:Bool = false
    var firstTouchPos:CGPoint? = nil
    var kResizeThumbSize:CGFloat = 45.0
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        firstTouchPos = touch?.location(in: self)
        isResizingLR = (self.bounds.size.width - (firstTouchPos?.x)! < kResizeThumbSize && self.bounds.size.height - (firstTouchPos?.y)! < kResizeThumbSize)
        isResizingUL = ((firstTouchPos?.x)! < kResizeThumbSize && (firstTouchPos?.y)! < kResizeThumbSize)
        isResizingUR = (self.bounds.size.width - (firstTouchPos?.x)! < kResizeThumbSize && (firstTouchPos?.y)! < kResizeThumbSize)
        isResizingLL = ((firstTouchPos?.x)! < kResizeThumbSize && self.bounds.size.height - (firstTouchPos?.y)! < kResizeThumbSize)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        var touchPoint = touch?.location(in: self)
        var previous = touch?.previousLocation(in: self)
        
        var widthChange = (touchPoint?.x)! - (previous?.x)!
        var heightChange = (touchPoint?.y)! - (previous?.y)!
        
        var x = self.frame.origin.x
        var y = self.frame.origin.y
        var width = self.frame.size.width
        var height = self.frame.size.height
        
        if(isResizingLR){
            self.frame = CGRect(x: x, y: y, width: (touchPoint?.x)! + widthChange, height: (touchPoint?.y)! + widthChange)
        }else if(isResizingUL){
            self.frame = CGRect(x: x + widthChange, y: y + heightChange, width: width - widthChange, height: height - heightChange)
        }else if(isResizingUR){
            self.frame = CGRect(x: x, y: y + heightChange, width: width + widthChange, height: height - heightChange)
        }else if(isResizingLL){
            self.frame = CGRect(x: x + widthChange, y: y, width: width - widthChange, height: height + heightChange)
        }else{
            self.center = CGPoint(x: self.center.x + (touchPoint?.x)! - (firstTouchPos?.x)!, y: self.center.y + (touchPoint?.y)! - (firstTouchPos?.y)!)
        }
    }
}
