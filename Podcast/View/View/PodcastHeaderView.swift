//
//  PodcastHeaderView.swift
//  testProject
//
//  Created by Dmitry Kushner on 9/17/20.
//  Copyright © 2020 Dmitry Kushner. All rights reserved.
//

import UIKit

final class PodcastHeaderView: UIView {
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("PodcastHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func configure() {
        imageView.layer.cornerRadius = 10
    }
}
