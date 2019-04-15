//
//  IconPicker.swift
//  FontKeyboardTest
//
//  Created by Rob Booth on 4/14/19.
//  Copyright © 2019 Intuit. All rights reserved.
//

import UIKit

protocol IconPickerDelegate {
    func iconPicker(_ picker: IconPicker, selected: FontkeyboardtestIconEnum)
}

class IconPicker: UIViewController {

    public var delegate: IconPickerDelegate?
    
    private let iconView = FontkeyboardtestIconView()
    private let textField = UITextField()
    private let iconKeyboard = IconKeyboard()
    
    @IBInspectable public var iconString: String = "" {
        didSet {
            iconView.icon = FontkeyboardtestIconEnum.init(rawValue: iconString)
        }
    }
    
    @IBInspectable public var iconColor: UIColor = .darkText {
        didSet {
            iconView.iconColor = iconColor
        }
    }
    
    public var icon: FontkeyboardtestIconEnum = .missingIcon {
        didSet {
            iconView.icon = icon
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(textField)
        textField.inputView = iconKeyboard.view
        iconKeyboard.delegate = self
        textField.alpha = 0
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        view.addSubview(iconView)
        iconView.backgroundColor = .white
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        iconView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        iconView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        iconView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        iconView.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
    }

    // MARK: - Gesture Recognizers
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        else {
            textField.becomeFirstResponder()
        }
    }
}

extension IconPicker: IconKeyboardDelegate {
    func selected(icon: FontkeyboardtestIconEnum) {
        iconView.icon = icon
        delegate?.iconPicker(self, selected: icon)
    }
}
