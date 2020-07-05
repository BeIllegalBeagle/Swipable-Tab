//
//  SecondViewController.swift
//  swipe-tab
//
//  Created by Peter Ajayi on 25/06/2020.
//  Copyright © 2020 Mito.P. All rights reserved.
//

import UIKit
import KDDragAndDropCollectionViews

// func mock() -> [TabItems] {
//
//     return [
//            TabItems(name: "home", order: 0, image: "first", hidden: false),
//
//            TabItems(name: "no", order: 1, image: "second", hidden: false),
//            TabItems(name: "setting", order: 2, image: "first", hidden: false),
//            TabItems(name: "like", order: 3, image: "first", hidden: false),
//
//            TabItems(name: "order", order: 0, image: "first", hidden: true),
////            TabItems(name: "me", order: 1, image: "person.fill", hidden: true),
//        ]
//    }

func checkNotch() -> Bool {
     if UIDevice().userInterfaceIdiom == .phone {
     switch UIScreen.main.nativeBounds.height {
         case 1136:
             print("iPhone 5 or 5S or 5C")
             return false
         case 1334:
             print("iPhone 6/6S/7/8")
             return false
         case 1920, 2208:
             print("iPhone 6+/6S+/7+/8+")
              return false
         case 2436:
             print("iPhone X/XS/11 Pro")
         return true
         case 2688:
             print("iPhone XS Max/11 Pro Max")
          return true
         case 1792:
             print("iPhone XR/ 11 ")
         return true
         default:
             print("Unknown")
         }
     }
    return false
 }



protocol dragStateStatus {
    
    func updateBarPosition(expanded: Bool)
    func updateOpacity(percent: Float)
    func updateHiddenConstraint(by: CGFloat)
}

enum notificationDisplayType {
    case dot, iOSbadge
}

