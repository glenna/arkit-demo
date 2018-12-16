//
//  AppDelegate.swift
//  ARAlbertDemo3D
//
//  Created by Glenna L Buford on 7/2/17.
//  Copyright © 2017 Glenna L Buford. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let initialViewController: ViewController = ViewController()
        
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
        
        return true
    }
}

