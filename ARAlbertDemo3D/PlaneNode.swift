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
    
    init(withAnchor anchor: ARPlaneAnchor) {
        super.init()
        
        plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = #imageLiteral(resourceName: "hardwood")
        floorMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(anchor.extent.x, anchor.extent.z, 1)
        floorMaterial.diffuse.wrapT = .repeat
        floorMaterial.diffuse.wrapS = .repeat
        plane.materials = [floorMaterial]
        
        childPlaneNode = SCNNode(geometry: plane)
        childPlaneNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        childPlaneNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        addChildNode(childPlaneNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func update(withAnchor anchor: ARPlaneAnchor) {
        plane.width = CGFloat(anchor.extent.x)
        plane.height = CGFloat(anchor.extent.z)
        if let floorMaterial = plane.firstMaterial {
            floorMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(anchor.extent.x,anchor.extent.z, 1)
            floorMaterial.diffuse.wrapT = .repeat
            floorMaterial.diffuse.wrapS = .repeat
        }
        
        let physics = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: plane, options: nil))
        childPlaneNode.physicsBody = physics
        childPlaneNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    }
}
