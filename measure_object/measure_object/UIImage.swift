//
//  UIImage.swift
//  measure_object
//
//  Created by Ju Young Kim on 2017. 1. 15..
//  Copyright © 2017년 Ju Young Kim. All rights reserved.
//

import UIKit

extension UIImage{
    func addOverlay(dist: String, width: String, height: String, startPoint: CGPoint) -> UIImage{
        let textColor = UIColor.black
        let textFont = UIFont(name: "Helvetica Bold", size: 60)!
        
        let text = "Distance to object: " + dist + "\n\n" + "Height: " + height + "\n\n" + "Width: " + width
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(self.size, false, scale)
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            NSStrokeColorAttributeName: UIColor.white,
            NSStrokeWidthAttributeName : NSNumber(floatLiteral: -4.0)
            ] as [String : Any]
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
        
        let rect = CGRect(origin: startPoint, size: self.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
