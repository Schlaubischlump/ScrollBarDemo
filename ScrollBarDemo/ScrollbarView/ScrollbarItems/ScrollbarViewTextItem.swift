//
//  ScrollbarViewTextItem.swift
//  ScrollBarDemo
//
//  Created by David Klopp on 29.07.22.
//

import UIKit

final public class ScrollbarViewTextItem: ScrollbarViewItem {

    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    public var bodyLabel: UIView = UIView()

    public lazy var footerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    public override func setup() {
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.bodyLabel)
        self.contentView.addSubview(self.footerLabel)
    }

    public override func layoutInFrame(_ frame: CGRect) {
        self.titleLabel.frame = frame.insetBy(dx: 10, dy: 0)
    }

    public override func prepareForReuse() {
        self.titleLabel.text = nil
        self.footerLabel.text = nil
    }
}
