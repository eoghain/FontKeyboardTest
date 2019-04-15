//
//  IconKeyboard.swift
//  FontKeyboardTest
//
//  Created by Booth, Robert on 4/14/19.
//  Copyright © 2019 Intuit. All rights reserved.
//

import UIKit

class IconInputField: UIViewController {
    
    var iconView: FontkeyboardtestIconView
    var 
    
}

class IconKeyboardCell: UICollectionViewCell {
    var iconView: FontkeyboardtestIconView? = nil
    var icon: String = "" {
        didSet {
            guard let iconView = iconView else { return }
            iconView.icon = icon
        }
    }
    
    override func prepareForReuse() {
        if iconView == nil { addIconView() }
        iconView?.icon = ""
    }
    
    func addIconView() {
        let iconView = FontkeyboardtestIconView()
        
        contentView.addSubview(iconView)
        iconView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        iconView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        iconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
}

class IconKeyboard: UIViewController {
    
    private var cellIdentifier = "iconButton"
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(IconKeyboardCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        collectionView.dataSource = self
    }
    
}

extension IconKeyboard: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FontkeyboardtestIcon.allIcons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! IconKeyboardCell
        
        cell.icon = FontkeyboardtestIcon.allIcons[indexPath.row]
        return cell
    }
}
