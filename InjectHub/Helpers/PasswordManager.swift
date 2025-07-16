//
//  PasswordManager.swift
//  InjectHub
//
//  Created by NKR on 14/07/25.
//

import SwiftUI

class PasswordManager {
    static let shared = PasswordManager()
    
    private let userDefaultsKey = "Admin"

    // Save encrypted password
    func savePassword(_ password: String) -> Bool {
        let passwordData = Data(password.utf8)
        let base64 = passwordData.base64EncodedString()
        UserDefaults.standard.set(base64, forKey: userDefaultsKey)
        return true
    }

    // Retrieve password
    func getPassword() -> String? {
        guard let base64 = UserDefaults.standard.string(forKey: userDefaultsKey),
              let data = Data(base64Encoded: base64),
              let password = String(data: data, encoding: .utf8) else {
            return nil
        }
        return password
    }
    
    // Delete password
    func deletePassword() -> Bool {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        return true
    }
}


//import Foundation
//import Security
//
//class PasswordManager {
//    
//    // Save a password to the Keychain
//    func savePassword(_ password: String, forKey key: String) -> Bool {
//        let passwordData = password.data(using: .utf8)!
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrAccount as String: key,
//            kSecValueData as String: passwordData
//        ]
//        
//        // Delete any existing items
//        SecItemDelete(query as CFDictionary)
//        
//        // Add the new password
//        let status = SecItemAdd(query as CFDictionary, nil)
//        return status == errSecSuccess
//    }
//    
//    // Retrieve a password from the Keychain
//    func getPassword(forKey key: String) -> String? {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrAccount as String: key,
//            kSecReturnData as String: kCFBooleanTrue!,
//            kSecMatchLimit as String: kSecMatchLimitOne
//        ]
//        
//        var dataTypeRef: AnyObject? = nil
//        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
//        
//        if status == errSecSuccess {
//            if let passwordData = dataTypeRef as? Data,
//               let password = String(data: passwordData, encoding: .utf8) {
//                return password
//            }
//        }
//        return nil
//    }
//}

//In Memory for Session
//class PasswordManager {
//    static let shared = PasswordManager()
//    private var memoryPassword: String?
//
//    func savePassword(_ password: String) -> Bool {
//        memoryPassword = password
//        return true
//    }
//
//    func getPassword() -> String? {
//        return memoryPassword
//    }
//
//    func deletePassword() -> Bool {
//        memoryPassword = nil
//        return true
//    }
//}

