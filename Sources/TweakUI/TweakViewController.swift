//
//  TweakViewController.swift
//  Copyright © 2025 Jason Fieldman.
//

import UIKit

public final class TweakViewController: UIViewController {
    private var tableView: UITableView!
    private var tableCoordinates: [TweakCoordinate.Table] = []

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTableCoordinates()
    }

    private func setupUI() {
        title = "Tweaks"
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TweakCell")
    }

    private func loadTableCoordinates() {
        let uniqueTables = Set(TweakRepository.shared.allCoordinates().map(\.table))
        tableCoordinates = Array(uniqueTables).sorted { $0.table < $1.table }
        tableView.reloadData()
    }
}

extension TweakViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableCoordinates.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweakCell", for: indexPath)
        let tableCoordinate = tableCoordinates[indexPath.row]
        cell.textLabel?.text = tableCoordinate.table
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableCoordinate = tableCoordinates[indexPath.row]
        let tweakFeaturesVC = TweakFeaturesViewController(tableCoordinate: tableCoordinate)
        navigationController?.pushViewController(tweakFeaturesVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
