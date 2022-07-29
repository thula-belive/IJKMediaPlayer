//
//  PlayerViewController.swift
//  IJKMediaPlayerDemo
//
//  Created by Thu Le on 19/07/2022.
//  Copyright © 2022 lee5783. All rights reserved.
//

import UIKit
//import IJKMediaFramework

class PlayerViewController: UIViewController {
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playerControlsView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var curentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var seekbar: UISlider!
    private var isSliderDragging = false

    public private(set) var url: URL!
    private var player: BLPlayerKit?
    private var isIJK: Bool = false

    static func present(isIJK: Bool, in controller: UIViewController, with urlString: String) {
        let storyboard = UIStoryboard(name: "MediaPlayer", bundle: nil)
        guard let playerVC = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController else { return }
        guard let url = URL(string: urlString) else { return }
        playerVC.url = url
        playerVC.isIJK = isIJK
        playerVC.modalPresentationStyle = .fullScreen
        playerVC.modalTransitionStyle = .coverVertical
        controller.present(playerVC, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initPlayer()
        initPlaybackControls()
    }

    private func initPlayer() {
        if self.isIJK {
//            let player = IJKPlayerKit(playerView: self.playerView, streamUrl: self.url.absoluteString)
//            player.delegate = self
//            player.start()
//            self.player = player
        } else {
            let player = KSYPlayerKit(playerView: self.playerView, streamUrl: self.url.absoluteString)
            player.delegate = self
            player.start()
            self.player = player
        }
    }

    private func initPlaybackControls() {
        self.seekbar.minimumValue = 0
        self.seekbar.maximumValue = 0
        self.curentTimeLabel.text = 0.toClockTime
        self.durationLabel.text = 0.toClockTime

        self.playButton.addTarget(self, action: #selector(playPauseBtnTapped(_:)), for: .touchUpInside)
        seekbar.isContinuous = true
        seekbar.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: [.valueChanged, .touchCancel])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    @IBAction func btnCloseTapped(_ sender: Any) {
        self.player?.releaseKit()
        self.player = nil
        self.dismiss(animated: true)
    }

    @objc func playPauseBtnTapped(_ sender: Any) {
        guard let player = self.player else { return }
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }

    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began, .moved:
                isSliderDragging = true
                let seekTime = TimeInterval(slider.value)
                curentTimeLabel.text = seekTime.toClockTime
            case .ended, .cancelled:
                // seek here
                let seekTime = TimeInterval(slider.value)
                self.player?.seek(to: seekTime, completionHandler: { _ in
                    print("Seek to: \(seekTime)")
                })
                isSliderDragging = false
            default:
                break
            }
        }
    }
}

extension PlayerViewController: BLPlayerKitDelegate {
    func playerKit(kit: BLPlayerKit, playerStateDidChange state: BLPlayerKitState) {
        switch state {
        case .playing:
            self.playButton.setImage(UIImage(named: "ic_pause"), for: .normal)
        default:
            self.playButton.setImage(UIImage(named: "ic_play"), for: .normal)
        }
    }

    func playerKit(kit: BLPlayerKit, playerDidFailWithError error: Error?) {

    }

    func playerKit(kit: BLPlayerKit, didChangeDuration duration: TimeInterval) {
        self.durationLabel.text = duration.toClockTime
        self.seekbar.maximumValue = Float(duration)
    }

    func playerKit(kit: BLPlayerKit, didChangePosition position: TimeInterval) {
        self.curentTimeLabel.text = position.toClockTime
        self.seekbar.value = Float(position)
    }

    func playerKit(kit: BLPlayerKit, didChangeVideoDimensions dimensions: CGSize) {
        if dimensions.width > dimensions.height {
            kit.setScalingMode(.aspectFit)
        } else {
            kit.setScalingMode(.aspectFill)
        }
    }
}

extension Double {
    var toClockTime: String {
        let hours = Int(self) / 3600
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}
