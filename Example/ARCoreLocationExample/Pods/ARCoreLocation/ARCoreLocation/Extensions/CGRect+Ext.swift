//
//  CGRect+Ext.swift
//  ARCoreLocation
//
//  Created by Skyler Smith on 2018-09-21.
//  Copyright © 2018 Skyler Smith. All rights reserved.
//

import CoreGraphics

extension CGRect {
    var minXminY: CGPoint {
        return CGPoint(x: minX, y: minY)
    }
    
    var maxXminY: CGPoint {
        return CGPoint(x: maxX, y: minY)
    }
    
    var minXmaxY: CGPoint {
        return CGPoint(x: minX, y: maxY)
    }
    
    var maxXmaxY: CGPoint {
        return CGPoint(x: maxX, y: maxY)
    }
}
