//
//  Model.swift
//  MyCustomFileManger
//
//  Created by Филипп Степанов on 08.09.2022.
//

import Foundation

enum StorageType: Int {
    case sandbox = 0
    case icloud = 1
    case userGroups = 2
}


var storage: StorageType {
    set {
        UserDefaults.standard.set(newValue.rawValue, forKey: "StorageTypeKey")
        UserDefaults.standard.synchronize()
    }
    
    get {
        return StorageType(rawValue: UserDefaults.standard.integer(forKey: "StorageTypeKey")) ?? .sandbox
    }
}



class Model {
    
    init() {
        loadData()
    }
    
    var isSorted: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isSorted")
        }
        set {
            UserDefaults.standard.set(true, forKey: "isSorted")
            UserDefaults.standard.synchronize()
        }
    }

    var files: [URL] {
        get {
            do {
                var files = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
                if self.isSorted {
                    files.sort(by: { $0.lastPathComponent.lowercased() < $1.lastPathComponent.lowercased() })
                }
                return files
            } catch {
                print(error.localizedDescription)
                return []
            }
        }
        set {
            
        }
    }
    
    var url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    private func loadData() {
        if storage == .icloud {
            if let _ = FileManager.default.ubiquityIdentityToken,
               let cloudFolderURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                
                print(cloudFolderURL.path)
                
                url = cloudFolderURL
            } else {
                print("iCloud not active")
            }
        } else if storage == .userGroups {
            if let urlAppGroups = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.StepanovFR") {
                print(urlAppGroups.path)
                url = urlAppGroups
            } else {
                print("App group not active")
            }
        } else {
            url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }
        
    }
    
    func createFile(name: String, content: String) {
        let path = self.url.appendingPathComponent(name).path
        do {
            try NSString(string: content).write(toFile: path, atomically: true, encoding: String.Encoding.utf8.rawValue)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createFolder(text: String) {
        let newUrl = self.url.appendingPathComponent(text)
        do {
            try FileManager.default.createDirectory(at: newUrl, withIntermediateDirectories: false)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
