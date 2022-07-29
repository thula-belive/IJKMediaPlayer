//
//  IJKPlayerKit.swift
//  IJKMediaPlayerDemo
//
//  Created by Thu Le on 27/07/2022.
//  Copyright © 2022 lee5783. All rights reserved.
//

import Foundation
import UIKit
//import IJKMediaFramework
//
//class IJKPlayerKit: NSObject, BLPlayerKit {
//    weak var playerView: UIView?
//    var streamUrl: String = ""
//    var isPlaying: Bool {
//        return player?.isPlaying() ?? false
//    }
//
//    var periodicTimer: Timer?
//    var duration: TimeInterval? = 0.0
//    var currentPosition: TimeInterval = 0.0
//    var retryTimer: Timer?
//    var shouldRetry = true
//    var player: IJKMediaPlayback?
//    weak var delegate: BLPlayerKitDelegate?
//
//    init(playerView: UIView, streamUrl: String) {
//        super.init()
//        self.playerView = playerView
//        self.streamUrl = streamUrl
//        self.reinitKit()
//    }
//
//    func updatePlayerView(view: UIView) {
//        guard let player = self.player else {
//            return
//        }
//        if player.view.superview != nil {
//            player.view.removeFromSuperview()
//        }
//        player.view.frame = view.bounds
//        player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        player.view.translatesAutoresizingMaskIntoConstraints = true
//        view.addSubview(player.view)
//        self.playerView = view
//    }
//
//    func reinitKit() {
//        self.releaseKit()
//
//        guard let option = IJKFFOptions.byDefault() else {
//            fatalError("Can't create IJKPlayer options")
//            return
//        }
//#if DEBUG
//        IJKFFMoviePlayerController.setLogReport(true)
//        IJKFFMoviePlayerController.setLogLevel(k_IJK_LOG_DEBUG)
//        option.showHudView = true
//#else
//        IJKFFMoviePlayerController.setLogReport(false)
//        IJKFFMoviePlayerController.setLogLevel(k_IJK_LOG_INFO)
//#endif
//        guard let ijkPlayer = IJKFFMoviePlayerController(contentURLString: self.streamUrl, with: option) else {
//            fatalError("Can't create IJKFFMoviePlayerController")
//            return
//        }
//        ijkPlayer.scalingMode = .aspectFill
//        ijkPlayer.shouldAutoplay = true
//        if let view = self.playerView {
//            ijkPlayer.view.frame = view.bounds
//            ijkPlayer.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            ijkPlayer.view.translatesAutoresizingMaskIntoConstraints = true
//            view.addSubview(ijkPlayer.view)
//        }
//        self.player = ijkPlayer
//        self.startPeriodicTimer()
//        self.registerPlayerObservers()
//    }
//
//    func setScalingMode(_ mode: BLPlayerScaleMode) {
//        switch mode {
//        case .none:
//            self.player?.scalingMode = .none
//        case .aspectFit:
//            self.player?.scalingMode = .aspectFit
//        case .aspectFill:
//            self.player?.scalingMode = .aspectFill
//        case .fill:
//            self.player?.scalingMode = .fill
//        }
//    }
//
//    func start() {
//        player?.prepareToPlay()
//        updatePlayerViewLayout()
//    }
//
//    func play() {
//        player?.play()
//    }
//
//    func pause() {
//        player?.pause()
//    }
//
//    func stop() {
//        player?.stop()
//    }
//
//    func seek(to time: TimeInterval, completionHandler: ((Bool) -> ())? = nil) {
//        player?.currentPlaybackTime = time
//        delegate?.playerKit(kit: self, didChangePosition: time)
//        completionHandler?(true)
//    }
//
//    func releaseKit() {
//        unregisterPlayerObservers()
//        stopPeriodicTimer()
//        duration = nil
//        player?.shutdown()
//        player?.stop()
//        player?.view.removeFromSuperview()
//        player = nil
//    }
//
//    func getPlayerLayer() -> AVPlayerLayer? {
//        return nil
//    }
//
//    func audioDidInterrupt() {
//        pause()
//    }
//
//    func updatePlayerViewLayout() {
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self, let view = self.playerView else { return }
//            self.player?.view.frame = view.bounds
//        }
//    }
//
//    func resumeAfterAudioInterruption() {
//        play()
//    }
//
//    func applicationDidEnterBackground() {
//        print("Application did enter background")
//        pause()
//        stopPeriodicTimer()
//    }
//
//    func applicationWillResignActive() {
//        print("Application will resign active")
//        pause()
//    }
//    func applicationDidBecomeActive() {
//        print("Application did become active")
//        play()
//    }
//
//    func applicationWillEnterForeground() {
//        print("Application will enter foreground")
//        startPeriodicTimer()
//        play()
//    }
//
//// MARK: - Timer
//    func startPeriodicTimer() {
//        stopPeriodicTimer()
//        periodicTimer = Timer.scheduledTimer(
//            timeInterval: 0.5,
//            target: self,
//            selector: #selector(updatePosition),
//            userInfo: nil,
//            repeats: true
//        )
//    }
//
//    @objc func updatePosition() {
//        guard let player = self.player else { return }
//        let duration = player.duration
//        if duration > 0 && duration > self.duration ?? 0 {
//            self.duration = duration
//            delegate?.playerKit(kit: self, didChangeDuration: duration)
//        }
//        delegate?.playerKit(kit: self, didChangePosition: player.currentPlaybackTime)
//    }
//
//    func stopPeriodicTimer() {
//        periodicTimer?.invalidate()
//        periodicTimer = nil
//    }
//
//// MARK: - Player Observers
//    func registerPlayerObservers() {
//        NotificationCenter.default.addObserver(self, selector: #selector(loadStateDidChange(_:)), name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: self.player)
//        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackDidFinish(_:)), name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: self.player)
//        NotificationCenter.default.addObserver(self, selector: #selector(mediaIsPreparedToPlayDidChange(_:)), name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: self.player)
//        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackStateDidChange(_:)), name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: self.player)
//    }
//
//    func unregisterPlayerObservers() {
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: self.player)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: self.player)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: self.player)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: self.player)
//    }
//
//    @objc func loadStateDidChange(_ notification: Notification) {
//        //    MPMovieLoadStateUnknown        = 0,
//        //    MPMovieLoadStatePlayable       = 1 << 0,
//        //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
//        //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
//        guard let loadState = self.player?.loadState else { return }
//        if loadState.contains(.playthroughOK) {
//            print("loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: \(loadState)\n")
//        }
//        else if loadState.contains(.stalled) {
//            print("loadStateDidChange: IJKMPMovieLoadStateStalled: \(loadState)\n")
//        }
//        else {
//            print("loadStateDidChange: ???: \(loadState)\n")
//        }
//    }
//    @objc func moviePlayBackDidFinish(_ notification: Notification) {
//        //    MPMovieFinishReasonPlaybackEnded,
//        //    MPMovieFinishReasonPlaybackError,
//        //    MPMovieFinishReasonUserExited
//        let reason = notification.userInfo?[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as! Int
//        switch reason {
//        case IJKMPMovieFinishReason.playbackEnded.rawValue:
//            print("playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: \(reason)\n")
//        case IJKMPMovieFinishReason.userExited.rawValue:
//            print("playbackStateDidChange: IJKMPMovieFinishReasonUserExited: \(reason)\n")
//        case IJKMPMovieFinishReason.playbackError.rawValue:
//            print("playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: \(reason)\n")
//        default:
//            print("playbackPlayBackDidFinish: ???: \(reason)\n")
//        }
//    }
//
//    @objc func mediaIsPreparedToPlayDidChange(_ notification: Notification) {
//        print("BLIJKPlayer mediaIsPreparedToPlayDidChange")
//        guard let player = self.player else {
//            return
//        }
//
//        if player.isPreparedToPlay {
//            self.delegate?.playerKit(kit: self, didChangeVideoDimensions: player.naturalSize)
//            if player.duration > 0 {
//                self.duration = player.duration
//                self.delegate?.playerKit(kit: self, didChangeDuration: player.duration)
//            }
//        }
//    }
//
//    @objc func moviePlayBackStateDidChange(_ notification: Notification) {
//        //    MPMoviePlaybackStateStopped,
//        //    MPMoviePlaybackStatePlaying,
//        //    MPMoviePlaybackStatePaused,
//        //    MPMoviePlaybackStateInterrupted,
//        //    MPMoviePlaybackStateSeekingForward,
//        //    MPMoviePlaybackStateSeekingBackward
//        guard player != nil else {
//            return
//        }
//        switch player!.playbackState {
//        case .playing:
//            delegate?.playerKit(kit: self, playerStateDidChange: .playing)
//        case .paused:
//            delegate?.playerKit(kit: self, playerStateDidChange: .idle)
//        case .stopped:
//            delegate?.playerKit(kit: self, playerStateDidChange: .idle)
//        case .interrupted:
//            delegate?.playerKit(kit: self, playerStateDidChange: .idle)
//        case .seekingForward, .seekingBackward:
//            delegate?.playerKit(kit: self, playerStateDidChange: .buffering)
//        @unknown default: break
//        }
//    }
//
////    @objc func playBackIsPreparedToPlay() {
////        print("KSY Playback Is Prepared To Play")
////        guard let player = player else {
////            return
////        }
////        self.printStreamInformation()
////        self.delegate?.playerKit(kit: self, didChangeVideoDimensions: player.naturalSize)
////    }
////    @objc func playerDidPlayFirstFrame() {
////        print("BLPlayer Did Play First Frame")
////        delegate?.playerKit(kit: self, playerStateDidChange: .playing)
////    }
////    @objc func playerPlayBackDidChangeState(notification: NSNotification) {
////        if let controller = notification.object as? KSYMoviePlayerController {
////            switch controller.playbackState {
////            case .seekingForward, .seekingBackward:
////                print("BLPlayer Buffering")
////                delegate?.playerKit(kit: self, playerStateDidChange: .buffering)
////            case .playing:
////                print("BLPlayer Playing")
////            case .stopped, .paused, .interrupted:
////                print("BLPlayer Idle")
////                if shouldRetry {
////                    startRetryTimer()
////                }
////                delegate?.playerKit(kit: self, playerStateDidChange: .idle)
////            default:
////                break
////            }
////        }
////    }
////
////    @objc func playerDidEnd() {
////        print("BLPlayer Did End")
////        if shouldRetry {
////            startRetryTimer()
////        }
////        delegate?.playerKit(kit: self, playerDidFailWithError: nil)
////    }
//
////    func startRetryTimer() {
////        print("Start Retry")
////        if retryTimer == nil {
////            retryTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.doRetry), userInfo: nil, repeats: true)
////        }
////    }
////    func stopRetryTimer() {
////        print("Stop Retry")
////        retryTimer?.invalidate()
////        retryTimer = nil
////    }
////    @objc func doRetry() {
////        print("Do Retry")
////        if !isPlaying {
////            reinitKit()
////            start()
////        } else {
////            stopRetryTimer()
////        }
////    }
//    deinit {
//        print("Deinit BLPlayerKit")
//    }
//}
