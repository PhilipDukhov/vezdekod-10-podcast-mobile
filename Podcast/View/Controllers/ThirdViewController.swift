//
//  ThirdViewController.swift
//  testProject
//
//  Created by Dmitry Kushner on 9/17/20.
//  Copyright © 2020 Dmitry Kushner. All rights reserved.
//

import UIKit

final class ThirdViewController: UIViewController {
    @IBOutlet private weak var navigationBarView: NavigationBarView!
    @IBOutlet private weak var postPodcastButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    
    private var data = [TimeintervalTableViewCellModel(time: "5:45", description: "Начало обсуждения")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarView.configure(with: "Новый подкаст", delegate: self)
        postPodcastButton.layer.cornerRadius = 10
        tableView.register(UINib(nibName: "TimeintervalTableViewCell", bundle: nil), forCellReuseIdentifier: "TimeintervalTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

}

extension ThirdViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = data[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimeintervalTableViewCell", for: indexPath) as? TimeintervalTableViewCell else { return UITableViewCell() }
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "   Содержание"
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        22
    }
}

extension ThirdViewController: NavigationBarViewDelegate {
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
