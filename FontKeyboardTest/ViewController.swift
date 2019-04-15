//
//  ViewController.swift
//  FontKeyboardTest
//
//  Created by Booth, Robert on 4/14/19.
//  Copyright © 2019 Intuit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var iconPicker: IconPicker? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedIconPicker" {
            guard let iconPicker = segue.destination as? IconPicker else {
                fatalError("embedIconPicker segue must embed an IconPicker!")
            }
            
            iconPicker.delegate = self
            iconPicker.icon = FontkeyboardtestIconEnum.money
            iconPicker.iconColor = .cyan
            self.iconPicker = iconPicker
        }
    }
    
}

extension ViewController: IconPickerDelegate {
    func iconPicker(_ picker: IconPicker, selected: FontkeyboardtestIconEnum) {
        print("🖼 selected \(selected.string)")
    }
}
