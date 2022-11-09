//
//  ScrollbarArrow.swift
//  ScrollBarDemo
//
//  Created by David Klopp on 28.07.22.
//

import UIKit

private extension UIColor {
    static var arrowDisabledColor: UIColor = .init { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return .systemBlue.withAlphaComponent(0.1)
        }
        return .separator
    }

    static var arrowColor: UIColor = .init { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return .systemBlue
        }
        return .gray
    }

    static var arrowActiveColor: UIColor = .init { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return .systemBlue
        }
        return .black
    }
}

final internal class ScrollbarArrowView: UIView {
    internal enum Direction {
        case left
        case right
    }

    /// The direction the arrow is pointing at.
    var direction: Direction = .left {
        didSet {
            self.setNeedsDisplay()
        }
    }

    /// The width of the arrow lines.
    var lineWidth: CGFloat = 2.0

    /// The action to perform when the arrow is clicked
    var action: (() -> Void)?

    /// True if the arrow is currently active
    private var isActive: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }

    override var isUserInteractionEnabled: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }

    /// The maximum size the arrow on the left or right side can occupy.
    private var maximumArrowSize: CGSize {
        return CGSize(width: 14, height: 50)
    }

    convenience init(direction: Direction) {
        self.init(frame: .zero)
        self.direction = direction
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isOpaque = false
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.onClick(_:)))
        recognizer.cancelsTouchesInView = false
        recognizer.delaysTouchesBegan = false
        recognizer.delaysTouchesEnded = false
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.addGestureRecognizer(recognizer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let height = min(rect.height, self.maximumArrowSize.height)
        let width = min(rect.width, self.maximumArrowSize.width)
        let originY = (rect.height - height)/2
        let originX = (rect.width - width)/2

        let path = UIBezierPath()
        path.lineCapStyle = .round
        path.lineJoinStyle = .round

        if self.direction == .left {
            path.move(to: CGPoint(x: rect.width - originX, y: originY))
            path.addLine(to: CGPoint(x: originX, y: originY + height/2))
            path.addLine(to: CGPoint(x: rect.width - originX, y: originY + height))
        } else {
            path.move(to: CGPoint(x: originX, y: originY))
            path.addLine(to: CGPoint(x: rect.width - originX, y: originY + height/2))
            path.addLine(to: CGPoint(x: originX, y: originY + height))
        }

        if self.isActive {
            UIColor.arrowActiveColor.setStroke()
            path.lineWidth = self.lineWidth + 1
        } else if self.isUserInteractionEnabled {
            UIColor.arrowColor.setStroke()
            path.lineWidth = self.lineWidth
        } else {
            UIColor.arrowDisabledColor.setStroke()
            path.lineWidth = self.lineWidth
        }

        path.stroke()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.isActive = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.isActive = false
    }

    @objc func onClick(_ recognizer: UITapGestureRecognizer) {
        if case .ended = recognizer.state {
            self.action?()
        }
    }
}
