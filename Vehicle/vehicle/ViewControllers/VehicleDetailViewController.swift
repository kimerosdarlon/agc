//
//  VehicleDetailViewController.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 30/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import MapKit
import AgenteDeCampoCommon
import Logger
/// Essa view mostra os detalhes de um veículo, os dados mostrados podem ser diferentes dependendo do tipo de usuário, assim como o estado do veículo.
/// - Só mostrar o map caso o veículo possua algum alerta e somente se o usuário tiver a permissão para isso
/// - Deve exibir a lista de localização ordenado por data de registro
/// - O pins no mapa devem ter cores que variam de um tom mais esculo para mais claro, sendo o mais escuro a loalização mais recente
class VehicleDetailViewController: CustomViewController, MapNavigationSheetDelagate {

    /// objeto usado para fazer logs.
    lazy var logger = Logger.forClass(Self.self)

    /// view que mostra a placa do veículo
    let plateView = PlateViewComponent()

    /// mostra os alertas do véiculo
    let alertView = VehicleAlertView()

    /// usado para pegar dados dos últimos locais onde o veículo esteve
    let vehicleService = VehicleService()

    /// view onde acontece a interação de esticar e comprimir o header com os detalhes do veículo, essa view é colocada
    /// no bottom do header
    let headerViewInterector = HeaderInteractorView()

    /// view que mostra as últimas localizaçãoes do veículo no formato de lista
    let tableViewVehicleLocations = VehicleTableView(frame: .zero, style: .plain)

    /// corresponde a localização selecionada no map, é utilizado para mostrar detalhes e para realizar a navegação
    var selectedLocation: VehicleLocation?

    /// constraint de onde o top da tabela de veículos deve ficar, isso porque, ela poderá ser modifcada
    var tableTop: NSLayoutConstraint!

    /// valor mínimo de altura que o header pode ter, essa valor é utilizado para impedir limitar o tamanho mínimo na interação
    var minHeaderHeight: CGFloat { 40 }

    /// O valor de altura da view que aparece no bootom quando alguma localização no mapa é selecionado.
    /// Este valor é referente ao estado da view quando não tem nenhuma localização selecionada
    var defaultFooterHeight: CGFloat { 0 }

    /// Contraint que contém a altura artual do footer
    var locationDetailViewHeight: NSLayoutConstraint!

    /// Contém todas as informações detalhadas do veículo.
    var vehicleDetail: VehicleDetailViewModel

    /// Contém a atual altura do header
    var headerHeightConstraint: NSLayoutConstraint!

    /// Contém a atual altura do alert
    var alertHeightConstraint: NSLayoutConstraint!

    /// O tamanho alerta quando está comprimido
    var alertHeightColapsed: CGFloat = 60

    /// O tamanho alerta quando está expandido
    var alertHeightExpanded: CGFloat {
        if vehicleDetail.hasAlert && vehicleDetail.alert == nil {
            return 130
        }
        return 320
    }

    /// Um array com até as últimas 10 localizações disponíveis.
    var locations =  [VehicleLocation]()

    /// Um array ordenado com as datas das lozalizações. É utilizado no mapa para saber qual a posição do rank ele se encontra referente
    /// as demais localizações, isso porque é preciso definir qual imagem deve ser colocada no pin.
    var locationDates = [Date]()

    /// Apenas um `MKMapView` com algumas configurações. Esse map exibe as ultímas localizações disponíveis do veículo.
    var vehicleMapView = VehicleMapView()

    var messageAlert = CustomMessageAlert()

    /// View que contem todas as informações de detalhes do veículo, disposta em 2 colunas
    lazy var vehicleContentView = VehicleHeaderContent(frame: .zero, cornerRadius: canSeeVehiclesTrack ? 50 : 0, details: vehicleDetail)

    /// valor usado na interação do header para controlatr a animação
    private var lastHeaderLocation: CGFloat = 0

