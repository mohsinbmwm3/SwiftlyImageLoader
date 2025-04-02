//
//  ViewController.swift
//  SwiftlyImageLoader-Demo
//
//  Created by Mohsin Khan on 02/04/25.
//

import UIKit
import SwiftlyImageLoader

class ViewController: UIViewController {
    let tableView = UITableView()
    let imageUrls: [URL] = (1...150).compactMap {
        URL(string: "https://picsum.photos/id/\($0)/500/300")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SwiftlyImageLoader Demo"
        view.backgroundColor = .systemBackground

        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.register(ImageCell.self, forCellReuseIdentifier: ImageCell.reuseId)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 75
        view.addSubview(tableView)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageUrls.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageCell.reuseId, for: indexPath) as? ImageCell else {
            return UITableViewCell()
        }

        let url = imageUrls[indexPath.row]
        cell.customImageView.setImage(from: url, placeholder: UIImage(systemName: "photo"))
        return cell
    }
}

