//
//  TouchView.swift
//  ZigLab
//
//  Created by Eric Ziegler on 2/23/21.
//

import UIKit

class TouchView: UIView {

    // MARK: - Properties

    var path = UIBezierPath()
    var initialLocation = CGPoint.zero
    var finalLocation = CGPoint.zero
    var shapeLayer = CAShapeLayer()

    // MARK: - Init

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.layer.addSublayer(shapeLayer)
        self.shapeLayer.lineWidth = 10
        self.shapeLayer.lineCap = .round
        self.shapeLayer.strokeColor = UIColor.systemPurple.cgColor
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let location = touches.first?.location(in: self){
            initialLocation = location
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let location = touches.first?.location(in: self){
            let dx =  location.x - initialLocation.x
            let dy = location.y - initialLocation.y

            finalLocation = abs(dx) > abs(dy) ? CGPoint(x: location.x, y: initialLocation.y) : CGPoint(x: initialLocation.x, y: location.y)

            path.removeAllPoints()
            path.move(to: initialLocation)
            path.addLine(to: location)

            shapeLayer.path = path.cgPath

        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        removePath()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        removePath()
    }

    private func removePath() {
        shapeLayer.path = nil
    }

}
