//
//  IconKeyboard.swift
//  FontKeyboardTest
//
//  Created by Booth, Robert on 4/14/19.
//  Copyright © 2019 Intuit. All rights reserved.
//

import UIKit
import QuartzCore

protocol IconKeyboardDelegate: class {
    func selected(icon: FontkeyboardtestIcon)
}

class IconKeyboardCell: UICollectionViewCell {
    var selectionColor: UIColor = .cyan
    var iconView: FontkeyboardtestIconView = FontkeyboardtestIconView()
    var icon: FontkeyboardtestIcon = .missingIcon {
        didSet {
            iconView.icon = icon
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                iconView.iconColor = selectionColor
            }
            else {
                iconView.iconColor = .darkText
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        iconView.icon = nil
        isSelected = false
    }
    
    func setup() {
        backgroundColor = .clear
        contentView.backgroundColor = .white
        
        // IconView
        iconView.backgroundColor = .white
        contentView.addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        iconView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        iconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
    }
}

class IconKeyboard: UIViewController {
    
    public var delegate: IconKeyboardDelegate?
    public var selectionColor: UIColor = .cyan
    
    private var cellIdentifier = "iconButton"
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        view.backgroundColor = .clear
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.estimatedItemSize = CGSize(width: 95, height: 95)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(IconKeyboardCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension IconKeyboard: UICollectionViewDelegateFlowLayout {
}

extension IconKeyboard: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FontkeyboardtestIcon.allCasesButMissing.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! IconKeyboardCell
        
        cell.icon = FontkeyboardtestIcon.allCasesButMissing[indexPath.row]
        
        // Selection Color
        cell.selectionColor = selectionColor
        
        // Round & Shadow
        cell.contentView.layer.cornerRadius = 10.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width:0,height: 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 0.8
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
        
        return cell
    }
}

extension IconKeyboard: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.selected(icon: FontkeyboardtestIcon.allCasesButMissing[indexPath.row])
    }
}
