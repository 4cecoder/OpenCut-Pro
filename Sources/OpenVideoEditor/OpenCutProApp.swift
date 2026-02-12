import SwiftUI
import OpenVideoCore

@main
struct OpenCutProApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .frame(minWidth: 1200, minHeight: 800)
        }
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Project") {
                    appState.showNewProjectSheet = true
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("Open Project...") {
                    appState.showOpenProjectDialog()
                }
                .keyboardShortcut("o", modifiers: .command)
                
                Button("Save Project") {
                    appState.saveProject()
                }
                .keyboardShortcut("s", modifiers: .command)
            }
            
            CommandMenu("Edit") {
                Button("Undo") {
                    appState.undo()
                }
                .keyboardShortcut("z", modifiers: .command)
                
                Button("Redo") {
                    appState.redo()
                }
                .keyboardShortcut("z", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Cut") {
                    appState.cut()
                }
                .keyboardShortcut("x", modifiers: .command)
                
                Button("Copy") {
                    appState.copy()
                }
                .keyboardShortcut("c", modifiers: .command)
                
                Button("Paste") {
                    appState.paste()
                }
                .keyboardShortcut("v", modifiers: .command)
                
                Button("Delete") {
                    appState.deleteSelection()
                }
                .keyboardShortcut(.delete, modifiers: .command)
            }
            
            CommandMenu("View") {
                Button("Toggle Browser") {
                    appState.showBrowser.toggle()
                }
                .keyboardShortcut("1", modifiers: .command)
                
                Button("Toggle Viewer") {
                    appState.showViewer.toggle()
                }
                .keyboardShortcut("2", modifiers: .command)
                
                Button("Toggle Timeline") {
                    appState.showTimeline.toggle()
                }
                .keyboardShortcut("3", modifiers: .command)
                
                Button("Toggle Inspector") {
                    appState.showInspector.toggle()
                }
                .keyboardShortcut("4", modifiers: .command)
                
                Divider()
                
                Button("Enter Full Screen") {
                    appState.toggleFullscreen()
                }
                .keyboardShortcut("f", modifiers: [.command, .control])
            }
            
            CommandMenu("Mark") {
                Button("Set Marker") {
                    appState.setMarker()
                }
                .keyboardShortcut("m", modifiers: .command)
                
                Button("Next Marker") {
                    appState.nextMarker()
                }
                .keyboardShortcut(.rightArrow, modifiers: .command)
                
                Button("Previous Marker") {
                    appState.previousMarker()
                }
                .keyboardShortcut(.leftArrow, modifiers: .command)
            }
            
            CommandMenu("Modify") {
                Button("Split Clip") {
                    appState.splitClip()
                }
                .keyboardShortcut("b", modifiers: .command)
                
                Button("Join Clips") {
                    appState.joinClips()
                }
                .keyboardShortcut("j", modifiers: .command)
                
                Divider()
                
                Button("Trim to Selection") {
                    appState.trimToSelection()
                }
                .keyboardShortcut("t", modifiers: .command)
                
                Button("Extend Edit") {
                    appState.extendEdit()
                }
                .keyboardShortcut("e", modifiers: .command)
            }
            
            CommandMenu("Share") {
                Button("Export File...") {
                    appState.showExportSheet = true
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
                
                Button("Export Settings...") {
                    appState.showExportSettings = true
                }
            }
        }
    }
}

// MARK: - App State

@MainActor
class AppState: ObservableObject {
    @Published var currentProject: VideoProject?
    @Published var currentTime: TimeInterval = 0
    @Published var isPlaying = false
    @Published var selectedClips: Set<UUID> = []
    @Published var zoomLevel: Double = 1.0
    @Published var showBrowser = true
    @Published var showViewer = true
    @Published var showTimeline = true
    @Published var showInspector = true
    @Published var showNewProjectSheet = false
    @Published var showExportSheet = false
    @Published var showExportSettings = false
    @Published var exportProgress: Double = 0
    @Published var isExporting = false
    
    var editor: VideoEditor?
    
    func createNewProject(name: String, resolution: VideoSize, frameRate: Double) {
        let project = VideoProject(name: name, resolution: resolution, frameRate: frameRate)
        currentProject = project
        editor = VideoEditor(project: project)
    }
    
    func openProject(url: URL) async throws {
        let fileManager = DefaultVideoFileManager()
        let project = try await fileManager.loadProject(from: url)
        currentProject = project
        editor = VideoEditor(project: project)
    }
    
    func saveProject() {
        // Implementation
    }
    
    func showOpenProjectDialog() {
        // Implementation
    }
    
    func undo() { }
    func redo() { }
    func cut() { }
    func copy() { }
    func paste() { }
    func deleteSelection() { }
    func toggleFullscreen() { }
    func setMarker() { }
    func nextMarker() { }
    func previousMarker() { }
    func splitClip() { }
    func joinClips() { }
    func trimToSelection() { }
    func extendEdit() { }
}
