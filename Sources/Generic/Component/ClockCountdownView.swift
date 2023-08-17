//
//  TrashOut
//  Copyright 2017 TrashOut NGO. All rights reserved.
// License GNU GPLv3
//

/**
  * TrashOut is an environmental project that teaches people how to recycle
  * and showcases the worst way of handling waste - illegal dumping. All you need is a smart phone.
  *
  *
  * There are 10 types of programmers - those who are helping TrashOut and those who are not.
  * Clean up our code, so we can clean up our planet.
  * Get in touch with us: help@trashout.ngo
  *
  * Copyright 2017 TrashOut, n.f.
  *
  * This file is part of the TrashOut project.
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 3 of the License, or
  * (at your option) any later version.
  *
  * This program is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  *
  * See the GNU General Public License for more details: <https://www.gnu.org/licenses/>.
 */

import Foundation
import UIKit
import QuartzCore

open class ClockCountdownView: UIView {

    private var shapeLayer = CAShapeLayer()
    private var lineCircleLayer = CAShapeLayer()
    // private var countDownTimer = Timer()
    
    private lazy var timer: BackgroundTimer = {
        let t = BackgroundTimer.default
        t.eventHandler = self.timerValueUpdated
        return t
    } ()
    
    private let interval: TimeInterval = 0.1

    open var circledView: Bool = true
    open override var bounds: CGRect {
        didSet {
            super.bounds = bounds
            if circledView {
                self.radius = (self.bounds.size.width) / 2
                self.layer.cornerRadius = self.bounds.size.width / 2
                self.layer.masksToBounds = true
            }
        }
    }

    open var startColor: UIColor = Theme.current.color.green {
        didSet {
            self.label.textColor = startColor
            self.shapeLayer.strokeColor = startColor.cgColor
        }
    }

    /// Inner label with remaining time
    ///
    /// Use monospaced font
    open var label = UILabel()

    /// Radius of circle
    open var radius: CGFloat = 100

    /// Start interval value
    open var startTimerValue: TimeInterval = 3 * 60
    /// Current interval value
    open var timerValue: TimeInterval = 3 * 60
    /// Minimum interval to show full circle
    open var minimumTimerValue: TimeInterval = 60
    /// Width of circle line
    open var lineWidth: CGFloat = 10

    open var updateColorDuration: TimeInterval = 2 * 60
    open var remainingDecisitionTime: TimeInterval = 3 * 60
    open var endColor: UIColor = Theme.current.color.red
    open var middleColor: UIColor = Theme.current.color.yellow

    open var updatesTextColor: Bool = true

