//
//  tabbar.swift
//  swipe-tab
//
//  Created by Peter Ajayi on 27/06/2020.
//  Copyright © 2020 Mito.P. All rights reserved.
//

import Foundation
import UIKit
import KDDragAndDropCollectionViews

@objc protocol DraggableViewDelegate: class {
 /*   @objc optional func panGestureDidBegin(_ panGesture:UIPanGestureRecognizer, originalCenter:CGPoint)
    @objc optional func panGestureDidChange(_ panGesture:UIPanGestureRecognizer,originalCenter:CGPoint, translation:CGPoint, velocityInView:CGPoint)
    @objc optional func panGestureStateToOriginal(_ panGesture:UIPanGestureRecognizer,originalCenter:CGPoint,  translation:CGPoint, velocityInView:CGPoint)
 */
    @objc optional func panGestureDidEnd(_ panGesture:UIPanGestureRecognizer, originalCenter:CGPoint, translation:CGPoint, velocityInView:CGPoint)
}

class SwipeTabBar: UIView, DraggableViewDelegate {
  
    private var isDragging: Bool = false
    public var hiddenTabBarItems: [TabItems]!
    public var visibleTabBarItems: [TabItems]!
    
    public var tabBarItems: [TabItems] = [] {
            //when set check for stored version
            didSet {
                hiddenTabBarItems = tabBarItems
                    .filter() {$0.hidden}
                    .sorted {$0.order < $1.order}
                
                visibleTabBarItems = tabBarItems
                    .filter() {!$0.hidden}
                    .sorted {$0.order < $1.order}
                
//                visibleTabItemsCollectionView.reloadData()
                //potentially change width layout here
    //               tabBar.tabBarItems = tabBarItems
            }
       }
    
    public var backgroundColour: UIColor = .blue {
        didSet {
            backgroundColor = backgroundColour
//            visibleTabItemsCollectionView.backgroundColor = .red//backgroundColour
        }
    }
    
    public var hiddenBarBackgroundColour: UIColor = .red {
        didSet {
//            hiddenTabItemsCollectionView.backgroundColor = hiddenBarBackgroundColour
        }
    }
    
    public var itemColor: UIColor = .purple
    
    weak var delegate : DraggableViewDelegate?
    
    public let tabItemHeight: CGFloat = 120
    public var compactScreenSize: CGFloat!
    public var divisibleHeight: CGFloat!

    public var drageStatusDelegate: dragStateStatus!
    
    private(set) var expanded: Bool = false
    private var panGestureRecognizer : UIPanGestureRecognizer?
    private var originalPosition : CGPoint?
    private var originalBottomPosition: CGPoint?
    
//    private var numberOfTabItems: Int = 3
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        delegate = self
        setUpTabBar()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func changeState() {
        
        if isDragging {
            isDragging = false
        }
        else if !isDragging {
            isDragging = true
        }
    }
    
    private func setUpTabBar(){
        //corner radius
        
        //set up swipe gesture
        setPanGestur()
    }
    
    //MARK: - Tab Swipe
    
    open func setPanGestur() {
        isUserInteractionEnabled = true
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        self.addGestureRecognizer(panGestureRecognizer!)
    }
    
    @objc open func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
        
        let expandedHeightPercent = ((compactScreenSize - self.frame.minY) / divisibleHeight)
        drageStatusDelegate.updateOpacity(percent: Float(expandedHeightPercent))
        
        let translation = panGesture.translation(in: superview)
        let velocityInView = panGesture.velocity(in: superview)
        
        if isDragging {
            print("ggggnanna")
            return }
            
        switch panGesture.state {
        case .began:
            originalPosition = self.center
            break
        case .changed:
            if expanded {
            
                self.frame.origin = CGPoint(
                    x: originalPosition!.x - self.bounds.midX,
                    y: originalPosition!.y - self.bounds.midY + max(translation.y, 0)
                )
                drageStatusDelegate.updateHiddenConstraint(by: expandedHeightPercent)
            }
            else {
                
               
                self.frame.origin = CGPoint(
                   x: originalPosition!.x - self.bounds.midX,
                   y: originalPosition!.y  - self.bounds.midY + max(translation.y, -80)
                    )
             
                drageStatusDelegate.updateHiddenConstraint(by: expandedHeightPercent)

                
            }
            break
        case .ended:
            delegate?.panGestureDidEnd?(panGesture, originalCenter: originalPosition!, translation: translation, velocityInView: velocityInView)

            break
        default:
            break
        }
    }
    
    func panGestureDidEnd(_ panGesture: UIPanGestureRecognizer, originalCenter: CGPoint, translation: CGPoint, velocityInView: CGPoint) {

        var center: CGPoint = originalCenter
        
        if !expanded {
            if translation.y < -50 {
                center = CGPoint(x: originalCenter.x, y: originalCenter.y - 80)
                expanded = true
                drageStatusDelegate.updateBarPosition(expanded: true)
                drageStatusDelegate.updateOpacity(percent: 1)
                drageStatusDelegate.updateHiddenConstraint(by: 1)
            }
            else {
                drageStatusDelegate.updateOpacity(percent: .zero)
                drageStatusDelegate.updateHiddenConstraint(by: .zero)
            }

        }
        else if expanded {
            if translation.y > 50 {
                center = CGPoint(x: originalCenter.x, y: originalCenter.y + 80)
                expanded = false
                drageStatusDelegate.updateOpacity(percent: .zero)
                //drageStatusDelegate.updateBarPosition(expanded: false)
                drageStatusDelegate.updateHiddenConstraint(by: .zero)

            }
            else {
                drageStatusDelegate.updateOpacity(percent: 1)
                drageStatusDelegate.updateHiddenConstraint(by: 1)

            }

        }
        
        print("expanded is \(expanded)")
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.9, options: .curveEaseInOut, animations: {
            self.center = center
        }, completion: nil)
    }

}
