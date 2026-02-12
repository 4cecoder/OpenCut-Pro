import Foundation
import ArgumentParser
import OpenVideoCore

/// Open Video Editor - A Final Cut Pro clone for macOS
@main
struct OpenVideoEditorCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "open-video-editor",
        abstract: "A professional video editing application",
        subcommands: [Create.self, Import.self, Export.self, Info.self]
    )
}

// MARK: - Create Subcommand

extension OpenVideoEditorCommand {
    struct Create: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "create",
            abstract: "Create a new video project"
        )
        
        @Option(name: .shortAndLong, help: "Project name")
        var name: String = "My Project"
        
        @Option(name: .shortAndLong, help: "Resolution (e.g., 1920x1080)")
        var resolution: String = "1920x1080"
        
        @Option(name: .shortAndLong, help: "Frame rate")
        var fps: Double = 30.0
        
        @Option(name: .shortAndLong, help: "Output file path")
        var output: String?
        
        func run() async throws {
            let res = parseResolution(resolution)
            let project = VideoProject(
                name: name,
                resolution: CGSize(width: res.width, height: res.height),
                frameRate: fps
            )
            
            let outputURL: URL
            if let outputPath = output {
                outputURL = URL(fileURLWithPath: outputPath)
            } else {
                outputURL = URL(fileURLWithPath: "./\(name).ove")
            }
            
            let fileManager = DefaultVideoFileManager()
            try await fileManager.saveProject(project, to: outputURL)
            
            print("✅ Created project: \(name)")
            print("   Resolution: \(Int(res.width))x\(Int(res.height))")
            print("   Frame Rate: \(fps) fps")
            print("   Saved to: \(outputURL.path)")
        }
        
        func parseResolution(_ resolution: String) -> (width: Double, height: Double) {
            let parts = resolution.split(separator: "x").compactMap { Double($0) }
            if parts.count == 2 {
                return (width: parts[0], height: parts[1])
            }
            return (width: 1920, height: 1080)
        }
    }
}

// MARK: - Import Subcommand

extension OpenVideoEditorCommand {
    struct Import: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "import",
            abstract: "Import media into a project"
        )
        
        @Option(name: .shortAndLong, help: "Project file path")
        var project: String
        
        @Option(name: .shortAndLong, help: "Media file to import")
        var file: String
        
        func run() async throws {
            let projectURL = URL(fileURLWithPath: project)
            let fileURL = URL(fileURLWithPath: file)
            
            let fileManager = DefaultVideoFileManager()
            var projectData = try await fileManager.loadProject(from: projectURL)
            
            // Create clip (simplified - in real app, we'd get duration from the file)
            let clip = VideoClip(
                filePath: fileURL.path,
                sourceDuration: 60.0 // Default duration
            )
            
            projectData.timeline.addVideoClip(clip)
            try await fileManager.saveProject(projectData, to: projectURL)
            
            print("✅ Imported: \(fileURL.lastPathComponent)")
            print("   Project: \(projectData.name)")
            print("   Clips: \(projectData.timeline.videoClips.count)")
        }
    }
}

// MARK: - Export Subcommand

extension OpenVideoEditorCommand {
    struct Export: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "export",
            abstract: "Export a video project"
        )
        
        @Option(name: .shortAndLong, help: "Project file path")
        var project: String
        
        @Option(name: .shortAndLong, help: "Output file path")
        var output: String
        
        func run() async throws {
            let projectURL = URL(fileURLWithPath: project)
            let outputURL = URL(fileURLWithPath: output)
            
            let fileManager = DefaultVideoFileManager()
            let projectData = try await fileManager.loadProject(from: projectURL)
            
            let editor = VideoEditor(project: projectData)
            try await editor.export(to: outputURL)
            
            print("✅ Exported successfully!")
            print("   Output: \(outputURL.path)")
        }
    }
}

// MARK: - Info Subcommand

extension OpenVideoEditorCommand {
    struct Info: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "info",
            abstract: "Display project information"
        )
        
        @Option(name: .shortAndLong, help: "Project file path")
        var project: String
        
        func run() async throws {
            let projectURL = URL(fileURLWithPath: project)
            
            let fileManager = DefaultVideoFileManager()
            let projectData = try await fileManager.loadProject(from: projectURL)
            
            print("📽️  Project: \(projectData.name)")
            print("   Resolution: \(Int(projectData.resolution.width))x\(Int(projectData.resolution.height))")
            print("   Frame Rate: \(projectData.frameRate) fps")
            print("   Duration: \(projectData.timeline.totalDuration)s")
            print("   Clips: \(projectData.timeline.videoClips.count)")
            print("   Created: \(projectData.createdAt)")
        }
    }
}
