//
//  TimeintervalTableViewCell.swift
//  testProject
//
//  Created by Dmitry Kushner on 9/17/20.
//  Copyright © 2020 Dmitry Kushner. All rights reserved.
//

import UIKit

struct TimeintervalTableViewCellModel {
    var time: String
    var description: String
}

final class TimeintervalTableViewCell: UITableViewCell {
    
    @IBOutlet weak var descriprionLabel: UILabel!
    @IBOutlet weak var timeIntervalLabel: UILabel!
    
    private var model: TimeintervalTableViewCellModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        guard let model = model else { return }
        configure(with: model)
    }
    
    func configure(with model: TimeintervalTableViewCellModel) {
        self.model = model
        timeIntervalLabel.text = model.time
        descriprionLabel.text = "- \(model.description)"
    }
    
}
