//
//  FirstViewController.swift
//  swipe-tab
//
//  Created by Peter Ajayi on 25/06/2020.
//  Copyright © 2020 Mito.P. All rights reserved.
//

import UIKit
import Foundation
import KDDragAndDropCollectionViews


class ColorCell: UICollectionViewCell {
    
    var label: UILabel?
    
}


class DataItem : Equatable {
    
    var indexes: String
    var colour: UIColor
    init(_ indexes: String, _ colour: UIColor = UIColor.clear) {
        self.indexes    = indexes
        self.colour     = colour
    }
    
    static func ==(lhs: DataItem, rhs: DataItem) -> Bool {
        return lhs.indexes == rhs.indexes && lhs.colour == rhs.colour
    }
}

extension UIColor {
    static var kdBrown:UIColor {
        return UIColor(red: 177.0/255.0, green: 88.0/255.0, blue: 39.0/255.0, alpha: 1.0)
    }
    static var kdGreen:UIColor {
        return UIColor(red: 138.0/255.0, green: 149.0/255.0, blue: 86.0/255.0, alpha: 1.0)
    }
    static var kdBlue:UIColor {
        return UIColor(red: 53.0/255.0, green: 102.0/255.0, blue: 149.0/255.0, alpha: 1.0)
    }
}
let colours = [UIColor.kdBrown, UIColor.kdGreen, UIColor.kdBlue]

class FirstViewController: UIViewController, KDDragAndDropCollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
    
   
   func collectionView(_ collectionView: UICollectionView, cellIsDraggableAtIndexPath indexPath: IndexPath) -> Bool {
         return true
     }
     
     func collectionView(_ collectionView: UICollectionView, cellIsDroppableAtIndexPath indexPath: IndexPath) -> Bool {
           return true
       }
    var firstCollectionView: KDDragAndDropCollectionView! = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = 50
    //        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
                     collectionViewFlowLayout.minimumInteritemSpacing = 5
                     collectionViewFlowLayout.scrollDirection = .horizontal
                     collectionViewFlowLayout.itemSize = CGSize(width: 35, height: 35)
        
        let k = KDDragAndDropCollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen
            .main.bounds.width, height: 260), collectionViewLayout: collectionViewFlowLayout)
        k.backgroundColor = .green
        k.isScrollEnabled = false
        k.tag = 1
        return k
    }()
    var secondCollectionView: KDDragAndDropCollectionView!  = {
            let collectionViewFlowLayout = UICollectionViewFlowLayout()
            collectionViewFlowLayout.minimumLineSpacing = 50
    //        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
                         collectionViewFlowLayout.minimumInteritemSpacing = 5
                         collectionViewFlowLayout.scrollDirection = .horizontal
                         collectionViewFlowLayout.itemSize = CGSize(width: 35, height: 35)
            
            let k = KDDragAndDropCollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen
                .main.bounds.width, height: 260), collectionViewLayout: collectionViewFlowLayout)
//            k.isScrollEnabled = false
        k.backgroundColor = .red
            k.tag = 1
            return k
        }()
    var thirdCollectionView: KDDragAndDropCollectionView!  = {
            let collectionViewFlowLayout = UICollectionViewFlowLayout()
            collectionViewFlowLayout.minimumLineSpacing = 50
    //        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
                         collectionViewFlowLayout.minimumInteritemSpacing = 5
                         collectionViewFlowLayout.scrollDirection = .horizontal
                         collectionViewFlowLayout.itemSize = CGSize(width: 35, height: 35)
            
            let k = KDDragAndDropCollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen
                .main.bounds.width, height: 260), collectionViewLayout: collectionViewFlowLayout)
//            k.isScrollEnabled = false
            k.tag = 1
            return k
        }()
    
    var data : [[DataItem]] = [[DataItem]]()
    
    var dragAndDropManager : KDDragAndDropManager?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // generate some mock data (change in real world project)
        self.data = (0...2).map({ i in (0...20).map({ j in DataItem("\(String(i)):\(String(j))", colours[i])})})
     
        self.dragAndDropManager = KDDragAndDropManager(
            canvas: self.view,
            collectionViews: [firstCollectionView, secondCollectionView, thirdCollectionView]
        )
        
        firstCollectionView.dataSource = self
        secondCollectionView.dataSource = self
        thirdCollectionView.dataSource = self
        
        firstCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: "Cell")
        secondCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: "Cell")
        thirdCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(firstCollectionView)
        view.addSubview(secondCollectionView)
        view.addSubview(thirdCollectionView)
        
        firstCollectionView.translatesAutoresizingMaskIntoConstraints = false
        firstCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        firstCollectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        firstCollectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        firstCollectionView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
        secondCollectionView.translatesAutoresizingMaskIntoConstraints = false
        secondCollectionView.topAnchor.constraint(equalTo: firstCollectionView.bottomAnchor).isActive = true
        secondCollectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        secondCollectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        secondCollectionView.heightAnchor.constraint(equalToConstant: 90).isActive = true

        thirdCollectionView.translatesAutoresizingMaskIntoConstraints = false
        thirdCollectionView.topAnchor.constraint(equalTo: secondCollectionView.bottomAnchor).isActive = true
        thirdCollectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        thirdCollectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
//        thirdCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        thirdCollectionView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
        
    }

    
    // MARK : UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[collectionView.tag].count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ColorCell
        
        let dataItem = data[collectionView.tag][indexPath.item]
            let ind = String(indexPath.item)
        cell.label?.text = ind + "\n\n" + dataItem.indexes
        cell.backgroundColor = dataItem.colour
        cell.roundCorners(.allCorners, radius: 20)
        cell.isHidden = false
        
        if let kdCollectionView = collectionView as? KDDragAndDropCollectionView {
            
            if let draggingPathOfCellBeingDragged = kdCollectionView.draggingPathOfCellBeingDragged {
                
                if draggingPathOfCellBeingDragged.item == indexPath.item {
                    
                    cell.isHidden = true
                    
                }
            }
        }
        
        return cell
    }

    // MARK : KDDragAndDropCollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, dataItemForIndexPath indexPath: IndexPath) -> AnyObject {
        return data[collectionView.tag][indexPath.item]
    }
    func collectionView(_ collectionView: UICollectionView, insertDataItem dataItem : AnyObject, atIndexPath indexPath: IndexPath) -> Void {
        
        if let di = dataItem as? DataItem {
            data[collectionView.tag].insert(di, at: indexPath.item)
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, deleteDataItemAtIndexPath indexPath : IndexPath) -> Void {
        data[collectionView.tag].remove(at: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, moveDataItemFromIndexPath from: IndexPath, toIndexPath to : IndexPath) -> Void {
        
        let fromDataItem: DataItem = data[collectionView.tag][from.item]
        data[collectionView.tag].remove(at: from.item)
        data[collectionView.tag].insert(fromDataItem, at: to.item)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, indexPathForDataItem dataItem: AnyObject) -> IndexPath? {
        
        guard let candidate = dataItem as? DataItem else { return nil }
        
        for (i,item) in data[collectionView.tag].enumerated() {
            if candidate != item { continue }
            return IndexPath(item: i, section: 0)
        }
        
        return nil
        
    }
    

}
