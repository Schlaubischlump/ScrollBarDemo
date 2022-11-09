//
//  ScrollbarView.swift
//  ScrollBarDemo
//
//  Created by David Klopp on 27.07.22.
//

import UIKit

let kArrowWidth: CGFloat = 50

public class ScrollbarView: UIView {
    public enum ItemSizingBehaviour {
        case fixed(_ minimumItemWidth: CGFloat)
        case dynamic(_ itemsPerPage: Int)
    }

    /// Enable or disable the scroll. You can still use the arrows to navigate.
    public var isScrollEnabled: Bool = true {
        didSet { self.collectionView.isScrollEnabled = self.isScrollEnabled }
    }

    /// Show a separator between each item and at the top of the view.
    public var showsSeparators: Bool = true {
        didSet {
            let layout = self.collectionView.collectionViewLayout as? ScrollbarViewFlowLayout
            layout?.showsSeparators = self.showsSeparators
            self.separatorTop.isHidden = !self.showsSeparators
        }
    }

    /// Autohide the paging arrows and only display them on mouse hover.
    public var autohideArrows: Bool = false {
        didSet {
            self.leftArrow.alpha = self.autohideArrows ? 0 : 1
            self.rightArrow.alpha = self.autohideArrows ? 0 : 1
        }
    }

    /// Toggle the visibility of the paging arrows.
    public var showsArrows: Bool = true {
        didSet {
            self.leftArrow.isHidden = !self.showsArrows
            self.rightArrow.isHidden = !self.showsArrows
        }
    }

    /// The behaviour that defines how the item size is calculated.
    public var itemSizingBehaviour: ItemSizingBehaviour = .dynamic(2)

    /// The amount of items to page. Use 0 to disable paging
    public var snappingStepSize: Int {
        get { return self.collectionView.snappingStepSize }
        set { self.collectionView.snappingStepSize = newValue }
    }

    public weak var delegate: ScrollbarViewDelegate?

    public weak var dataSource: ScrollbarViewDataSource?

    private let collectionView = ScrollbarCollectionView()

    private lazy var separatorTop: UIView = {
        let sep = UIView()
        sep.backgroundColor = .separator
        return sep
    }()