    /// View que mostra os detalhes da localização quando alguma localização é selecionada no mapa
    lazy var locationDetailView: PinDetail = {
        let detail = PinDetail(location: nil, marginBotton: 3)
        detail.backgroundColor = .appBackgroundCell
        detail.enableAutoLayout()
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoNavigation))
        detail.addGestureRecognizer(tap)
        return detail
    }()

    /// Um `UISegmentedControl` responsável por realizar o toggle entre o map e lista
    let switchMapListButton: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Mapa", "Lista"])
        segment.enableAutoLayout()
        segment.configureAppDefault()
        segment.selectedSegmentIndex = 0
        segment.backgroundColor = .appBackgroundCell
        return segment
    }()

    /// O tamanho inicial do header de details
    var startHeaderHeight: CGFloat { 300 }

    /// É verdadeiro caso o usuário tenha permissão pra ver os detalhes do veículo e o veículo tenha algum alerta. É false caso contrário
    var canSeeVehiclesTrack: Bool {
        guard let user = UserService.shared.getCurrentUser() else {
            return false
        }
        return user.canSeeVehiclesTrack && vehicleDetail.hasAlert
    }

    /// Tempo de animação do header, o tempo é variável, com a finalidade de manter a velocidade da animação constante.
    var headerAnimationTime: Double {
        return Double(abs((startHeaderHeight - headerHeightConstraint.constant)/500))
    }

    /// Controller com os detalhes do veículo
    /// - Parameter vehicleDetail: view model com as informações de detalhes do veículo
    init(vehicleDetail: VehicleDetailViewModel) {
        self.vehicleDetail = vehicleDetail
        super.init(nibName: nil, bundle: nil)
        title = "Detalhes"
        plateView.set(vehicle: vehicleDetail)
        alertView.delegate = self
        tableViewVehicleLocations.delegate = self
        tableViewVehicleLocations.dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupGestures()
        self.vehicleMapView.delegate = self
        requestVehicleTrack()

        if let conversionAlert = vehicleDetail.conversionAlert {
            messageAlert.configure(withText: conversionAlert, inView: view)
            messageAlert.show()
            messageAlert.delegate = self

            plateView.warningDelegate = self

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.messageAlert.hide()
            }
        }

        if vehicleDetail.alertSystemOutOfService || vehicleDetail.hasAlert {
            alertView.configure(with: vehicleDetail.alert,
                                hasAlert: vehicleDetail.hasAlert,
                                alertSystemOutOfService: vehicleDetail.alertSystemOutOfService)
        }
    }

    /// Obtém as localizações do veículo caso o usuário tenha permissão
    private func requestVehicleTrack() {
        if canSeeVehiclesTrack {
            vehicleService.track(plate: vehicleDetail.plate) { result in
                switch result {
                case .success(let locations):
                    self.setupVehicleTrack(locations)
                case .failure(let error):
                    self.handlerRequestError(error, completion: nil)
                }
            }
        }
    }

    @objc
    func gotoNavigation() {
        guard let location = selectedLocation else { return  }
        let navigationOptions = MapNavigationSheet(location: location)
        navigationOptions.delegate = self
        navigationOptions.showOptions()
    }

    func setupVehicleTrack(_ locations: [VehicleLocation]) {
        self.locations = locations.sorted(by: { $0.date.compare($1.date) == ComparisonResult.orderedDescending })
        locationDates = locations.map({$0.date})
        DispatchQueue.main.async {
            self.vehicleMapView.addAnnotations(locations)
            if let firstLocation = locations.first {
                let center = firstLocation.coordinate
                self.vehicleMapView.setCenter(center, animated: true)
                let region = MKCoordinateRegion(center: center, span: .init(latitudeDelta: 0.5, longitudeDelta: 0.5))
                self.vehicleMapView.setRegion(region, animated: true)
            }
            self.tableViewVehicleLocations.reloadData()
        }
    }

    func setupGestures() {
        if canSeeVehiclesTrack {
            let tap = UITapGestureRecognizer(target: self, action: #selector(didClickOnMapView))
            tap.numberOfTapsRequired = 1
            vehicleMapView.addGestureRecognizer(tap)
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(increaseHeight ))
            headerViewInterector.addGestureRecognizer(gesture)
        }
    }

    override func addSubviews() {
        if canSeeVehiclesTrack { view.addSubview(vehicleMapView) }
        view.addSubview(vehicleContentView)
        view.addSubview(locationDetailView)
        view.backgroundColor = .white
        view.addSubview(plateView)
        view.addSubview(alertView)
        headerViewInterector.isHidden = !canSeeVehiclesTrack
        vehicleContentView.addSubview(headerViewInterector)
        headerHeightConstraint = vehicleContentView.heightAnchor.constraint(equalToConstant: startHeaderHeight)
        if canSeeVehiclesTrack {
            headerHeightConstraint.isActive = true
            let compassBtn = MKCompassButton(mapView: vehicleMapView)
            compassBtn.enableAutoLayout()
            compassBtn.width(40).height(40)
            compassBtn.compassVisibility = .visible

            view.insertSubview(switchMapListButton, aboveSubview: vehicleMapView)
            switchMapListButton.addTarget(self, action: #selector(toggleTableView(_:)), for: .valueChanged)
            view.insertSubview(tableViewVehicleLocations, belowSubview: switchMapListButton)
            tableTop = vehicleContentView.bottomAnchor.constraint(equalToSystemSpacingBelow: tableViewVehicleLocations.topAnchor, multiplier: 5)
            view.insertSubview(compassBtn, belowSubview: tableViewVehicleLocations)
            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalToSystemSpacingAfter: compassBtn.trailingAnchor, multiplier: 2),
                view.bottomAnchor.constraint(equalToSystemSpacingBelow: compassBtn.bottomAnchor, multiplier: 3)
            ])
        } else {
            NSLayoutConstraint.activate([
                view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: vehicleContentView.bottomAnchor)
            ])
        }
    }

    override func setupConstraints() {
        let contrainstDelegate = VehicleContraintsConfigurations()
        contrainstDelegate.setupContraints(controller: self)
    }

    @objc
    func toggleTableView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            UIView.animate(withDuration: 0.3) {
                self.toggleDetailFooter(reveal: false)
                self.locationDetailView.layoutIfNeeded()
                NSLayoutConstraint.activate([ self.tableTop ])
                self.tableViewVehicleLocations.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                NSLayoutConstraint.deactivate([ self.tableTop ])
                self.tableViewVehicleLocations.layoutIfNeeded()
            }
        }
    }

    @objc
    func increaseHeight(_ gesture: UIPanGestureRecognizer ) {
        let translation = gesture.translation(in: view)
        lastHeaderLocation = lastHeaderLocation == 0 ? startHeaderHeight : lastHeaderLocation
        let point = lastHeaderLocation + translation.y
        let stoppedBelowTheMiddle =  point >= ( view.frame.height/2 ) && gesture.state == .ended
        let stoppedAboveTheStartHeight = point < startHeaderHeight && gesture.state == .ended

        if stoppedBelowTheMiddle {
            increaseHeaderHeightToBottom(headerAnimationTime)
        } else if stoppedAboveTheStartHeight {
            decreaseHeaderHeightToTop(headerAnimationTime)
        } else {
            NSLayoutConstraint.deactivate([headerHeightConstraint])
            headerHeightConstraint.constant = min(max(point, minHeaderHeight), view.frame.height - (alertHeightExpanded - 120))
            NSLayoutConstraint.activate([headerHeightConstraint])
            self.lastHeaderLocation = gesture.state == .ended ? point : lastHeaderLocation
        }
    }

    @objc
    fileprivate func didClickOnMapView() {
        decreaseHeaderHeightToTop(headerAnimationTime)
        if alertView.expanded {
            colapseAlert(height: alertHeightColapsed)
        }
    }

    fileprivate func increaseHeaderHeightToBottom(_ time: Double) {
        NSLayoutConstraint.deactivate([headerHeightConstraint])
        if self.locationDetailViewHeight.constant > 50 {
            headerHeightConstraint.constant = view.frame.height - (view.frame.height/3.2 + self.locationDetailViewHeight.constant)
        } else {
            headerHeightConstraint.constant = view.frame.height - alertHeightExpanded
        }

        UIView.animate(withDuration: time, delay: 0, options: [.curveEaseInOut, .layoutSubviews], animations: {
            NSLayoutConstraint.activate([self.headerHeightConstraint])
            self.lastHeaderLocation = self.headerHeightConstraint.constant
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    func decreaseHeaderHeightToTop(_ time: Double) {
        NSLayoutConstraint.deactivate([headerHeightConstraint])
        headerHeightConstraint.constant = minHeaderHeight
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseInOut, .layoutSubviews], animations: {
            NSLayoutConstraint.activate([self.headerHeightConstraint])
            self.lastHeaderLocation = self.headerHeightConstraint.constant
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    func toggleDetailFooter(reveal: Bool) {
        let width = tableViewVehicleLocations.frame.width * 0.95
        let attr = [NSAttributedString.Key.font: UIFont.robotoMedium.withSize(17)]
        let title = NSString(string: locationDetailView.locationLabel.text ?? "" )
        let size = CGSize(width: width, height: 1000)
        let estimateFrame = title.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attr, context: nil)
        self.locationDetailViewHeight.constant =  reveal ? estimateFrame.height + 90 : defaultFooterHeight
        NSLayoutConstraint.activate([self.locationDetailViewHeight])
        self.view.layoutIfNeeded()
        self.locationDetailView.layoutIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }
}

extension VehicleDetailViewController: PlateViewWarningDelegate, CustomMessageAlertDelegate {
    func toggleWarningMessage() {
        messageAlert.toggle()
    }

    func didVisibilityChanged(_ isVisible: Bool) {
        plateView.didWarningVisibilityChanged(isVisible)
    }
}
