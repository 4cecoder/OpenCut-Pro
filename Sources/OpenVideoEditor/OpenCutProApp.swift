import SwiftUI
import OpenVideoCore

@main
struct OpenCutProApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainWindowView()
                .environmentObject(appState)
                .frame(minWidth: 1400, minHeight: 900)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 1600, height: 1000)
        .commands {
            buildCommands()
        }
    }
    
    private func buildCommands() -> some Commands {
        Group {
            CommandGroup(replacing: .newItem) {
                Button("New Project...") {
                    appState.showNewProjectSheet = true
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("Open Project...") {
                    appState.showOpenProjectDialog()
                }
                .keyboardShortcut("o", modifiers: .command)
                
                Divider()
                
                Button("Save") {
                    appState.saveProject()
                }
                .keyboardShortcut("s", modifiers: .command)
                
                Button("Save As...") {
                    appState.saveProjectAs()
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
            }
            
            CommandMenu("Edit") {
                Button("Undo") { appState.undo() }
                    .keyboardShortcut("z", modifiers: .command)
                
                Button("Redo") { appState.redo() }
                    .keyboardShortcut("z", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Cut") { appState.cut() }
                    .keyboardShortcut("x", modifiers: .command)
                
                Button("Copy") { appState.copy() }
                    .keyboardShortcut("c", modifiers: .command)
                
                Button("Paste") { appState.paste() }
                    .keyboardShortcut("v", modifiers: .command)
                
                Button("Paste Attributes") { appState.pasteAttributes() }
                    .keyboardShortcut("v", modifiers: [.command, .shift, .option])
                
                Divider()
                
                Button("Delete") { appState.deleteSelection() }
                    .keyboardShortcut(.delete, modifiers: .command)
                
                Button("Ripple Delete") { appState.rippleDelete() }
                    .keyboardShortcut(.delete, modifiers: [.command, .shift])
                
                Button("Select All") { appState.selectAll() }
                    .keyboardShortcut("a", modifiers: .command)
                
                Button("Deselect All") { appState.deselectAll() }
                    .keyboardShortcut("a", modifiers: [.command, .shift])
            }
            
            CommandMenu("Trim") {
                Button("Trim Start") { appState.trimStart() }
                    .keyboardShortcut("[", modifiers: .command)
                
                Button("Trim End") { appState.trimEnd() }
                    .keyboardShortcut("]", modifiers: .command)
                
                Button("Trim to Selection") { appState.trimToSelection() }
                    .keyboardShortcut("t", modifiers: .command)
                
                Button("Extend Edit") { appState.extendEdit() }
                    .keyboardShortcut("e", modifiers: .command)
                
                Divider()
                
                Button("Blade") { appState.splitClip() }
                    .keyboardShortcut("b", modifiers: .command)
                
                Button("Blade All") { appState.splitAll() }
                    .keyboardShortcut("b", modifiers: [.command, .shift])
                
                Button("Join Clips") { appState.joinClips() }
                    .keyboardShortcut("j", modifiers: .command)
                
                Divider()
                
                Button("Lift from Storyline") { appState.lift() }
                    .keyboardShortcut(.upArrow, modifiers: .command)
                
                Button("Overwrite to Primary Storyline") { appState.overwrite() }
                    .keyboardShortcut(.downArrow, modifiers: .command)
            }
            
            CommandMenu("Mark") {
                Button("Set Marker") { appState.setMarker() }
                    .keyboardShortcut("m", modifiers: .command)
                
                Button("Set Chapter Marker") { appState.setChapterMarker() }
                    .keyboardShortcut("m", modifiers: [.command, .option])
                
                Button("Delete Marker") { appState.deleteMarker() }
                    .keyboardShortcut("m", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Next Marker") { appState.nextMarker() }
                    .keyboardShortcut(.rightArrow, modifiers: .command)
                
                Button("Previous Marker") { appState.previousMarker() }
                    .keyboardShortcut(.leftArrow, modifiers: .command)
                
                Divider()
                
                Button("Mark Selection") { appState.markSelection() }
                    .keyboardShortcut("x", modifiers: [.command, .option])
            }
            
            CommandMenu("View") {
                Button("Show/Hide Browser") { appState.showBrowser.toggle() }
                    .keyboardShortcut("1", modifiers: .command)
                
                Button("Show/Hide Viewer") { appState.showViewer.toggle() }
                    .keyboardShortcut("2", modifiers: .command)
                
                Button("Show/Hide Timeline") { appState.showTimeline.toggle() }
                    .keyboardShortcut("3", modifiers: .command)
                
                Button("Show/Hide Inspector") { appState.showInspector.toggle() }
                    .keyboardShortcut("4", modifiers: .command)
                
                Button("Show/Hide Color Inspector") { appState.showColorInspector.toggle() }
                    .keyboardShortcut("5", modifiers: .command)
                
                Button("Show/Hide Audio Meters") { appState.showAudioMeters.toggle() }
                    .keyboardShortcut("6", modifiers: .command)
                
                Divider()
                
                Button("Viewer Display Size: 25%") { appState.viewerScale = 0.25 }
                
                Button("Viewer Display Size: 50%") { appState.viewerScale = 0.5 }
                    .keyboardShortcut("minus", modifiers: .command)
                
                Button("Viewer Display Size: 100%") { appState.viewerScale = 1.0 }
                
                Button("Viewer Display Size: 200%") { appState.viewerScale = 2.0 }
                    .keyboardShortcut("plus", modifiers: .command)
                
                Divider()
                
                Button("Show in Finder") { appState.showInFinder() }
                .keyboardShortcut("f", modifiers: [.command, .shift])
            }
            
            CommandMenu("Window") {
                Button("Minimize") { }
                    .keyboardShortcut("m", modifiers: .command)
                
                Button("Zoom") { }
                
                Divider()
                
                Button("Show Events") { }
                
                Button("Show Project Timeline") { }
                
                Button("Show Retime Editor") { }
            }
            
            CommandMenu("Share") {
                Button("Export File...") { appState.showExportSheet = true }
                    .keyboardShortcut("e", modifiers: [.command, .shift])
                
                Button("Export Settings...") { appState.showExportSettings = true }
                
                Button("Send to Compressor") { }
                
                Button("Publish to YouTube") { }
                
                Button("Publish to Vimeo") { }
            }
        }
    }
}
    func saveProjectAs() { }
    func showOpenProjectDialog() { }
    func showInFinder() { }
    func undo() { }
    func redo() { }
    func cut() { }
    func copy() { }
    func paste() { }
    func pasteAttributes() { }
    func deleteSelection() { }
    func rippleDelete() { }
    func selectAll() { }
    func deselectAll() { }
    func trimStart() { }
    func trimEnd() { }
    func trimToSelection() { }
    func extendEdit() { }
    func splitClip() { }
    func splitAll() { }
    func joinClips() { }
    func lift() { }
    func overwrite() { }
    func setMarker() { }
    func setChapterMarker() { }
    func deleteMarker() { }
    func nextMarker() { }
    func previousMarker() { }
    func markSelection() { }
    func toggleFullscreen() { isFullscreen.toggle() }
}

enum InspectorTab {
    case video, audio, info, effects, transitions, color
}

enum BrowserTab {
    case allMedia, video, audio, titles, generators, transitions, effects
}
