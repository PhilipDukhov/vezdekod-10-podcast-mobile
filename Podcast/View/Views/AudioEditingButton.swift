//
//  AudioEditingButton.swift
//  vezdekod-10-podcast-mobile
//
//  Created by Philip Dukhov on 9/16/20.
//  Copyright © 2020 Bubble. All rights reserved.
//

import UIKit

class AudioEditingButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        update()
    }
    
    override var isSelected: Bool {
        didSet {
            update()
        }
    }
    
    private func update() {
        if isSelected {
            backgroundColor = Asset.Colors.blue.color
            tintColor = .white
        } else {
            backgroundColor = Asset.Colors.selectionGray.color
            tintColor = Asset.Colors.blue.color
        }
    }
}
