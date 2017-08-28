//
//  ViewController.swift
//  ARAlbertDemo3D
//
//  Created by Glenna L Buford on 7/2/17.
//  Copyright © 2017 Glenna L Buford. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
                
        //show the feature points
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        if let planeNode = node as? PlaneNode {
            planeNode.update(withAnchor: planeAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return nil }
        return PlaneNode(withAnchor: planeAnchor)
    }
    
    // TODO: I don't know if i want to keep this here
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        print("removed anchor \(anchor.identifier)")
    }
    
    // MARK: - Actions
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: sceneView)
        let results = sceneView.hitTest(tapPoint, types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
        
        if let arhitresult = results.first {
            addABox(at: arhitresult)
        }
    }
    
    // MARK: more ARSCNViewDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("session didFailWithError \(session)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        print("session interrupted \(session)")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        print("session ended \(session)")
    }
    
    func addABox(at hitPoint: ARHitTestResult) {
        let cubeNode = BoxyNode()
        cubeNode.position = positionFromHitTestResult(hitPoint)

        sceneView.scene.rootNode.addChildNode(cubeNode)
        
        let anchor = ARAnchor(transform: hitPoint.worldTransform)
        sceneView.session.add(anchor: anchor)
        boxes.append(cubeNode)
    }
    
    func positionFromHitTestResult(_ hitPoint: ARHitTestResult) -> SCNVector3 {
        let yOffset = Float(0.5)
        return SCNVector3Make(hitPoint.worldTransform.columns.3.x,
                              hitPoint.worldTransform.columns.3.y + yOffset,
                              hitPoint.worldTransform.columns.3.z)
    }
    
    
    // MARK: - More Actions
    
    @IBAction func onRefreshPressed(_ sender: UIButton) {
        let sessionConfig = ARWorldTrackingConfiguration()
        if planeDetectionSwitch.isOn {
            sessionConfig.planeDetection = .horizontal
        }
        sceneView.session.run(sessionConfig, options: [.resetTracking, .removeExistingAnchors])
        planes.removeAll()
        boxes.removeAll()
    }
    
    @IBAction func onPlaneDetectionSwitchChanged(_ sender: UISwitch) {
        //stop/start plane detection
        let sessionConfig = ARWorldTrackingConfiguration()
        if sender.isOn {
            sessionConfig.planeDetection = .horizontal
        }
        
        sceneView.session.run(sessionConfig, options: [])
    }
    
    @IBAction func onFeaturePointSwitchChanged(_ sender: UISwitch) {
        
        if sender.isOn {
            sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        } else {
            sceneView.debugOptions = []
        }
    }
    
    @IBOutlet weak var planeDetectionSwitch: UISwitch!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var featurePointSwitch: UISwitch!
    var planes = Dictionary<UUID, PlaneNode>() {
        didSet {
            print("number of planes \(planes.count)")
        }
    }
    var boxes = Array<SCNNode>() {
        didSet {
            print("number of boxes \(boxes.count)")
        }
    }
}
