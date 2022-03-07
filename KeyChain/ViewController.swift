//
//  ViewController.swift
//  KeyChain
//
//  Created by Aaryaman Saini on 06/03/22.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        save()
        
        getPassword()
    }
    
    func getPassword(){
        guard let data = KeychainManager.get(service: "Brazzers.com", account: "tom")
        else {
            print("failed to read password")
            return
        }
        
        let password = String(decoding: data, as: UTF8.self)
        print("Read password: \(password)")
    }
    
    func save() {
        do{
            try KeychainManager.save(
                service: "Brazzers.com",
                account: "tom",
                password: "password".data(using: .utf8) ?? Data()
            )
        } catch {
            print(error)
        }
    }
}

class KeychainManager {
    enum KeychainError: Error{
        case duplicateEntry
        case unknown(OSStatus)
    }
    
    static func save(
        service: String,
        account: String,
        password: Data
    ) throws {
        print("Starting...")
        // service, account, password, class
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecValueData as String: password as AnyObject
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil) // Core Factor Dictionary
        
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateEntry
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
        
        print("Saved")
    }
    
    // service, account, class, return-data, matchlimit
    static func get(
        service: String,
        account: String
    ) -> Data? {
        print("Starting...")
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne // We want to match the query with all the things we have saved but we only want it to be matched to one.
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary,
                                         &result)
        
        print("read status: \(status)")
        return result as? Data
    }
    
}

