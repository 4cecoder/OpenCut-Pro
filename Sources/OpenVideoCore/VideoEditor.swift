import Foundation
import SwiftUI

// MARK: - Simple Logger

public actor SimpleLogger {
    public static let shared = SimpleLogger()
    
    public func debug(_ message: String) { print("[DEBUG] \(message)") }
    public func info(_ message: String) { print("[INFO] \(message)") }
    public func warning(_ message: String) { print("[WARNING] \(message)") }
    public func error(_ message: String) { print("[ERROR] \(message)") }
}

typealias VideoEditorLogger = SimpleLogger

// MARK: - Errors

public enum VideoEditorError: Error {
    case invalidClipIndex(Int)
    case clipNotFound(UUID)
    case invalidTimeRange(start: TimeInterval, end: TimeInterval)
    case exportFailed(URL, Error)
    case fileNotFound(URL)
    case processingFailed(String)
    case invalidProjectSettings
    case ffmpegNotFound
    case timelineEmpty
    case codecNotSupported(VideoCodec)
    case insufficientPermissions(URL)
    case diskSpaceInsufficient
    case networkError(Error)
    case unknownError(Error)
}

// MARK: - Video Processor Protocol

public protocol VideoProcessor: Sendable {
    func process(videoProject: VideoProject, timeline: Timeline) async throws -> Data
    func export(videoProject: VideoProject, timeline: Timeline, to url: URL) async throws
}

// MARK: - FFmpeg Video Processor

public actor FFmpegVideoProcessor: VideoProcessor {
    public init() {}
    
    public func process(videoProject: VideoProject, timeline: Timeline) async throws -> Data {
        return Data()
    }
    
    public func export(videoProject: VideoProject, timeline: Timeline, to url: URL) async throws {
        print("Exporting to \(url.path)...")
    }
}

// MARK: - File Manager

public protocol VideoFileManager: Sendable {
    func loadVideoFiles(from directory: URL) async throws -> [URL]
    func saveProject(_ project: VideoProject, to url: URL) async throws
    func loadProject(from url: URL) async throws -> VideoProject
}

public actor DefaultVideoFileManager: VideoFileManager {
    public init() {}
    
    public func loadVideoFiles(from directory: URL) async throws -> [URL] {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        let videoExtensions = ["mp4", "mov", "avi", "mkv", "webm", "m4v", "mts", "m2ts"]
        return contents.filter { url in
            videoExtensions.contains(url.pathExtension.lowercased())
        }
    }
    
    public func saveProject(_ project: VideoProject, to url: URL) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(project)
        try data.write(to: url)
    }
    
    public func loadProject(from url: URL) async throws -> VideoProject {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(VideoProject.self, from: data)
    }
}

// MARK: - Video Editor

public actor VideoEditor {
    private var project: VideoProject
    private var videoProcessor: any VideoProcessor
    private var fileManager: any VideoFileManager
    private let logger = SimpleLogger.shared
    
    public init(
        project: VideoProject,
        videoProcessor: (any VideoProcessor)? = nil,
        fileManager: (any VideoFileManager)? = nil
    ) {
        self.project = project
        self.videoProcessor = videoProcessor ?? FFmpegVideoProcessor()
        self.fileManager = fileManager ?? DefaultVideoFileManager()
    }
    
    public func addVideoClip(_ clip: VideoClip) async {
        project.timeline.addVideoClip(clip)
        await logger.info("Added video clip: \(clip.id)")
    }
    
    public func removeVideoClip(at index: Int) async {
        project.timeline.removeVideoClip(at: index)
        await logger.info("Removed video clip at index: \(index)")
    }
    
    public func export(to url: URL) async throws {
        guard !project.timeline.videoClips.isEmpty else {
            throw VideoEditorError.timelineEmpty
        }
        try await videoProcessor.export(videoProject: project, timeline: project.timeline, to: url)
        await logger.info("Exported to: \(url.path)")
    }
    
    public func preview() async throws -> Data {
        return try await videoProcessor.process(videoProject: project, timeline: project.timeline)
    }
    
    public var currentProject: VideoProject { project }
}
