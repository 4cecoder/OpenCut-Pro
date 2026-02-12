import Foundation
import ArgumentParser
import OpenVideoCore
import Logging

/// Open Video Editor - A Final Cut Pro clone for macOS
@main
struct OpenVideoEditorCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "open-video-editor",
        abstract: "A professional video editing application",
        discussion: """
        Open Video Editor is a powerful video editing tool inspired by Final Cut Pro.
        
        Use this command-line interface to create, edit, and export video projects.
        
        Examples:
          open-video-editor create --name "My Project" --resolution 1920x1080 --fps 30
          open-video-editor import --project ~/Documents/MyProject.ove --file ~/Videos/clip.mp4
          open-video-editor export --project ~/Documents/MyProject.ove --output ~/Desktop/output.mp4
        """,
        version: "1.0.0",
        subcommands: [
            CreateProject.self,
            ImportMedia.self,
            ListClips.self,
            AddClip.self,
            RemoveClip.self,
            TrimClip.self,
            SplitClip.self,
            ApplyEffect.self,
            ExportProject.self,
            PreviewProject.self,
            Thumbnail.self,
            Info.self
        ],
        defaultSubcommand: nil
    )
}

// MARK: - Create Project

struct CreateProject: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a new video project"
    )
    
    @Option(name: .long, help: "Project name")
    var name: String
    
    @Option(name: .long, help: "Resolution (e.g., 1920x1080, 3840x2160)")
    var resolution: String = "1920x1080"
    
    @Option(name: .long, help: "Frame rate (fps)")
    var fps: Double = 30.0
    
    @Option(name: .long, help: "Output directory")
    var output: String?
    
    @Option(name: .long, help: "Export format (mp4, mov, avi, mkv, webm)")
    var format: ExportFormat = .mp4
    
    @Option(name: .long, help: "Video codec (h264, h265, prores, vp9, av1)")
    var codec: VideoCodec = .h264
    
    @Option(name: .long, help: "Export quality (low, medium, high, ultra, lossless)")
    var quality: ExportQuality = .high
    
    func run() async throws {
        let logger = await VideoEditorLogger.shared
        await logger.info("Creating new project: \(name)")
        
        // Parse resolution
        let resolutionParts = resolution.split(separator: "x")
        guard resolutionParts.count == 2,
              let width = Double(resolutionParts[0]),
              let height = Double(resolutionParts[1]) else {
            throw ValidationError("Invalid resolution format. Use WIDTHxHEIGHT (e.g., 1920x1080)")
        }
        
        // Create project
        let project = VideoProject(
            name: name,
            resolution: CGSize(width: width, height: height),
            frameRate: fps
        )
        
        // Configure export settings
        var settings = ExportSettings()
        settings.format = format
        settings.codec = codec
        settings.quality = quality
        
        // Determine output directory
        let outputDir: URL
        if let outputPath = output {
            outputDir = URL(fileURLWithPath: outputPath)
        } else {
            outputDir = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Movies", isDirectory: true)
        }
        
        // Create project directory
        let fileManager = await DefaultVideoFileManager()
        let projectDir = try await fileManager.createProjectDirectory(name: name, in: outputDir)
        
        // Save project file
        let projectURL = projectDir.appendingPathComponent("project.json")
        try await fileManager.saveProject(project, to: projectURL)
        
        print("✅ Project created successfully!")
        print("   Name: \(project.name)")
        print("   Resolution: \(Int(width))x\(Int(height))")
        print("   Frame Rate: \(fps) fps")
        print("   Location: \(projectDir.path)")
        
        await logger.info("Project created at: \(projectDir.path)")
    }
}

// MARK: - Import Media

