//
//  FileBrowserManager.swift
//  FlyTools
//
//  Created by FlyKite on 2022/10/24.
//

import Foundation

protocol FileBrowserProvider {
    var currentDirectoryName: String { get }
    var showHiddenFiles: Bool { get }
    var items: [FileItem] { get }
    var error: Error? { get }
    
    func canDelete(at index: Int) -> Bool
    func delete(at index: Int) -> Bool
}

class DirectoryBrowserManager: FileBrowserProvider {
    
    let directory: Directory
    var currentDirectoryName: String { directory.name }
    let showHiddenFiles: Bool
    
    private(set) var items: [FileItem] = []
    private(set) var error: Error?
    
    init(directory: Directory, showHiddenFiles: Bool) {
        self.directory = directory
        self.showHiddenFiles = showHiddenFiles
        loadContents()
    }
    
    private func loadContents() {
        do {
            var contents = try FileManager.default.contentsOfDirectory(atPath: directory.url.path)
            if !showHiddenFiles {
                contents = contents.filter { !$0.starts(with: ".") }
            }
            items = contents.map { name in
                let url = directory.url.appendingPathComponent(name)
                var isDirectory = ObjCBool(false)
                FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
                return isDirectory.boolValue ? .directory(Directory(url: url)) : .file(File(url: url))
            }
        } catch {
            self.error = error
            FlyTools.log(.verbose, message: "\(error)")
        }
    }
    
    func canDelete(at index: Int) -> Bool {
        return true
    }
    
    func delete(at index: Int) -> Bool {
        do {
            let item = items[index]
            try FileManager.default.removeItem(at: item.url)
            items.remove(at: index)
            return true
        } catch {
            FlyTools.log(.verbose, message: "\(error)")
            return false
        }
    }
}

class SandboxBrowserManager: FileBrowserProvider {
    
    let containers: [SandboxContainer]
    var currentDirectoryName: String { "Home" }
    let showHiddenFiles: Bool
    
    let items: [FileItem]
    var error: Error? { nil }
    
    init(containers: [SandboxContainer], showHiddenFiles: Bool) {
        self.containers = containers
        self.showHiddenFiles = showHiddenFiles
        self.items = containers.map { container in
            return .directory(Directory(url: container.url, name: container.name))
        }
    }
    
    func canDelete(at index: Int) -> Bool {
        return false
    }
    
    func delete(at index: Int) -> Bool {
        return false
    }
}