    var onFinish: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.createLabel()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.createLabel()
    }

    private func addCircle() {
        let center = CGPoint(x: self.center.x - self.frame.origin.x, y: self.center.y - self.frame.origin.y)
		self.addShapeLayer(center: center)
		self.addLineCircle(center: center)
    }

	private func addLineCircle(center: CGPoint) {
		let centerCirclePath = UIBezierPath(arcCenter: center,
		                                    radius: radius - lineWidth / 4,
		                                    startAngle: CGFloat(3*Double.pi/2),
		                                    endAngle: CGFloat(2*Double.pi) + CGFloat(3*Double.pi/2),
		                                    clockwise: true)

		lineCircleLayer.path = centerCirclePath.cgPath
		lineCircleLayer.fillColor = UIColor.clear.cgColor
		lineCircleLayer.strokeColor = self.startColor.cgColor
		lineCircleLayer.lineWidth = 1 / UIScreen.main.scale
		lineCircleLayer.shouldRasterize = false
		self.layer.addSublayer(lineCircleLayer)
	}

	private func addShapeLayer(center: CGPoint) {
		let circlePath = UIBezierPath(arcCenter: center,
		                              radius: radius,
                                      startAngle: CGFloat(3*Double.pi/2),
		                              endAngle: CGFloat(2*Double.pi) + CGFloat(3*Double.pi/2),
		                              clockwise: true)
		self.shapeLayer.path = circlePath.cgPath
		self.shapeLayer.fillColor = UIColor.clear.cgColor
		self.shapeLayer.strokeColor = self.startColor.cgColor
		self.shapeLayer.lineWidth = lineWidth

		self.shapeLayer.shouldRasterize = false
		self.layer.addSublayer(self.shapeLayer)
	}

    private func createLabel() {
        self.label.font = UIFont.boldSystemFont(ofSize: 24)
        // Monospaced font !important
        self.label.font = self.label.font.monospacedDigitFont
        self.label.textColor = self.startColor
        self.addSubview(self.label)

        // constraints
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.label.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.label.textAlignment = .center
    }
    
    private func setStrokeEnd(timerDuration: TimeInterval, currentTime: TimeInterval) {
        self.shapeLayer.strokeEnd = CGFloat(currentTime / timerDuration)
    }

    private func updateLabel(value: TimeInterval) {
        self.setLabelText(value: self.timeFormatted(totalSeconds: value))
        self.addCircle()
    }

    private func setLabelText(value: String) {
        self.label.text = value
    }

    private func timeFormatted(totalSeconds: TimeInterval) -> String {
        let seconds: Int = Int(totalSeconds) % 60
        let minutes: Int = Int(totalSeconds / 60)
        return String(format: "%01d:%02d", minutes, seconds)
    }


    private var completionCallbackCalled = false
    
    private func timerValueUpdated(_ nextValue: TimeInterval) -> Void {
        timerValue = startTimerValue - nextValue
        guard timerValue >= 0 else {
            self.stopTimer()
            return
        }
        
        self.setLabelText(value: self.timeFormatted(totalSeconds: timerValue))
        self.updateColor(remainingTime: timerValue)
        self.setStrokeEnd(timerDuration: startTimerValue, currentTime: timerValue)
    }

    func updateColor(remainingTime: TimeInterval) {
        let fraction = (remainingTime - remainingDecisitionTime + updateColorDuration) / updateColorDuration
        let color: UIColor = self.color(for: fraction)

        self.shapeLayer.strokeColor = color.cgColor
        self.lineCircleLayer.strokeColor = color.cgColor
        if updatesTextColor {
            self.label.textColor = color
        }
    }

	/**
	Color for fraction, interpolate using middle color, simple interpolation from green to red looks ugly
	*/
	func color(for fraction: Double) -> UIColor {
		guard fraction < 1 else {
			return self.startColor
		}
		guard fraction > 0 else {
			return self.endColor
		}
		if fraction > 0.5 {
			let p = fraction * 2 - 1
			return self.middleColor.interpolateRGB(to: self.startColor, with: CGFloat(p))
		} else {
			let p = fraction * 2
			return self.endColor.interpolateRGB(to: self.middleColor, with: CGFloat(p))
		}
	}

    func setTimer(value: TimeInterval) {
        self.startTimerValue = value
        self.updateLabel(value: value)
    }

    func startTimer() {
        completionCallbackCalled = false
        timer.start()
    }
    
    func stopTimer() {
        if completionCallbackCalled == false {
            completionCallbackCalled = true
            self.onFinish?()
        }
        
        timer.stop()
    }
}

fileprivate extension UIColor {

    func interpolateRGB(to end: UIColor, with fraction: CGFloat) -> UIColor {
        let f = max(0, min(1, fraction))
        guard self.cgColor.numberOfComponents > 3 else { return self }
        guard end.cgColor.numberOfComponents > 3 else { return self }
        let c1 = self.cgColor.components!
        let c2 = end.cgColor.components!
        let rFrac: CGFloat = (c2[0] - c1[0]) * f
        let gFrac: CGFloat = (c2[1] - c1[1]) * f
        let bFrac: CGFloat = (c2[2] - c1[2]) * f
        let aFrac: CGFloat = (c2[3] - c1[3]) * f
        let r: CGFloat = CGFloat(c1[0] + rFrac)
        let g: CGFloat = CGFloat(c1[1] + gFrac)
        let b: CGFloat = CGFloat(c1[2] + bFrac)
        let a: CGFloat = CGFloat(c1[3] + aFrac)
		// print("r: \(r), g: \(g), b: \(b), a: \(a)")
        return UIColor.init(red: r, green: g, blue: b, alpha: a)
    }

}
