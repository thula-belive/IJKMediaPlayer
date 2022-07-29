//
//  KSYPlayerKit.swift
//  IJKMediaPlayerDemo
//
//  Created by Thu Le on 27/07/2022.
//  Copyright © 2022 lee5783. All rights reserved.
//

import Foundation
import UIKit
import libksygpulive

class KSYPlayerKit: NSObject, BLPlayerKit {
    weak var playerView: UIView?
    var streamUrl: String = ""
    var isPlaying: Bool {
        return player?.isPlaying() ?? false
    }
    var periodicTimer: Timer?
    var duration: TimeInterval? = 0.0
    var currentPosition: TimeInterval = 0.0
    var retryTimer: Timer?
    var shouldRetry = true
    var player: KSYMoviePlayerController?
    weak var delegate: BLPlayerKitDelegate?
    init(playerView: UIView, streamUrl: String) {
        super.init()
        self.playerView = playerView
        self.streamUrl = streamUrl
        self.reinitKit()
    }

    func updatePlayerView(view: UIView) {
        guard let player = self.player else {
            return
        }
        if player.view.superview != nil {
            player.view.removeFromSuperview()
        }
        player.view.frame = view.bounds
        player.view.autoresizesSubviews = true
        player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player.view.translatesAutoresizingMaskIntoConstraints = true
        view.addSubview(player.view)
        self.playerView = view
    }

    func reinitKit() {
        self.releaseKit()
        self.player = KSYMoviePlayerController(contentURL: URL(string: streamUrl))
        self.player?.controlStyle = .none
        self.player?.shouldEnableKSYStatModule = true
        self.player?.videoDecoderMode = .software
        self.player?.scalingMode = .aspectFill
        self.player?.shouldAutoplay = true
//        self.player?.deinterlaceMode = .none
        self.player?.shouldLoop = false
        self.player?.bInterruptOtherAudio = true
//        self.player?.bufferTimeMax = 10
//        self.player?.bufferSizeMax = 25
//        self.player?.setTimeout(10, readTimeout: 10)
        self.player?.logBlock = { logs in
            if let logs = logs {
                print("Player logs: \(logs)")
            }
        }
        if let view = self.playerView {
            self.updatePlayerView(view: view)
        }
        self.startPeriodicTimer()
        self.registerPlayerObservers()
    }
    func setScalingMode(_ mode: BLPlayerScaleMode) {
        switch mode {
        case .none:
            self.player?.scalingMode = .none
        case .aspectFit:
            self.player?.scalingMode = .aspectFit
        case .aspectFill:
            self.player?.scalingMode = .aspectFill
        case .fill:
            self.player?.scalingMode = .fill
        }
    }

    func start() {
        shouldRetry = true
        player?.prepareToPlay()
        updatePlayerViewLayout()
    }

    func play() {
        shouldRetry = true
        player?.play()
    }

    func pause() {
        shouldRetry = false
        player?.pause()
    }

    func stop() {
        shouldRetry = false
        player?.stop()
    }

    func seek(to time: TimeInterval, completionHandler: ((Bool) -> ())? = nil) {
        player?.seek(to: time, accurate: true)
        delegate?.playerKit(kit: self, didChangePosition: time)
        completionHandler?(true)
    }

    func releaseKit() {
        unregisterPlayerObservers()
        stopRetryTimer()
        stopPeriodicTimer()
        duration = nil
        player?.stop()
        player?.view.removeFromSuperview()
        player = nil
    }

    func getPlayerLayer() -> AVPlayerLayer? {
        return nil
    }

    func audioDidInterrupt() {
        pause()
    }

    func updatePlayerViewLayout() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let view = self.playerView else { return }
            self.player?.view.frame = view.bounds
        }
    }

    func resumeAfterAudioInterruption() {
        play()
    }

    func applicationDidEnterBackground() {
        print("Application did enter background")
        pause()
        stopPeriodicTimer()
    }

    func applicationWillResignActive() {
        print("Application will resign active")
        pause()
    }

    func applicationDidBecomeActive() {
        print("Application did become active")
        play()
    }

    func applicationWillEnterForeground() {
        print("Application will enter foreground")
        startPeriodicTimer()
        play()
    }

    func startPeriodicTimer() {
        stopPeriodicTimer()
        periodicTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updatePosition),
            userInfo: nil,
            repeats: true
        )
    }

    @objc func updatePosition() {
        guard let player = self.player else { return }
        let duration = player.duration
        if duration > 0 && duration > self.duration ?? 0 {
            self.duration = duration
            delegate?.playerKit(kit: self, didChangeDuration: duration)
        }
        delegate?.playerKit(kit: self, didChangePosition: player.currentPlaybackTime)
    }

    func stopPeriodicTimer() {
        periodicTimer?.invalidate()
        periodicTimer = nil
    }

    func registerPlayerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(playBackIsPreparedToPlay), name: Notification.Name.init("MPMediaPlaybackIsPreparedToPlayDidChangeNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidPlayFirstFrame), name: Notification.Name.init("MPMoviePlayerFirstVideoFrameRenderedNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerPlayBackDidChangeState), name: Notification.Name.init("MPMoviePlayerPlaybackStateDidChangeNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidEnd), name: Notification.Name.init("MPMoviePlayerPlaybackDidFinishNotification"), object: nil)
    }

    func unregisterPlayerObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func playBackIsPreparedToPlay() {
        print("KSY Playback Is Prepared To Play")
        guard let player = player else {
            return
        }
        self.printStreamInformation()
        self.delegate?.playerKit(kit: self, didChangeVideoDimensions: player.naturalSize)
    }

    @objc func playerDidPlayFirstFrame() {
        print("BLPlayer Did Play First Frame")
        delegate?.playerKit(kit: self, playerStateDidChange: .playing)
    }

    @objc func playerPlayBackDidChangeState(notification: NSNotification) {
        if let controller = notification.object as? KSYMoviePlayerController {
            print("KSYMoviePlayer state changed: \(controller.playbackState.rawValue)")
            switch controller.playbackState {
            case .seekingForward, .seekingBackward:
                print("BLPlayer Buffering")
                delegate?.playerKit(kit: self, playerStateDidChange: .buffering)
            case .playing:
                print("BLPlayer Playing")
            case .stopped, .paused, .interrupted:
                print("BLPlayer Idle")
                if shouldRetry {
                    startRetryTimer()
                }
                delegate?.playerKit(kit: self, playerStateDidChange: .idle)
            default:
                break
            }
        }
    }

    @objc func playerDidEnd() {
        print("BLPlayer Did End")
        if shouldRetry {
            startRetryTimer()
        }
        delegate?.playerKit(kit: self, playerDidFailWithError: nil)
    }

    func startRetryTimer() {
        print("Start Retry")
        if retryTimer == nil {
            retryTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.doRetry), userInfo: nil, repeats: true)
        }
    }

    func stopRetryTimer() {
        print("Stop Retry")
        retryTimer?.invalidate()
        retryTimer = nil
    }

    @objc func doRetry() {
        print("Do Retry")
        if !isPlaying {
            reinitKit()
            start()
        } else {
            stopRetryTimer()
        }
    }

    deinit {
        print("Deinit BLPlayerKit")
    }
}

extension KSYPlayerKit {
    func printStreamInformation() {
        var logs: [String] = []
        logs.append("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        logs.append("BLKSYPlayerKit")
        guard let player = self.player else { return }
        logs.append("Video Size: \(player.naturalSize)")
        logs.append("Video Rotate: \(player.naturalRotate)")
        logs.append("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        print(logs.joined(separator: "\n"))
    }
}