    private let leftArrow = ScrollbarArrowView(direction: .left)
    private let rightArrow = ScrollbarArrowView(direction: .right)

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
        self.reloadData()
        self.layoutInFrame(self.bounds)
    }

    override public func layoutSubviews() {
        print("Layout subviews...")
        super.layoutSubviews()
        self.layoutInFrame(self.bounds)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.addSubview(self.collectionView)
        self.addSubview(self.separatorTop)
        self.addSubview(self.leftArrow)
        self.addSubview(self.rightArrow)

        if #available(iOS 13.0, *) {
            let hoverGesture = UIHoverGestureRecognizer(target: self, action: #selector(self.onHover(_:)))
            self.addGestureRecognizer(hoverGesture)
        }

        self.leftArrow.action = self.collectionView.snapToPrevious
        self.rightArrow.action = self.collectionView.snapToNext
    }

    private func layoutInFrame(_ frame: CGRect) {
        print("Layout in frame: ", frame)
        let spacing = 20.0
        let height = frame.height

        // Save the currentOffset.x inside the collectionView.
        let itemOffset = self.collectionView.itemOffset

        // Calculate the new frame for the collectionView.
        let collectionViewFrame = frame.insetBy(dx: kArrowWidth + spacing, dy: 0)

        // Set the new item height before changing the collectionView frame. This prevents the warning, that the item
        // height is bigger than the collectionView height.
        self.collectionView.scrollbarViewFlowLayout?.itemSize.height = collectionViewFrame.height

        // Update the frames of all subviews.
        self.collectionView.frame = collectionViewFrame
        self.separatorTop.frame = frame.insetBy(dx: kArrowWidth, dy: 0)
        self.separatorTop.frame.size.height = 1

        self.leftArrow.frame = CGRect(x: 0, y: 0, width: kArrowWidth, height: height)
        self.rightArrow.frame = CGRect(x: collectionViewFrame.maxX + spacing, y: 0, width: kArrowWidth, height: height)

        // Resize the items according to the sizin behaviour.
        let collectionFrame = self.collectionView.bounds
        self.collectionView.scrollbarViewFlowLayout?.itemSize.width = self.calculateItemWidth(inFrame: collectionFrame)

        // Fix the contentOffset.x if dynamic sizing is activated.
        if !itemOffset.isNaN, let _ = self.dataSource, case .dynamic = self.itemSizingBehaviour {
            self.collectionView.itemOffset = itemOffset
        }

        // Enable or disable the paging arrows.
        self.updateArrowAvailability()
    }

    /// The correct item size based on the current item sizing behaviour and the size of the collection view.
    public func calculateItemSize(inFrame: CGRect) -> CGSize {
        let width = self.calculateItemWidth(inFrame: inFrame)
        return CGSize(width: width, height: self.collectionView.bounds.height)
    }

    private func calculateItemWidth(inFrame: CGRect) -> CGFloat {
        guard let _ = self.dataSource else { return 0 }

        let collectionView = self.collectionView
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let lineWidth = layout?.minimumLineSpacing ?? 0
        let numItems = CGFloat(collectionView.numberOfItems(inSection: 0))

        let collectionViewWidth = inFrame.width

        if case .dynamic(let numItemsPerPage) = self.itemSizingBehaviour {
            // Fill the screen equally
            return (collectionViewWidth - (CGFloat(numItemsPerPage - 1) * lineWidth)) / CGFloat(numItemsPerPage)
        } else if case .fixed(let minimumItemWidth) = self.itemSizingBehaviour {
            let contentWidth = (minimumItemWidth + lineWidth) * (numItems - 1) + minimumItemWidth
            // If the collectionView width is greater than the content, fill the screen equally.
            if collectionViewWidth > contentWidth {
                return (collectionViewWidth - ((numItems - 1) * lineWidth)) / numItems
            }
            // Use the minimumItemWidth defined by the user.
            return minimumItemWidth
        }
        // This should never happen
        return 0
    }

    // MARK: - public

    public func reloadData() {
        self.collectionView.reloadData()
    }

    public func invalidateLayout() {
        self.layoutInFrame(self.bounds)
    }

    public func dequeueReusableItem(withReuseIdentifier identifier: String, for index: Int) -> ScrollbarViewItem {
        let indexPath = IndexPath(row: index, section: 0)
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        return cell as! ScrollbarViewItem
    }

    public func register(itemClass: AnyClass, forItemWithReuseIdentifier identifier: String) {
        if !itemClass.isSubclass(of: ScrollbarViewItem.self) {
            fatalError("Only subclasses of 'ScrollbarViewItem' can be registered.")
        }
        self.collectionView.register(itemClass, forCellWithReuseIdentifier: identifier)
    }

    // MARK: - Interaction

    @available(iOS 13.0, *)
    @objc func onHover(_ recognizer: UIHoverGestureRecognizer) {
        // Fade in or out the paging arrows
        switch recognizer.state {
        case .began, .changed:
            if self.autohideArrows && self.showsArrows {
                UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState]) {
                    self.leftArrow.alpha = 1
                    self.rightArrow.alpha = 1
                }
            }
        default:
            if self.autohideArrows && self.showsArrows {
                UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState]) {
                    self.leftArrow.alpha = 0
                    self.rightArrow.alpha = 0
                }
            }
        }
    }

    private func updateArrowAvailability() {
        let relativeContentOffset = self.collectionView.relativeContentOffset.x
        self.leftArrow.isUserInteractionEnabled = relativeContentOffset > 0.0
        self.rightArrow.isUserInteractionEnabled = relativeContentOffset < 1.0
    }
}

extension ScrollbarView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.scrollbarView(self, didSelectItemAtIndex: indexPath.row)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateArrowAvailability()
        self.delegate?.scrollViewDidScroll?(scrollView)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.delegate?.scrollViewWillBeginDragging?(scrollView)
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.delegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity,
                                                  targetContentOffset: targetContentOffset)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {


        self.delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.delegate?.scrollViewWillBeginDecelerating?(scrollView)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.delegate?.scrollViewWillBeginDecelerating?(scrollView)
    }

    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        self.delegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.delegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
}

extension ScrollbarView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = self.dataSource else {
            fatalError("numberOfItems(in scrollbarView:) can not be called, since no ScrollbarViewDataSource is set!")
        }
        return dataSource.numberOfItems(in: self)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = self.dataSource else {
            fatalError("scrollbarView(_:itemAtIndex:) can not be called, since no ScrollbarViewDataSource is set!")
        }
        let item = dataSource.scrollbarView(self, itemAtIndex: indexPath.row)
        return item
    }
}
