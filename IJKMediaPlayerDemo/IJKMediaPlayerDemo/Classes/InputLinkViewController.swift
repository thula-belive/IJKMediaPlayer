//
//  InputLinkViewController.swift
//  IJKMediaPlayerDemo
//
//  Created by Thu Le on 19/07/2022.
//  Copyright © 2022 lee5783. All rights reserved.
//

import Foundation
import UIKit
//import IJKMediaFramework

class InputLinkViewController: UIViewController {
    @IBOutlet weak var linkTextView: UITextView! {
        didSet {
            linkTextView.layer.borderColor = UIColor.gray.cgColor
            linkTextView.layer.borderWidth = 1
//             linkTextView.text = "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"
//            linkTextView.text = "https://slive-cdn-stg.belive.sg/Record/slive-stg-rtmp.belive.sg/live/continuous_record/hls/07e23cb5cdc645caab160dc66b8e4b64_2022-07-21-09-35-53/07e23cb5cdc645caab160dc66b8e4b64_2022-07-21-09-35-53.m3u8"

            //linkTextView.text = "https://slive-cdn-stg.belive.sg/Record/slive-stg-rtmp.belive.sg/live/continuous_record/hls/f526791e09da4a02adf8035a08c2d691_2022-07-27-09-26-27/f526791e09da4a02adf8035a08c2d691_2022-07-27-09-26-27.m3u8"
            //linkTextView.text = "https://slive-cdn-stg.belive.sg/Record/slive-stg-rtmp.belive.sg/live/continuous_record/hls/f44d2a967ac144d7b89391421fd61bc7_2022-07-14-07-50-46/f44d2a967ac144d7b89391421fd61bc7_2022-07-14-07-50-46.m3u8"
            linkTextView.text = "https://slive-cdn-stg.belive.sg/Record/slive-stg-rtmp.belive.sg/live/continuous_record/hls/8fedc69f4ea14405866678ed136063ba_2022-07-28-06-51-05/8fedc69f4ea14405866678ed136063ba_2022-07-28-06-51-05.m3u8"
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func playButtonTapped(sender: Any?) {
        guard let url = linkTextView.text, !url.isEmpty else { return }
        PlayerViewController.present(isIJK: false, in: self, with: url)
    }

    @IBAction func playIJKButtonTapped(_ sender: Any) {
        guard let url = linkTextView.text, !url.isEmpty else { return }
        PlayerViewController.present(isIJK: true, in: self, with: url)
    }
}
