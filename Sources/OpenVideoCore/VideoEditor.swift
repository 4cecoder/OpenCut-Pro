import Foundation

// MARK: - Simple Logger (replaces swift-log dependency)

/// A simple actor-based logger for the video editor
public actor SimpleLogger {
    public static let shared = SimpleLogger()
    
    private var logLevel: LogLevel = .info
    
    public func setLogLevel(_ level: LogLevel) {
        self.logLevel = level
    }
    
    public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    public func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    public func error(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        var fullMessage = message
        if let err = error {
            fullMessage += " - Error: \(err.localizedDescription)"
        }
        log(fullMessage, level: .error, file: file, function: function, line: line)
    }
    
    private func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        guard level.rawValue >= logLevel.rawValue else { return }
        
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let filename = (file as NSString).lastPathComponent
        print("[\(timestamp)] [\(level.rawValue)] [\(filename):\(line)] \(function): \(message)")
    }
}

/// Log severity levels
public enum LogLevel: Int, Sendable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    
    public var rawValue: String {
        switch self {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARNING"
        case .error: return "ERROR"
        }
    }
}

// Type alias for backwards compatibility
typealias VideoEditorLogger = SimpleLogger

// MARK: - Errors

/// Errors that can occur during video editing operations
public enum VideoEditorError: Error, LocalizedError {
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
    
