//
//  RestTemplateBuilder.swift
//  RestClient
//
//  Created by Ramires Moreira on 06/05/20.
//  Copyright © 2020 Ramires Moreira. All rights reserved.
//

import Foundation

typealias HeaderType = (name: String, value: String)

struct HttpHeader {
    static var Authorization: HeaderType = (name: "Authorization", value: "")
    static var AcceptJson: HeaderType = (name: "Accept", value: "application/json")
    static var JsonContent: HeaderType = (name: "Content-Type", value: "application/json")
}

public class RestTemplateBuilder {

    private(set) var host: String?

    private var debug: Bool!

    typealias Entity = Encodable
    private var path = ""
    private var params: [String: Any]?
    private var headers: [String: Any]?
    private var body: Data?
    private var basePath = ""
    private let connectionService: ConnectionService!
    public init(enviroment: RestConfiguration, basePath: String = "/api") {
        debug = enviroment.debug
        host = enviroment.host
        connectionService = ConnectionService(host: host!)
        headers = .init()
        self.basePath = basePath
        if host!.hasSuffix("/") {
            host = String(host!.dropLast())
        }
    }

    public func path(_ path: String) -> RestTemplateBuilder {
        let prefix = path.hasPrefix("/") ? "" : "/"
        self.path = basePath + prefix + path
        return self
    }

    public func params(_ params: [String: Any]) -> RestTemplateBuilder {
        self.params = params
        return self
    }

    public func body(_ body: Data ) -> RestTemplateBuilder {
        self.body = body
        return self
    }

    public func body<T: Encodable>(_ body: T ) -> RestTemplateBuilder {
        self.body = try? JSONEncoder().encode(body)
        return self
    }

    public func headers(_ headers: [String: Any]) -> RestTemplateBuilder {
        self.headers = headers
        return self
    }

    public func addHeader(name: String, value: Any) -> RestTemplateBuilder {
        self.headers?[name] = value
        return self
    }

    public func acceptJson() -> RestTemplateBuilder {
        self.headers?[HttpHeader.AcceptJson.name] = HttpHeader.AcceptJson.value
        return self
    }

    public func ContentTypeJson() -> RestTemplateBuilder {
        self.headers?[HttpHeader.JsonContent.name] = HttpHeader.AcceptJson.value
        return self
    }

    public func addToken(token: String) -> RestTemplateBuilder {
        self.headers?[HttpHeader.Authorization.name] = token
        return self
    }

    private func buildQueryItem( _ param : (key: String, value: Any) ) -> [URLQueryItem] {
        if let valueList = param.value as? [String] {
            return valueList.map { valueItem in
                URLQueryItem(name: param.key, value: valueItem)
            }
        }
        return [URLQueryItem(name: param.key, value: "\(param.value)")]
    }

    public func extractRequest() -> URLRequest? {
        guard let host = host else { NSLog("host is not defined"); return nil }
        let baseUrl = host.appending(path)
        var urlComponents = URLComponents(string: baseUrl)
        if let params = params {
            let queryItems = params.flatMap { buildQueryItem($0) }
            urlComponents?.queryItems = queryItems
        }
        guard let url = urlComponents?.url else {NSLog("Error to create URL"); return nil}
        var request = URLRequest(url: url)

        let containerDb = UserDefaults(suiteName: "serpro_data")
        if let identityHeader = containerDb?.string(forKey: "identity") {
            request.addValue(identityHeader, forHTTPHeaderField: "Identity")
        }

        headers?.forEach { (key, value) in
            request.addValue("\(value)", forHTTPHeaderField: key)
        }

        request.addValue("agente-campo-ios-\(version())", forHTTPHeaderField: "X-Identifier")
        request.httpBody = body
        return request
    }

    public func build() -> RestTemplate? {
        guard let request = extractRequest() else { return nil }
        let client = RestTemplate(request: request, debug: debug)
        client.connectionService = self.connectionService
        return client
    }

    private func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version).\(build)"
    }
}
