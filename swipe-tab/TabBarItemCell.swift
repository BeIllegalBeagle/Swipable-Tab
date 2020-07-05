//
//  TabBarItemCell.swift
//  swipe-tab
//
//  Created by Peter Ajayi on 27/06/2020.
//  Copyright © 2020 Mito.P. All rights reserved.
//

import UIKit

class TabBarItemCell: UICollectionViewCell {
    
    public var backgroundColour: UIColor!
    public var textColour: UIColor!
    public var iconSize: CGFloat!
    public var imageName: String? {
        didSet {
            setIcon()
        }
    }
    
    
    public let nameLabel: UILabel = {
        let l = UILabel()
        return l
    }()
    
    var tabIcon: UIImageView!
    
    override init(frame: CGRect) {
             
       super.init(frame: frame)
       configCell()
    }
       
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configCell() {
    
        layer.cornerRadius = 12
       
        addSubview(nameLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 20).isActive = true
        
    }
    
    public func reset() {
        if let img = subviews.filter() {$0.tag == 117}.first {
            img.removeFromSuperview()
        } else {
               return
        }
    }
    
    private func setIcon() {
        
        let image: UIImage!
        image = UIImage(named: imageName!)!
            .resized(toWidth: iconSize)?
            .withTintColor(textColour)
        
        tabIcon = UIImageView(image: image)
//        tabIcon.image = image
        tabIcon.setNeedsDisplay()
        tabIcon.tag = 117
        addSubview(tabIcon)
        
        tabIcon.translatesAutoresizingMaskIntoConstraints = false
        tabIcon.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor).isActive = true
        tabIcon.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor).isActive = true
        tabIcon.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
        tabIcon.heightAnchor.constraint(equalToConstant: iconSize).isActive = true

    
    }
    
    public func addBorder() {
      
        let color = textColour.cgColor
        let shapeLayer = CAShapeLayer()
        let frameSize = bounds.size
        let shapeRect = CGRect(x:0 , y: 0, width: frameSize.width, height: frameSize.height)
        shapeLayer.frame = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 1.5
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [4,3]
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        layer.addSublayer(shapeLayer)
    }
    
}
