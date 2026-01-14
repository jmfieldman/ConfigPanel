//
//  TweakFeaturesViewController.swift
//  Copyright © 2025 Jason Fieldman.
//

import UIKit

/// A view controller that displays tweaks organized by table and section
public final class TweakFeaturesViewController: UIViewController {
    private let tableCoordinate: TweakCoordinate.Table
    private var tableView: UITableView!

    // Organize tweaks by section
    private var sections: [TweakCoordinate.Section: [TweakCoordinate]] = [:]
    private var sortedSections: [TweakCoordinate.Section] = []

    /// Initializes a new tweak features view controller with the specified table coordinate
    /// - Parameter tableCoordinate: The table coordinate to display tweaks for
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

    /// Sets up the UI components for this view controller
    private func setupUI() {
        title = tableCoordinate.table
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TweakTableViewCell.self, forCellReuseIdentifier: "TweakTableViewCell")

        view.addSubview(tableView)

        let menuButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape.2.fill"),
            style: .plain,
            target: nil,
            action: nil
        )
        menuButton.menu = UIMenu(children: [
            UIAction(title: "Reset \(tableCoordinate.table) Tweaks", image: UIImage(systemName: "arrow.clockwise")) { [unowned self] _ in
                let alert = UIAlertController(
                    title: "Reset \(tableCoordinate.table) Tweaks",
                    message: "Are you sure you want to reset all \(tableCoordinate.table) tweaks?",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [unowned self] _ in
                    TweakRepository.shared.reset(table: tableCoordinate)
                    loadTweaks()
                })
                present(alert, animated: true)
            },
        ])
        navigationItem.rightBarButtonItem = menuButton
    }

    /// Loads and organizes tweaks for display
    private func loadTweaks() {
        // Filter and group coordinates by section
        let tableCoordinates = TweakRepository.shared.allCoordinates()
            .filter { $0.table == tableCoordinate }
            .sorted { $0.section.section < $1.section.section }

        sections = Dictionary(grouping: tableCoordinates) { $0.section }
            .mapValues { $0.sorted { $0.row < $1.row } }

        sortedSections = sections.keys.sorted { $0.section < $1.section }

        tableView.reloadData()
    }
}

// MARK: - Table View Data Source and Delegate

extension TweakFeaturesViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let currentSection = sectionForIndex(section) else { return 0 }
        return sections[currentSection]?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let currentSection = sectionForIndex(section) else { return nil }
        return currentSection.section
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let coordinate = coordinateForIndexPath(indexPath) else {
            return UITableViewCell()
        }

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

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIApplication.shared.sendAction(#selector(UIView.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // MARK: - Helper Methods

    /// Gets the section at a given index, if it exists
    private func sectionForIndex(_ index: Int) -> TweakCoordinate.Section? {
        guard index < sortedSections.count else { return nil }
        return sortedSections[index]
    }

    /// Gets the tweak coordinate for a given index path, if it exists
    private func coordinateForIndexPath(_ indexPath: IndexPath) -> TweakCoordinate? {
        guard let currentSection = sectionForIndex(indexPath.section) else { return nil }
        guard let sectionRows = sections[currentSection],
              indexPath.row < sectionRows.count
        else {
            return nil
        }

        return sectionRows[indexPath.row]
    }
}

// MARK: - Node Extension

extension TweakRepository.NodeProviding {
    /// Dequeues and configures a table view cell for this node
    func dequeueTableViewCell(in tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweakTableViewCell", for: indexPath) as! TweakTableViewCell
        cell.configure(with: coordinate, node: self)
        return cell
    }
}

// MARK: - Cell Implementations

// swiftformat:disable opaqueGenericParameters

/// Protocol for cells that can be selected
protocol SelectableCell: UITableViewCell {
    func didSelect()
}

/// Custom table view cell for displaying tweak controls
private class TweakTableViewCell: UITableViewCell, SelectableCell, UITextFieldDelegate {
    var updateBlock: () -> Void = {}
    var onSelect: () -> Void = {}

    /// Configures the cell with a tweak coordinate and node
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

    /// Configures a toggle control for the tweak
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
        switchView.isOn = currentTweakState.enabled ? (currentTweakState.value == onValue) : toggleDefault
        updateBlock = {
            UIApplication.shared.sendAction(#selector(UIView.resignFirstResponder), to: nil, from: nil, for: nil)
            node.persistentProperty.value = TweakState(value: switchView.isOn ? onValue : offValue, enabled: true)
        }
        onSelect = { [unowned self] in
            switchView.setOn(!switchView.isOn, animated: true)
            updateBlock()
        }

        accessoryView = switchView
    }

