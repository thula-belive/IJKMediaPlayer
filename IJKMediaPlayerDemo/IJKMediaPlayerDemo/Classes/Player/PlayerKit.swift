//
//  PlayerKit.swift
//  IJKMediaPlayerDemo
//
//  Created by Thu Le on 27/07/2022.
//  Copyright © 2022 lee5783. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

/// Player Kit State
public enum BLPlayerKitState: String {
    /// Stream is not start or playable
    case idle
    /// Stream is ready to play
    case ready
    /// Stream is buffering/loading
    case buffering
    /// Stream is playing
    case playing
    /// Stream is stopped
    case stopped
    /// Stream is ended
    case ended
}

/// Player Kit Delegation
public protocol BLPlayerKitDelegate: AnyObject {
    /// Player's state did change
    /// - Parameters:
    ///   - kit: Player kit
    ///   - state: Player state
    func playerKit(kit: BLPlayerKit, playerStateDidChange state: BLPlayerKitState)
    /// Player's failed with error
    /// - Parameters:
    ///   - kit: Player kit
    ///   - error: Error
    func playerKit(kit: BLPlayerKit, playerDidFailWithError error: Error?)
    /// Stream's duration did change
    /// - Parameters:
    ///   - kit: Player kit
    ///   - duration: Stream duration
    func playerKit(kit: BLPlayerKit, didChangeDuration duration: TimeInterval)
    /// Stream's current position did change
    /// - Parameters:
    ///   - kit: Player kit
    ///   - position: Current stream position
    func playerKit(kit: BLPlayerKit, didChangePosition position: TimeInterval)
    /// Stream video frame update did change
    /// - Parameters:
    ///   - kit: Player kit
    ///   - position: Current stream position
    func playerKit(kit: BLPlayerKit, didChangeVideoDimensions dimensions: CGSize)
}

/// Player Kit Type
public enum BLPlayerKitType {
    /// RTMP
    case rtmp
    /// HLS and others
    case hls
}

/// Player Scale Mode
public enum BLPlayerScaleMode {
    /// Do not scale the stream/video.
    case none
    /// Scale the stream/video uniformly until one dimension fits the visible bounds of the view exactly.
    case aspectFit
    /// Scale the stream/video uniformly until the movie fills the visible bounds of the view.
    case aspectFill
    /// Scale the stream/video until both dimensions fit the visible bounds of the view exactly.
    case fill
}

/// Player Kit
public protocol BLPlayerKit: NSObject {
    /// View that player render stream/video on
    var playerView: UIView? { get }
    /// Update view that player render stream/video on
    func updatePlayerView(view: UIView)
    /// URL of stream/video
    var streamUrl: String { get set }
    /// Playing status of stream/video
    var isPlaying: Bool { get }
    /// Playing timer
    var periodicTimer: Timer? { get set }
    /// Stream/video duration
    var duration: TimeInterval? { get set }
    /// Stream/video current position
    var currentPosition: TimeInterval { get set }
    /// Retry timer
    var retryTimer: Timer? { get set }
    /// Should retry flag
    var shouldRetry: Bool { get set }
    /// Player Kit Delegation
    var delegate: BLPlayerKitDelegate? { get set }
    /// Reinit Kit
    func reinitKit()
    /// Set player scaling mode
    /// - Parameter mode: Scale mode
    func setScalingMode(_ mode: BLPlayerScaleMode)
    /// Start player and auto play stream/video
    func start()
    /// Play stream/video
    func play()
    /// Pause stream/video
    func pause()
    /// Stop stream/video
    func stop()
    /// Sets the current playback time to the specified time.
    /// - Parameter second: The time to which to seek.
    func seek(to time: TimeInterval, completionHandler: ((Bool) -> Void)?)
    /// Stop player kit and release resources
    func releaseKit()
    func getPlayerLayer() -> AVPlayerLayer?
    /// Call when detect audio interrupt by call or other video/music playing
    func audioDidInterrupt()
    /// Call when there's somg change in UI like orientation change
    func updatePlayerViewLayout()
    /// Call after audio interruption
    func resumeAfterAudioInterruption()
    /// Call when you detect app enter background
    func applicationDidEnterBackground()
    /// Call when you detect app resign active
    func applicationWillResignActive()
    /// Call when you detect app become active
    func applicationDidBecomeActive()
    /// Call when you detect app will enter foreground
    func applicationWillEnterForeground()
}
