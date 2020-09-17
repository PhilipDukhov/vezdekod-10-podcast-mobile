//
//  LoadPodcastView.swift
//  testProject
//
//  Created by Dmitry Kushner on 9/17/20.
//  Copyright © 2020 Dmitry Kushner. All rights reserved.
//

import UIKit

final class LoadPodcastView: UIView {
    @IBOutlet private var contentView: UIView!
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var loadFileButton: UIButton!
    
    
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
        Bundle.main.loadNibNamed("LoadPodcastView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        configure()
    }
    
    private func configure() {
        descriptionLabel.text = "Выберите готовый аудиофайл из вашего\nтелефона и добавьте его"
        loadFileButton.layer.cornerRadius = 10
        loadFileButton.layer.borderWidth = 1
        loadFileButton.borderColor = Asset.Colors.blue.color
    }
}
