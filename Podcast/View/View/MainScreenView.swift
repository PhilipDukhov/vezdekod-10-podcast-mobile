//
//  MainScreenView.swift
//  vezdekod-10-podcast-mobile
//
//  Created by Dmitry Kushner on 9/17/20.
//  Copyright © 2020 Bubble. All rights reserved.
//

import UIKit

protocol MainScreenViewDelegate: class {
    func buttonTapped()
}

final class MainScreenView: UIView {
    
    enum `Type` {
        case main
        case last
    }
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var widthConstraint: NSLayoutConstraint!
    
    private weak var delegate: MainScreenViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("MainScreenView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        button.layer.cornerRadius = 10
    }
    
    func configure(with type: `Type`, delegate: MainScreenViewDelegate) {
        self.delegate = delegate
        switch type {
        case .main:
            imageView.image = UIImage(named: "mainScreen") // картинку подходящую
            titleLabel.text = "Добавьте первый подкаст"
            descriptionLabel.text = "Добавляйте, редактируйте и делитесь\n подкастами вашего сообщества."
            button.setTitle("Добавить подкаст", for: .normal)
            widthConstraint.constant = 160
        case .last:
            imageView.image = UIImage(named: "lastScreen") // картинку подходящую
            titleLabel.text = "Подкаст добавлен"
            descriptionLabel.text = "Расскажите своим подписчикам\nо новом подкасте, чтобы получить\nбольше слушателей."
            button.setTitle("Поделиться подкастом", for: .normal)
            widthConstraint.constant = 200
        }
    }
    
    @IBAction private func tapAction(_ sender: UIButton) {
        delegate?.buttonTapped()
    }
}
