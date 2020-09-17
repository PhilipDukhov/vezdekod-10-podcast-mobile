//
//  TextField.swift
//  vezdekod-10-podcast-mobile
//
//  Created by Philip Dukhov on 9/17/20.
//  Copyright © 2020 Bubble. All rights reserved.
//

import UIKit

class TextField: UITextField {
    enum BorderState {
        case idle
        case editing
        case error
        
        var color: UIColor {
            switch self {
            case .idle:
                return Asset.Colors.border.color
            case .editing:
                return Asset.Colors.blue.color
            case .error:
                return Asset.Colors.destructive.color
            }
        }
    }
    
    var borderState: BorderState = .idle {
        didSet {
            borderColor = borderState.color
        }
    }
    
    var onEndEditing: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
        cornerRadius = 10
        borderWidth = 1
        borderState = .idle
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 12, dy: 12)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 12, dy: 12)
    }
    
    override func shouldChangeText(in range: UITextRange, replacementText text: String) -> Bool {
        borderState = .editing
        return true
    }
    
    func replaceSelection(replacementString: String) {
        guard let text = text else {
            self.text = replacementString
            return
        }
        guard let selectedTextRange = selectedTextRange else {
            self.text! += replacementString
            return
        }
        let location = offset(from: beginningOfDocument, to: selectedTextRange.start)
        let length = offset(from: selectedTextRange.start, to: selectedTextRange.end)
        let range = text.index(text.startIndex, offsetBy: location)..<text.index(text.startIndex, offsetBy: location + length)
        self.text!.replaceSubrange(range, with: replacementString)
        let newPosition = position(from: selectedTextRange.end, offset: 1)!
        self.selectedTextRange = textRange(from: newPosition, to: newPosition)
    }
}

extension TextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        borderState = .editing
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        borderState = textField.text?.isEmpty == false ? .idle : .error
        onEndEditing?(textField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
