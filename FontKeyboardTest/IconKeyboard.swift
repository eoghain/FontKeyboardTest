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
    func selected(icon: FontkeyboardtestIconEnum)
}

class IconKeyboardCell: UICollectionViewCell {
    var iconView: FontkeyboardtestIconView = FontkeyboardtestIconView()
    var icon: FontkeyboardtestIconEnum = .missingIcon {
        didSet {
            iconView.icon = icon
        }
    }
    
//    var icon: String = "" {
//        didSet {
//            iconView.icon = icon
//        }
//    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                iconView.iconColor = .cyan
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
        
        // Round and Shadow
//        contentView.layer.cornerRadius = 10
//        contentView.layer.borderWidth = 1.0
//        contentView.layer.borderColor = UIColor.clear.cgColor
//        contentView.layer.masksToBounds = true
//
//        layer.shadowColor = UIColor.lightGray.cgColor
//        layer.shadowOffset = CGSize(width: 0, height: 2.0)
//        layer.shadowRadius = 10
//        layer.shadowOpacity = 1.0
//        layer.masksToBounds = false
//        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
//        layer.backgroundColor = UIColor.clear.cgColor
        
        // IconView
        iconView.backgroundColor = .white
        contentView.addSubview(iconView)
        
        // Round and Shadow
//        iconView.clipsToBounds = false
//        iconView.layer.cornerRadius = 10.0
//        iconView.layer.shadowColor = UIColor.black.cgColor
//        iconView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        iconView.layer.shadowOpacity = 0.5
//        iconView.layer.shadowRadius = 5
//        iconView.layer.shadowPath = UIBezierPath(roundedRect: iconView.bounds, cornerRadius: iconView.layer.cornerRadius).cgPath
//        iconView.layer.masksToBounds = true
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        iconView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        iconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
    }
}

class IconKeyboard: UIViewController {
    
    public var delegate: IconKeyboardDelegate?
    
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
        view.backgroundColor = .lightGray
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.estimatedItemSize = CGSize(width: 150, height: 150)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(IconKeyboardCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension IconKeyboard: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FontkeyboardtestIconEnum.allCasesButMissing.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! IconKeyboardCell
        
        cell.icon = FontkeyboardtestIconEnum.allCasesButMissing[indexPath.row]
        
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
        delegate?.selected(icon: FontkeyboardtestIconEnum.allCasesButMissing[indexPath.row])
    }
}
