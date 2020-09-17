//
//  PodcastDescriptionTitleView.swift
//  testProject
//
//  Created by Dmitry Kushner on 9/17/20.
//  Copyright © 2020 Dmitry Kushner. All rights reserved.
//

import UIKit

final class PodcastDescriptionTitleView: UIView {

    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("PodcastDescriptionTitleView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        configure()
    }
    
    private func configure() {
        descriptionLabel.text = "Подкаст, который рассказывает про то, как\nмного в мире прекрасных вещей, которые\nможно совершить, а также сколько людей,\nкоторые могут помочь вам в реализации\nваших заветных мечт."
    }
}
