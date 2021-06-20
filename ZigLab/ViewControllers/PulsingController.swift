//
//  PulsingController.swift
//  ZigLab
//
//  Created by Eric Ziegler on 2/9/21.
//

import UIKit

class PulsingController: BaseViewController {

    @IBOutlet var recordButton: RecordButton!
    @IBOutlet var startButton: ActionButton!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordButton.startPulsing()
        startButton.startPulsing()
    }

    @IBAction func recordTapped(_ sender: AnyObject) {
        toggleRecording()
    }

    private func toggleRecording() {
        if recordButton.isPulsing == true {
            recordButton.startRecording()
            recordButton.stopPulsing()
        } else {
            recordButton.startPulsing()
            recordButton.stopRecording()
        }
    }

}
