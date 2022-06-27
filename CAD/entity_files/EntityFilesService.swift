//
//  EntityFilesService.swift
//  CAD
//
//  Created by Samir Chaves on 20/12/21.
//  Copyright © 2021 Samir Chaves. All rights reserved.
//

import Foundation
import UIKit
import RestClient

extension UIImage {
    func compressTo(expectedSizeInBytes sizeInBytes: Int) -> Data? {
        var needCompress = true
        var imgData: Data?
        var compressingValue: CGFloat = 1.0
        while needCompress && compressingValue > 0.0 {
            if let data = self.jpegData(compressionQuality: compressingValue) {
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                } else {
                    compressingValue -= 0.2
                }
            }
        }
        return imgData
    }
}

extension Data {
   mutating func append(_ string: String) {
      if let data = string.data(using: .utf8) {
         append(data)
      }
   }
}

public protocol EntityFilesService {
    func loadImage(id: UUID, completion: @escaping (Result<UIImage, Error>) -> Void)
    func addImage(to entityId: UUID, image: UIImage, completion: @escaping (Result<UUID, Error>) -> Void)
    func getImages(fromEntity entityId: UUID, completion: @escaping (Result<[UUID], Error>) -> Void)
    func removeImage(id: UUID, completion: @escaping (Error?) -> Void)
}

class EntityFilesServiceImpl: EntityFilesService {
    @CadServiceInject
    private var cadService: CadService

    private func generateBoundary() -> String {
        return "Boundary-\(UUID().uuidString)"
    }

    private func createDataBody(fromImage image: UIImage, boundary: String) -> Data? {
        let fileName = UUID().uuidString
        let lineBreak = "\r\n"
        var body = Data()
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"" + lineBreak)
        body.append("Content-Type: image/jpeg" + lineBreak + lineBreak)

        guard let imageData = image.compressTo(expectedSizeInBytes: 500000) ??
                image.jpegData(compressionQuality: 0.3) ??
                image.pngData() else { return nil }

        body.append(imageData)
        body.append(lineBreak)
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }

    func loadImage(id: UUID, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível recuperar o arquivo.", code: 400, userInfo: nil)))
            return
        }

        let rest = cadClient
            .path("/cad/entity-files/\(id.uuidString)")
            .build()

        rest?.get { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    completion(.failure(NSError(domain: "Não foi possível processar o arquivo.", code: 400, userInfo: nil)))
                    return
                }
                completion(.success(image))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getImages(fromEntity entityId: UUID, completion: @escaping (Result<[UUID], Error>) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(.failure(NSError(domain: "Não foi possível recuperar os arquivos.", code: 400, userInfo: nil)))
            return
        }

        let rest = cadClient
            .acceptJson()
            .path("/cad/entity-files/entity/\(entityId.uuidString)")
            .build()

        rest?.get(completion: completion)
    }

    func addImage(to entityId: UUID, image: UIImage, completion: @escaping (Result<UUID, Error>) -> Void) {
        let boundary = generateBoundary()
        guard let cadClient = cadService.getCadClient(),
              let body = createDataBody(fromImage: image, boundary: boundary) else {
            completion(.failure(NSError(domain: "Não foi possível enviar o arquivo.", code: 400, userInfo: nil)))
            return
        }

        let rest = cadClient
            .addHeader(name: "Content-Type", value: "multipart/form-data; boundary=\(boundary)")
            .body(body)
            .path("/cad/entity-files/entity/\(entityId.uuidString)")
            .build()

        rest?.post(completion: completion)
    }

    func removeImage(id: UUID, completion: @escaping (Error?) -> Void) {
        guard let cadClient = cadService.getCadClient() else {
            completion(NSError(domain: "Não foi possível remover o arquivo.", code: 400, userInfo: nil))
            return
        }

        let rest = cadClient
            .acceptJson()
            .path("/cad/entity-files/\(id.uuidString)")
            .build()

        rest?.delete { (result: Result<NoContent, Error>) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}

@propertyWrapper
public struct EntityFilesServiceInject {
    private var value: EntityFilesService

    public init() {
        self.value = EntityFilesServiceImpl()
    }

    public var wrappedValue: EntityFilesService { value }
}
