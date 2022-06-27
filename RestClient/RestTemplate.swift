//
//  RestTemplate.swift
//  Sinesp-Agente-Campo
//
//  Created by Ramires Moreira on 27/04/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation
import Location

public struct ErrorCodes: Equatable {
    public let code: Int
    public let message: String
    public static let noConnection = ErrorCodes(code: 100, message: "Verificamos que o dispositivo está sem internet.")
}

public enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

public struct HttpRequestError: Codable {
    let message: String
    let status: Int
}

public struct NoContent: Decodable {}

public class RestTemplate {
    public var request: URLRequest
    private var debug = true
    var connectionService: ConnectionService?
    private let locationService = LocationService.shared

    public init(request: URLRequest, debug: Bool) {
        self.request = request
        self.debug = debug
    }

    public func get(completion: @escaping (Result<Data, Error>) -> Void) {
        request.httpMethod = HTTPMethod.get.rawValue
        run(completion: completion)
    }

    public func post(completion: @escaping (Result<Data, Error>) -> Void) {
        request.httpMethod = HTTPMethod.post.rawValue
        run(completion: completion)
    }

    public func delete(completion: @escaping (Result<Data, Error>) -> Void) {
        request.httpMethod = HTTPMethod.delete.rawValue
        run(completion: completion)
    }

    public func put(completion: @escaping (Result<Data, Error>) -> Void) {
        request.httpMethod = HTTPMethod.put.rawValue
        run(completion: completion)
    }

    public func get<T: Decodable>(completion: @escaping (Result<T, Error>) -> Void) {
        request.httpMethod = HTTPMethod.get.rawValue
        run(completion: completion)
    }

    public func post<T: Decodable>(completion: @escaping (Result<T, Error>) -> Void) {
        request.httpMethod = HTTPMethod.post.rawValue
        run(completion: completion)
    }

    public func delete<T: Decodable>(completion: @escaping (Result<T, Error>) -> Void) {
        request.httpMethod = HTTPMethod.delete.rawValue
        run(completion: completion)
    }

    public func put<T: Decodable>(completion: @escaping (Result<T, Error>) -> Void) {
        request.httpMethod = HTTPMethod.put.rawValue
        run(completion: completion)
    }

    public func get(completion: @escaping (Result<NoContent, Error>) -> Void) {
        request.httpMethod = HTTPMethod.get.rawValue
        run(completion: completion)
    }

    public func post(completion: @escaping (Result<NoContent, Error>) -> Void) {
        request.httpMethod = HTTPMethod.post.rawValue
        run(completion: completion)
    }

    public func delete(completion: @escaping (Result<NoContent, Error>) -> Void) {
        request.httpMethod = HTTPMethod.delete.rawValue
        run(completion: completion)
    }

    public func put(completion: @escaping (Result<NoContent, Error>) -> Void) {
        request.httpMethod = HTTPMethod.put.rawValue
        run(completion: completion)
    }

