//
//  ViewController.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 13/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//
import SinespSegurancaAuthMobile
import AgenteDeCampoCommon
import AgenteDeCampoModule
import OcurrencyBulletin
import CoreDataModels
import Location
import Vehicle
import Warrant
import Driver
import Logger
import UIKit
import CAD

class LoginViewController: UIViewController {

    var loginButton = LoginButton(title: "Entrar com Sinesp Segurança")
    private var token: String?
    private var service: SinespAuthService?
    weak var loginDelegate: SinespAuthDelegate?
    var errorMessage: String?
    var loginButtonTop: NSLayoutConstraint!
    lazy var logger = Logger.forClass(Self.self)
    internal var model: LoginModel?
    internal var loginButtonHeight: NSLayoutConstraint?

    @CadServiceInject
    internal var cadService: CadService

    @OccurrenceServiceInject
    internal var occurrenceService: OccurrenceService

    @PlacesServiceInject
    internal var placesService: PlacesService

    @domainServiceInject
    internal var domainsService: DomainService

    @DispatchServiceInject
    internal var dispatchService: DispatchService

    internal let cadNotificationManager = CadNotificationManager.shared
    
    internal var trackingService = RTTrackingService.shared

    internal let locationService = LocationService.shared

    internal let externalSettings = ExternalSettingsService()

    internal var smallTitle: UILabel = {
        let label = UILabel()
        label.text = "Autenticação"
        label.textColor = .appTitle
        label.font = .appSmallTitle
        label.enableAutoLayout()
        return label
    }()

