//
//  UIViewController+RequestHandler.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 05/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit

class ErrorPageViewController: UIViewController {}

public extension UIViewController {

    func isUnauthorized(_ error: NSError) -> Bool {
        return error.code == 401
    }

    func gotoLogin(_ message: String? = nil, completion: (() -> Void)? = nil ) {
        if let message = message {
            NotificationCenter.default.post(name: .loginErrorMessage, object: nil, userInfo: ["message": message])
        }
        if let presentedViewController = self.presentedViewController {
            presentedViewController.dismiss(animated: true, completion: completion)
        }
        self.dismiss(animated: true, completion: completion)
    }

    func handlerRequestError(_ error: Error, completion: (() -> Void)? = nil ) {
        garanteeMainThread {
            if self.isUnauthorized(error as NSError) {
                let nsError = error as NSError
                self.gotoLogin( nsError.domain, completion: completion)
            } else {
                let message = (error as NSError).domain
                self.alert(error: message, completion: completion)
            }
        }
    }

    func getErrorViewController(title: String, error: NSError, onRetry: (() -> Void)? = nil) -> UIViewController {
        let serverError = EmptyStateView(title: title, subTitle: error.domain, image: UIImage(named: "service")!).enableAutoLayout()
        let errorPage = ErrorPageViewController()
        errorPage.view.backgroundColor = .appBackground
        errorPage.view.addSubview(serverError)
        let safeArea = errorPage.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            serverError.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),
            serverError.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15),
            serverError.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
        serverError.actionButton.setTitle("Tentar novamente", for: .normal)
        serverError.onAction = {
            serverError.actionButton.startLoad()
            onRetry?()
        }
        return errorPage
    }

    func showErrorPage(title: String, error: NSError, onRetry: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        garanteeMainThread {
            if self.isUnauthorized(error) {
                let nsError = error
                self.gotoLogin( nsError.domain, completion: completion)
            } else {
                let errorPage = self.getErrorViewController(title: title, error: error, onRetry: onRetry)
                DispatchQueue.main.async {
                    if var viewControllers = self.navigationController?.viewControllers,
                       let lastScreen = viewControllers.last,
                       lastScreen is ErrorPageViewController {
                        _ = viewControllers.popLast()
                        viewControllers.append(errorPage)
                        self.navigationController?.setViewControllers(viewControllers, animated: false)
                    } else {
                        self.navigationController?.pushViewController(errorPage, animated: true)
                    }
                }
            }
        }
    }
}

public extension UIViewController {

    func alert(error: String, completion: (() -> Void)? = nil ) {
        let controler = UIAlertController(title: nil, message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { (_) in
            completion?()
        }
        controler.addAction(okAction)
        present(controler, animated: true, completion: nil)
    }
}
