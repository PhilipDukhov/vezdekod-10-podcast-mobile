//
//  EditAudioViewController.swift
//  vezdekod-10-podcast-mobile
//
//  Created by Philip Dukhov on 9/17/20.
//  Copyright © 2020 Bubble. All rights reserved.
//

import UIKit
import AVFoundation
import CoreServices

class EditAudioViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var playPauseButton: UIButton!
    @IBOutlet private var trimButton: UIButton!
    @IBOutlet private var undoButton: UIButton!
    @IBOutlet private var musicButton: UIButton!
    @IBOutlet private var rampAtTheStartButton: UIButton!
    @IBOutlet private var rampAtTheEndButton: UIButton!
    @IBOutlet private var audioSlider: AudioSlider!
    @IBOutlet private var waveformView: WaveformView!
    @IBOutlet private var timelineView: TimelineView!
    
    private let audioPlayer = AudioPlayer()
    
    var audioFile: AudioFile! {
        didSet {
            let audioFileUpdated = oldValue == nil ||
                (audioFile.backgroundAudio != nil) != (oldValue.backgroundAudio != nil) ||
                    audioFile.segments != oldValue.segments ||
                    audioFile.rampAtTheStart != oldValue.rampAtTheStart ||
                    audioFile.rampAtTheEnd != oldValue.rampAtTheEnd
            if audioFileUpdated {
                refreshAudioFile()
            }
            musicButton.isSelected = audioFile.backgroundAudio != nil
            rampAtTheStartButton.isSelected = audioFile.rampAtTheStart
            rampAtTheEndButton.isSelected = audioFile.rampAtTheEnd
            if oldValue != nil {
                updateTimecodesTableView(oldValue)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 1
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = 1
        
        audioPlayer.delegate = self
        audioFile = .init(url: Bundle.main.url(forResource: "track", withExtension: "m4a")!)
        undoButton.isEnabled = false
        trimButton.isEnabled = false
        audioSlider.thumbValueChanged = { [weak self] in
            self?.audioPlayer.seek($0)
        }
    }
    
    @IBAction private func playPauseButtonTap() {
        switch audioPlayer.status {
        case .paused:
            audioPlayer.play()
            
        case .playing:
            audioPlayer.pause()
        }
    }
    
    @IBAction private func trimButtonTap() {
        let segments = audioFile.segments
        audioFile.crop(range: audioSlider.minSelectedValue...audioSlider.maxSelectedValue)
        undoManager?.registerUndo(withTarget: self, handler: { selfTarget in
            selfTarget.audioFile.segments = segments
        })
        undoButton.isEnabled = true
        audioSlider.trimmingViewVisible = false
    }
    
    @IBAction private func undoButtonTap() {
        undoManager?.undo()
        undoButton.isEnabled = undoManager?.canUndo == true
    }
    
    @IBAction private func musicButtonTap() {
        guard audioFile.backgroundAudio != nil else {
            presentDocumentPicker()
            return
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: "Изменить музыку", style: .default, handler: { [weak self] _ in
            self?.presentDocumentPicker()
        }))
        alert.addAction(.init(title: "Удалить музыку", style: .destructive, handler: { [weak self] _ in
            self?.audioFile.backgroundAudio = nil
        }))
        alert.addAction(.init(title: "Отменить", style: .cancel))
        present(alert, animated: true)
    }
    
    @IBAction private func rampAtTheStartButtonTap() {
        audioFile.rampAtTheStart.toggle()
    }
    
    @IBAction private func rampAtTheEndButtonTap() {
        audioFile.rampAtTheEnd.toggle()
    }
    
    @IBAction private func audioSliderValueChanged(_ audioSlider: AudioSlider) {
        trimButton.isEnabled = audioSlider.trimmingViewVisible &&
            (audioSlider.maxSelectedValue < audioSlider.maxValue ||
                audioSlider.minSelectedValue > audioSlider.minValue)
    }
    
    private func presentDocumentPicker() {
        let viewController = UIDocumentPickerViewController(documentTypes: [kUTTypeAudio as String], in: .import)
        viewController.shouldShowFileExtensions = true
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
    private func refreshAudioFile() {
        do {
            let (asset, audioMix) = try audioFile.generateAudioInfo()
       
        audioPlayer.setAsset(asset: asset, audioMix: audioMix)
        timelineView.visibleRange = 0...asset.duration.seconds
        audioSlider.maxValue = asset.duration.seconds
        audioSlider.minSelectionRange = max(1, audioSlider.maxValue / 10)
        UIView.animate(withDuration: 0.3) {
            self.audioSlider.updateConstraintsIfNeeded()
            self.audioSlider.layoutIfNeeded()
        }
        
        let assetGenerator = AssetWaveformGenerator(asset: asset, audioMix: audioMix)
        assetGenerator.generateSamples(count: Int(waveformView.bounds.width / 6)) {
            self.waveformView.samples = $0
        }
        } catch {
            print(error)
        }
        
    }
    
    private func updateTimecodesTableView(_ oldValue: AudioFile) {
        let diff = audioFile.timecodes.difference(from: oldValue.timecodes) {
            $0.id == $1.id
        }
        var deletedIndexPaths = [IndexPath]()
        var insertedIndexPaths = [IndexPath]()
        for change in diff {
            switch change {
            case let .remove(offset, _, _):
                deletedIndexPaths.append(IndexPath(row: offset, section: 0))
            case let .insert(offset, _, _):
                insertedIndexPaths.append(IndexPath(row: offset, section: 0))
            }
        }
        let updatedIndexPaths =
            zip(oldValue.timecodes.applying(diff)!, audioFile.timecodes)
                .enumerated()
                .filter { $1.0 != $1.1 }
                .map { IndexPath(row: $0.offset, section: 0) }
        
        tableView.performBatchUpdates({
            tableView.deleteRows(at: deletedIndexPaths, with: .fade)
            tableView.insertRows(at: insertedIndexPaths, with: .right)
            tableView.reloadRows(at: updatedIndexPaths, with: .none)
        })
    }
}

extension EditAudioViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        audioFile.timecodes.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == audioFile.timecodes.count {
            return tableView.dequeueReusableCell(withIdentifier: "add", for: indexPath)
        }
        return tableView.dequeueReusableCell(withIdentifier: "timecode", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let (container, label) = generateHeaderFooterTitle()
        label.heightAnchor.constraint(equalToConstant: 40).isActive = true
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.text = "ТАЙМКОДЫ"
        return container
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let (container, label) = generateHeaderFooterTitle()
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "Отметки времени с названием темы. Позволяют слушателям легче путешествовать по подкасту."
        label.numberOfLines = 0
        return container
    }
    
    private func generateHeaderFooterTitle() -> (UIView, UILabel) {
        let containerView = UIView()
        let label = UILabel()
        label.textColor = Asset.Colors.lightText.color
        containerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            label.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12),
            label.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -12),
        ])
        return (containerView, label)
    }
}

