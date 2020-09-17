//
//  LoadedPodcastView.swift
//  testProject
//
//  Created by Dmitry Kushner on 9/17/20.
//  Copyright © 2020 Dmitry Kushner. All rights reserved.
//

import UIKit

final class LoadedPodcastView: UIView {
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var podcastBackgroundView: UIView!
    @IBOutlet private weak var podcastImageView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var changeButton: UIButton!
    
    var action: (() -> Void)?
    
    @IBAction func buttonAction() {
        action?()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("LoadedPodcastView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        configure()
    }
    
    private func configure() {
        podcastBackgroundView.layer.cornerRadius = 10
        descriptionLabel.text = "Вы можете добавить таймкоды и скорректировать\nподкаст в режиме редактирования"
        changeButton.layer.borderWidth = 1
        changeButton.layer.cornerRadius = 10
        changeButton.borderColor = Asset.Colors.blue.color
    }
}
