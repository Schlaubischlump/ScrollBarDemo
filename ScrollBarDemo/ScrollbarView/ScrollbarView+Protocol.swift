//
//  ScrollbarView+Protocol.swift
//  ScrollBarDemo
//
//  Created by David Klopp on 27.07.22.
//

import UIKit

public protocol ScrollbarViewDelegate: UIScrollViewDelegate {
    func scrollbarView(_ scrollbarView: ScrollbarView, didSelectItemAtIndex index: Int)
}

public protocol ScrollbarViewDataSource: AnyObject {
    func numberOfItems(in scrollbarView: ScrollbarView) -> Int
    func scrollbarView(_ scrollbarView: ScrollbarView, itemAtIndex index: Int) -> ScrollbarViewItem
}

extension ScrollbarViewDelegate {
    func scrollbarView(_ scrollbarView: ScrollbarView, didSelectItemAtIndex index: Int) {}
}
