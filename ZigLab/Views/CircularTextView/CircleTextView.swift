//
//  CircularTextView.swift
//  ZigLab
//
//  Created by Eric Ziegler on 1/31/21.
//

import UIKit

class CircleTextView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        self.clipsToBounds = true
    }

    func createObjectsAroundCircle(text: [String], color: UIColor) {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius : CGFloat = bounds.width / 4
        let count = text.count

        var angle = CGFloat(2 * Double.pi)
        let step = CGFloat(2 * Double.pi) / CGFloat(count)

        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath

        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 45.0

        self.layer.addSublayer(shapeLayer)

        // set objects around circle
        for index in 0..<text.count {
            let x = cos(angle) * radius + center.x
            let y = sin(angle) * radius + center.y

            let label = UILabel()
            label.text = "\(text[index])"
            label.font = UIFont(name: "Arial", size: 28)
            label.textColor = UIColor.white
            label.sizeToFit()
            label.frame.origin.x = x - label.frame.midX
            label.frame.origin.y = y - label.frame.midY

            self.addSubview(label)
            let transform = CGAffineTransform(rotationAngle: angle + 1.5708)
            label.transform = transform

            angle += step
        }
    }

}