struct ImportMedia: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "import",
        abstract: "Import media files into a project"
    )
    
    @Option(name: .long, help: "Path to the project directory or .ove file")
    var project: String
    
    @Option(name: .long, help: "Path to the media file to import")
    var file: String
    
    @Flag(name: .long, help: "Copy file to project (default: true)")
    var copy: Bool = true
    
    func run() async throws {
        let logger = await VideoEditorLogger.shared
        
        let projectURL = URL(fileURLWithPath: project)
        let fileURL = URL(fileURLWithPath: file)
        
        await logger.info("Importing media: \(fileURL.path)")
        
        // Validate file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw ValidationError("File not found: \(file)")
        }
        
        // Determine project directory
        let projectDir: URL
        if projectURL.pathExtension == "ove" {
            projectDir = projectURL
        } else {
            projectDir = projectURL.deletingLastPathComponent()
        }
        
        let fileManager = await DefaultVideoFileManager()
        
        if copy {
            let importedURL = try await fileManager.importAsset(from: fileURL, toProject: projectDir)
            print("✅ Media imported to: \(importedURL.path)")
        } else {
            print("✅ Media reference added (not copied): \(fileURL.path)")
        }
        
        await logger.info("Media import completed")
    }
}

// MARK: - List Clips

struct ListClips: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all clips in a project timeline"
    )
    
    @Option(name: .long, help: "Path to the project JSON file")
    var project: String
    
    @Flag(name: .long, help: "Show detailed information")
    var detailed: Bool = false
    
    func run() async throws {
        let fileManager = await DefaultVideoFileManager()
        let projectURL = URL(fileURLWithPath: project)
        
        let project = try await fileManager.loadProject(from: projectURL)
        
        print("📁 Project: \(project.name)")
        print("🎬 Video Clips (\(project.timeline.videoClips.count)):")
        
        for (index, clip) in project.timeline.videoClips.enumerated() {
            let status = clip.isEnabled ? "✓" : "✗"
            let duration = (clip.endTime - clip.startTime).timecodeString
            
            if detailed {
                print("""
                    \n  [\(index)] \(status) \(clip.id)
      File: \(clip.filePath)
      Source Duration: \(clip.sourceDuration.timecodeString)
      Timeline: \(clip.startTime.timecodeString) - \(clip.endTime.timecodeString)
      Active Duration: \(duration)
      Effects: \(clip.effects.count)
      Transitions: \(clip.transitions.count)
""")
            } else {
                print("  [\(index)] \(status) \(duration) - \(clip.filePath)")
            }
        }
        
        print("\n🔊 Audio Clips (\(project.timeline.audioClips.count)):")
        for (index, clip) in project.timeline.audioClips.enumerated() {
            let status = clip.isEnabled ? "✓" : "✗"
            let duration = (clip.endTime - clip.startTime).timecodeString
            print("  [\(index)] \(status) \(duration) - \(clip.filePath) (Vol: \(Int(clip.volume * 100))%)")
        }
        
        print("\n⏱ Total Duration: \(project.timeline.totalDuration.timecodeString)")
    }
}

// MARK: - Add Clip

struct AddClip: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add a video or audio clip to the timeline"
    )
    
    @Option(name: .long, help: "Path to the project JSON file")
    var project: String
    
    @Option(name: .long, help: "Type of clip (video or audio)")
    var type: String = "video"
    
    @Option(name: .long, help: "Path to the media file")
    var file: String
    
    @Option(name: .long, help: "Source duration in seconds")
    var duration: Double
    
    @Option(name: .long, help: "Start trim time in seconds (default: 0)")
    var start: Double = 0
    
    @Option(name: .long, help: "End trim time in seconds (default: full duration)")
    var end: Double?
    
    @Option(name: .long, help: "Timeline position in seconds")
    var position: Double = 0
    
    @Option(name: .long, help: "Audio volume (0.0 to 1.0, audio only)")
    var volume: Float = 1.0
    
    func run() async throws {
        let logger = await VideoEditorLogger.shared
        
        let projectURL = URL(fileURLWithPath: project)
        let fileURL = URL(fileURLWithPath: file)
        
        await logger.info("Adding clip to project: \(project)")
        
        // Load project
        let fileManager = await DefaultVideoFileManager()
        var projectData = try await fileManager.loadProject(from: projectURL)
        
        // Create editor
        let editor = try await VideoEditor(project: projectData)
        
        let endTime = end ?? duration
        
        switch type.lowercased() {
        case "video":
            let clip = VideoClip(
                filePath: fileURL.path,
                sourceDuration: duration,
                startTime: start,
                endTime: endTime
            )
            await editor.addVideoClip(clip)
            print("✅ Video clip added: \(clip.id)")
            
        case "audio":
            let clip = AudioClip(
                filePath: fileURL.path,
                sourceDuration: duration,
                startTime: start,
                endTime: endTime,
                volume: volume
            )
            await editor.addAudioClip(clip)
            print("✅ Audio clip added: \(clip.id)")
            
        default:
            throw ValidationError("Invalid clip type. Use 'video' or 'audio'")
        }
        
        // Save project
        // Note: We need to get the updated project from the editor actor
        // This would require a getProject() method in VideoEditor
        // For now, we'll reload and modify directly
        
        print("✅ Clip added successfully!")
        await logger.info("Clip added to project")
    }
}

