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
import Vision

class DemoARViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet weak var faceObservationSwitch: UISwitch!
    @IBOutlet weak var planeDetectionSwitch: UISwitch!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var featurePointSwitch: UISwitch!
    
    
    var boxes = Array<SCNNode>() {
        didSet {
            print("number of boxes \(boxes.count)")
        }
    }
    private let visionSequenceHandler = VNSequenceRequestHandler()
    private var lastObservation : VNFaceObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        self.sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        self.sceneView.showsStatistics = true
                
        //show the feature points
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        //vision framework is upside down
        self.sceneView.layer.sublayerTransform = CATransform3DMakeScale(1.0, -1.0, 1.0);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        self.sceneView.session.run(configuration)
        self.sceneView.session.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        self.sceneView.session.pause()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return nil }
        return PlaneNode(withAnchor: planeAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard
            let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = node as? PlaneNode
        else { return }

        planeNode.update(withAnchor: planeAnchor)
    }
    
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
    
    // MARK: ARSessionDelegate
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if !self.faceObservationSwitch.isOn {
            //don't overload ourselves here
            return
        }
        let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: self.handleVisionRequestUpdate)

        do {
            try self.visionSequenceHandler.perform([faceLandmarksRequest], on: frame.capturedImage, orientation: CGImagePropertyOrientation.right)
        } catch {
            print("Throws: \(error)")
        }
    }
    
    private func handleVisionRequestUpdate(_ request: VNRequest, error: Error?) {
        if let err = error {
            print("error: \(err)")
        }
        
        if let results = request.results as? [VNFaceObservation] {
            print(results)
            guard
                let faceObservation = results.first,
                let faceLandmarks = faceObservation.landmarks
            else { print("no landmarks"); return }
            
            self.lastObservation = results.first
            self.sceneView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            if let nose = faceLandmarks.nose {
                let nosePoints = nose.pointsInImage(imageSize: self.sceneView.bounds.size)
                
                self.drawOnImage(withPoints: nosePoints)
            }
            
            if let rightEye = faceLandmarks.rightEye {
                let rightEyePoints = rightEye.pointsInImage(imageSize: self.sceneView.bounds.size)
                
                self.drawOnImage(withPoints: rightEyePoints)
            }
            
            if let leftEye = faceLandmarks.leftEye {
                let leftEyePoints = leftEye.pointsInImage(imageSize: self.sceneView.bounds.size)
                
                self.drawOnImage(withPoints: leftEyePoints)
            }
            
            if let rightEyebrow = faceLandmarks.rightEyebrow {
                let rightEyebrowPoints = rightEyebrow.pointsInImage(imageSize: self.sceneView.bounds.size)
                
                self.drawOnImage(withPoints: rightEyebrowPoints)
            }
            
            if let leftEyebrow = faceLandmarks.leftEyebrow {
                let leftEyebrowPoints = leftEyebrow.pointsInImage(imageSize: self.sceneView.bounds.size)
                
                self.drawOnImage(withPoints: leftEyebrowPoints)
            }
            
            if let outerLips = faceLandmarks.outerLips {
                let outerLipsPoints = outerLips.pointsInImage(imageSize: self.sceneView.bounds.size)
                
                self.drawOnImage(withPoints: outerLipsPoints)
            }
        }
    }
    
    // MARK: Helpers
    func addABox(at hitPoint: ARHitTestResult) {
        let cubeNode = BoxyNode()
        cubeNode.position = positionFromHitTestResult(hitPoint)

        self.sceneView.scene.rootNode.addChildNode(cubeNode)
        
        let anchor = ARAnchor(transform: hitPoint.worldTransform)
        self.sceneView.session.add(anchor: anchor)
        self.boxes.append(cubeNode)
    }
    
    func positionFromHitTestResult(_ hitPoint: ARHitTestResult) -> SCNVector3 {
        let yOffset: Float = 0.5
        return SCNVector3Make(hitPoint.worldTransform.columns.3.x,
                              hitPoint.worldTransform.columns.3.y + yOffset,
                              hitPoint.worldTransform.columns.3.z)
    }
    
    func drawOnImage(withPoints points: [CGPoint]) {
        
        let bezierPath = UIBezierPath.init(withPoints: points)
        
        let bezierPathLayer = CAShapeLayer()
        bezierPathLayer.strokeColor = UIColor.red.cgColor
        bezierPathLayer.fillColor = UIColor.red.cgColor
        bezierPathLayer.lineWidth = 5.0
        
        bezierPathLayer.path = bezierPath.cgPath
        
        self.sceneView.layer.addSublayer(bezierPathLayer)
    }
    
    // MARK: - Actions
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: sceneView)
        let results = sceneView.hitTest(tapPoint, types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
        
        if let arhitresult = results.first {
            addABox(at: arhitresult)
        }
    }
    
    @IBAction func onRefreshPressed(_ sender: UIButton) {
        let sessionConfig = ARWorldTrackingConfiguration()
        if planeDetectionSwitch.isOn {
            sessionConfig.planeDetection = .horizontal
        }
        self.sceneView.session.run(sessionConfig, options: [.resetTracking, .removeExistingAnchors])
        self.boxes.removeAll()
    }
    
    @IBAction func onPlaneDetectionSwitchChanged(_ sender: UISwitch) {
        //stop/start plane detection
        let sessionConfig = ARWorldTrackingConfiguration()
        if sender.isOn {
            sessionConfig.planeDetection = .horizontal
        }
        
        self.sceneView.session.run(sessionConfig, options: [])
    }
    
    @IBAction func onFeaturePointSwitchChanged(_ sender: UISwitch) {
        
        if sender.isOn {
            self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        } else {
            self.sceneView.debugOptions = []
        }
    }
    
    @IBAction func onFaceDetectPressed(_ sender: Any) {
        if !self.faceObservationSwitch.isOn {
            self.sceneView.layer.sublayers?.removeAll()
            return
        }
        
        guard let currentFrameImage = self.sceneView.session.currentFrame?.capturedImage else {
            print("something went wrong here")
            return
        }
        
        let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: self.handleVisionRequestUpdate)
        
        do {
            try self.visionSequenceHandler.perform([faceLandmarksRequest], on: currentFrameImage, orientation: CGImagePropertyOrientation.right)
        } catch {
            print("Throws: \(error)")
        }
    }
}
