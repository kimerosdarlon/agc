//
//  SuccessViewCrontroller.swift
//  CAD
//
//  Created by Samir Chaves on 30/11/20.
//  Copyright © 2020 Samir Chaves. All rights reserved.
//

import Foundation
import Lottie
import AgenteDeCampoCommon
import UIKit

class SuccessViewController: UIViewController {
    private var feedbackText: String!
    private var backgroundColor: UIColor!
    private var animationView: AnimationView!

    private let feedbackLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .white
        label.enableAutoLayout()
        return label
    }()

    init(feedbackText: String, backgroundColor: UIColor) {
        super.init(nibName: nil, bundle: nil)
        self.feedbackText = feedbackText
        self.backgroundColor = backgroundColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundColor

        feedbackLabel.text = feedbackText

        animationView = .init(name: "correct")
        animationView.enableAutoLayout()
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 1
        animationView.width(200).height(200)

        view.addSubview(feedbackLabel)
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -10),
            feedbackLabel.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 10),
            feedbackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        animationView.play()
    }

    func showModal(_ parentController: UIViewController, duration: Double, completion: (() -> Void)? = nil) {
        self.modalPresentationStyle = .fullScreen
        self.modalTransitionStyle = .crossDissolve
        parentController.present(self, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.dismiss(animated: true, completion: nil)
                completion?()
            }
        }
    }
}
