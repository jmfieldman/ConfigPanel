//
//  DemoViewController.swift
//  Copyright © 2025 Jason Fieldman.
//

import CombineEx
import ConfigPanel
import ConfigRefreshManager
import FeatureOneConfigManager
import FeatureTwoConfigManager
import Inject
import Mortar
import UIKit

public final class DemoViewController: UIViewController {
    fileprivate let model: DemoViewControllerModel = .init()

    override public func loadView() {
        view = UIContainer {
            $0.backgroundColor = .white

            UIVStack {
                $0.alignment = .center
                $0.layout.width == $0.parentLayout.width - 16
                $0.layout.center == $0.parentLayout.center

                UILabel {
                    $0.bind(\.text) <~ model.featureTwoInteger.map { "Integer: \($0)" }
                }

                UILabel {
                    $0.bind(\.text) <~ model.featureTwoString.map { "String: \($0)" }
                }

                UIButton {
                    $0.setTitle("Increment Config", for: .normal)
                    $0.setTitleColor(.blue, for: .normal)
                    $0.handleEvents(.touchUpInside, model.incrementConfigAction)
                }

                UIButton {
                    $0.setTitle("Open Tweaks", for: .normal)
                    $0.setTitleColor(.orange, for: .normal)
                    $0.handleEvents(.touchUpInside) { [weak self] _ in
                        self?.navigationController?.pushViewController(TweakViewController(), animated: true)
                    }
                }
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "ConfigPanel Demo"
    }
}

private final class DemoViewControllerModel {
    let configRefreshManager: ConfigRefreshManager = Inject()
    let featureOneConfigManager: FeatureOneConfigManager = Inject()
    let featureTwoConfigManager: FeatureTwoConfigManager = Inject()

    lazy var incrementConfigAction: Action<Void, Void, Never> = .immediate { [configRefreshManager] _ in
        configRefreshManager.incrementConfigStruct()
    }

    lazy var featureTwoInteger: Property<Int> = Property(featureTwoConfigManager.configInteger)
    lazy var featureTwoString: Property<String> = Property(featureTwoConfigManager.configString)
}
