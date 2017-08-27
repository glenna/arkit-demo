//
//  BoxyNode.swift
//  ARAlbertDemo3D
//
//  Created by Glenna L Buford on 8/24/17.
//  Copyright © 2017 Glenna L Buford. All rights reserved.
//

import Foundation
import SceneKit

class BoxyNode: SCNNode {
    
    override init() {
        super.init()
        
        let cube = createBox()
        self.geometry = cube;
        
        let physics = SCNPhysicsBody(type:.static, shape: SCNPhysicsShape(geometry: cube, options: nil))
        physics.mass = 0.01
        physics.categoryBitMask = 1
        
        self.physicsBody = physics
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func createBox() -> SCNBox {
        let dimension:CGFloat = 0.2
        let cube = SCNBox(width: dimension, height: dimension, length: dimension, chamferRadius: 0)
        cube.firstMaterial?.diffuse.contents = UIColor.purple
        cube.firstMaterial?.isDoubleSided = true
        return cube
    }
    
}