extension EditAudioViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath)
    {
        guard let cell = cell as? TimecodeCell else { return }
        let timecode = audioFile.timecodes[indexPath.row]
        cell.props = .init(
            title: timecode.title,
            timestamp: timecode.startTime.timeString,
            remove: { [weak self] in
                self?.audioFile.timecodes.removeAll { $0.id == timecode.id }
            }, titleChanged: { [weak self] title in
                self?.audioFile.timecodes.updateElement(timecode) {
                    $0.title = title
                }
            }, timestampChanged: { [weak self] timestampString in
                self?.audioFile.timecodes.updateElement(timecode) {
                    $0.updateStartTime(with: timestampString)
                }
            }, updateTimestampWithCurrentTime: { [weak self] in
                self?.audioFile.timecodes.updateElement(timecode) {
                    $0.startTime = self!.audioPlayer.currentTime
                }
        })
    }
    
    func tableView(
        _ tableView: UITableView,
        didEndDisplaying cell: UITableViewCell,
        forRowAt indexPath: IndexPath)
    {
        (cell as? TimecodeCell)?.props = nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard indexPath.row == audioFile.timecodes.count else { return }
        audioFile.timecodes.append(.init(title: "", startTime: audioPlayer.currentTime))
    }
}

extension Array where Element: Equatable {
    mutating func updateElement(_ element: Element, block: (inout Element) -> Void) {
        guard let index = firstIndex(of: element) else { return }
        block(&self[index])
    }
}

extension EditAudioViewController: UIDocumentPickerDelegate {
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
        audioFile.backgroundAudio = url
    }
}

extension EditAudioViewController: AudioPlayerDelegate {
    func audioPlayer(_ audioPlayer: AudioPlayer, statusChanged status: AudioPlayer.Status) {
        switch status {
        case .paused:
            playPauseButton.isSelected = false
            
        case .playing:
            playPauseButton.isSelected = true
        }
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, currentTimeChanged time: TimeInterval) {
        audioSlider.thumbValue = time
    }
}
