//
//  BaseNavigationController.swift
//

import UIKit

// MARK: - Enums

class BaseNavigationController: UINavigationController {

    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
