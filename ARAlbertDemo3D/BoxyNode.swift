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
        
        let cube: SCNBox = createBox()
        geometry = cube;
        
        let physics: SCNPhysicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: cube, options: nil))
        physics.mass = 0.02
        physics.categoryBitMask = 1
        
        physicsBody = physics
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func createBox() -> SCNBox {
        let dimension: CGFloat = CGFloat(Float.random(in: 0.2...0.25))
        let cube: SCNBox = SCNBox(width: dimension, height: dimension, length: dimension, chamferRadius: 0.01)
        
        let material: SCNMaterial = SCNMaterial()
        material.diffuse.contents = UIImage(named: "wrapping_paper_\(Int.random(in: 1...3))")!
        
        cube.materials = [material]
        
        return cube
    }
    
}
