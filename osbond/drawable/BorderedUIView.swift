//
//  BorderedUIView.swift
//  osbond
//
//  Created by gmedia ios dev 2 on 06/03/19.
//  Copyright © 2019 gmedia ios dev 2. All rights reserved.
//

import UIKit

class BorderedUIView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            
            layer.borderColor = borderColor?.cgColor
        }
    }

}
