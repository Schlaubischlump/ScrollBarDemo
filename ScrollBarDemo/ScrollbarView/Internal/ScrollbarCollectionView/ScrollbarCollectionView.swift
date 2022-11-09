//
//  ScrollbarCollectionView.swift
//  ScrollBarDemo
//
//  Created by David Klopp on 29.07.22.
//

import UIKit

internal final class ScrollbarCollectionView: UICollectionView {

    var snappingStepSize: Int {
        get { return self.scrollbarViewFlowLayout?.snappingStepSize ?? 0 }
        set { self.scrollbarViewFlowLayout?.snappingStepSize = newValue }
    }

    /// The content offset given as a CGPoint with values between 0 (start) and 1 (end).
    var relativeContentOffset: CGPoint {
        get {
            let relOffX = self.contentOffset.x / (self.contentSize.width - self.frame.width)
            let relOffY = self.contentOffset.y / (self.contentSize.height - self.frame.height)
            return CGPoint(x: round(relOffX * 100) / 100, y: round(relOffY * 100) / 100)
        }
        set {
            let x = (self.contentSize.width - self.frame.width) * newValue.x
            let y = (self.contentSize.height - self.frame.height) * newValue.y
            self.contentOffset = CGPoint(x: x, y: y)
        }
    }

    /// The current horizontal content offset given as an index of the first visible item.
    /// E.g. A value of 7.5 would mean, that item 7 is visible and half of its size is already scrolled offscreen.
    var itemOffset: CGFloat {
        get {
            guard let itemSize = self.scrollbarViewFlowLayout?.itemSizeWithPadding else {
                return 0
            }
            return round(self.contentOffset.x / itemSize.width * 100) / 100
        }
        set {
            if let itemSize = self.scrollbarViewFlowLayout?.itemSizeWithPadding {
                self.contentOffset.x = itemSize.width * newValue
            }
        }
    }

    var scrollbarViewFlowLayout: ScrollbarViewFlowLayout? {
        return self.collectionViewLayout as? ScrollbarViewFlowLayout
    }

    convenience init() {
        let layout = ScrollbarViewFlowLayout()
        layout.scrollDirection = .horizontal

        self.init(frame: .zero, collectionViewLayout: layout)

        self.backgroundColor = .clear
        self.showsHorizontalScrollIndicator = false
        self.bounces = true
        self.decelerationRate = .fast
    }

    func snapToPrevious() {
        guard var newOffset = self.scrollbarViewFlowLayout?.calculateTargetContentOffset(
            forProposedContentOffset: self.contentOffset, withHorizontalScrollingVelocity: -1.0) else {
            return
        }
        newOffset.x = max(newOffset.x, 0)
        self.setContentOffset(newOffset, animated: true)
    }

    func snapToNext() {
        guard var newOffset = self.scrollbarViewFlowLayout?.calculateTargetContentOffset(
            forProposedContentOffset: self.contentOffset, withHorizontalScrollingVelocity: 1.0) else {
            return
        }
        newOffset.x = min(newOffset.x, self.contentSize.width - self.bounds.width)
        self.setContentOffset(newOffset, animated: true)
    }
}
