//
//  TimecodeCell.swift
//  vezdekod-10-podcast-mobile
//
//  Created by Philip Dukhov on 9/17/20.
//  Copyright © 2020 Bubble. All rights reserved.
//

import UIKit

class TimecodeCell: UITableViewCell {
    struct Props {
        let title: String
        let timestamp: String
        
        let remove: () -> Void
        let titleChanged: (String) -> Void
        let timestampChanged: (String) -> Void
        let updateTimestampWithCurrentTime: () -> Void
    }
    
    @IBOutlet private var titleTextField: TextField!
    @IBOutlet private var timestampTextField: TextField!
    
    var props: Props? {
        didSet {
            titleTextField.text = props?.title
            timestampTextField.text = props?.timestamp
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTimestampInputAccessoryView()
        
        titleTextField.onEndEditing = { [weak self] in
            self?.props?.titleChanged($0)
        }
        timestampTextField.onEndEditing = { [weak self] in
            self?.props?.timestampChanged($0)
        }
    }
    
    @IBAction private func removeTap() {
        props?.remove()
    }
    
    private func setTimestampInputAccessoryView() {
        let colonButton = UIButton()
        colonButton.setTitleColor(Asset.Colors.blue.color, for: .normal)
        colonButton.setTitle(":", for: .normal)
        colonButton.addTarget(self, action: #selector(colonButtonTap), for: .touchUpInside)
        let currentTimeButton = UIButton()
        currentTimeButton.setTitleColor(Asset.Colors.blue.color, for: .normal)
        currentTimeButton.setTitle("Текущее время", for: .normal)
        currentTimeButton.addTarget(self, action: #selector(currentTimeButtonTap), for: .touchUpInside)
        let stackView = UIStackView(arrangedSubviews:
            [colonButton, currentTimeButton]
        )
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let view = UIView(frame: .init(x: 0, y: 0, width: 0, height: 44))
        view.backgroundColor = Asset.Colors.selectionGray.color
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        timestampTextField.inputAccessoryView = view
    }
    
    @objc private func colonButtonTap() {
        timestampTextField.replaceSelection(replacementString: ":")
    }
    
    @objc private func currentTimeButtonTap() {
        props?.updateTimestampWithCurrentTime()
    }
}
