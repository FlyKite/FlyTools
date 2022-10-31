//
//  FileItem.swift
//  FlyTools
//
//  Created by FlyKite on 2022/10/25.
//

import UIKit

public struct SandboxContainer {
    public let name: String
    public let url: URL
    
    public init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
}

public struct Directory {
    let url: URL
    let name: String
    
    init(url: URL, name: String? = nil) {
        self.url = url
        self.name = name ?? url.lastPathComponent
    }
}

enum FileItem {
    case directory(_ directory: Directory)
    case file(_ file: File)
}

class File {
    let url: URL
    let name: String
    var type: FileType { getItemType() }
    
    private var itemType: FileType?
    
    enum FileType {
        case text
        case image
        case video
        case audio
        case database
        case unsupported
    }
    
    init(url: URL, name: String? = nil) {
        self.url = url
        self.name = name ?? url.lastPathComponent
    }
    
    private func getItemType() -> FileType {
        if let itemType = itemType {
            return itemType
        } else {
            let itemType: FileType
            if let fileType = SupportedFileType(rawValue: url.pathExtension.lowercased()) {
                itemType = fileType.itemType
            } else {
                itemType = .unsupported
            }
            self.itemType = itemType
            return itemType
        }
    }
}

extension FileItem {
    var url: URL {
        switch self {
        case let .directory(directory): return directory.url
        case let .file(file): return file.url
        }
    }
    
    var name: String {
        switch self {
        case let .directory(directory): return directory.name
        case let .file(file): return file.name
        }
    }
    
    @available(iOS 13.0, *)
    var icon: UIImage? {
        switch self {
        case .directory: return UIImage(systemName: "folder.fill")
        case let .file(file): return file.type.icon
        }
    }
    
    var iconEmoji: String {
        switch self {
        case .directory: return "📁"
        case let .file(file): return file.type.iconEmoji
        }
    }
}

extension File.FileType {
    @available(iOS 13.0, *)
    var icon: UIImage? {
        switch self {
        case .text: return UIImage(systemName: "doc.plaintext.fill")
        case .image: return UIImage(systemName: "photo.fill")
        case .video: return UIImage(systemName: "play.tv.fill")
        case .audio: return UIImage(systemName: "music.note.tv.fill")
        case .database: return UIImage(systemName: "chart.bar.doc.horizontal.fill")
        case .unsupported: return UIImage(systemName: "doc.fill")
        }
    }
    
    var iconEmoji: String {
        switch self {
        case .text: return "📋"
        case .image: return "🖼️"
        case .video: return "🎦"
        case .audio: return "▶️"
        case .database: return "🗄️"
        case .unsupported: return "📄"
        }
    }
}

private enum SupportedFileType: String {
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
    
    var itemType: File.FileType {
        switch self {
        case .txt, .json:
            return .text
        case .jpg, .jpeg, .png, .heic, .dng, .gif, .ktx:
            return .image
        case .mp3, .m4a, .wav:
            return .audio
        case .mp4, .avi:
            return .video
        case .sqlite:
            return .database
        }
    }
}
