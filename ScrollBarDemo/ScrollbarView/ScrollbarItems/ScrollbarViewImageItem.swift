//
//  ScrollbarViewImageItem.swift
//  ScrollBarDemo
//
//  Created by David Klopp on 29.07.22.
//

import UIKit

final public class ScrollbarViewImageItem: ScrollbarViewItem {

    private let imageView = UIImageView()

    public var image: UIImage? {
        get {
            return self.imageView.image
        }
        set(newValue) {
            self.imageView.image = newValue
        }
    }

    public override func setup() {
        self.imageView.clipsToBounds = true
        self.contentView.addSubview(self.imageView)
    }

    public override func layoutInFrame(_ frame: CGRect) {
        let padding = 10.0
        self.imageView.frame = frame.insetBy(dx: padding, dy: padding)
        self.imageView.layer.cornerRadius = 10
        self.imageView.layer.borderWidth = 1.0
        self.imageView.layer.borderColor = UIColor.separator.cgColor
    }

    public override func prepareForReuse() {
        self.image = nil
    }
}
