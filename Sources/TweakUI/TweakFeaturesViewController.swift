//
//  TweakFeaturesViewController.swift
//  Copyright © 2025 Jason Fieldman.
//

import UIKit

public final class TweakFeaturesViewController: UIViewController {
    private let tableCoordinate: TweakCoordinate.Table
    private var tableView: UITableView!

    // Organize tweaks by section
    private var sections: [TweakCoordinate.Section: [TweakCoordinate]] = [:]
    private var sortedSections: [TweakCoordinate.Section] = []

    public init(tableCoordinate: TweakCoordinate.Table) {
        self.tableCoordinate = tableCoordinate
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTweaks()
    }

    private func setupUI() {
        title = tableCoordinate.table
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self

        // Register different cell types based on tweak type
        tableView.register(ToggleTableViewCell.self, forCellReuseIdentifier: "ToggleCell")
        tableView.register(FreeformTableViewCell.self, forCellReuseIdentifier: "FreeformCell")
        tableView.register(SelectionTableViewCell.self, forCellReuseIdentifier: "SelectionCell")

        view.addSubview(tableView)
    }

    private func loadTweaks() {
        // Get all tweaks from the repository that belong to this table
        let allCoordinates = TweakRepository.shared.accessQueue.sync {
            Array(TweakRepository.shared.nodes.keys)
        }

        // Filter coordinates by table
        let tableCoordinates = allCoordinates.filter { $0.table == tableCoordinate }

        // Group by section
        for coordinate in tableCoordinates {
            if sections[coordinate.section] == nil {
                sections[coordinate.section] = []
            }
            sections[coordinate.section]?.append(coordinate)
        }

        // Sort sections and rows
        sortedSections = sections.keys.sorted { $0.section < $1.section }
        for section in sortedSections {
            sections[section]?.sort { $0.row < $1.row }
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension TweakFeaturesViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < sortedSections.count else { return 0 }
        let currentSection = sortedSections[section]
        return sections[currentSection]?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section < sortedSections.count else { return nil }
        return sortedSections[section].section
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section < sortedSections.count else {
            return UITableViewCell()
        }

        let currentSection = sortedSections[indexPath.section]
        guard let sectionRows = sections[currentSection],
              indexPath.row < sectionRows.count
        else {
            return UITableViewCell()
        }

        let coordinate = sectionRows[indexPath.row]

        // Get the node for this tweak
        guard let node = TweakRepository.shared.accessQueue.sync(execute: {
            TweakRepository.shared.nodes[coordinate]
        }) else {
            return UITableViewCell()
        }

        return node.dequeueTableViewCell(in: tableView, indexPath: indexPath)
    }
}

// MARK: - Cell Implementations

// swiftformat:disable opaqueGenericParameters

private class ToggleTableViewCell: UITableViewCell {
    func configure<T: Codable & Equatable>(with coordinate: TweakCoordinate, node: any TweakRepository.NodeProviding<T>) {
        textLabel?.text = coordinate.row

        let switchView = UISwitch()
        let tweakState = node.persistentProperty.value
        if case let .toggle(_, onValue, defaultValue) = node.tweakType {
            let curToggle = tweakState.enabled ? (tweakState.value == onValue) : defaultValue
            switchView.isOn = curToggle
        }
        accessoryView = switchView
    }
}

private class FreeformTableViewCell: UITableViewCell {
    func configure<T>(with coordinate: TweakCoordinate, node: any TweakRepository.NodeProviding<T>) {
        textLabel?.text = coordinate.row
        detailTextLabel?.text = "Freeform"
    }
}

private class SelectionTableViewCell: UITableViewCell {
    func configure<T>(with coordinate: TweakCoordinate, node: any TweakRepository.NodeProviding<T>) {
        textLabel?.text = coordinate.row
        detailTextLabel?.text = "Selection"
    }
}

// swiftformat:enable opaqueGenericParameters

extension TweakRepository.NodeProviding {
    func dequeueTableViewCell(in tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        // Create appropriate cell based on tweak type
        switch tweakType {
        case .toggle:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell", for: indexPath) as! ToggleTableViewCell
            cell.configure(with: coordinate, node: self)
            return cell

        case .freeform:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FreeformCell", for: indexPath) as! FreeformTableViewCell
            cell.configure(with: coordinate, node: self)
            return cell

        case .selection, .namedSelection, .segment:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionTableViewCell
            cell.configure(with: coordinate, node: self)
            return cell
        }
    }
}
