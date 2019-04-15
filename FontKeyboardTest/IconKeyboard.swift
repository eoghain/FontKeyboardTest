//
//  IconKeyboard.swift
//  FontKeyboardTest
//
//  Created by Booth, Robert on 4/14/19.
//  Copyright © 2019 Intuit. All rights reserved.
//

import UIKit

protocol KeyboardDelegate: class {
    func keyWasTapped(character: String)
}

class IconKeyboardCell: UICollectionViewCell {
    var iconView: FontkeyboardtestIconView = FontkeyboardtestIconView()
    var icon: String = "" {
        didSet {
            iconView.icon = icon
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                iconView.iconColor = .cyan
            }
            else {
                iconView.iconColor = .darkText
            }
            
            iconView.setNeedsDisplay()
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
        iconView.icon = ""
    }
    
    func setup() {
        backgroundColor = .white
        iconView.backgroundColor = .white
        contentView.addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        iconView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        iconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
}

class IconKeyboard: UIViewController {
    
    public var delegate: KeyboardDelegate?
    
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
        layout.estimatedItemSize = CGSize(width: 100, height: 100)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(IconKeyboardCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        view.addSubview(collectionView)
        collectionView.heightAnchor.constraint(equalToConstant: 230).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension IconKeyboard: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FontkeyboardtestIcon.allIcons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! IconKeyboardCell
        
        cell.icon = FontkeyboardtestIcon.allIcons[indexPath.row]
        cell.backgroundColor = .white
        return cell
    }
}

extension IconKeyboard: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let icon = FontkeyboardtestIcon.allIcons[indexPath.row]
        delegate?.keyWasTapped(character: icon)
    }
}
