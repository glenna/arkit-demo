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
    private let planeDetectionSwitch: UISwitch = {
        let planeSwitch: UISwitch = UISwitch()
        planeSwitch.addTarget(self, action: #selector(onPlaneDetectionSwitchChanged(_:)), for: UIControl.Event.valueChanged)
        planeSwitch.isOn = true
        return planeSwitch
    }()
    private let sceneView: ARSCNView = ARSCNView()
    private var boxes = Array<SCNNode>() {
        didSet {
            print("number of boxes \(boxes.count)")
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // show the feature points
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder:) not implemented")
    }
    
    func setupViews() {
        let planeDetectionSwitchStackView: UIStackView = UIStackView()
        planeDetectionSwitchStackView.axis = .vertical
        planeDetectionSwitchStackView.alignment = .center
        planeDetectionSwitchStackView.spacing = 4.0
        
        let planeDetectionLabel: UILabel = UILabel()
        planeDetectionLabel.text = "Plane Detection"
        
        planeDetectionSwitchStackView.addArrangedSubview(planeDetectionSwitch)
        planeDetectionSwitchStackView.addArrangedSubview(planeDetectionLabel)
        
        let featurePointSwitchStackView: UIStackView = UIStackView()
        featurePointSwitchStackView.axis = .vertical
        featurePointSwitchStackView.alignment = .center
        featurePointSwitchStackView.spacing = 4.0
        
        let featurePointSwitch: UISwitch = UISwitch()
        featurePointSwitch.addTarget(self, action: #selector(onFeaturePointSwitchChanged(_:)), for: UIControl.Event.valueChanged)
        featurePointSwitch.isOn = true
        
        let featurePointLabel: UILabel = UILabel()
        featurePointLabel.text = "Feature Point"
        
        featurePointSwitchStackView.addArrangedSubview(featurePointSwitch)
        featurePointSwitchStackView.addArrangedSubview(featurePointLabel)
        
        let refreshButton: UIButton = UIButton(type: .custom)
        refreshButton.setTitle("Refresh", for: .normal)
        refreshButton.addTarget(self, action: #selector(onRefreshPressed(_:)), for: .touchUpInside)
        
        let controlStackView: UIStackView = UIStackView(arrangedSubviews: [planeDetectionSwitchStackView,
                                                                           featurePointSwitchStackView,
                                                                           refreshButton])
        controlStackView.axis = .horizontal
        controlStackView.alignment = .center
        controlStackView.distribution = .fillEqually
        controlStackView.spacing = 5.0
        controlStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlStackView)
        
        sceneView.backgroundColor = UIColor.lightGray
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sceneView)
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                                  action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)

        
        view.backgroundColor = UIColor.darkGray
        
        NSLayoutConstraint.activate([
            controlStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            controlStackView.rightAnchor.constraint(equalTo: view.rightAnchor),
            controlStackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            sceneView.topAnchor.constraint(equalTo: controlStackView.bottomAnchor),
            sceneView.rightAnchor.constraint(equalTo: view.rightAnchor),
            sceneView.leftAnchor.constraint(equalTo: view.leftAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration: ARWorldTrackingConfiguration = ARWorldTrackingConfiguration()
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
        guard
            let planeAnchor: ARPlaneAnchor = anchor as? ARPlaneAnchor,
            let planeNode: PlaneNode = node as? PlaneNode
        else { return }

        planeNode.update(withAnchor: planeAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let planeAnchor: ARPlaneAnchor = anchor as? ARPlaneAnchor else { return nil }
        return PlaneNode(withAnchor: planeAnchor)
    }
    
    // MARK: - Actions
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        let tapPoint: CGPoint = sender.location(in: sceneView)
        let results: [ARHitTestResult] = sceneView.hitTest(tapPoint, types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
        
        if let arhitresult: ARHitTestResult = results.first {
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
        let cubeNode: BoxyNode = BoxyNode()
        cubeNode.position = positionFromHitTestResult(hitPoint)

        sceneView.scene.rootNode.addChildNode(cubeNode)
        
        let anchor: ARAnchor = ARAnchor(transform: hitPoint.worldTransform)
        sceneView.session.add(anchor: anchor)
        boxes.append(cubeNode)
    }
    
    func positionFromHitTestResult(_ hitPoint: ARHitTestResult) -> SCNVector3 {
        let yOffset: Float = 0.5
        return SCNVector3Make(hitPoint.worldTransform.columns.3.x,
                              hitPoint.worldTransform.columns.3.y + yOffset,
                              hitPoint.worldTransform.columns.3.z)
    }
    
    
    // MARK: - More Actions
    
    @objc private func onRefreshPressed(_ sender: UIButton) {
        let sessionConfig: ARWorldTrackingConfiguration = ARWorldTrackingConfiguration()
        if planeDetectionSwitch.isOn {
            sessionConfig.planeDetection = .horizontal
        }
        sceneView.session.run(sessionConfig, options: [.resetTracking, .removeExistingAnchors])
        boxes.removeAll()
    }
    
    @objc private func onPlaneDetectionSwitchChanged(_ sender: UISwitch) {
        //stop/start plane detection
        let sessionConfig: ARWorldTrackingConfiguration = ARWorldTrackingConfiguration()
        if sender.isOn {
            sessionConfig.planeDetection = .horizontal
        }
        
        sceneView.session.run(sessionConfig, options: [])
    }
    
    @objc private func onFeaturePointSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        } else {
            sceneView.debugOptions = []
        }
    }
}