    public var errorDescription: String? {
        switch self {
        case .invalidClipIndex(let index):
            return "Invalid clip index: \(index)"
        case .clipNotFound(let id):
            return "Clip not found with ID: \(id)"
        case .invalidTimeRange(let start, let end):
            return "Invalid time range: \(start) to \(end)"
        case .exportFailed(let url, let error):
            return "Failed to export to \(url.path): \(error.localizedDescription)"
        case .fileNotFound(let url):
            return "File not found: \(url.path)"
        case .processingFailed(let message):
            return "Processing failed: \(message)"
        case .invalidProjectSettings:
            return "Invalid project settings"
        case .ffmpegNotFound:
            return "FFmpeg not found in system PATH"
        case .timelineEmpty:
            return "Timeline is empty"
        case .codecNotSupported(let codec):
            return "Codec not supported: \(codec.rawValue)"
        case .insufficientPermissions(let url):
            return "Insufficient permissions for: \(url.path)"
        case .diskSpaceInsufficient:
            return "Insufficient disk space for operation"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknownError(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .invalidClipIndex:
            return "Check that the clip index is within the timeline bounds"
        case .clipNotFound:
            return "Verify the clip ID exists in the project"
        case .invalidTimeRange:
            return "Ensure start time is less than end time and both are positive"
        case .exportFailed:
            return "Check output directory permissions and available disk space"
        case .fileNotFound:
            return "Verify the file path is correct and the file exists"
        case .ffmpegNotFound:
            return "Install FFmpeg and ensure it's in your system PATH"
        case .timelineEmpty:
            return "Add at least one video clip to the timeline before exporting"
        case .insufficientPermissions:
            return "Check file permissions or choose a different output location"
        case .diskSpaceInsufficient:
            return "Free up disk space or choose a different output location"
        default:
            return nil
        }
    }
}

// MARK: - Logging

/// Centralized logging system for the video editor
public actor VideoEditorLogger {
    public static let shared = VideoEditorLogger()
    
    private var logger: Logger
    private var logHandlers: [LogHandler] = []
    private var logLevel: LogLevel = .info
    
    public init() {
        self.logger = Logger(label: "com.openvideoeditor.core")
    }
    
    /// Configures the logger with custom settings
    /// - Parameters:
    ///   - level: Minimum log level to output
    ///   - handlers: Additional log handlers
    public func configure(level: LogLevel, handlers: [LogHandler] = []) {
        self.logLevel = level
        self.logHandlers = handlers
    }
    
    /// Logs a debug message
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: Source file (auto-filled)
    ///   - function: Function name (auto-filled)
    ///   - line: Line number (auto-filled)
    public func debug(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    /// Logs an info message
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: Source file (auto-filled)
    ///   - function: Function name (auto-filled)
    ///   - line: Line number (auto-filled)
    public func info(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    /// Logs a warning message
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: Source file (auto-filled)
    ///   - function: Function name (auto-filled)
    ///   - line: Line number (auto-filled)
    public func warning(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    /// Logs an error message
    /// - Parameters:
    ///   - message: The message to log
    ///   - error: Optional error to include
    ///   - file: Source file (auto-filled)
    ///   - function: Function name (auto-filled)
    ///   - line: Line number (auto-filled)
    public func error(
        _ message: String,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        var fullMessage = message
        if let error = error {
            fullMessage += " - Error: \(error.localizedDescription)"
        }
        log(fullMessage, level: .error, file: file, function: function, line: line)
    }
    
    private func log(
        _ message: String,
        level: LogLevel,
        file: String,
        function: String,
        line: Int
    ) {
        guard level.rawValue >= logLevel.rawValue else { return }
        
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let filename = (file as NSString).lastPathComponent
        let logMessage = "[\(timestamp)] [\(level.rawValue)] [\(filename):\(line)] \(function): \(message)"
        
        // Print to console
        print(logMessage)
        
        // Send to custom handlers
        for handler in logHandlers {
            handler.handle(message: message, level: level, file: filename, function: function, line: line)
        }
        
        // Use swift-log
        switch level {
        case .debug:
            logger.debug("\(message)")
        case .info:
            logger.info("\(message)")
        case .warning:
            logger.warning("\(message)")
        case .error:
            logger.error("\(message)")
        }
    }
}

/// Log severity levels
public enum LogLevel: Int, CaseIterable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    
    public var rawValue: String {
        switch self {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARNING"
        case .error: return "ERROR"
        }
    }
}

/// Protocol for custom log handlers
public protocol LogHandler: Sendable {
    func handle(message: String, level: LogLevel, file: String, function: String, line: Int)
}

// MARK: - Video Processor Protocol

/// Protocol defining video processing capabilities
public protocol VideoProcessor: Sendable {
    /// Processes video project data and returns preview data
    /// - Parameters:
    ///   - videoProject: The project to process
    ///   - timeline: The timeline containing clips
    /// - Returns: Processed video data for preview
    /// - Throws: VideoEditorError if processing fails
    func process(videoProject: VideoProject, timeline: Timeline) async throws -> Data
    
    /// Exports the video project to a file
    /// - Parameters:
    ///   - videoProject: The project to export
    ///   - timeline: The timeline containing clips
    ///   - url: Destination URL for the exported file
    /// - Throws: VideoEditorError if export fails
    func export(videoProject: VideoProject, timeline: Timeline, to url: URL) async throws
    
    /// Generates a thumbnail for a specific time
    /// - Parameters:
    ///   - videoProject: The project
    ///   - timeline: The timeline
    ///   - time: Time position for the thumbnail
    ///   - size: Desired thumbnail size
    /// - Returns: Thumbnail image data
    /// - Throws: VideoEditorError if generation fails
    func generateThumbnail(
        videoProject: VideoProject,
        timeline: Timeline,
        at time: TimeInterval,
        size: CGSize
    ) async throws -> Data
    
    /// Extracts audio from the timeline
    /// - Parameters:
    ///   - timeline: The timeline containing audio clips
    ///   - url: Destination URL for the audio file
    /// - Throws: VideoEditorError if extraction fails
    func extractAudio(from timeline: Timeline, to url: URL) async throws
    
    /// Analyzes video metadata
    /// - Parameter fileURL: URL of the video file
    /// - Returns: Dictionary containing metadata
    /// - Throws: VideoEditorError if analysis fails
    func analyzeVideoMetadata(at fileURL: URL) async throws -> [String: Any]
}

// MARK: - FFmpeg Video Processor

/// FFmpeg-based video processor implementation
public actor FFmpegVideoProcessor: VideoProcessor {
    
    // MARK: - Properties
    
    private let ffmpegPath: String
    private let ffprobePath: String
    private let logger = VideoEditorLogger.shared
    private var activeProcesses: [Process] = []
    
    // MARK: - Initialization
    
    /// Creates a new FFmpeg video processor
    /// - Parameters:
    ///   - ffmpegPath: Path to FFmpeg executable (default: "ffmpeg")
    ///   - ffprobePath: Path to FFprobe executable (default: "ffprobe")
    /// - Throws: VideoEditorError.ffmpegNotFound if executables are not found
    public init(ffmpegPath: String = "ffmpeg", ffprobePath: String = "ffprobe") async throws {
        self.ffmpegPath = ffmpegPath
        self.ffprobePath = ffprobePath
        
        try await validateFFmpegInstallation()
        await logger.info("FFmpegVideoProcessor initialized")
    }
    
    // MARK: - VideoProcessor Implementation
    
    public func process(videoProject: VideoProject, timeline: Timeline) async throws -> Data {
        await logger.info("Starting video processing for project: \(videoProject.name)")
        
        guard !timeline.videoClips.isEmpty else {
            throw VideoEditorError.timelineEmpty
        }
        
        // For preview, we generate a low-resolution version
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("preview_\(UUID().uuidString).mp4")
        
        defer {
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        try await export(videoProject: videoProject, timeline: timeline, to: tempURL)
        
        let data = try Data(contentsOf: tempURL)
        await logger.info("Video processing completed. Generated \(data.count) bytes")
        
        return data
    }
    
    public func export(videoProject: VideoProject, timeline: Timeline, to url: URL) async throws {
        await logger.info("Starting export to: \(url.path)")
        
        guard !timeline.videoClips.isEmpty else {
            throw VideoEditorError.timelineEmpty
        }
        
        // Validate output directory
        let outputDir = url.deletingLastPathComponent()
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: outputDir.path, isDirectory: &isDirectory)
        
        guard exists && isDirectory.boolValue else {
            throw VideoEditorError.fileNotFound(outputDir)
        }
        
        // Check write permissions
        guard FileManager.default.isWritableFile(atPath: outputDir.path) else {
            throw VideoEditorError.insufficientPermissions(outputDir)
        }
        
        // Build FFmpeg command
        let command = try await buildExportCommand(
            videoProject: videoProject,
            timeline: timeline,
            outputURL: url
        )
        
        try await executeFFmpegCommand(command)
        
        await logger.info("Export completed successfully to: \(url.path)")
    }
    
    public func generateThumbnail(
        videoProject: VideoProject,
        timeline: Timeline,
        at time: TimeInterval,
        size: CGSize
    ) async throws -> Data {
        await logger.info("Generating thumbnail at time: \(time), size: \(size.width)x\(size.height)")
        
        guard let clip = timeline.getVideoClip(at: time) else {
            throw VideoEditorError.processingFailed("No clip found at time \(time)")
        }
        
        let videoURL = URL(fileURLWithPath: clip.filePath)
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("thumb_\(UUID().uuidString).jpg")
        
        defer {
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        let arguments = [
            "-ss", String(format: "%.3f", time - clip.startTime),
            "-i", videoURL.path,
            "-vframes", "1",
            "-s", "\(Int(size.width))x\(Int(size.height))",
            "-q:v", "2",
            tempURL.path
        ]
        
        try await executeFFmpegCommand(arguments)
        
        let data = try Data(contentsOf: tempURL)
        await logger.info("Thumbnail generated: \(data.count) bytes")
        
        return data
    }
    
    public func extractAudio(from timeline: Timeline, to url: URL) async throws {
        await logger.info("Extracting audio to: \(url.path)")
        
        guard !timeline.audioClips.isEmpty else {
            throw VideoEditorError.processingFailed("No audio clips in timeline")
        }
        
        // Build audio extraction command
        var inputs: [String] = []
        var filterComplex = ""
        
        for (index, clip) in timeline.audioClips.enumerated() {
            inputs.append(contentsOf: ["-i", clip.filePath])
            let volume = clip.isEnabled ? clip.volume : 0.0
            filterComplex += "[\(index):a]volume=\(volume)[a\(index)];"
        }
        
        // Mix all audio tracks
        let mixInputs = (0..<timeline.audioClips.count).map { "[a\($0)]" }.joined()
        filterComplex += "\(mixInputs)amix=inputs=\(timeline.audioClips.count):duration=longest[aout]"
        
        var arguments = inputs
        arguments.append(contentsOf: [
            "-filter_complex", filterComplex,
            "-map", "[aout]",
            "-c:a", "aac",
            "-b:a", "192k",
            url.path
        ])
        
        try await executeFFmpegCommand(arguments)
        
        await logger.info("Audio extraction completed")
    }
    
    public func analyzeVideoMetadata(at fileURL: URL) async throws -> [String: Any] {
        await logger.info("Analyzing video metadata: \(fileURL.path)")
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw VideoEditorError.fileNotFound(fileURL)
        }
        
        let arguments = [
            "-v", "quiet",
            "-print_format", "json",
            "-show_format",
            "-show_streams",
            fileURL.path
        ]
        
        let output = try await executeFFprobeCommand(arguments)
        
        // Parse JSON output
        guard let data = output.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw VideoEditorError.processingFailed("Failed to parse FFprobe output")
        }
        
        await logger.info("Metadata analysis completed")
        
        return json
    }
    
    // MARK: - Private Methods
    
    private func validateFFmpegInstallation() async throws {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        task.arguments = [ffmpegPath]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        try task.run()
        task.waitUntilExit()
        
        guard task.terminationStatus == 0 else {
            throw VideoEditorError.ffmpegNotFound
        }
        
        // Also verify ffprobe
        let probeTask = Process()
        probeTask.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        probeTask.arguments = [ffprobePath]
        
        let probePipe = Pipe()
        probeTask.standardOutput = probePipe
        
        try probeTask.run()
        probeTask.waitUntilExit()
        
        guard probeTask.terminationStatus == 0 else {
            throw VideoEditorError.ffmpegNotFound
        }
    }
    
    private func buildExportCommand(
        videoProject: VideoProject,
        timeline: Timeline,
        outputURL: URL
    ) async throws -> [String] {
        var arguments: [String] = []
        
        // Add inputs for video clips
        var filterComplex = ""
        var inputIndex = 0
        
        for clip in timeline.videoClips where clip.isEnabled {
            arguments.append(contentsOf: ["-i", clip.filePath])
            
            // Apply trim filter
            let trimFilter = "[\(inputIndex):v]trim=start=\(clip.startTime):end=\(clip.endTime),setpts=PTS-STARTPTS[v\(inputIndex)]"
            filterComplex += trimFilter + ";"
            
            inputIndex += 1
        }
        
        // Concatenate all video segments
        if inputIndex > 0 {
            let concatInputs = (0..<inputIndex).map { "[v\($0)]" }.joined()
            filterComplex += "\(concatInputs)concat=n=\(inputIndex):v=1:a=0[outv]"
            
            arguments.append(contentsOf: [
                "-filter_complex", filterComplex,
                "-map", "[outv]"
            ])
        }
        
        // Add video codec settings based on export settings
        let settings = videoProject.exportSettings
        arguments.append(contentsOf: [
            "-c:v", codecString(for: settings.codec),
            "-b:v", "\(settings.videoBitrate)",
            "-r", "\(videoProject.frameRate)",
            "-s", "\(Int(videoProject.resolution.width))x\(Int(videoProject.resolution.height))"
        ])
        
        // Add audio if enabled
        if settings.includeAudio && !timeline.audioClips.isEmpty {
            // Add audio inputs and mixing
            var audioInputs: [String] = []
            for clip in timeline.audioClips where clip.isEnabled {
                arguments.append(contentsOf: ["-i", clip.filePath])
                let volume = clip.volume
                audioInputs.append("[\(inputIndex):a]volume=\(volume),atrim=start=\(clip.startTime):end=\(clip.endTime)[a\(inputIndex)]")
                inputIndex += 1
            }
            
            // Rebuild filter complex with audio
            // This is simplified - full implementation would merge video and audio properly
        }
        
        // Add quality settings
        switch settings.quality {
        case .low:
            arguments.append(contentsOf: ["-crf", "28"])
        case .medium:
            arguments.append(contentsOf: ["-crf", "23"])
        case .high:
            arguments.append(contentsOf: ["-crf", "18"])
        case .ultra:
            arguments.append(contentsOf: ["-crf", "10"])
        case .lossless:
            arguments.append(contentsOf: ["-lossless", "1"])
        }
        
        // Add format
        arguments.append(contentsOf: ["-f", formatString(for: settings.format)])
        
        // Output file
        arguments.append(outputURL.path)
        
        return arguments
    }
    
    private func codecString(for codec: VideoCodec) -> String {
        switch codec {
        case .h264:
            return "libx264"
        case .h265:
            return "libx265"
        case .prores:
            return "prores_ks"
        case .vp9:
            return "libvpx-vp9"
        case .av1:
            return "libaom-av1"
        }
    }
    
    private func formatString(for format: ExportFormat) -> String {
        switch format {
        case .mp4:
            return "mp4"
        case .mov:
            return "mov"
        case .avi:
            return "avi"
        case .mkv:
            return "matroska"
        case .webm:
            return "webm"
        }
    }
    
    private func executeFFmpegCommand(_ arguments: [String]) async throws {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: ffmpegPath)
        task.arguments = arguments
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        await logger.debug("Executing FFmpeg: \(ffmpegPath) \(arguments.joined(separator: " "))")
        
        try task.run()
        
        // Store active process for potential cancellation
        await addActiveProcess(task)
        
        task.waitUntilExit()
        
        await removeActiveProcess(task)
        
        guard task.terminationStatus == 0 else {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown FFmpeg error"
            throw VideoEditorError.processingFailed("FFmpeg error: \(errorMessage)")
        }
    }
    
    private func executeFFprobeCommand(_ arguments: [String]) async throws -> String {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: ffprobePath)
        task.arguments = arguments
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        await logger.debug("Executing FFprobe: \(ffprobePath) \(arguments.joined(separator: " "))")
        
        try task.run()
        task.waitUntilExit()
        
        guard task.terminationStatus == 0 else {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown FFprobe error"
            throw VideoEditorError.processingFailed("FFprobe error: \(errorMessage)")
        }
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: outputData, encoding: .utf8) else {
            throw VideoEditorError.processingFailed("Failed to decode FFprobe output")
        }
        
