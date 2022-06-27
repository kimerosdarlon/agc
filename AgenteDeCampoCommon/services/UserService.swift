//
//  UserService.swift
//  SinespAgenteCampo
//
//  Created by Ramires Moreira on 13/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import SwiftyBeaver
import RestClient
import Logger

public class UserService {

    private var confidentialityService = ConfidentialityService()
    private static var sharedService: UserService!
    lazy var logger = Logger.forClass(Self.self)

    private var termsStatus: AgreementStatus!

    public static var shared: UserService {
        if let service = sharedService {
            return service
        }
        sharedService = UserService()
        return sharedService
    }

    private init() {}

    private var sharedUser: User?

    public func setCurrentUser(_ user: User) {
        sharedUser = user
    }

    public func getCurrentUser() -> User? {
        return sharedUser
    }

    public func getTermsStatus() -> AgreementStatus? {
        return termsStatus
    }

    public func agreeTerms(completion: @escaping () -> Void) {
        confidentialityService.agreeTerms { result in
            switch result {
            case .success:
                self.checkTermsAgreement(completion: completion)
            case .failure(let error):
                self.logger.error("Erro ao registrar assinatura dos termos: \(error.localizedDescription)")

            }
            completion()
        }
    }

    public func checkTermsAgreement(completion: @escaping () -> Void) {
        confidentialityService.checkAgreetment { result in
            switch result {
            case .success(let status):
                self.termsStatus = status
                completion()
            case .failure(let error):
                self.logger.error("Erro ao verificar assinatura dos termos: \(error.localizedDescription)")
                completion()
            }
        }
    }

    public func checkIfIsCadResource( completion: @escaping(Result<Bool, Error>) -> Void ) {
        DispatchQueue.global(qos: .background).async {
            sleep(3)
            #if DEBUG
                completion(.success(true))
            #else
                completion(.success(false))
            #endif
        }
    }
}
