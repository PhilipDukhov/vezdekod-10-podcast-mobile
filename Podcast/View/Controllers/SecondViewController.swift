//
//  SecondViewController.swift
//  testProject
//
//  Created by Dmitry Kushner on 9/17/20.
//  Copyright © 2020 Dmitry Kushner. All rights reserved.
//

import UIKit
import AVFoundation
import CoreServices

final class SecondViewController: UIViewController {

    @IBOutlet private weak var navigationBarView: NavigationBarView!
    @IBOutlet private weak var load: LoadPodcastView!
    @IBOutlet private weak var loaded: LoadedPodcastView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var nextButton: UIButton!
    
    var audioFile: AudioFile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarView.configure(with: "Новый подкаст", delegate: self)
        nextButton.layer.cornerRadius = 10
        descriptionLabel.text = "При публикации записи с эпизодом, он становится\nдоступным для всех пользователей"
        loaded.isHidden = true
        loaded.action = { [weak self] in
            guard let self = self else { return }
            self.performSegue(withIdentifier: "edit", sender: nil)
        }
        load.action = { [weak self] in
            self?.presentDocumentPicker()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "edit" else { return }
        let edit = segue.destination as! EditAudioViewController
        edit.audioFile = audioFile
        edit.endEditing = { [weak self] audioFile in
            self?.audioFile = audioFile
        }
    }

    @IBAction private func nextAction(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ThirdViewController") as! ThirdViewController
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    private func presentDocumentPicker() {
        let viewController = UIDocumentPickerViewController(documentTypes: [kUTTypeAudio as String], in: .import)
        viewController.shouldShowFileExtensions = true
        viewController.delegate = self
        present(viewController, animated: true)
    }
}

extension SecondViewController: NavigationBarViewDelegate {
    func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SecondViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        tryImportTrack(url)
    }
    
    func tryImportTrack(_ url: URL) {
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: false)
        }
        guard !AVURLAsset(url: url).tracks(withMediaType: .audio).isEmpty else {
            let alert = UIAlertController(title: "Файл не содержит аудио дорожки", message: nil, preferredStyle: .actionSheet)
            alert.addAction(.init(title: "Выбрать другой", style: .default, handler: { [weak self] _ in
                self?.presentDocumentPicker()
            }))
            alert.addAction(.init(title: "Отменить", style: .default))
            present(alert, animated: true)
            return
        }
        audioFile = .init(url: url)
        loaded.isHidden = false
        load.isHidden = true
    }
}
