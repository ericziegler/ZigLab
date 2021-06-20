//
//  PulseAnimation.swift
//  ZigLab
//
//  Created by Eric Ziegler on 2/9/21.
//

import UIKit

class PulseAnimation: CALayer {

    var animationGroup = CAAnimationGroup()
    var animationDuration: TimeInterval = 1.5
    var radius: CGFloat = 200
    var numebrOfPulses: Float = Float.infinity

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(parentView: UIView, padding: CGFloat = 10) {
        super.init()
        self.backgroundColor = UIColor.black.cgColor
        self.contentsScale = UIScreen.main.scale
        self.opacity = 0
        self.position = parentView.center
        self.cornerRadius = parentView.layer.cornerRadius
        self.bounds = CGRect(x: 0, y: 0, width: parentView.frame.size.width, height: parentView.frame.size.height)

        DispatchQueue.global(qos: .default).async {
            self.setupAnimationGroup()
            DispatchQueue.main.async {
                self.add(self.animationGroup, forKey: "pulse")
           }
        }
    }

//    init(numberOfPulses: Float = Float.infinity, radius: CGFloat, postion: CGPoint){
//        super.init()
//        self.backgroundColor = UIColor.black.cgColor
//        self.contentsScale = UIScreen.main.scale
//        self.opacity = 0
//        self.radius = radius
//        self.numebrOfPulses = numberOfPulses
//        self.position = postion
//
//        self.bounds = CGRect(x: 0, y: 0, width: radius*2, height: radius*2)
//        self.cornerRadius = radius
//
//        DispatchQueue.global(qos: .default).async {
//            self.setupAnimationGroup()
//            DispatchQueue.main.async {
//                self.add(self.animationGroup, forKey: "pulse")
//           }
//        }
//    }

    func scaleXAnimation() -> CABasicAnimation {
        let scaleAnimaton = CABasicAnimation(keyPath: "transform.scale.x")
        scaleAnimaton.fromValue = NSNumber(value: 1)
        scaleAnimaton.toValue = NSNumber(value: 1.2)
        scaleAnimaton.duration = animationDuration
        return scaleAnimaton
    }

    func scaleYAnimation() -> CABasicAnimation {
        let scaleAnimaton = CABasicAnimation(keyPath: "transform.scale.y")
        scaleAnimaton.fromValue = NSNumber(value: 1)
        scaleAnimaton.toValue = NSNumber(value: 1.2)
        scaleAnimaton.duration = animationDuration
        return scaleAnimaton
    }

    func opacityAnimation() -> CAKeyframeAnimation {
        let opacityAnimiation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimiation.duration = animationDuration
        opacityAnimiation.values = [0.4,0.8,0]
        opacityAnimiation.keyTimes = [0,0.3,1]
        return opacityAnimiation
    }

    func setupAnimationGroup() {
        self.animationGroup.duration = animationDuration
        self.animationGroup.repeatCount = numebrOfPulses
        let defaultCurve = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        self.animationGroup.timingFunction = defaultCurve
        self.animationGroup.animations = [scaleXAnimation(), scaleYAnimation(), opacityAnimation()]
    }


}
