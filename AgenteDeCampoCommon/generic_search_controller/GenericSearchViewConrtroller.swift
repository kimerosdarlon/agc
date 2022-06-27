//
//  GenericSearchViewConrtroller.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 25/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import Logger
import AgenteDeCampoModule

open class GenericSearchViewController: UIViewController, SearchApiResultController, EmptyStateViewDelegate {

    private var state: GenericSearchViewConrtollerState = .normal

    public var isFromSearch: Bool
    public var showOnlyInfoLabels: Bool

    lazy var logger = Logger.forClass(Self.self)

    public weak var dataSource: GenericSearchViewControllerDataSource? {
        didSet {
            table.dataSource = dataSource
        }
    }

    public weak var delegate: GenericSearchViewControllerDelegate? {
        didSet {
            table.delegate = self.delegate
        }
    }

    public let acvityIndicator = UIActivityIndicatorView(style: .large)

    public var userInfo = [String: String]()

    private var listParms = [String]()

    public var searchParms = [String: Any]()

    public let lblBadge = UILabel.init(frame: CGRect.init(x: 20, y: 0, width: 15, height: 15))

    public var collectionParams: UICollectionView = {
        let layout = FlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(SearchParamCollectionViewCell.self, forCellWithReuseIdentifier: SearchParamCollectionViewCell.identifier)
        collection.enableAutoLayout()
        collection.backgroundColor = .appBackground
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()

    public var table: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.backgroundColor = .appBackground
        table.enableAutoLayout()
        table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        table.separatorStyle = .singleLine
        return table
    }()

    public func setupInfo() {
        listParms.removeAll()
        for info in userInfo {
            if showOnlyInfoLabels {
                self.listParms.append(info.key)
            } else {
                self.listParms.append("\(info.key): \(info.value.uppercased())")
            }
        }
        self.lblBadge.text = "\(listParms.count)"
    }

    public required init(search params: [String: Any], userInfo: [String: String], isFromSearch: Bool) {
        self.isFromSearch = isFromSearch
        self.showOnlyInfoLabels = false
        super.init(nibName: nil, bundle: nil)
        self.userInfo = userInfo
        for param in params {
            if let paramStr = param.value as? String {
                self.searchParms[param.key] = paramStr.trimmingCharacters(in: .whitespaces)
            } else {
                self.searchParms[param.key] = param.value
            }
        }
        setupInfo()
    }

    public required init(search params: [String: Any], userInfo: [String: String], isFromSearch: Bool, showOnlyInfoLabels: Bool = false) {
        self.isFromSearch = isFromSearch
        self.showOnlyInfoLabels = showOnlyInfoLabels
        super.init(nibName: nil, bundle: nil)
        self.userInfo = userInfo
        for param in params {
            if let paramStr = param.value as? String {
                self.searchParms[param.key] = paramStr.trimmingCharacters(in: .whitespaces)
            } else {
                self.searchParms[param.key] = param.value
            }
        }
        setupInfo()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        title = "Boletins de Ocorrência"
        collectionParams.delegate = self
        collectionParams.dataSource = self
        addSubviews()
        setupContraints()
        setupFilterButton()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        table.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        collectionParams.overrideUserInterfaceStyle = UserStylePreferences.theme.style
        self.hidesBottomBarWhenPushed = false
    }

    func setupFilterButton() {
        if !isFromSearch { return }
        let filterBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
        filterBtn.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        filterBtn.addTarget(self, action: #selector(didClickInFilterButton), for: .touchUpInside)
        self.lblBadge.backgroundColor = .appBlue
        self.lblBadge.clipsToBounds = true
        self.lblBadge.layer.cornerRadius = 7
        self.lblBadge.textColor = UIColor.white
        self.lblBadge.font = UIFont.robotoRegular.withSize(10)
        self.lblBadge.textAlignment = .center
        filterBtn.addSubview(self.lblBadge)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(customView: filterBtn)]
    }

    @objc
    func didClickInFilterButton() {
        delegate?.didClickOnFilterButton()
    }

    public func setState(_ state: GenericSearchViewConrtollerState, message: String?) {
        self.state = state
        switch state {
        case .loading:
            setLoadingState()
        case .normal:
            setNormalState()
        case .notFound:
            setNotFoundState()
        case .serverError:
            setServiceErrorState(message: message)
        case .loadingMore:
            self.setRequestMoreState()
        }
    }

