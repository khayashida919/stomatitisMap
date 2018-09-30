//
//  UIScrollView+extension.swift
//  stomatitisMap
//
//  Created by khayashida on 2018/09/23.
//  Copyright © 2018 khayashida. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
    }
}

extension UICollectionView {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
    }
}

//extension UIView {
//    override open func hitTest(_ point: CGPoint,with event: UIEvent?) -> UIView? {
//
//    }
//}
