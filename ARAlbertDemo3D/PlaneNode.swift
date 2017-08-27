//
//  Plane.swift
//  ARAlbertDemo3D
//
//  Created by Glenna L Buford on 8/23/17.
//  Copyright © 2017 Glenna L Buford. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class PlaneNode : SCNNode {
    
    var plane: SCNPlane!
    var childPlaneNode: SCNNode!
    
    public init(withAnchor anchor: ARPlaneAnchor) {
        super.init()
        
        self.plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        self.plane.firstMaterial?.diffuse.contents = UIColor.gray
        
        self.childPlaneNode = SCNNode(geometry:self.plane)
        self.childPlaneNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        self.childPlaneNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        self.addChildNode(self.childPlaneNode)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
        //don't do it!
    }
    
    public func update(withAnchor anchor: ARPlaneAnchor) {
        self.plane.width = CGFloat(anchor.extent.x)
        self.plane.height = CGFloat(anchor.extent.z)
        let physics = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: self.plane, options: nil))
        self.childPlaneNode.physicsBody = physics
        self.childPlaneNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    }
}