    func setRequestMoreState() {
        DispatchQueue.main.async {
            let view = UIView(frame: .init(x: 0, y: 0, width: self.table.frame.width, height: 33))
            view.backgroundColor = .appBackground
            view.addSubview(self.acvityIndicator)
            self.acvityIndicator.enableAutoLayout()
            self.acvityIndicator.fillSuperView()
            self.table.tableFooterView = view
            self.acvityIndicator.startAnimating()
        }
    }

    public func reloadTableView() {
        stopLoading()
        setupInfo()
        table.reloadData()
        self.userInfo.removeAll()
        collectionParams.reloadData()
    }

    private func setLoadingState() {
        table.backgroundView = acvityIndicator
        acvityIndicator.startAnimating()
    }

    private func setNormalState() {
        stopLoading()
    }

    private func setServiceErrorState(message: String?) {
        stopLoading()
        guard let config = dataSource?.didReturnServerErrorConfiguration() else { return }
        let serverError = EmptyStateView(title: config.title, subTitle: config.subtitle, image: UIImage(named: "service")!)
        serverError.delegate = self
        serverError.actionButton.setTitle(config.buttonTitle, for: .normal)
        table.backgroundView = serverError
        if let message = message, let title = message.split(separator: ".").first {
            serverError.titleLabel.text = String(title)
            if message.split(separator: ".").count > 1 {
                var array = message.split(separator: ".")
                array.removeSubrange(0...0)
                serverError.subTitleLabel.text = array.joined(separator: ".").appending(".")
            }
        }
    }

    private func setNotFoundState() {
        stopLoading()
        guard let config = dataSource?.didReturnNotFoundConfiguration() else {
            logger.warning("DataSource is nil")
            return
        }
        let notFoundView = EmptyStateView(title: config.title, subTitle: config.subtitle )
        notFoundView.actionButton.isHidden = !config.showButtonAction
        notFoundView.actionButton.setTitle(config.buttonTitle, for: .normal)
        notFoundView.delegate = self
        table.backgroundView = notFoundView
    }

    private func stopLoading() {
        garanteeMainThread {
            self.acvityIndicator.stopAnimating()
            self.acvityIndicator.removeFromSuperview()
            self.table.backgroundView = nil
        }
    }

    func addSubviews() {
        view.addSubview(collectionParams)
        view.addSubview(table)
    }

    func setupContraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            collectionParams.topAnchor.constraint(equalToSystemSpacingBelow: safeArea.topAnchor, multiplier: 2),
            collectionParams.leadingAnchor.constraint(equalToSystemSpacingAfter: safeArea.leadingAnchor, multiplier: 2),
            collectionParams.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionParams.heightAnchor.constraint(equalToConstant: 50)
        ])
        setupTableConstrains()
    }

    public func setupTableConstrains() {
        view.addSubview(table)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: collectionParams.bottomAnchor),
            table.leadingAnchor.constraint(equalToSystemSpacingAfter: safeArea.leadingAnchor, multiplier: 1),
            safeArea.trailingAnchor.constraint(equalToSystemSpacingAfter: table.trailingAnchor, multiplier: 1),
            safeArea.bottomAnchor.constraint(equalToSystemSpacingBelow: table.bottomAnchor, multiplier: 2)
        ])
    }

    public func didClickActionButton(_ button: UIButton) {
        delegate?.didClickRetryButton(button, on: state)
    }

    public func handlerError(_ error: NSError?) {
        guard let error = error else { return }
        if error.code == 404 {
            DispatchQueue.main.async {
                self.setState(.notFound, message: nil)
            }
        } else if isUnauthorized(error) {
            self.handlerRequestError(error) {
                self.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            DispatchQueue.main.async {
                if error.code == NSURLErrorTimedOut {
                    self.setState(.serverError, message: error.localizedDescription)
                } else {
                    self.setState(.serverError, message: error.domain)
                }
            }
        }
    }
}

extension GenericSearchViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listParms.count
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = SearchParamCollectionViewCell.identifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! SearchParamCollectionViewCell
        cell.configure(with: listParms[indexPath.item])
        return cell
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let attr = [NSAttributedString.Key.font: UIFont.robotoMedium.withSize(12)]
        let title = NSString(string: listParms[indexPath.item]).uppercased
        let size = CGSize(width: 1000, height: 50)
        let estimateFrame = title.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attr, context: nil)
        return .init(width: estimateFrame.width * 1.1, height: 33)
    }
}
