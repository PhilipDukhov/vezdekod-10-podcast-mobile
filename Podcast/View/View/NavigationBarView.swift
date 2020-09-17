//
//  NavigationBarView.swift
//  vezdekod-10-podcast-mobile
//
//  Created by Dmitry Kushner on 9/17/20.
//  Copyright © 2020 Bubble. All rights reserved.
//

import UIKit

/// You should write all class to this protocol
protocol NavigationBarViewDelegate: class {
    /// You should call when backButton tapped
    func backButtonTapped()
}

final class NavigationBarView: UIView {
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private weak var delegate: NavigationBarViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("NavigationBarView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func configure(with text: String, delegate: NavigationBarViewDelegate) {
        self.delegate = delegate
        titleLabel.text = text
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        delegate?.backButtonTapped()
    }
}
