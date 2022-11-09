//
//  ViewController.swift
//  ScrollBarDemo
//
//  Created by David Klopp on 27.07.22.
//

import UIKit

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(), green: .random(), blue:  .random(), alpha: 1.0)
    }
}

extension UIImage {
    convenience init?(text: String?, color: UIColor, size: CGSize = CGSize(width: 100, height: 100)) {
        let frame = CGRect(origin: .zero, size: size)
        let font = UIFont.boldSystemFont(ofSize: 400)
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = color
        nameLabel.textColor = .white
        nameLabel.font = font
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.numberOfLines = 0
        nameLabel.minimumScaleFactor = 0.2
        nameLabel.baselineAdjustment = .alignCenters
        nameLabel.textAlignment  = .center
        nameLabel.text = text
        UIGraphicsBeginImageContextWithOptions(frame.size, true, 0.0)
        if let currentContext = UIGraphicsGetCurrentContext() {
            nameLabel.layer.render(in: currentContext)
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

class ViewController: UIViewController {

    var textScroller: ScrollbarView?

    var imageScroller: ScrollbarView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let textScroller = ScrollbarView(frame: CGRect(x: 0, y: 100, width: 0, height: 100))
        textScroller.register(itemClass: ScrollbarViewTextItem.self, forItemWithReuseIdentifier: "Cell")
        textScroller.dataSource = self
        textScroller.delegate = self
        textScroller.showsArrows = true
        textScroller.showsSeparators = true
        textScroller.autohideArrows = false
        textScroller.itemSizingBehaviour = .fixed(150)
        textScroller.snappingStepSize = 0
        self.view.addSubview(textScroller)

        let imageScroller = ScrollbarView(frame: CGRect(x: 0, y: textScroller.frame.maxY + 100, width: 0, height: 0))
        imageScroller.register(itemClass: ScrollbarViewImageItem.self, forItemWithReuseIdentifier: "ImageCell")
        imageScroller.dataSource = self
        imageScroller.delegate = self
        imageScroller.showsArrows = true
        imageScroller.showsSeparators = false
        imageScroller.autohideArrows = false
        imageScroller.itemSizingBehaviour = .dynamic(2)
        imageScroller.snappingStepSize = 2
        imageScroller.isScrollEnabled = true
        self.view.addSubview(imageScroller)

        self.imageScroller = imageScroller
        self.textScroller = textScroller
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewDidLayoutSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.textScroller?.frame.size.width = self.view.bounds.width

        // Do whatever it takes to keep the image aspect ratio when we resize the view.
        let targetFrame = self.view.bounds
        let itemSize = self.imageScroller?.calculateItemSize(inFrame: targetFrame)
        let width = itemSize?.width ?? 0
        self.imageScroller?.frame.size = CGSize(width: targetFrame.width, height: width * 0.7)
    }

}

extension ViewController: ScrollbarViewDataSource {
    func numberOfItems(in scrollbarView: ScrollbarView) -> Int {
        return 7
    }

    func scrollbarView(_ scrollbarView: ScrollbarView, itemAtIndex index: Int) -> ScrollbarViewItem {
        if scrollbarView == self.imageScroller {
            let item = scrollbarView.dequeueReusableItem(withReuseIdentifier: "ImageCell",
                                                         for: index) as? ScrollbarViewImageItem
            let itemSize = scrollbarView.calculateItemSize(inFrame: self.view.bounds)
            item?.image = UIImage(text: "\(index + 1)", color: .random(), size: itemSize)
            return item!
        }

        let item = scrollbarView.dequeueReusableItem(withReuseIdentifier: "Cell", for: index) as? ScrollbarViewTextItem
        item?.backgroundColor = .clear
        item?.titleLabel.text = "\(index + 1) and some more text and more and more and even more and even even more !!!"

        return item!
    }
}

extension ViewController: ScrollbarViewDelegate {
    func scrollbarView(_ scrollbarView: ScrollbarView, didSelectItemAtIndex index: Int) {
        print("Did select item: \(index)")
    }
}