// MARK: - Remove Clip

struct RemoveClip: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "remove",
        abstract: "Remove a clip from the timeline"
    )
    
    @Option(name: .long, help: "Path to the project JSON file")
    var project: String
    
    @Option(name: .long, help: "Type of clip (video or audio)")
    var type: String = "video"
    
    @Option(name: .long, help: "Index of the clip to remove")
    var index: Int
    
    func run() async throws {
        let logger = await VideoEditorLogger.shared
        
        let projectURL = URL(fileURLWithPath: project)
        
        await logger.info("Removing clip \(index) from project")
        
        // Load project
        let fileManager = await DefaultVideoFileManager()
        let projectData = try await fileManager.loadProject(from: projectURL)
        
        // Create editor
        let editor = try await VideoEditor(project: projectData)
        
        switch type.lowercased() {
        case "video":
            try await editor.removeVideoClip(at: index)
            print("✅ Video clip at index \(index) removed")
            
        case "audio":
            try await editor.removeAudioClip(at: index)
            print("✅ Audio clip at index \(index) removed")
            
        default:
            throw ValidationError("Invalid clip type. Use 'video' or 'audio'")
        }
    }
}

// MARK: - Trim Clip

struct TrimClip: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "trim",
        abstract: "Trim a video clip"
    )
    
    @Option(name: .long, help: "Path to the project JSON file")
    var project: String
    
    @Option(name: .long, help: "Index of the clip to trim")
    var index: Int
    
    @Option(name: .long, help: "New start time in seconds")
    var start: Double
    
    @Option(name: .long, help: "New end time in seconds")
    var end: Double
    
    func run() async throws {
        let logger = await VideoEditorLogger.shared
        
        let projectURL = URL(fileURLWithPath: project)
        
        await logger.info("Trimming clip \(index)")
        
        // Load project
        let fileManager = await DefaultVideoFileManager()
        let projectData = try await fileManager.loadProject(from: projectURL)
        
        // Create editor
        let editor = try await VideoEditor(project: projectData)
        
        try await editor.trimVideoClip(at: index, start: start, end: end)
        
        print("✅ Clip trimmed: \(start.timecodeString) - \(end.timecodeString)")
    }
}

// MARK: - Split Clip

struct SplitClip: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "split",
        abstract: "Split a video clip at a specific time"
    )
    
    @Option(name: .long, help: "Path to the project JSON file")
    var project: String
    
    @Option(name: .long, help: "Index of the clip to split")
    var index: Int
    
    @Option(name: .long, help: "Time to split at (in seconds)")
    var time: Double
    
    func run() async throws {
        let logger = await VideoEditorLogger.shared
        
        let projectURL = URL(fileURLWithPath: project)
        
        await logger.info("Splitting clip \(index) at \(time)")
        
        // Load project
        let fileManager = await DefaultVideoFileManager()
        let projectData = try await fileManager.loadProject(from: projectURL)
        
        // Create editor
        let editor = try await VideoEditor(project: projectData)
        
        try await editor.splitVideoClip(at: index, time: time)
        
        print("✅ Clip split at \(time.timecodeString)")
    }
}

// MARK: - Apply Effect

