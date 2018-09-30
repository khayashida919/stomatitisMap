//
//  CornerButton.swift
//  stomatitisMap
//
//  Created by khayashida on 2018/08/19.
//  Copyright © 2018 khayashida. All rights reserved.
//

import UIKit

@IBDesignable
final class CornerButton: UIButton {

    @IBInspectable var textColor: UIColor?
    
    @IBInspectable var cornerRadius: CGFloat = 15 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

}
