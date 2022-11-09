//
//  ScrollbarViewFlowLayout.swift
//  ScrollBarDemo
//
//  Created by David Klopp on 28.07.22.
//

import UIKit

import UIKit

private let kSeparatorDecorationView = "Separator"
private let kMinimumLineSpacing = 1.0

private final class SeparatorView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .separator
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        self.frame = layoutAttributes.frame
    }
}


internal final class ScrollbarViewFlowLayout: UICollectionViewFlowLayout {

    /// The number of items to snap by
    var snappingStepSize: Int = 1

    var showsSeparators: Bool = true {
        didSet {
            self.minimumLineSpacing = self.showsSeparators ? kMinimumLineSpacing : 0
            self.invalidateLayout()
        }
    }

    var itemSizeWithPadding: CGSize {
        return CGSize(width: self.itemSize.width + self.minimumLineSpacing, height: self.itemSize.height)
    }

    //var snapToNearestItem: Bool = true

    override init() {
        super.init()
        self.register(SeparatorView.self, forDecorationViewOfKind: kSeparatorDecorationView)
        self.minimumLineSpacing = kMinimumLineSpacing
        self.minimumInteritemSpacing = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        // Do not snap if snapping is disabled
        guard self.snappingStepSize > 0 else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset,
                                             withScrollingVelocity: velocity)
        }

        if let targetOffset = self.calculateTargetContentOffset(forProposedContentOffset: proposedContentOffset,
                                                                withHorizontalScrollingVelocity: velocity.x) {
            return targetOffset
        }

        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset,
                                         withScrollingVelocity: velocity)
    }

    /**
     * Calculate the next snapping position for a given proposedContentOffset.
     */
    func calculateTargetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withHorizontalScrollingVelocity velocity: CGFloat) -> CGPoint? {
        guard let collectionView = collectionView else {
            return nil
        }
        // We always snap at least one item, even if snapping is disabled. This allows us to use the arrows even
        // when snapping is disabled.
        let pageStep = CGFloat(max(self.snappingStepSize, 1))
        let itemCount = Int(ceil(CGFloat(collectionView.numberOfItems(inSection: 0)) / pageStep))
        let pageWidth = self.itemSizeWithPadding.width * pageStep
        // Round the value to prevent small floating point errors. E.g en offset of 2.000145 would lead to a rounding
        // up when velocity is < 0. This would prevent scrolling.
        var pageIndex = round(proposedContentOffset.x / pageWidth * 10) / 10

        if abs(velocity) < 0.2 {
            // Snap to the nearest. Probably this is where we started from.
            pageIndex = round(pageIndex)
        } else if velocity < 0 {
            // Snap to start of the next closest item on the left.
            pageIndex = max(0, ceil(pageIndex) - 1)
        } else {
            // Snap to start of the next closest item on the right.
            pageIndex = min(floor(pageIndex) + 1, CGFloat(itemCount))
        }
        return CGPoint(x: pageIndex * pageWidth, y: proposedContentOffset.y)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect) ?? []

        guard self.showsSeparators else {
            return layoutAttributes
        }

        var decorationAttributes: [UICollectionViewLayoutAttributes] = []

        // Skip the first cell
        for layoutAttribute in layoutAttributes where layoutAttribute.indexPath.item > 0 {
            let separatorAttribute = UICollectionViewLayoutAttributes(forDecorationViewOfKind: kSeparatorDecorationView,
                                                                      with: layoutAttribute.indexPath)
            let cellFrame = layoutAttribute.frame
            let cellHeight = cellFrame.size.height
            let sepHeight = cellHeight * 0.5
            separatorAttribute.frame = CGRect(x: cellFrame.origin.x - self.minimumLineSpacing,
                                              y: cellFrame.origin.y + (cellHeight - sepHeight)/2,
                                              width: self.minimumLineSpacing,
                                              height: sepHeight)
            separatorAttribute.zIndex = .max
            decorationAttributes.append(separatorAttribute)
        }

        return layoutAttributes + decorationAttributes
    }

}
