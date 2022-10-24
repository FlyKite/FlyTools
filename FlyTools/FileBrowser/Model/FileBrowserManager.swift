//
//  FileBrowserManager.swift
//  FlyTools
//
//  Created by FlyKite on 2022/10/24.
//

import Foundation

struct FileContainer {
    let name: String
    let url: URL
}

protocol FileBrowserDataSource {
    var currentDirectoryName: String { get }
    var showHiddenFiles: Bool { get }
    var contents: [String] { get }
    func contentType(for contentName: String) -> FileContentType
    func url(for contentName: String) -> URL
}

enum FileContentType {
    case directory
    case text
    case image
    case video
    case audio
    case database
    case unsupported
    
    var icon: UIImage? {
        switch self {
        case .directory: return UIImage(systemName: "folder.fill")
        case .text: return UIImage(systemName: "doc.plaintext.fill")
        case .image: return UIImage(systemName: "photo.fill")
        case .video: return UIImage(systemName: "play.tv.fill")
        case .audio: return UIImage(systemName: "music.note.tv.fill")
        case .database: return UIImage(systemName: "chart.bar.doc.horizontal.fill")
        case .unsupported: return UIImage(systemName: "doc.fill")
        }
    }
}

enum SupportedFileType: String {
    case txt
    case json
    
    case jpg
    case jpeg
    case png
    case heic
    case dng
    case gif
    case ktx
    
    case mp3
    case m4a
    case wav
    
    case mp4
    case avi
    
    case sqlite
}

class FileBrowserManager: FileBrowserDataSource {
    
    let directoryUrl: URL
    let currentDirectoryName: String
    let showHiddenFiles: Bool
    
    private(set) var contents: [String] = []
    private var contentTypeDict: [String: FileContentType] = [:]
    
    init(sandbox container: SandboxContainer, showHiddenFiles: Bool) {
        self.directoryUrl = URL(fileURLWithPath: container.path)
        self.currentDirectoryName = container.name
        self.showHiddenFiles = showHiddenFiles
    }
    
    init(directoryUrl: URL? = nil, showHiddenFiles: Bool) {
        self.directoryUrl = directoryUrl ?? URL(fileURLWithPath: NSHomeDirectory())
        self.currentDirectoryName = directoryUrl == nil ? "Home" : self.directoryUrl.lastPathComponent
        self.showHiddenFiles = showHiddenFiles
        loadContents()
    }
    
    private func loadContents() {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: directoryUrl.path)
            if showHiddenFiles {
                self.contents = contents
            } else {
                self.contents = contents.filter { !$0.starts(with: ".") }
            }
        } catch {
            print(error)
        }
    }
    
    func contentType(for contentName: String) -> FileContentType {
        if let contentType = contentTypeDict[contentName] {
            return contentType
        } else {
            let url = directoryUrl.appendingPathComponent(contentName)
            var isDirectory = ObjCBool(false)
            FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
            let contentType: FileContentType
            if isDirectory.boolValue {
                contentType = .directory
            } else if let type = SupportedFileType(rawValue: url.pathExtension) {
                switch type {
                case .txt, .json: contentType = .text
                case .jpg, .jpeg, .png, .heic, .dng, .gif, .ktx: contentType = .image
                case .mp3, .m4a, .wav: contentType = .audio
                case .mp4, .avi: contentType = .video
                case .sqlite: contentType = .database
                }
            } else {
                contentType = .unsupported
            }
            contentTypeDict[contentName] = contentType
            return contentType
        }
    }
    
    func url(for contentName: String) -> URL {
        return directoryUrl.appendingPathComponent(contentName)
    }
}

class SandboxContainerManager: FileBrowserDataSource {
    let containers: [SandboxContainer]
    var currentDirectoryName: String { "Home" }
    let showHiddenFiles: Bool
    
    let contents: [String]
    private let urlDict: [String: URL]
    
    init(containers: [SandboxContainer], showHiddenFiles: Bool) {
        self.containers = containers
        self.showHiddenFiles = showHiddenFiles
        self.contents = containers.map { $0.name }
        var urlDict: [String: URL] = [:]
        for container in containers {
            urlDict[container.name] = URL(fileURLWithPath: container.path)
        }
        self.urlDict = urlDict
    }
    
    func contentType(for contentName: String) -> FileContentType {
        return .directory
    }
    
    func url(for contentName: String) -> URL {
        return urlDict[contentName] ?? URL(fileURLWithPath: NSHomeDirectory())
    }
}
