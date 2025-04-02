//
//  SwiftlyImageLoaderConfiguration.swift
//  SwiftlyImageLoader
//
//  Created by Mohsin Khan on 02/04/25.
//

import Foundation

public struct SwiftlyImageLoaderConfiguration: @unchecked Sendable {
    
    /**
     Why it's useful:
     In UITableView or UICollectionView, cells get reused rapidly.
     If you start an image download and the cell scrolls offscreen before it's done:

     You don't want to keep downloading a now-unneeded image

     You might also accidentally update the wrong cell when it scrolls back in

     This setting helps cancel redundant or stale downloads, improving:

     Performance 🚀

     Network usage 📶

     UI accuracy 🎯
     */
    public var cancelPreviousLoadForSameURL: Bool
    
    /**
     Why it's useful:
     Let’s say you:

     Leave a screen (e.g., pop a view controller or navigate away)

     Want to cancel all in-flight image downloads associated with that screen

     Avoid background activity or memory pressure

     Batch cancelation helps keep things clean and efficient.
     */
    public var enableGlobalCancellation: Bool
    
    
    public var logLevel: LogLevel

    public init(autoCancelOnReuse: Bool = true,
                enableBatchCancelation: Bool = true,
                logLevel: LogLevel = .basic) {
        self.cancelPreviousLoadForSameURL = autoCancelOnReuse
        self.enableGlobalCancellation = enableBatchCancelation
        self.logLevel = logLevel
    }
    
    public static let `default` = SwiftlyImageLoaderConfiguration()
}