        return output
    }
    
    private func addActiveProcess(_ process: Process) async {
        activeProcesses.append(process)
    }
    
    private func removeActiveProcess(_ process: Process) async {
        activeProcesses.removeAll { $0 === process }
    }
}

// MARK: - Video File Manager

/// Protocol for managing video files and projects
public protocol VideoFileManager: Sendable {
    /// Loads video files from a directory
    /// - Parameter directory: Directory URL to scan
    /// - Returns: Array of video file URLs
    /// - Throws: VideoEditorError if loading fails
    func loadVideoFiles(from directory: URL) async throws -> [URL]
    
    /// Saves a project to disk
    /// - Parameters:
    ///   - project: Project to save
    ///   - url: Destination URL
    /// - Throws: VideoEditorError if saving fails
    func saveProject(_ project: VideoProject, to url: URL) async throws
    
    /// Loads a project from disk
    /// - Parameter url: Project file URL
    /// - Returns: Loaded project
    /// - Throws: VideoEditorError if loading fails
    func loadProject(from url: URL) async throws -> VideoProject
    
    /// Copies a file to the project's assets directory
    /// - Parameters:
    ///   - sourceURL: Source file URL
    ///   - projectURL: Project directory URL
    /// - Returns: URL of the copied file
    /// - Throws: VideoEditorError if copying fails
    func importAsset(from sourceURL: URL, toProject projectURL: URL) async throws -> URL
    
