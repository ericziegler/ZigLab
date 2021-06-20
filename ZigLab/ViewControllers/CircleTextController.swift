//
//  CircleTextController.swift
//  ZigLab
//
//  Created by Eric Ziegler on 1/31/21.
//

import UIKit

class CircleTextController: BaseViewController {

    // MARK: - Properties

    var outerCircle: CircleTextView!
    var innerCircle: CircleTextView!

    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hex: 0x242424)
        addCircleTextViews()
    }

    private func addCircleTextViews() {
        outerCircle = CircleTextView(frame: CGRect(x: 50, y: 50, width: 400, height: 400))
        self.view.addSubview(outerCircle)
        outerCircle.center = CGPoint(x: self.view.center.x, y: 200)
        let outerWord = ["I", "H", "T", "E", "L", "A", "C"]
        outerCircle.createObjectsAroundCircle(text: outerWord, color: UIColor(hex: 0xEF3340))

        innerCircle = CircleTextView(frame: CGRect(x: 50, y: 50, width: 200, height: 200))
        self.view.addSubview(innerCircle)
        innerCircle.center = outerCircle.center
        let innerWord = ["P", "E", "L", "P", "R", "U"]
        innerCircle.createObjectsAroundCircle(text: innerWord, color: UIColor(hex: 0x00A3E0))
    }

}