    /// Configures a freeform text input control for the tweak
    private func configureFreeform<Output: TweakOutputType>(
        fromString: @escaping (String) -> Output,
        toString: (Output) -> String?,
        defaultValue: Output,
        node: any TweakRepository.NodeProviding<Output>
    ) {
        let persistentProperty = node.persistentProperty
        let currentTweakState = persistentProperty.value

        let textField = UITextField()
        textField.borderStyle = .none
        textField.placeholder = toString(defaultValue) ?? "No Override"
        textField.textAlignment = .right
        textField.returnKeyType = .done
        textField.text = currentTweakState.enabled ? toString(currentTweakState.value) : nil
        textField.sizeToFit()
        if textField.bounds.size.width < 44 {
            textField.bounds = CGRect(x: 0, y: 0, width: 44, height: textField.bounds.size.height)
        }

        // Update the tweak value when text changes
        let updateTweakValue: (String) -> Void = { text in
            if text.isEmpty {
                persistentProperty.value = TweakState(value: defaultValue, enabled: false)
            } else {
                persistentProperty.value = TweakState(value: fromString(text), enabled: true)
            }
        }

        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        textField.delegate = self

        updateBlock = {
            updateTweakValue(textField.text ?? "")
            textField.sizeToFit()
            if textField.bounds.size.width < 44 {
                textField.bounds = CGRect(x: 0, y: 0, width: 44, height: textField.bounds.size.height)
            }
        }

        onSelect = {
            textField.becomeFirstResponder()
        }

        accessoryView = textField
    }

    /// Configures a selection control for the tweak
    private func configureSelection<Output: TweakOutputType>(
        options: [(String, Output)],
        required: Bool,
        defaultIndex: Int?,
        node: any TweakRepository.NodeProviding<Output>
    ) {
        let stringForValue: (Output) -> String? = { value in
            options.first(where: { $1 == value })?.0
        }

        let stringForState: (TweakState<Output>) -> String? = { state in
            guard state.enabled else { return "No Override" }
            if let valueString = stringForValue(state.value) {
                return valueString
            } else {
                return "\(state.value)"
            }
        }

        let persistentProperty = node.persistentProperty
        let currentTweakState = persistentProperty.value

        let selectionButton = UIButton()
        selectionButton.setTitle(stringForState(currentTweakState), for: .normal)
        selectionButton.setTitleColor(.label, for: .normal)
        selectionButton.sizeToFit()

        let setTweakState: (TweakState<Output>) -> Void = { state in
            selectionButton.setTitle(stringForState(state), for: .normal)
            selectionButton.sizeToFit()
            persistentProperty.value = state
        }

        var actions: [UIAction] = []

        if !required {
            actions.append(UIAction(title: "No Override", identifier: nil) { _ in
                setTweakState(.init(value: currentTweakState.value, enabled: false))
            })
        }

        actions.append(contentsOf: options.map { option in
            UIAction(title: option.0, identifier: nil) { _ in
                setTweakState(.init(value: option.1, enabled: true))
            }
        })

        let menu = UIMenu(options: UIMenu.Options.singleSelection, children: actions)
        selectionButton.menu = menu
        selectionButton.showsMenuAsPrimaryAction = true
        selectionButton.addTarget(self, action: #selector(menuAction), for: .menuActionTriggered)

        updateBlock = {}
        onSelect = {
            UIApplication.shared.sendAction(#selector(UIView.resignFirstResponder), to: nil, from: nil, for: nil)
            selectionButton.gestureRecognizers?.forEach {
                $0.touchesBegan([], with: UIEvent())
            }
        }

        accessoryView = selectionButton
    }

    @objc func toggleValue(switch: UISwitch) {
        updateBlock()
    }

    @objc func menuAction() {
        UIApplication.shared.sendAction(#selector(UIView.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    @objc func textDidChange(textField: UITextField) {
        updateBlock()
    }

    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UIApplication.shared.sendAction(#selector(UIView.resignFirstResponder), to: nil, from: nil, for: nil)
        return true
    }

    func didSelect() {
        onSelect()
    }
}

// swiftformat:enable opaqueGenericParameters
