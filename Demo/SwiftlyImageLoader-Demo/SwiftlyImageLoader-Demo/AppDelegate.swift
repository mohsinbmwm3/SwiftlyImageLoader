//
//  AppDelegate.swift
//  SwiftlyImageLoader-Demo
//
//  Created by Mohsin Khan on 02/04/25.
//

import UIKit
import SwiftlyImageLoader

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        configureImageLoader()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.rootViewController = ViewController()
        
        window?.makeKeyAndVisible()
        
        return true
    }
    
    private func configureImageLoader() {
        let config = SwiftlyImageLoaderConfiguration(
            autoCancelOnReuse: true,
            enableBatchCancelation: true,
            logLevel: .verbose // or .none or .basic
        )
        ImageLoader.setup(with: .default)
    }
}

