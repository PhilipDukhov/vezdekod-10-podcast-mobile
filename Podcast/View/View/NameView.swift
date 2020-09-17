//
//  NameView.swift
//  testProject
//
//  Created by Dmitry Kushner on 9/17/20.
//  Copyright © 2020 Dmitry Kushner. All rights reserved.
//

import UIKit

final class NameView: UIView {

    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var imageBackgroundView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("NameView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textField.layer.cornerRadius = 10
        imageBackgroundView.layer.cornerRadius = 10
        imageBackgroundView.clipsToBounds = true
    }

}
