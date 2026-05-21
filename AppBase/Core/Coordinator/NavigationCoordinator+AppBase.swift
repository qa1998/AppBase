//
//  NavigationCoordinator+AppBase.swift
//  AppBase
//

import UIKit

extension NavigationCoordinator {

    /// Push VC — wrapper cho `navigate(to: .push)`.
    func pushViewController(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        navigate(to: .push(viewController), animated: animated, completion: completion)
    }

    /// Present modal full screen hoặc page sheet.
    func presentViewController(
        _ viewController: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        navigate(to: .present(viewController), animated: animated, completion: completion)
    }

    func popViewController(animated: Bool = true, completion: (() -> Void)? = nil) {
        navigate(to: .pop, animated: animated, completion: completion)
    }

    func popToRootViewController(animated: Bool = true, completion: (() -> Void)? = nil) {
        navigate(to: .root, animated: animated, completion: completion)
    }

    func showAlert(
        title: String? = L10n.Common.Error.title,
        message: String,
        primaryTitle: String = L10n.Common.ok,
        onPrimary: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: primaryTitle, style: .default) { _ in
            onPrimary?()
        })
        navigate(to: .present(alert))
    }
}
