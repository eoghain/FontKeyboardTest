//
//  ViewController.swift
//  FontKeyboardTest
//
//  Created by Booth, Robert on 4/14/19.
//  Copyright © 2019 Intuit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func iconChanged(_ sender: FontkeyboardtestIconPicker) {
        print("\(sender.iconColor), \(sender.icon?.name ?? "nil")")
    }
}
