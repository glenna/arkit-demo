//
//  UIBezierPath+Extension.swift
//  ARAlbertDemo3D
//
//  Created by Glenna L Buford on 10/12/17.
//  Copyright © 2017 Glenna L Buford. All rights reserved.
//

import UIKit

extension UIBezierPath {
    convenience init(withPoints points: [CGPoint]) {
        self.init()
        
        self.lineWidth = 2.0
        self.move(to: points[0])
        let otherPoints = points.suffix(points.count - 1)
        
        for point in otherPoints {
            self.addLine(to: point)
        }
        
        self.close()
    }
}
