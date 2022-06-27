//
//  NotificationServicew.swift
//  AgenteDeCampoCommon
//
//  Created by Samir Chaves on 21/06/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import RestClient

private struct DeviceRegistration: Codable {
    public let deviceToken: String
}

public class CadNotificationService {
    @CadServiceInject
    private var cadService: CadService

    public static var shared = CadNotificationService()

    public func registerDevice(token: String, completion: @escaping (Error?) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(NSError(domain: "Não foi registrar o token de notificação para esse dispositivo.", code: 400, userInfo: nil))
            return
        }

        let registration = DeviceRegistration(deviceToken: token)
        let rest = cadClient.path("/cad/notifications/register/ios")
            .ContentTypeJson()
            .body(registration)
            .acceptJson()
            .build()
        rest?.post(completion: { (result: Result<NoContent, Error>) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        })
    }
}
