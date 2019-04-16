//
//  IconPicker.swift
//  FontKeyboardTest
//
//  Created by Rob Booth on 4/14/19.
//  Copyright © 2019 Intuit. All rights reserved.
//

import UIKit

//protocol IconPickerDelegate {
//    func iconPicker(_ picker: IconPicker, selected: FontkeyboardtestIcon)
//}
//protocol IconPickerControlDelegate {
//    func iconPicker(_ picker: IconPickerControl, selected: FontkeyboardtestIcon)
//}

@IBDesignable
class IconPicker: UIControl {
    
//    public var delegate: IconPickerDelegate?
    
    @IBInspectable var iconString: String = "" {
        didSet {
            icon = FontkeyboardtestIcon(rawValue: iconString)
        }
    }
    
    @IBInspectable var iconColor: UIColor = .darkText {
        didSet {
            iconKeyboard.selectionColor = iconColor
            iconView.iconColor = iconColor
            setNeedsDisplay()
        }
    }
    
    var icon: FontkeyboardtestIcon? {
        didSet {
            iconView.icon = icon
            setNeedsDisplay()
        }
    }
        
    private let iconView = FontkeyboardtestIconView()
    private let textField = UITextField()
    private let iconKeyboard = IconKeyboard()
    
    convenience init(icon: FontkeyboardtestIcon, iconColor: UIColor){
        self.init(frame: .zero)
        
        self.icon = icon
        self.iconColor = iconColor
    }
    
    // Default initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        iconKeyboard.selectionColor = iconColor
        addSubview(iconView)
        iconView.isUserInteractionEnabled = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.backgroundColor = backgroundColor
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        iconView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        iconView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        iconView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        addSubview(textField)
        textField.inputView = iconKeyboard.view
        iconKeyboard.delegate = self
        textField.alpha = 0
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        else {
            textField.becomeFirstResponder()
        }
    }
}

extension IconPicker: IconKeyboardDelegate {
    func selected(icon: FontkeyboardtestIcon) {
        self.icon = icon
        self.sendActions(for: UIControl.Event.valueChanged)
    }
}

//class IconPicker: UIViewController {
//
//    public var delegate: IconPickerDelegate?
//
//    private let iconView = FontkeyboardtestIconView()
//    private let textField = UITextField()
//    private let iconKeyboard = IconKeyboard()
//
//    @IBInspectable public var iconString: String = "" {
//        didSet {
//            iconView.icon = FontkeyboardtestIcon.init(rawValue: iconString)
//        }
//    }
//
//    @IBInspectable public var iconColor: UIColor = .darkText {
//        didSet {
//            iconView.iconColor = iconColor
//        }
//    }
//
//    public var icon: FontkeyboardtestIcon = .missingIcon {
//        didSet {
//            iconView.icon = icon
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        view.addSubview(textField)
//        textField.inputView = iconKeyboard.view
//        iconKeyboard.delegate = self
//        textField.alpha = 0
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        textField.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        textField.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        textField.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//
//        view.addSubview(iconView)
//        iconView.backgroundColor = .white
//        iconView.translatesAutoresizingMaskIntoConstraints = false
//        iconView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        iconView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        iconView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        iconView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
//        iconView.addGestureRecognizer(tapGesture)
//
//        // Do any additional setup after loading the view.
//    }
//
//    // MARK: - Gesture Recognizers
//    @objc func tapped(_ sender: UITapGestureRecognizer) {
//        if textField.isFirstResponder {
//            textField.resignFirstResponder()
//        }
//        else {
//            textField.becomeFirstResponder()
//        }
//    }
//}
//
//extension IconPicker: IconKeyboardDelegate {
//    func selected(icon: FontkeyboardtestIcon) {
//        iconView.icon = icon
//        delegate?.iconPicker(self, selected: icon)
//    }
//}