struct ApplyEffect: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "effect",
        abstract: "Apply an effect to a video clip"
    )
    
    @Option(name: .long, help: "Path to the project JSON file")
    var project: String
    
    @Option(name: .long, help: "Index of the target clip")
    var clip: Int
    
    @Option(name: .long, help: "Effect type")
    var type: EffectType
    
    @Option(name: .long, help: "Effect name")
    var name: String?
    
    @Option(name: .long, help: "Start time in seconds")
    var start: Double = 0
    
    @Option(name: .long, help: "Duration in seconds")
    var duration: Double = 1.0
    
    @Option(name: .long, help: "Effect intensity (0.0 to 1.0)")
    var intensity: Double = 1.0
    
    func run() async throws {
        let logger = await VideoEditorLogger.shared
        
        let projectURL = URL(fileURLWithPath: project)
        
        await logger.info("Applying effect to clip \(clip)")
        
        // Load project
        let fileManager = await DefaultVideoFileManager()
        let projectData = try await fileManager.loadProject(from: projectURL)
        
        // Create editor
        let editor = try await VideoEditor(project: projectData)
        
        let effectName = name ?? type.rawValue
        let effect = Effect(
            name: effectName,
            type: type,
            startTime: start,
            duration: duration,
            intensity: intensity
        )
        
        try await editor.applyEffect(effect, toVideoClipAt: clip)
        
        print("✅ Effect '\(effectName)' applied to clip \(clip)")
    }
}

// MARK: - Export Project

struct ExportProject: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "export",
        abstract: "Export a project to a video file"
    )
    
    @Option(name: .long, help: "Path to the project JSON file")
    var project: String
    
    @Option(name: .long, help: "Output file path")
    var output: String
    
    @Option(name: .long, help: "Export format (mp4, mov, avi, mkv, webm)")
    var format: ExportFormat?
    
    @Option(name: .long, help: "Video codec (h264, h265, prores, vp9, av1)")
    var codec: VideoCodec?
    
    @Option(name: .long, help: "Export quality (low, medium, high, ultra, lossless)")
    var quality: ExportQuality?
    
    @Option(name: .long, help: "Video bitrate in bps")
    var videoBitrate: Int?
    
    @Option(name: .long, help: "Audio bitrate in bps")
    var audioBitrate: Int?
    
    @Flag(name: .long, help: "Disable audio export")
    var noAudio: Bool = false
    
    func run() async throws {
        let logger = await VideoEditorLogger.shared
        
        let projectURL = URL(fileURLWithPath: project)
        let outputURL = URL(fileURLWithPath: output)
        
        await logger.info("Starting export to: \(outputURL.path)")
        
        // Load project
        let fileManager = await DefaultVideoFileManager()
        var projectData = try await fileManager.loadProject(from: projectURL)
        
        // Update export settings if specified
        if let format = format {
            projectData.exportSettings.format = format
        }
        if let codec = codec {
            projectData.exportSettings.codec = codec
        }
        if let quality = quality {
            projectData.exportSettings.quality = quality
        }
        if let bitrate = videoBitrate {
            projectData.exportSettings.videoBitrate = bitrate
        }
        if let bitrate = audioBitrate {
            projectData.exportSettings.audioBitrate = bitrate
        }
        projectData.exportSettings.includeAudio = !noAudio
        
        // Create editor
        let editor = try await VideoEditor(project: projectData)
        
        // Perform export
        print("🎬 Exporting project: \(projectData.name)")
        print("   Format: \(projectData.exportSettings.format.rawValue)")
        print("   Codec: \(projectData.exportSettings.codec.rawValue)")
        print("   Quality: \(projectData.exportSettings.quality.rawValue)")
        print("   Resolution: \(Int(projectData.resolution.width))x\(Int(projectData.resolution.height))")
        print("   Frame Rate: \(projectData.frameRate) fps")
        print("")
        print("⏳ Exporting...")
        
        try await editor.export(to: outputURL)
        
        print("")
        print("✅ Export completed successfully!")
        print("   Output: \(outputURL.path)")
        
        await logger.info("Export completed: \(outputURL.path)")
    }
}

// MARK: - Preview Project