    fileprivate func showRequestInfo() {
        printDebug("\n\n============== REQUEST ====================")
        printDebug(request.allHTTPHeaderFields ?? "Sem header")
        printDebug(request.httpMethod ?? "Sem Método" )
        printDebug(request.url?.absoluteString ?? "Sem url")
        if let data = request.httpBody {
            let json = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments])
            printDebug(json ?? "")
        } else {
            printDebug("Requisição sem corpo")
        }
        printDebug("================== FIM REQUEST ======================\n\n")
    }

    fileprivate func showResponseInfo(_ data: Data?, _ http: HTTPURLResponse) {
        printDebug("\n\n============== RESPONSE ==========================")
        if let data = data {
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            printDebug(json ?? "SEM CORPO NA RESPOSTA")
            printDebug("HTTP STATUS => \(http.statusCode)")
        } else {
            printDebug("Response sem corpo")
        }
        printDebug("=================== FIM RESPONSE ==================\n\n")
    }

    private func beforeRun<T>(completion: @escaping (Result<T, Error>) -> Void) {
        showRequestInfo()
        if let connetionType = self.connectionService?.checkConnection() {
            printDebug("================== Cheking connection ================")
            switch connetionType {
            case .none:
                printDebug(connetionType.rawValue)
                printDebug("============================================")
                let error = ErrorCodes.noConnection
                completion(.failure(NSError(domain: error.message, code: error.code, userInfo: nil)))
                return
            default:
                printDebug("Conectado via \(connetionType.rawValue)")
                printDebug("============================================\n\n")
            }
        }

        if let userLocation = locationService.currentLocation,
           userLocation.coordinate.latitude != 0,
           userLocation.coordinate.longitude != 0 {
            let coordinate = userLocation.coordinate
            request.addValue("\(coordinate.latitude),\(coordinate.longitude)", forHTTPHeaderField: "Geolocation")
        }
    }

    private func run(completion: @escaping (Result<Data, Error>) -> Void) {
        beforeRun(completion: completion)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let http = response as? HTTPURLResponse else { completion(.failure(error!)) ; return;}
            self.showResponseInfo(data, http)
            let success = (200...299).contains(http.statusCode)
            if let data = data, success {
                completion(.success(data))
            } else if http.statusCode == 404 {
                completion(.failure(NSError(domain: "NOT FOUND", code: 404, userInfo: nil) ))
            } else {
                self.decode(data: data, type: HttpRequestError.self) { (result, error) in
                    if let error = error {
                        completion(.failure( NSError.init(domain: error.localizedDescription, code: 0, userInfo: nil)) )
                    } else {
                        completion(.failure( NSError.init(domain: result!.message, code: result!.status, userInfo: nil)))
                    }
                }
            }
        }.resume()
    }

    private func run(completion: @escaping (Result<NoContent, Error>) -> Void) {
        beforeRun(completion: completion)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let http = response as? HTTPURLResponse else { completion(.failure(error!)) ; return;}
            self.showResponseInfo(data, http)
            let success = (200...299).contains(http.statusCode)
            if success {
                self.handleSuccess(completion: completion)
            } else if http.statusCode == 404 {
                completion(.failure(NSError(domain: "NOT FOUND", code: 404, userInfo: nil) ))
            } else {
                self.decode(data: data, type: HttpRequestError.self) { (result, error) in
                    if let error = error {
                        completion(.failure( NSError.init(domain: error.localizedDescription, code: 0, userInfo: nil)) )
                    } else {
                        completion(.failure( NSError.init(domain: result!.message, code: result!.status, userInfo: nil)))
                    }
                }
            }
        }.resume()
    }

    private func run<T: Decodable>(completion: @escaping (Result<T, Error>) -> Void) {
        beforeRun(completion: completion)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let http = response as? HTTPURLResponse else { completion(.failure(error!)) ; return;}
            self.showResponseInfo(data, http)
            let success = (200...299).contains(http.statusCode)
            if success {
                self.handleSuccess(data, type: T.self, completion: completion)
            } else if http.statusCode == 404 {
                completion(.failure(NSError(domain: "NOT FOUND", code: 404, userInfo: nil) ))
            } else {
                self.decode(data: data, type: HttpRequestError.self) { (result, error) in
                    if let error = error {
                        completion(.failure( NSError.init(domain: error.localizedDescription, code: 0, userInfo: nil)) )
                    } else {
                        completion(.failure( NSError.init(domain: result!.message, code: result!.status, userInfo: nil)))
                    }
                }
            }
        }.resume()
    }

    fileprivate func handleSuccess(completion: @escaping (Result<NoContent, Error>) -> Void) {
        completion(.success(NoContent()))
    }

    fileprivate func handleSuccess<T: Decodable>(_ data: Data?, type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        self.decode(data: data, type: type) { (object, error) in
            if let nserror = error as NSError? {
                completion(.failure(nserror))
            } else {
                 completion(.success(object!))
            }
        }
    }

    private func decode<T: Decodable >( data: Data?, type: T.Type, completion: ((T?, Error?) -> Void)? ) {
        let decoder = JSONDecoder()
        guard let data = data else {return}
        do {
            let result = try decoder.decode(type, from: data)
            completion?(result, nil)
        } catch let error as NSError {
            NSLog("Error to decode entity:")
            NSLog("%@", error.description)
            completion?(nil, NSError(domain: "Os dados não estão no formato esperado.", code: error.code, userInfo: error.userInfo))
        }
    }

    func printDebug(_ value: Any ) {
        if debug {
            print(value)
        }
    }
}
