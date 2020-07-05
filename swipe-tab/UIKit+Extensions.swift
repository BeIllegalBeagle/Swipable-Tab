//
//  UIKit+Extensions.swift
//  swipe-tab
//
//  Created by Peter Ajayi on 29/06/2020.
//  Copyright © 2020 Mito.P. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
          let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
          let mask = CAShapeLayer()
          mask.path = path.cgPath
          self.layer.mask = mask
      }
}

extension UIImage {
    
    func resized(toWidth width: CGFloat) -> UIImage? {
          let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
          UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
          defer { UIGraphicsEndImageContext() }
          draw(in: CGRect(origin: .zero, size: canvasSize))
          return UIGraphicsGetImageFromCurrentImageContext()
      }
}
extension UIViewController {
    func add(_ child: UIViewController) {
        addChild(child)
//        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        // Just to be safe, we check that this view controller
        // is actually added to a parent before removing it.
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
//        view.removeFromSuperview()
        removeFromParent()
    }
}
