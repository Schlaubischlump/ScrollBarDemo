//
//  ScrollbarItemView.swift
//  ScrollBarDemo
//
//  Created by David Klopp on 27.07.22.
//

import UIKit

open class ScrollbarViewItem: UICollectionViewCell {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func setup() {
        fatalError("'setup' must be overriden by a subclass!")
    }

    open func layoutInFrame(_ frame: CGRect) {
        fatalError("'layoutInFrame(_ :)' must be overriden by a subclass!")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutInFrame(self.contentView.bounds)
    }
}