class SecondViewController: UIViewController, KDDragAndDropCollectionViewDataSource, UICollectionViewDelegate, dragStateStatus, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
    
    
    private let screenHeight = UIScreen.main.bounds.size.height
    
    private let cellId = "TabCell"
    private var hasNotch: Bool = checkNotch()
    private var currentContext: Int = 0
    
    public var hiddenTabBarItems: [TabItems] = [] {
        didSet {
            let m = hiddenTabBarItems
                .filter() {$0.hidden}
                .sorted {$0.order < $1.order}
            
            hiddenTabBarItems = m
        }
        
    }
    
    public var visibleTabBarItems: [TabItems] = [] {
        didSet{
            let k = visibleTabBarItems
                .filter() {!$0.hidden}
                .sorted {$0.order < $1.order}
            
            visibleTabBarItems = k
        }
    }
    
    private var tabBar: SwipeTabBar = {
        let b = SwipeTabBar()
        b.tag = 117
        b.backgroundColour = .cyan
        b.hiddenBarBackgroundColour = .cyan
        b.layer.cornerRadius = 20
        return b
    }()
 
    public var viewControllers: [UIViewController] = [] {
        didSet {
            for vc in children {
                vc.remove()
            }
            for vc in viewControllers {
                self.add(vc)
            }
        }
    }
    
    public var tabBarItems: [TabItems] = [] {
        //when set check for stored version
        didSet {
            tabBar.hiddenTabBarItems  = tabBarItems
                .filter() {$0.hidden}
                .sorted {$0.order < $1.order}
            
            tabBar.visibleTabBarItems = tabBarItems
                .filter() {!$0.hidden}
                .sorted {$0.order < $1.order}
            
            //potentially change width layout here
//               tabBar.tabBarItems = tabBarItems
        }
   }
    
    public var enableTabItemBackgroundColour: Bool = false
    public var showTabItemTitle: Bool = false
    public var iconSize: CGFloat = 35
    public var maximumOpacity: Float = 0.3
    public var badgeType: notificationDisplayType = .dot
    public var enableOverlay: Bool = false
    
    private var hiddenTopAnchor: NSLayoutConstraint!
    private var tabBarBottomConstraint: NSLayoutConstraint!
    
    private lazy var overlay: CALayer = {
        let layer = CALayer()
        layer.opacity = .zero
        layer.isOpaque = false
        layer.backgroundColor = UIColor.darkGray.cgColor
        return layer
    }()
    
    let visibleTabItemsCollectionView: KDDragAndDropCollectionView! = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = 50
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: -5, left: 20, bottom: 20, right: 20)
        collectionViewFlowLayout.minimumInteritemSpacing = 5
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionViewFlowLayout.itemSize = CGSize(width: 44, height: 44)
        
        let k = KDDragAndDropCollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen
            .main.bounds.width, height: 260), collectionViewLayout: collectionViewFlowLayout)
        k.isScrollEnabled = false
        k.backgroundColor = .cyan
        k.layer.cornerRadius = 20
        k.tag = 1
        return k
    }()
    
    let hiddenContainer: UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen
        .main.bounds.width, height: 260))
        v.backgroundColor = .yellow
        v.roundCorners([.topLeft, .topRight], radius: 20)
            return v
    }()
    
    let hiddenTabItemsCollectionView: KDDragAndDropCollectionView! = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = 30
        collectionViewFlowLayout.minimumInteritemSpacing = 5
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionViewFlowLayout.itemSize = CGSize(width: 60, height: 60)
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: -5, left: 20, bottom: 10, right: 20)

        let k = KDDragAndDropCollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen
            .main.bounds.width * 1.5, height: 260), collectionViewLayout: collectionViewFlowLayout)
        k.roundCorners([.topLeft, .topRight], radius: 20)
        k.backgroundColor = .yellow
        k.showsHorizontalScrollIndicator = false
        k.tag = 2
        return k
    }()
    
    lazy var overlayContainer: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        view.isUserInteractionEnabled = false
        return view
    }()
    
    public let tabItemHeight: CGFloat = checkNotch()
        ? 170
        : 150
    
    var dragAndDropManager : KDDragAndDropManager?
    private var currentIndex = 0
    
    @objc func touched(){
        print("you touched me thanks")
    }
    
    @objc func dismissCheck() {
        if tabBar.expanded {
            print("compress")
//            tabBar.compress()
        } else {
            print("not compped")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dragAndDropManager = KDDragAndDropManager(
            canvas: self.view,
            collectionViews: [visibleTabItemsCollectionView, hiddenTabItemsCollectionView,]
        )
        
        
        
        
        let vc1 = homeViewController()
        vc1.view.backgroundColor = .red
        
        let btn = UIButton(frame: CGRect(x: 80, y: 50, width: 100, height: 70))
        btn.backgroundColor = .orange
        btn.addTarget(self, action: #selector(touched), for: .touchUpInside)
        btn.setTitle("AGGHHH", for: .normal)
        vc1.view.addSubview(btn)
//        UIGestureRecognizer(target: self, action: #selector(dismissCheck))
//        vc1.view.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(dismissCheck)))
//        btn.centerXAnchor.constraint(equalTo: vc1.view.centerXAnchor).isActive = true
//        btn.centerYAnchor.constraint(equalTo: vc1.view.centerYAnchor).isActive = true
        
        let vc2 = orderViewController()
        vc2.view.backgroundColor = .orange
        vc2.view.addGestureRecognizer(UIGestureRecognizer(target: vc2, action: #selector(dismissCheck)))

        let vc3 = homeViewController()
        vc3.view.backgroundColor = .green
        vc3.view.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(dismissCheck)))

        let vc4 = orderViewController()
        vc4.view.backgroundColor = .purple
        vc4.view.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(dismissCheck)))

        let vc5 = homeViewController()
        vc5.view.backgroundColor = .blue
        
        viewControllers = [vc1, vc2, vc3, vc4, vc5]
        
        tabBarItems = [
            TabItems(name: "home", order: 0, image: "first", hidden: false, hashValue: vc1.hashValue),
            TabItems(name: "noer", order: 1, image: "second", hidden: false, hashValue: vc2.hashValue),
            TabItems(name: "setting", order: 2, image: "first", hidden: false, hashValue: vc3.hashValue),
            TabItems(name: "like", order: 3, image: "first", hidden: false, hashValue: vc4.hashValue),
            TabItems(name: "order", order: 0, image: "first", hidden: true, hashValue: vc5.hashValue),
        ]
        
        for i in viewControllers {
            i.view.tag = 111
        }
        
        setUpTabBar()
        setUpOverlay()
        addCollectionData()
        setCollectionViews()
    }
    
    func setUpOverlay() {
        
        if enableOverlay {
            overlayContainer.layer.addSublayer(overlay)
            overlay.frame = self.view.frame
            
            view.insertSubview(overlayContainer, belowSubview: tabBar)
            overlayContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            overlayContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            overlayContainer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            overlayContainer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            overlayContainer.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            overlayContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }

    }

    func setUpTabBar() {
        
        view.addSubview(tabBar)
        
        tabBar.drageStatusDelegate = self
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        
        let equalTo = hasNotch
            ? view.bottomAnchor
            : view.safeAreaLayoutGuide.bottomAnchor
        
        tabBarBottomConstraint = tabBar.bottomAnchor.constraint(equalTo: equalTo, constant: 80)
        tabBarBottomConstraint.isActive = true
        tabBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tabBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tabBar.heightAnchor.constraint(equalToConstant: tabItemHeight + 5).isActive = true

        tabBar.compactScreenSize = screenHeight - 75
        tabBar.divisibleHeight = hasNotch
            ? 100
            : 80
    }
    
    func updateBarPosition(expanded: Bool) {
     
        if expanded {
            tabBarBottomConstraint.constant = 0
        }
        else {
            tabBarBottomConstraint.constant = 80
        }
    }
    
    func updateOpacity(percent: Float) {
        
        overlay.opacity = percent * maximumOpacity
    }
    
    func updateHiddenConstraint(by: CGFloat) {
        let newHeightConst: CGFloat = -30
        
        hiddenTopAnchor.constant = by * newHeightConst

//        UIView.animateKeyframes(withDuration: 0.3, delay: 0.1, options: .calculationModeLinear, animations: {
//            self.hiddenTabItemsCollectionView.setNeedsLayout()//layoutIfNeeded()
//
//        }) { _ in
//
//        }
         UIView.animate(withDuration: 0.3) {
            self.hiddenContainer.layoutIfNeeded()
         }
     }
    
    func setCollectionViews() {
        
        tabBar.addSubview(visibleTabItemsCollectionView)
        tabBar.addSubview(hiddenContainer)
          
          visibleTabItemsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        visibleTabItemsCollectionView.topAnchor.constraint(equalTo: tabBar.safeAreaLayoutGuide.topAnchor).isActive = true
        visibleTabItemsCollectionView.leftAnchor.constraint(equalTo: tabBar.safeAreaLayoutGuide.leftAnchor).isActive = true
        visibleTabItemsCollectionView.rightAnchor.constraint(equalTo: tabBar.safeAreaLayoutGuide.rightAnchor).isActive = true
        visibleTabItemsCollectionView.heightAnchor.constraint(equalToConstant: tabItemHeight/1.7).isActive = true
          
        hiddenContainer.translatesAutoresizingMaskIntoConstraints = false
        hiddenTopAnchor = hiddenContainer.topAnchor.constraint(equalTo: visibleTabItemsCollectionView.bottomAnchor)
        hiddenTopAnchor.isActive = true
        hiddenContainer.leftAnchor.constraint(equalTo: tabBar.leftAnchor).isActive = true
        hiddenContainer.rightAnchor.constraint(equalTo: tabBar.rightAnchor).isActive = true
        let hiddenHeight = visibleTabItemsCollectionView.frame.height / 2.4
        hiddenContainer.heightAnchor.constraint(equalToConstant: hiddenHeight).isActive = true
        
        hiddenContainer.addSubview(hiddenTabItemsCollectionView)
        
        hiddenTabItemsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        hiddenTabItemsCollectionView.topAnchor.constraint(equalTo: hiddenContainer.topAnchor).isActive = true
        hiddenTabItemsCollectionView.leftAnchor.constraint(equalTo: hiddenContainer.leftAnchor).isActive = true
        hiddenTabItemsCollectionView.widthAnchor.constraint(equalToConstant:UIScreen.main.bounds.width * 1.5).isActive = true

        hiddenTabItemsCollectionView.rightAnchor.constraint(equalTo: hiddenContainer.rightAnchor).isActive = true
        hiddenTabItemsCollectionView.bottomAnchor.constraint(equalTo: hiddenContainer.bottomAnchor).isActive = true
        
      }
    
    func addCollectionData() {
        visibleTabItemsCollectionView.register(TabBarItemCell.self, forCellWithReuseIdentifier: cellId)
        hiddenTabItemsCollectionView.register(TabBarItemCell.self, forCellWithReuseIdentifier: cellId)
        visibleTabItemsCollectionView.dataSource = self
        visibleTabItemsCollectionView.delegate = self
        hiddenTabItemsCollectionView.dataSource = self
        hiddenTabItemsCollectionView.delegate = self
    }
    
    func didSelectTab(index: IndexPath, item: TabItems) {
        
        if tabBar.expanded {
            tabBarBottomConstraint.constant = 0
        }
        else {
            tabBarBottomConstraint.constant = 80
        }
        
        if currentIndex == index.item {
            return
        }
        
        currentIndex = index.item
        
        let vc = viewControllers.filter() {$0.hashValue == item.hashValue}.first!
        
//        if vc.isViewLoaded {
            
            for subView in view.subviews {
                if subView.tag == 111 {
                    subView.removeFromSuperview()
                }
                
            }
        
            enableOverlay
                ? view.insertSubview((vc.view)!, belowSubview: overlayContainer)
                : view.insertSubview((vc.view)!, belowSubview: tabBar)
        
//        if enableOverlay {
//            print(view.subviews)
//
//            view.exchangeSubview(at: 0, withSubviewAt: 2)
//        }
            
//        }
        
        if vc.isViewLoaded {
            vc.viewDidAppear(false)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, stylingRepresentationView: UIView) -> UIView? {
        
        stylingRepresentationView.roundCorners(.allCorners, radius: 12)
        return stylingRepresentationView
    }
    
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        switch tabBar.visibleTabBarItems.count {
        case 1:
            return 40
        case 2:
            return 40
        case 3:
            return 40
        case 4:
            return 40
        case 5:
            return 30
        default:
            return 30
        }

    }
    
    func collectionView(_ collectionView: UICollectionView,
               layout collectionViewLayout: UICollectionViewLayout,
               insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView.tag == 1 {
            let cellCount = tabBar.visibleTabBarItems.count
            let totalCellWidth = 44 * cellCount
            let spacing = cellCount == 5
                ? 30
                : 40
            let totalSpacingWidth = spacing * (cellCount - 1)

            let leftInset = (collectionView.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
            let rightInset = leftInset
            
            return UIEdgeInsets(top: -5, left: leftInset, bottom: 20, right: rightInset)
        }
        else {
            return UIEdgeInsets(top: -5, left: 20, bottom: 10, right: 20)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 1 {
            didSelectTab(index: indexPath, item: tabBar.visibleTabBarItems[indexPath.item])
        }
        else if collectionView.tag == 2 {
            didSelectTab(index: indexPath, item: tabBar.hiddenTabBarItems[indexPath.item])
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellIsDraggableAtIndexPath indexPath: IndexPath) -> Bool {
        return tabBar.expanded
    }
    
    func collectionView(_ collectionView: UICollectionView, cellIsDroppableAtIndexPath indexPath: IndexPath) -> Bool {
          return true
      }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           if collectionView.tag == 1 {
                 return tabBar.visibleTabBarItems.count
             }
             else if collectionView.tag == 2 {
                 return tabBar.hiddenTabBarItems.count
             }
             
             return 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TabBarItemCell
        
        var dataItem: TabItems!
        cell.reset()
        cell.iconSize = iconSize
        
        if collectionView.tag == 1 {
            dataItem = tabBar.visibleTabBarItems[indexPath.item]
            cell.textColour = .green
            cell.nameLabel.textColor = .red
            cell.imageName = dataItem.image
            cell.backgroundColor = .cyan
            if enableTabItemBackgroundColour {
                cell.backgroundColor = .white//backgroundColour

            }
            if showTabItemTitle {
                cell.nameLabel.text = dataItem.name
            }
        }
        else if collectionView.tag == 2 {
            dataItem = tabBar.hiddenTabBarItems[indexPath.item]
            cell.textColour = .black
            cell.imageName = dataItem.image
            cell.backgroundColor = .red
            cell.nameLabel.isHidden = false
            cell.tabIcon.isHidden = false
            cell.nameLabel.text = dataItem.name
            cell.addBorder()
        }
        
        cell.layer.isOpaque = false
        cell.isHidden = false
        
        if let kdCollectionView = collectionView as? KDDragAndDropCollectionView {
            
            if let draggingPathOfCellBeingDragged = kdCollectionView.draggingPathOfCellBeingDragged {
                
                if draggingPathOfCellBeingDragged.item == indexPath.item &&  collectionView.tag == 1 {
                    cell.isHidden = true
                }
                if draggingPathOfCellBeingDragged.item == indexPath.item && currentContext != collectionView.tag {
                    
                    if collectionView.tag == 2 {
                        cell.isHidden = false
                        cell.backgroundColor = .clear
                        cell.tabIcon.isHidden = true
                        cell.nameLabel.isHidden = true
                    }
                }
            
                currentContext = collectionView.tag

            }
        }
        
        return cell
    }

    // MARK : KDDragAndDropCollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, dataItemForIndexPath indexPath: IndexPath) -> AnyObject {

        if collectionView.tag == 1 {
            return tabBar.visibleTabBarItems[indexPath.item]
        }
        else if collectionView.tag ==  2 {
          return tabBar.hiddenTabBarItems[indexPath.item]
        }
              
        return tabBar.visibleTabBarItems.first as AnyObject
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        
        let previewParams = UIDragPreviewParameters()
        let size = collectionView.tag == 1
            ? 44
            : 60
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size, height: size), cornerRadius: 12)
        previewParams.visiblePath = path

        return previewParams
    }
    
    func collectionView(_ collectionView: UICollectionView, insertDataItem dataItem : AnyObject, atIndexPath indexPath: IndexPath) -> Void {
        
        if let di = dataItem as? TabItems {
            if collectionView.tag == 1 {
                  tabBar.visibleTabBarItems.insert(di, at: indexPath.item)
            }
            else if collectionView.tag == 2 {
                tabBar.hiddenTabBarItems.insert(di, at: indexPath.item)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, deleteDataItemAtIndexPath indexPath : IndexPath) -> Void {

        if collectionView.tag == 1 {
            tabBar.visibleTabBarItems.remove(at: indexPath.item)
        }
        else if collectionView.tag == 2 {
            tabBar.hiddenTabBarItems.remove(at: indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveDataItemFromIndexPath from: IndexPath, toIndexPath to : IndexPath) -> Void {
        
        var fromDataItem: TabItems
        
        if collectionView.tag == 1 {
            fromDataItem = tabBar.visibleTabBarItems[from.item]
            tabBar.visibleTabBarItems.remove(at: from.item)
            tabBar.visibleTabBarItems.insert(fromDataItem, at: to.item)
        }
        else if collectionView.tag == 2 {
            fromDataItem = tabBar.hiddenTabBarItems[from.item]
            tabBar.hiddenTabBarItems.remove(at: from.item)
            tabBar.hiddenTabBarItems.insert(fromDataItem, at: to.item)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, indexPathForDataItem dataItem: AnyObject) -> IndexPath? {
    
        guard let candidate = dataItem as? TabItems else { return nil }
        
        if collectionView.tag == 1  {
            for (i,item) in tabBar.visibleTabBarItems.enumerated() {
                if candidate != item { continue }
                return IndexPath(item: i, section: 0)
            }
        }
        else if collectionView.tag == 2 {
            for (i,item) in tabBar.hiddenTabBarItems.enumerated() {
                if candidate != item { continue }
                return IndexPath(item: i, section: 0)
            }
        }
        
        return nil
    }
    
}