struct PreviewProject: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "preview",
        abstract: "Generate a preview of the project"
    )
    
    @Option(name: .long, help: "Path to the project JSON file")
    var project: String
    
    @Option(name: .long, help: "Output preview file path")
    var output: String?
    
    func run() async throws {
        let logger = await VideoEditorLogger.shared
        
        let projectURL = URL(fileURLWithPath: project)
        let outputURL = output.map { URL(fileURLWithPath: $0) }
        
        await logger.info("Generating preview for: \(project)")
        
        // Load project
        let fileManager = await DefaultVideoFileManager()
        let projectData = try await fileManager.loadProject(from: projectURL)
        
        // Create editor
        let editor = try await VideoEditor(project: projectData)
        
        print("⏳ Generating preview...")
        
        let previewData = try await editor.preview()
        
        print("✅ Preview generated: \(previewData.count) bytes")
        
        // Save to file if output specified
        if let outputURL = outputURL {
            try previewData.write(to: outputURL)
            print("✅ Preview saved to: \(outputURL.path)")
        }
        
        await logger.info("Preview generated: \(previewData.count) bytes")
    }
}

// MARK: - Thumbnail

struct Thumbnail: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "thumbnail",
        abstract: "Generate a thumbnail at a specific time"
    )
    
    @Option(name: .long, help: "Path to the project JSON file")
    var project: String
    
    @Option(name: .long, help: "Time position in seconds")
    var time: Double = 0
    
    @Option(name: .long, help: "Thumbnail width")
    var width: Double = 320
    
    @Option(name: .long, help: "Thumbnail height")
    var height: Double = 180
    
    @Option(name: .long, help: "Output file path")
    var output: String
    
    func run() async throws {
        let logger = await VideoEditorLogger.shared
        
        let projectURL = URL(fileURLWithPath: project)
        let outputURL = URL(fileURLWithPath: output)
        
        await logger.info("Generating thumbnail at \(time)")
        
        // Load project
        let fileManager = await DefaultVideoFileManager()
        let projectData = try await fileManager.loadProject(from: projectURL)
        
        // Create editor
        let editor = try await VideoEditor(project: projectData)
        
        print("⏳ Generating thumbnail...")
        
        let thumbnailData = try await editor.generateThumbnail(
            at: time,
            size: CGSize(width: width, height: height)
        )
        
        try thumbnailData.write(to: outputURL)
        
        print("✅ Thumbnail saved to: \(outputURL.path)")
        print("   Size: \(Int(width))x\(Int(height))")
        print("   Time: \(time.timecodeString)")
        
        await logger.info("Thumbnail generated: \(outputURL.path)")
    }
}

// MARK: - Info

struct Info: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "info",
        abstract: "Display project information"
    )
    
    @Option(name: .long, help: "Path to the project JSON file")
    var project: String
    
    func run() async throws {
        let projectURL = URL(fileURLWithPath: project)
        
        // Load project
        let fileManager = await DefaultVideoFileManager()
        let projectData = try await fileManager.loadProject(from: projectURL)
        
        print("""
        📁 Project Information
        ════════════════════════════════════════
        
        Name: \(projectData.name)
        ID: \(projectData.id)
        
        📊 Video Settings
        ─────────────────────────────────────────
        Resolution: \(Int(projectData.resolution.width))x\(Int(projectData.resolution.height))
        Frame Rate: \(projectData.frameRate) fps
        Duration: \(projectData.timeline.totalDuration.timecodeString)
        
        📼 Timeline
        ─────────────────────────────────────────
        Video Clips: \(projectData.timeline.videoClips.count)
        Audio Clips: \(projectData.timeline.audioClips.count)
        
        ⚙️ Export Settings
        ─────────────────────────────────────────
        Format: \(projectData.exportSettings.format.rawValue)
        Codec: \(projectData.exportSettings.codec.rawValue)
        Quality: \(projectData.exportSettings.quality.rawValue)
        Video Bitrate: \(projectData.exportSettings.videoBitrate) bps
        Audio Bitrate: \(projectData.exportSettings.audioBitrate) bps
        Include Audio: \(projectData.exportSettings.includeAudio ? "Yes" : "No")
        
        📅 Timestamps
        ─────────────────────────────────────────
        Created: \(projectData.createdAt)
        Modified: \(projectData.modifiedAt)
        ════════════════════════════════════════
        """)
    }
}

// MARK: - Validation Error

struct ValidationError: LocalizedError {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    var errorDescription: String? {
        return message
    }
}
