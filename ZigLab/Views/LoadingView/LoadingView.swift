//
//  LoadingView.swift
//

import UIKit

// MARK: - Constants

fileprivate let ProgressViewAnimationDuration: TimeInterval = 0.15

class LoadingView: UIView {

    // MARK: - Properties

    @IBOutlet var loadingLabel: LightLabel!

    // MARK: - Init

    class func createLoaderFor(parentController: UIViewController, title: String = "Loading...") -> LoadingView {
        let loader: LoadingView = UIView.fromNib()
        loader.alpha = 0
        loader.fillInParentView(parentView: parentController.view)
        loader.loadingLabel.text = title
        return loader
    }

    // MARK: - Animations

    func showLoader() {        
        UIView.animate(withDuration: ProgressViewAnimationDuration) {
            self.alpha = 1
        }
    }

    func hideLoaderWith(message: String?) {
        if let message = message {
            loadingLabel.text = message
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.hideSelf()
            }
        } else {
            hideSelf()
        }
    }

    // MARK: - Helpers

    private func hideSelf() {
        UIView.animate(withDuration: ProgressViewAnimationDuration, animations: {
            self.alpha = 0
        }) { (didFinish) in
            self.removeFromSuperview()
        }
    }

}
