//
//  ViewController.swift
//  testProject
//
//  Created by Dmitry Kushner on 9/17/20.
//  Copyright © 2020 Dmitry Kushner. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var backgroundView: MainScreenView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        backgroundView.configure(with: .main, delegate: self)
        
    }

}

extension ViewController: MainScreenViewDelegate {
    func buttonTapped() {
        performSegue(withIdentifier: "show", sender: nil)
    }
}
