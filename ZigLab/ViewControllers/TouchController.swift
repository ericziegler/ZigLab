//
//  TouchController.swift
//  ZigLab
//
//  Created by Eric Ziegler on 2/23/21.
//

import UIKit

class TouchController: BaseViewController {

    var touchView: TouchView?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTouchView()
    }

    private func setupTouchView() {
        touchView = TouchView(frame: self.view.frame)
        self.view.addSubview(touchView!)
    }

}