    internal var continueWithoutCadBtn: AGCRoundedButton = {
        let btn = AGCRoundedButton(text: "Continuar")
        btn.backgroundColor = .appBlue
        btn.setTitleColor(.white, for: .disabled)
        btn.addTarget(self, action: #selector(continueWithoutCad), for: UIControl.Event.touchUpInside)
        btn.enableAutoLayout().height(40).width(90)
        return btn
    }()

    internal var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Autenticação"
        label.textColor = .white
        label.font = UIFont.robotoRegular.withSize(14)
        label.enableAutoLayout()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    internal lazy var errorBox: UIView = {
        let content = UIView()
        content.enableAutoLayout()
        content.backgroundColor = .systemOrange
        content.layer.cornerRadius = 5
        content.addSubview(self.errorLabel)
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalToSystemSpacingBelow: content.topAnchor, multiplier: 1),
            errorLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: content.leadingAnchor, multiplier: 1),
            content.trailingAnchor.constraint(equalToSystemSpacingAfter: errorLabel.trailingAnchor, multiplier: 1),
            content.bottomAnchor.constraint(equalToSystemSpacingBelow: errorLabel.bottomAnchor, multiplier: 1)
        ])
        return content
    }()

    internal var footerTitle: UILabel = {
        let label = UILabel()
        label.text = "MINISTÉRIO DA JUSTIÇA E SEGURANÇA PÚBLICA"
        label.textColor = .label
        label.font = UIFont.robotoRegular.withSize(12)
        label.enableAutoLayout()
        return label
    }()

    internal var largeTitle: UILabel = {
        let label = UILabel()
        label.text = "Agente de Campo"
        label.textColor = .appTitle
        label.font = .appLargeTitle
        label.enableAutoLayout()
        return label
    }()

    internal var feedBackLabel: UILabel? = {
        if !FeatureFlags.cadModule { return nil}
        let label = UILabel()
        label.textColor = .appTitle
        label.font = UIFont.robotoMedium.withSize(20)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.enableAutoLayout()
        return label
    }()

    internal var logo: UIImageView = {
        let view = UIImageView()
        view.enableAutoLayout()
        view.width(80).height(80)
        view.image = UIImage(named: "logo_default")
        return view
    }()

    internal var logoFooter: UIImageView = {
        let view = UIImageView()
        view.enableAutoLayout()
        view.width(40).height(40)
        view.image = UIImage(named: "brasao_do_brasil_republica")
        return view
    }()

    internal var grapho: UIImageView = {
        let view = UIImageView()
        view.enableAutoLayout()
        view.image = UIImage(named: "connection")
        view.alpha = 0.4
        return view
    }()

    override func viewDidLoad() {
        guard UIApplication.shared.applicationState != .background else { return }

        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        loginButton.delegate = self
        loginButton.titleLabel?.font = UIFont.robotoMedium.withSize(15)
        loginButton.backgroundColor = .appBlue
        loginButton.enableAutoLayout()
        continueWithoutCadBtn.isHidden = true
        addSubviews()
        setupConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(setupMessage(_:)), name: .loginErrorMessage, object: nil)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }

    func loadStates(completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            self.placesService.loadData(completion: completion)
        }
    }

    @objc func continueWithoutCad() {
        if let model = self.model {
            self.initTabBarController(model: model, cadResource: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        guard UIApplication.shared.applicationState != .background else { return }
        
        super.viewWillAppear(animated)
        let appServerKey = ACEnviroment.shared.appServerKey
        let env = ACEnviroment.shared.securityEnv
        #if DEBUG
            let debug = false
        #else
            let debug = false
        #endif
        service = SinespAuthService(appServerKey: appServerKey, enviroment: env, systemInitials: didReturnSystemInitials(), debug: debug)
        loginButton.startLoad()
        service?.me(completion: { result in
            switch result {
            case .success(let model):
                if model.roles.isEmpty {
                    self.handlerError(.notAuthorized)
                    return
                }
                let login = LoginModel(status_code: 200, mensagem: "", mob_code: .MOB200, token: nil, usuario: model, alertas: [])
                self.didFinished(with: login)
            case .failure(let error):
                self.handlerError(error)
            }
        })
    }

    @objc
    func setupMessage(_ notification: Notification) {
        self.errorMessage = notification.userInfo?["message"] as? String
        DispatchQueue.main.async {
            self.errorLabel.text = self.errorMessage
            self.showError()
        }
    }

    func handlerError(_ error: LoginError) {
        DispatchQueue.main.async { [unowned self] in
            self.loginButton.stopLoad()
        }
    }

    func addSubviews() {
        let containerView = UIView(frame: view.bounds.inset(by: .zero))
        containerView.addSubview(grapho)
        containerView.addSubview(loginButton)
        containerView.addSubview(continueWithoutCadBtn)
        containerView.addSubview(largeTitle)
        containerView.addSubview(logo)
        containerView.addSubview(smallTitle)
        containerView.addSubview(footerTitle)
        containerView.addSubview(logoFooter)

        if let label = feedBackLabel {
            containerView.addSubview(label)
        }

        if errorMessage != nil {
            errorLabel.text = errorMessage
            containerView.addSubview(errorBox)
        }

//        let blockingView = UITextField()
//        blockingView.isSecureTextEntry = true
//        blockingView.addSubview(containerView)
        view.addSubview(containerView)
//        view.layer.superlayer?.addSublayer(blockingView.layer)
//        blockingView.layer.sublayers?.first?.addSublayer(view.layer)
    }

    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        loginButtonHeight = loginButton.heightAnchor.constraint(equalToConstant: 42)
        loginButtonHeight?.isActive = true

        NSLayoutConstraint.activate([
            loginButton.widthAnchor.constraint(equalToConstant: 231),
            loginButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),

            largeTitle.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),

            logo.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            largeTitle.topAnchor.constraint(equalToSystemSpacingBelow: logo.bottomAnchor, multiplier: 3),

            logo.topAnchor.constraint(equalToSystemSpacingBelow: smallTitle.bottomAnchor, multiplier: 3),
            smallTitle.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),

            safeArea.bottomAnchor.constraint(equalToSystemSpacingBelow: footerTitle.bottomAnchor, multiplier: 3),
            footerTitle.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),

            footerTitle.topAnchor.constraint(equalToSystemSpacingBelow: logoFooter.bottomAnchor, multiplier: 3),
            logoFooter.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            grapho.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            grapho.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            grapho.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            grapho.topAnchor.constraint(equalToSystemSpacingBelow: loginButton.bottomAnchor, multiplier: 6)
        ])

        if let label = feedBackLabel {
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalToSystemSpacingBelow: loginButton.bottomAnchor, multiplier: 1),
                label.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
                label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),

                continueWithoutCadBtn.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
                continueWithoutCadBtn.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 15)
            ])
        }

        if errorMessage != nil {
            loginButtonTop = loginButton.topAnchor.constraint(equalToSystemSpacingBelow: errorLabel.bottomAnchor, multiplier: 2.5)
            NSLayoutConstraint.activate([
                loginButtonTop,
                errorBox.topAnchor.constraint(equalToSystemSpacingBelow: largeTitle.bottomAnchor, multiplier: 2.5),
                errorBox.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
                errorBox.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
            ])
        } else {
            loginButtonTop = loginButton.topAnchor.constraint(equalToSystemSpacingBelow: largeTitle.bottomAnchor, multiplier: 5)
            NSLayoutConstraint.activate([
                loginButtonTop
            ])
        }
    }

    func clearError() {
        self.errorMessage = nil
        self.errorLabel.text = nil
        NSLayoutConstraint.deactivate([loginButtonTop])
        loginButtonTop = loginButton.topAnchor.constraint(equalToSystemSpacingBelow: largeTitle.bottomAnchor, multiplier: 5)
        NSLayoutConstraint.activate([loginButtonTop])
        errorBox.removeFromSuperview()
    }

    func showError() {
        view.addSubview(errorBox)
        NSLayoutConstraint.deactivate([loginButtonTop])
        loginButtonTop = loginButton.topAnchor.constraint(equalToSystemSpacingBelow: errorLabel.bottomAnchor, multiplier: 2.5)
        NSLayoutConstraint.activate([
            loginButtonTop,
            errorBox.topAnchor.constraint(equalToSystemSpacingBelow: largeTitle.bottomAnchor, multiplier: 2.5),
            errorBox.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            errorBox.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
}