    /// Creates a new project directory structure
    /// - Parameters:
    ///   - name: Project name
    ///   - baseDirectory: Base directory for the project
    /// - Returns: URL of the created project directory
    /// - Throws: VideoEditorError if creation fails
    func createProjectDirectory(name: String, in baseDirectory: URL) async throws -> URL
    
    /// Validates a video file
    /// - Parameter url: Video file URL
    /// - Returns: True if valid, false otherwise
    func validateVideoFile(at url: URL) async -> Bool
}

/// Default implementation of VideoFileManager
public actor DefaultVideoFileManager: VideoFileManager {
    
    // MARK: - Properties
    
    private let logger = VideoEditorLogger.shared
    private let supportedVideoExtensions = ["mp4", "mov", "avi", "mkv", "webm", "m4v", "mts", "m2ts"]
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    
    // MARK: - Initialization
    
    public init() {
        self.jsonEncoder = JSONEncoder()
        self.jsonEncoder.outputFormatting = .prettyPrinted
        self.jsonEncoder.dateEncodingStrategy = .iso8601
        
        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - VideoFileManager Implementation
    
    public func loadVideoFiles(from directory: URL) async throws -> [URL] {
        await logger.info("Loading video files from: \(directory.path)")
        
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: directory.path) else {
            throw VideoEditorError.fileNotFound(directory)
        }
        
        let contents = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        
        let videoFiles = contents.filter { url in
            let ext = url.pathExtension.lowercased()
            return supportedVideoExtensions.contains(ext)
        }
        
        await logger.info("Found \(videoFiles.count) video files")
        
        return videoFiles
    }
    
    public func saveProject(_ project: VideoProject, to url: URL) async throws {
        await logger.info("Saving project to: \(url.path)")
        
        let data = try jsonEncoder.encode(project)
        
        // Create directory if needed
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        try data.write(to: url, options: .atomic)
        
        await logger.info("Project saved successfully")
    }
    
    public func loadProject(from url: URL) async throws -> VideoProject {
        await logger.info("Loading project from: \(url.path)")
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw VideoEditorError.fileNotFound(url)
        }
        
        let data = try Data(contentsOf: url)
        let project = try jsonDecoder.decode(VideoProject.self, from: data)
        
        await logger.info("Project loaded successfully: \(project.name)")
        
        return project
    }
    
    public func importAsset(from sourceURL: URL, toProject projectURL: URL) async throws -> URL {
        await logger.info("Importing asset: \(sourceURL.path) to project: \(projectURL.path)")
        
        // Create assets directory
        let assetsDir = projectURL.appendingPathComponent("Assets", isDirectory: true)
        try FileManager.default.createDirectory(
            at: assetsDir,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        // Generate unique filename
        let filename = sourceURL.lastPathComponent
        let destinationURL = assetsDir.appendingPathComponent(filename)
        
        // Handle duplicates
        var finalDestination = destinationURL
        var counter = 1
        while FileManager.default.fileExists(atPath: finalDestination.path) {
            let baseName = (filename as NSString).deletingPathExtension
            let ext = sourceURL.pathExtension
            let newName = "\(baseName)_\(counter).\(ext)"
            finalDestination = assetsDir.appendingPathComponent(newName)
            counter += 1
        }
        
        try FileManager.default.copyItem(at: sourceURL, to: finalDestination)
        
        await logger.info("Asset imported to: \(finalDestination.path)")
        
        return finalDestination
    }
    
    public func createProjectDirectory(name: String, in baseDirectory: URL) async throws -> URL {
        await logger.info("Creating project directory for: \(name)")
        
        // Sanitize project name for filesystem
        let sanitizedName = name.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
        
        let projectDir = baseDirectory.appendingPathComponent("\(sanitizedName).ove", isDirectory: true)
        
        // Handle existing directory
        var finalDir = projectDir
        var counter = 1
        while FileManager.default.fileExists(atPath: finalDir.path) {
            finalDir = baseDirectory.appendingPathComponent("\(sanitizedName)_\(counter).ove", isDirectory: true)
            counter += 1
        }
        
        try FileManager.default.createDirectory(
            at: finalDir,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        // Create subdirectories
        let subdirs = ["Assets", "Exports", "Cache"]
        for subdir in subdirs {
            let subdirURL = finalDir.appendingPathComponent(subdir, isDirectory: true)
            try FileManager.default.createDirectory(
                at: subdirURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        
        await logger.info("Project directory created at: \(finalDir.path)")
        
        return finalDir
    }
    
    public func validateVideoFile(at url: URL) async -> Bool {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return false
        }
        
        let ext = url.pathExtension.lowercased()
        return supportedVideoExtensions.contains(ext)
    }
}

// MARK: - Video Editor

/// Main video editor class providing high-level editing operations
public actor VideoEditor {
    
    // MARK: - Properties
    
    /// The current video project
    public private(set) var project: VideoProject
    
    /// The video processor for rendering operations
    private let videoProcessor: any VideoProcessor
    
    /// File manager for project operations
    private let fileManager: any VideoFileManager
    
    /// Logger instance
    private let logger = VideoEditorLogger.shared
    
    /// Undo manager for tracking changes (basic implementation)
    private var undoStack: [VideoProject] = []
    private let maxUndoStackSize = 50
    
    // MARK: - Initialization
    
    /// Creates a new video editor instance
    /// - Parameters:
    ///   - project: The video project to edit
    ///   - videoProcessor: Video processor implementation (default: FFmpegVideoProcessor)
    ///   - fileManager: File manager implementation (default: DefaultVideoFileManager)
    public init(
        project: VideoProject,
        videoProcessor: (any VideoProcessor)? = nil,
        fileManager: (any VideoFileManager)? = nil
    ) async throws {
        self.project = project
        self.videoProcessor = videoProcessor ?? try await FFmpegVideoProcessor()
        self.fileManager = fileManager ?? DefaultVideoFileManager()
        
        await logger.info("VideoEditor initialized for project: \(project.name)")
    }
    
    // MARK: - Timeline Operations
    
    /// Adds a video clip to the timeline
    /// - Parameter clip: The video clip to add
    public func addVideoClip(_ clip: VideoClip) async {
        await saveUndoState()
        project.timeline.addVideoClip(clip)
        project.modifiedAt = Date()
        await logger.info("Added video clip: \(clip.id)")
    }
    
    /// Removes a video clip from the timeline
    /// - Parameter index: Index of the clip to remove
    /// - Throws: VideoEditorError if index is invalid
    public func removeVideoClip(at index: Int) async throws {
        guard index >= 0 && index < project.timeline.videoClips.count else {
            throw VideoEditorError.invalidClipIndex(index)
        }
        
        await saveUndoState()
        project.timeline.removeVideoClip(at: index)
        project.modifiedAt = Date()
        await logger.info("Removed video clip at index: \(index)")
    }
    
    /// Reorders a video clip in the timeline
    /// - Parameters:
    ///   - fromIndex: Source index
    ///   - toIndex: Destination index
    /// - Throws: VideoEditorError if indices are invalid
    public func reorderVideoClip(from fromIndex: Int, to toIndex: Int) async throws {
        guard fromIndex >= 0 && fromIndex < project.timeline.videoClips.count else {
            throw VideoEditorError.invalidClipIndex(fromIndex)
        }
        
        guard toIndex >= 0 && toIndex < project.timeline.videoClips.count else {
            throw VideoEditorError.invalidClipIndex(toIndex)
        }
        
        await saveUndoState()
        project.timeline.reorderVideoClip(from: fromIndex, to: toIndex)
        project.modifiedAt = Date()
        await logger.info("Reordered video clip from \(fromIndex) to \(toIndex)")
    }
    
    /// Trims a video clip
    /// - Parameters:
    ///   - index: Clip index
    ///   - startTime: New start time
    ///   - endTime: New end time
    /// - Throws: VideoEditorError if operation fails
    public func trimVideoClip(at index: Int, start: TimeInterval, end: TimeInterval) async throws {
        guard index >= 0 && index < project.timeline.videoClips.count else {
            throw VideoEditorError.invalidClipIndex(index)
        }
        
        guard start >= 0 && end > start else {
            throw VideoEditorError.invalidTimeRange(start: start, end: end)
        }
        
        await saveUndoState()
        
        var clip = project.timeline.videoClips[index]
        guard clip.trim(start: start, end: end) else {
            throw VideoEditorError.invalidTimeRange(start: start, end: end)
        }
        
        project.timeline.videoClips[index] = clip
        project.modifiedAt = Date()
        
        await logger.info("Trimmed video clip at index \(index) to \(start)-\(end)")
    }
    
    /// Splits a video clip at a specific time
    /// - Parameters:
    ///   - index: Clip index
    ///   - time: Time to split at
    /// - Throws: VideoEditorError if operation fails
    public func splitVideoClip(at index: Int, time: TimeInterval) async throws {
        guard index >= 0 && index < project.timeline.videoClips.count else {
            throw VideoEditorError.invalidClipIndex(index)
        }
        
        let clip = project.timeline.videoClips[index]
        let (first, second) = clip.split(at: time)
        
        guard let firstClip = first, let secondClip = second else {
            throw VideoEditorError.invalidTimeRange(start: time, end: time)
        }
        
        await saveUndoState()
        
        project.timeline.videoClips[index] = firstClip
        project.timeline.videoClips.insert(secondClip, at: index + 1)
        project.modifiedAt = Date()
        
        await logger.info("Split video clip at index \(index) at time \(time)")
    }
    
    /// Adds an audio clip to the timeline
    /// - Parameter clip: The audio clip to add
    public func addAudioClip(_ clip: AudioClip) async {
        await saveUndoState()
        project.timeline.addAudioClip(clip)
        project.modifiedAt = Date()
        await logger.info("Added audio clip: \(clip.id)")
    }
    
    /// Removes an audio clip from the timeline
    /// - Parameter index: Index of the clip to remove
    /// - Throws: VideoEditorError if index is invalid
    public func removeAudioClip(at index: Int) async throws {
        guard index >= 0 && index < project.timeline.audioClips.count else {
            throw VideoEditorError.invalidClipIndex(index)
        }
        
        await saveUndoState()
        project.timeline.removeAudioClip(at: index)
        project.modifiedAt = Date()
        await logger.info("Removed audio clip at index: \(index)")
    }
    
    // MARK: - Effects and Transitions
    
    /// Applies an effect to a video clip
    /// - Parameters:
    ///   - effect: The effect to apply
    ///   - clipIndex: Index of the target clip
    /// - Throws: VideoEditorError if index is invalid
    public func applyEffect(_ effect: Effect, toVideoClipAt clipIndex: Int) async throws {
        guard clipIndex >= 0 && clipIndex < project.timeline.videoClips.count else {
            throw VideoEditorError.invalidClipIndex(clipIndex)
        }
        
        await saveUndoState()
        
        var clip = project.timeline.videoClips[clipIndex]
        clip.effects.append(effect)
        project.timeline.videoClips[clipIndex] = clip
        project.modifiedAt = Date()
        
        await logger.info("Applied effect \(effect.name) to clip at index \(clipIndex)")
    }
    
    /// Removes an effect from a video clip
    /// - Parameters:
    ///   - effectId: ID of the effect to remove
    ///   - clipIndex: Index of the target clip
    /// - Throws: VideoEditorError if not found
    public func removeEffect(_ effectId: UUID, fromVideoClipAt clipIndex: Int) async throws {
        guard clipIndex >= 0 && clipIndex < project.timeline.videoClips.count else {
            throw VideoEditorError.invalidClipIndex(clipIndex)
        }
        
        await saveUndoState()
        
        var clip = project.timeline.videoClips[clipIndex]
        guard let index = clip.effects.firstIndex(where: { $0.id == effectId }) else {
            throw VideoEditorError.clipNotFound(effectId)
        }
        
        clip.effects.remove(at: index)
        project.timeline.videoClips[clipIndex] = clip
        project.modifiedAt = Date()
        
        await logger.info("Removed effect \(effectId) from clip at index \(clipIndex)")
    }
    
    /// Adds a transition between clips
    /// - Parameters:
    ///   - transition: The transition to add
    ///   - clipIndex: Index of the clip to apply transition to (at the end)
    /// - Throws: VideoEditorError if index is invalid
    public func addTransition(_ transition: Transition, afterVideoClipAt clipIndex: Int) async throws {
        guard clipIndex >= 0 && clipIndex < project.timeline.videoClips.count else {
            throw VideoEditorError.invalidClipIndex(clipIndex)
        }
        
        await saveUndoState()
        
        var clip = project.timeline.videoClips[clipIndex]
        clip.transitions.append(transition)
        project.timeline.videoClips[clipIndex] = clip
        project.modifiedAt = Date()
        
        await logger.info("Added transition \(transition.name) after clip at index \(clipIndex)")
    }
    
    // MARK: - Export and Preview
    
    /// Exports the project to a file
    /// - Parameter url: Destination URL
    /// - Throws: VideoEditorError if export fails
    public func export(to url: URL) async throws {
        await logger.info("Starting export to: \(url.path)")
        
        do {
            try await videoProcessor.export(videoProject: project, timeline: project.timeline, to: url)
            await logger.info("Export completed successfully")
        } catch {
            await logger.error("Export failed", error: error)
            throw VideoEditorError.exportFailed(url, error)
        }
    }
    
    /// Generates a preview of the project
    /// - Returns: Preview data
    /// - Throws: VideoEditorError if preview generation fails
    public func preview() async throws -> Data {
        await logger.info("Generating preview")
        
        do {
            let data = try await videoProcessor.process(videoProject: project, timeline: project.timeline)
            await logger.info("Preview generated: \(data.count) bytes")
            return data
        } catch {
            await logger.error("Preview generation failed", error: error)
            throw error
        }
    }
    
    /// Generates a thumbnail for a specific time
    /// - Parameters:
    ///   - time: Time position
    ///   - size: Thumbnail size
    /// - Returns: Thumbnail image data
    /// - Throws: VideoEditorError if generation fails
    public func generateThumbnail(at time: TimeInterval, size: CGSize) async throws -> Data {
        await logger.info("Generating thumbnail at \(time)")
        
        do {
            let data = try await videoProcessor.generateThumbnail(
                videoProject: project,
                timeline: project.timeline,
                at: time,
                size: size
            )
            return data
        } catch {
            await logger.error("Thumbnail generation failed", error: error)
            throw error
        }
    }
    
    // MARK: - Project Management
    
    /// Saves the project to a file
    /// - Parameter url: Destination URL
    /// - Throws: VideoEditorError if saving fails
    public func saveProject(to url: URL) async throws {
        try await fileManager.saveProject(project, to: url)
    }
    
    /// Updates export settings
    /// - Parameter settings: New export settings
    public func updateExportSettings(_ settings: ExportSettings) async {
        await saveUndoState()
        project.exportSettings = settings
        project.modifiedAt = Date()
        await logger.info("Updated export settings")
    }
    
    /// Updates project metadata
    /// - Parameters:
    ///   - name: New project name
    ///   - resolution: New resolution
    ///   - frameRate: New frame rate
    public func updateProjectMetadata(name: String? = nil, resolution: CGSize? = nil, frameRate: Double? = nil) async {
        await saveUndoState()
        
        if let name = name {
            project.name = name
        }
        if let resolution = resolution {
            project.resolution = resolution
        }
        if let frameRate = frameRate {
            project.frameRate = frameRate
        }
        
        project.modifiedAt = Date()
        await logger.info("Updated project metadata")
    }
    
    // MARK: - Undo/Redo
    
    /// Saves the current state for undo functionality
    private func saveUndoState() async {
        // Create a copy of the project for undo
        if undoStack.count >= maxUndoStackSize {
            undoStack.removeFirst()
        }
        
        // We need to encode/decode to create a true copy
        do {
            let data = try JSONEncoder().encode(project)
            if let copy = try? JSONDecoder().decode(VideoProject.self, from: data) {
                undoStack.append(copy)
            }
        } catch {
            await logger.error("Failed to save undo state", error: error)
        }
    }
    
    /// Undoes the last operation
    /// - Returns: True if undo was successful
    public func undo() async -> Bool {
        guard !undoStack.isEmpty else {
            return false
        }
        
        project = undoStack.removeLast()
        await logger.info("Undo performed")
        return true
    }
    
    /// Clears the undo history
    public func clearUndoHistory() async {
        undoStack.removeAll()
        await logger.info("Undo history cleared")
    }
    
    // MARK: - Utilities
    
    /// Gets the clip at a specific time
    /// - Parameter time: Time position
    /// - Returns: The clip at that time, if any
    public func getClip(at time: TimeInterval) -> VideoClip? {
        return project.timeline.getVideoClip(at: time)
    }
    
    /// Gets all clips that overlap a time range
    /// - Parameters:
    ///   - start: Start time
    ///   - end: End time
    /// - Returns: Array of overlapping clips
    public func getClipsInRange(start: TimeInterval, end: TimeInterval) -> [VideoClip] {
        return project.timeline.videoClips.filter { clip in
            clip.isEnabled && clip.startTime < end && clip.endTime > start
        }
    }
    
    /// Returns the total project duration
    public func getTotalDuration() -> TimeInterval {
        return project.timeline.totalDuration
    }
}

// MARK: - Extensions

extension TimeInterval {
    /// Creates a TimeInterval from seconds
    public static func seconds(_ value: Double) -> TimeInterval {
        return value
    }
    
    /// Creates a TimeInterval from minutes
    public static func minutes(_ value: Double) -> TimeInterval {
        return value * 60
    }
    
    /// Creates a TimeInterval from hours
    public static func hours(_ value: Double) -> TimeInterval {
        return value * 3600
    }
    
    /// Formats the time interval as a timecode string (HH:MM:SS.ms)
    public var timecodeString: String {
        let totalSeconds = Int(self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        let milliseconds = Int((self - Double(totalSeconds)) * 1000)
        
        return String(format: "%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
    }
}
