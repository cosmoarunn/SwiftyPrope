//
//  KeyChainStorage.swift
//  Prope
//
//  Created by ARUN PANNEERSELVAM on 14/12/2024.
//

import Foundation
import Combine

public enum KeychainError: Error {
    case notFound
    case notAllowed
    case unknownError(OSStatus)

    fileprivate init(_ status: OSStatus) {
        switch status {
        case errSecItemNotFound:
            self = .notFound
        case errSecInteractionNotAllowed:
            self = .notAllowed
        default:
            self = .unknownError(status)
        }
    }
}

// MARK: -

public protocol KeychainStorage : ObservableObject {
    func dataValue(service: String, key: String) throws -> Data
    func setDataValue(_ dataValue: Data, service: String, key: String) throws
    func removeValue(service: String, key: String) throws
}

// MARK: -

public class KeychainStorageImpl: KeychainStorage {
    private let isUsingProductionService: Bool

    public init(isUsingProductionService: Bool) {
        self.isUsingProductionService = isUsingProductionService
        PropeSingleton.register(self)
    }

    private func normalizeService(_ service: String) -> String {
        return self.isUsingProductionService ? service : service + ".staging"
    }

    private func baseQuery(service: String, key: String) -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: normalizeService(service),
            kSecAttrAccount as String: key,
        ]
    }

    public func dataValue(service: String, key: String) throws -> Data {
        var query = self.baseQuery(service: service, key: key)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = true

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            throw KeychainError(status)
        }
        return item as! Data
    }

    public func setDataValue(_ dataValue: Data, service: String, key: String) throws {
        let query = self.baseQuery(service: service, key: key)
        let setValueQuery: [String: Any] = [
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecValueData as String: dataValue,
        ]

        PropeLog.info("Inserting \(service)/\(key)")

        // Insert
        do {
            let addValueQuery = query.merging(setValueQuery, uniquingKeysWith: { _, new in new })
            let status = SecItemAdd(addValueQuery as CFDictionary, nil)
            switch status {
            case errSecSuccess:
                return
            case errSecDuplicateItem:
                break
            default:
                throw KeychainError(status)
            }
        }

        PropeLog.info("Updating \(service)/\(key)")

        // or Update; if it already exists
        do {
            let status = SecItemUpdate(query as CFDictionary, setValueQuery as CFDictionary)
            switch status {
            case errSecSuccess:
                return
            default:
                throw KeychainError(status)
            }
        }
    }

    public func removeValue(service: String, key: String) throws {
        PropeLog.info("Removing \(service)/\(key)")
        let query = self.baseQuery(service: service, key: key)
        let status = SecItemDelete(query as CFDictionary)
        switch status {
        case errSecSuccess, errSecItemNotFound:
            return
        default:
            throw KeychainError(status)
        }
    }
}

