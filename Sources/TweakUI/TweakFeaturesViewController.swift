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
        tableView.register(TweakTableViewCell.self, forCellReuseIdentifier: "TweakTableViewCell")

        view.addSubview(tableView)
    }

    private func loadTweaks() {
        // Filter coordinates by table
        let tableCoordinates = TweakRepository.shared.allCoordinates().filter { $0.table == tableCoordinate }

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

        tableView.reloadData()
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
        guard let node = TweakRepository.shared.node(for: coordinate) else {
            return UITableViewCell()
        }

        return node.dequeueTableViewCell(in: tableView, indexPath: indexPath)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SelectableCell {
            cell.didSelect()
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension TweakRepository.NodeProviding {
    func dequeueTableViewCell(in tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweakTableViewCell", for: indexPath) as! TweakTableViewCell
        cell.configure(with: coordinate, node: self)
        return cell
    }
}

// MARK: - Cell Implementations

// swiftformat:disable opaqueGenericParameters

protocol SelectableCell: UITableViewCell {
    func didSelect()
}

private class TweakTableViewCell: UITableViewCell, SelectableCell {
    var updateBlock: () -> Void = {}
    var onSelect: () -> Void = {}

    func configure<Output: TweakOutputType>(with coordinate: TweakCoordinate, node: any TweakRepository.NodeProviding<Output>) {
        textLabel?.text = coordinate.row
        selectionStyle = .none

        switch node.tweakType {
        case let .toggle(offValue, onValue, toggleDefault):
            configureToggle(
                offValue: offValue,
                onValue: onValue,
                toggleDefault: toggleDefault,
                node: node
            )
        case let .freeform(fromString, toString, defaultValue):
            configureFreeform(
                fromString: fromString,
                toString: toString,
                defaultValue: defaultValue,
                node: node
            )
        case let .selection(options, required, defaultIndex):
            configureSelection(
                options: options.map { ("\($0)", $0) },
                required: required,
                defaultIndex: defaultIndex,
                node: node
            )
        case let .namedSelection(options, required, defaultIndex):
            configureSelection(
                options: options,
                required: required,
                defaultIndex: defaultIndex,
                node: node
            )
        }
    }

    private func configureToggle<Output: TweakOutputType>(
        offValue: Output,
        onValue: Output,
        toggleDefault: Bool,
        node: any TweakRepository.NodeProviding<Output>
    ) {
        let persistentProperty = node.persistentProperty
        let currentTweakState = persistentProperty.value

        let switchView = UISwitch()
        switchView.addTarget(self, action: #selector(toggleValue), for: .valueChanged)

        let curToggle = currentTweakState.enabled ? (currentTweakState.value == onValue) : toggleDefault
        switchView.isOn = curToggle
        updateBlock = {
            node.persistentProperty.value = TweakState(value: switchView.isOn ? onValue : offValue, enabled: true)
        }
        onSelect = { [unowned self] in
            switchView.setOn(!switchView.isOn, animated: true)
            updateBlock()
        }

        accessoryView = switchView
    }

    private func configureFreeform<Output: TweakOutputType>(
        fromString: (String) -> Output,
        toString: (Output) -> String?,
        defaultValue: Output,
        node: any TweakRepository.NodeProviding<Output>
    ) {}

    private func configureSelection<Output: TweakOutputType>(
        options: [(String, Output)],
        required: Bool,
        defaultIndex: Int?,
        node: any TweakRepository.NodeProviding<Output>
    ) {}

    @objc func toggleValue(switch: UISwitch) {
        updateBlock()
    }

    func didSelect() {
        onSelect()
    }
}

// swiftformat:enable opaqueGenericParameters
