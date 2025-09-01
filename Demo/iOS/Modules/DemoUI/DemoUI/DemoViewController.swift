//
//  DemoViewController.swift
//  Copyright © 2025 Jason Fieldman.
//

import CombineEx
import ConfigRefreshManager
import FeatureOneConfigManager
import FeatureTwoConfigManager
import Inject
import Mortar
import UIKit

public final class DemoViewController: UIViewController {
    fileprivate let model: DemoViewControllerModel = .init()

    override public func loadView() {
        view = UIContainer {}
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "ConfigPanel Demo"
    }
}

private final class DemoViewControllerModel {}
