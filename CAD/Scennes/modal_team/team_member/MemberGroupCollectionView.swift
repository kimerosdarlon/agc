//
//  MemberGroupCollectionView.swift
//  CAD
//
//  Created by Ramires Moreira on 08/08/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import UIKit
import AgenteDeCampoCommon

protocol MemberGroupDelegate: class {
    func didSelectAMember(_ member: TeamPerson)
    func didSelectAMember(_ member: SimpleTeamPerson)
}

extension MemberGroupDelegate {
    func didSelectAMember(_ member: TeamPerson) { }
    func didSelectAMember(_ member: SimpleTeamPerson) { }
}

class MemberGroupCollectionView: UICollectionView {
    weak var membersDelegate: MemberGroupDelegate?
    private var isInteractable = false

    enum Section {
        case main
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, TeamPerson>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, TeamPerson>
    private typealias NonCriticalDataSource = UICollectionViewDiffableDataSource<Section, SimpleTeamPerson>
    private typealias NonCriticalSnapshot = NSDiffableDataSourceSnapshot<Section, SimpleTeamPerson>
    private var snapShot: Snapshot?
    private var qualificationDataSource: DataSource?
    private var nonCriticalSnapShot: NonCriticalSnapshot?
    private var nonCriticalDataSource: NonCriticalDataSource?
    private let builder = GenericDetailBuilder()
    private var onlinePeopleCpfs: [String]

    init(people: [TeamPerson], onlinePeopleCpfs: [String] = []) {
        let layout = FlowLayout()
        isInteractable = true
        layout.scrollDirection = .horizontal
        self.onlinePeopleCpfs = onlinePeopleCpfs
        super.init(frame: .zero, collectionViewLayout: layout)
        register(MemberCollectionViewCell.self, forCellWithReuseIdentifier: MemberCollectionViewCell.identifier)
        backgroundColor = .clear
        qualificationDataSource = makeDatasource(collection: self)
        dataSource = qualificationDataSource
        delegate = self
        snapShot = Snapshot()
        snapShot?.appendSections([.main])
        snapShot?.appendItems(people)
        qualificationDataSource?.apply(snapShot!, animatingDifferences: false, completion: nil)
        overrideUserInterfaceStyle = UserStylePreferences.theme.style
    }

    init(people: [SimpleTeamPerson], onlinePeopleCpfs: [String] = []) {
        let layout = FlowLayout()
        layout.scrollDirection = .horizontal
        isInteractable = true
        self.onlinePeopleCpfs = onlinePeopleCpfs
        super.init(frame: .zero, collectionViewLayout: layout)
        register(MemberCollectionViewCell.self, forCellWithReuseIdentifier: MemberCollectionViewCell.identifier)
        backgroundColor = .clear
        delegate = self
        nonCriticalDataSource = makeNonCriticalDatasource(collection: self)
        dataSource = nonCriticalDataSource
        nonCriticalSnapShot = NonCriticalSnapshot()
        nonCriticalSnapShot?.appendSections([.main])
        nonCriticalSnapShot?.appendItems(people)
        nonCriticalDataSource?.apply(nonCriticalSnapShot!, animatingDifferences: false, completion: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeDatasource(collection: UICollectionView) -> DataSource {
        return DataSource(collectionView: collection) {(collectionView, indexPath, person) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MemberCollectionViewCell.identifier,
                for: indexPath) as! MemberCollectionViewCell
            cell.configure(
                withName: person.person.functionalName,
                teamRole: person.role.name,
                role: person.person.role,
                image: MemberViewModel.defaultImage!,
                isOnline: self.onlinePeopleCpfs.contains(person.person.cpf)
            )
            return cell
        }
    }

    private func makeNonCriticalDatasource(collection: UICollectionView) -> NonCriticalDataSource {
        return NonCriticalDataSource(collectionView: collection) {(collectionView, indexPath, member) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MemberCollectionViewCell.identifier,
                for: indexPath) as! MemberCollectionViewCell
            cell.configure(
                withName: member.person.functionalName,
                teamRole: member.role.name,
                role: member.person.role,
                image: MemberViewModel.defaultImage!,
                isOnline: member.person.cpf.map { self.onlinePeopleCpfs.contains($0) } ?? false
            )
            cell.contentView.backgroundColor = .clear
            cell.contentView.layer.borderWidth = 1
            cell.contentView.layer.borderColor = UIColor.appTitle.cgColor.copy(alpha: 0.4)
            return cell
        }
    }

    func configure(withPeople people: [SimpleTeamPerson], onlinePeopleCpfs: [String]) {
        self.onlinePeopleCpfs = onlinePeopleCpfs
        nonCriticalSnapShot = NonCriticalSnapshot()
        nonCriticalSnapShot?.appendSections([.main])
        nonCriticalSnapShot?.appendItems(people)
        nonCriticalDataSource?.apply(nonCriticalSnapShot!, animatingDifferences: false, completion: nil)
    }
}

extension MemberGroupCollectionView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 220, height: 70)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let member = qualificationDataSource?.itemIdentifier(for: indexPath), isInteractable {
            membersDelegate?.didSelectAMember(member)
        }
        if let member = nonCriticalDataSource?.itemIdentifier(for: indexPath), isInteractable {
            membersDelegate?.didSelectAMember(member)
        }
    }
}
