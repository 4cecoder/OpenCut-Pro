import SwiftUI
import Combine

// MARK: - Keyboard Shortcuts Manager

@MainActor
public final class KeyboardShortcutsManager: ObservableObject {
    @Published public var shortcuts: [KeyboardShortcutItem] = []
    @Published public var customBindings: [String: KeyboardShortcut] = [:]
    @Published public var isRecordingShortcut = false
    @Published public var recordingAction: String?
    
    public static let shared = KeyboardShortcutsManager()
    
    public struct KeyboardShortcutItem: Identifiable, Codable {
        public let id = UUID()
        public let action: String
        public let category: ShortcutCategory
        public let defaultShortcut: KeyboardShortcut
        public var customShortcut: KeyboardShortcut?
        public let description: String
        
        public var currentShortcut: KeyboardShortcut {
            customShortcut ?? defaultShortcut
        }
        
        public init(action: String, category: ShortcutCategory, defaultShortcut: KeyboardShortcut, description: String) {
            self.action = action
            self.category = category
            self.defaultShortcut = defaultShortcut
            self.description = description
        }
    }
    
    public struct KeyboardShortcut: Codable, Equatable {
        public let key: String
        public let modifiers: [ModifierKey]
        
        public init(key: String, modifiers: [ModifierKey] = []) {
            self.key = key
            self.modifiers = modifiers
        }
        
        public var displayString: String {
            let modifierString = modifiers.map { $0.displayString }.joined()
            return modifierString + key.uppercased()
        }
        
        public var isEmpty: Bool {
            return key.isEmpty
        }
    }
    
    public enum ModifierKey: String, Codable, CaseIterable {
        case command = "⌘"
        case option = "⌥"
        case control = "⌃"
        case shift = "⇧"
        
        public var displayString: String { rawValue }
        public var eventModifier: NSEvent.ModifierFlags {
            switch self {
            case .command: return .command
            case .option: return .option
            case .control: return .control
            case .shift: return .shift
            }
        }
    }
    
    public enum ShortcutCategory: String, Codable, CaseIterable {
        case playback = "Playback"
        case editing = "Editing"
        case navigation = "Navigation"
        case view = "View"
        case tools = "Tools"
        case window = "Window"
        case export = "Export"
        
        public var icon: String {
            switch self {
            case .playback: return "play.fill"
            case .editing: return "scissors"
            case .navigation: return "arrow.left.arrow.right"
            case .view: return "eye"
            case .tools: return "wrench.fill"
            case .window: return "macwindow"
            case .export: return "square.and.arrow.up"
            }
        }
    }
    
    public enum ShortcutAction: String, CaseIterable {
        // Playback
        case playPause = "playPause"
        case playReverse = "playReverse"
        case stop = "stop"
        case goToStart = "goToStart"
        case goToEnd = "goToEnd"
        case stepForward = "stepForward"
        case stepBackward = "stepBackward"
        case stepForward10 = "stepForward10"
        case stepBackward10 = "stepBackward10"
        case loop = "loop"
        case increaseSpeed = "increaseSpeed"
        case decreaseSpeed = "decreaseSpeed"
        
        // Editing
        case cut = "cut"
        case copy = "copy"
        case paste = "paste"
        case delete = "delete"
        case selectAll = "selectAll"
        case deselectAll = "deselectAll"
        case splitClip = "splitClip"
        case joinClips = "joinClips"
        case rippleDelete = "rippleDelete"
        case lift = "lift"
        case overwrite = "overwrite"
        case insert = "insert"
        case replace = "replace"
        case blade = "blade"
        case trimStart = "trimStart"
        case trimEnd = "trimEnd"
        case extendEdit = "extendEdit"
        
        // Navigation
        case nextClip = "nextClip"
        case previousClip = "previousClip"
        case nextEdit = "nextEdit"
        case previousEdit = "previousEdit"
        case zoomIn = "zoomIn"
        case zoomOut = "zoomOut"
        case zoomToFit = "zoomToFit"
        case zoomToSelection = "zoomToSelection"
        
        // View
        case toggleViewer = "toggleViewer"
        case toggleTimeline = "toggleTimeline"
        case toggleBrowser = "toggleBrowser"
        case toggleInspector = "toggleInspector"
        case toggleFullscreen = "toggleFullscreen"
        case increaseViewerSize = "increaseViewerSize"
        case decreaseViewerSize = "decreaseViewerSize"
        
        // Tools
        case selectTool = "selectTool"
        case bladeTool = "bladeTool"
        case trimTool = "trimTool"
        case rangeTool = "rangeTool"
        case handTool = "handTool"
        case zoomTool = "zoomTool"
        case textTool = "textTool"
        
        // Window
        case newProject = "newProject"
        case openProject = "openProject"
        case saveProject = "saveProject"
        case closeWindow = "closeWindow"
        case minimizeWindow = "minimizeWindow"
        case nextWindow = "nextWindow"
        case previousWindow = "previousWindow"
        
        // Export
        case export = "export"
        case share = "share"
        case batchExport = "batchExport"
        case exportCurrentFrame = "exportCurrentFrame"
        
        public var category: ShortcutCategory {
            switch self {
            case .playPause, .playReverse, .stop, .goToStart, .goToEnd, .stepForward, .stepBackward,
                    .stepForward10, .stepBackward10, .loop, .increaseSpeed, .decreaseSpeed:
                return .playback
            case .cut, .copy, .paste, .delete, .selectAll, .deselectAll, .splitClip, .joinClips,
                    .rippleDelete, .lift, .overwrite, .insert, .replace, .blade, .trimStart, .trimEnd, .extendEdit:
                return .editing
            case .nextClip, .previousClip, .nextEdit, .previousEdit, .zoomIn, .zoomOut, .zoomToFit, .zoomToSelection:
                return .navigation
            case .toggleViewer, .toggleTimeline, .toggleBrowser, .toggleInspector, .toggleFullscreen,
                    .increaseViewerSize, .decreaseViewerSize:
                return .view
            case .selectTool, .bladeTool, .trimTool, .rangeTool, .handTool, .zoomTool, .textTool:
                return .tools
            case .newProject, .openProject, .saveProject, .closeWindow, .minimizeWindow, .nextWindow, .previousWindow:
                return .window
            case .export, .share, .batchExport, .exportCurrentFrame:
                return .export
            }
        }
        
        public var defaultShortcut: KeyboardShortcut {
            switch self {
            // Playback
            case .playPause: return KeyboardShortcut(key: " ", modifiers: [])
            case .playReverse: return KeyboardShortcut(key: "j", modifiers: [.shift])
            case .stop: return KeyboardShortcut(key: "k", modifiers: [])
            case .goToStart: return KeyboardShortcut(key: "home", modifiers: [])
            case .goToEnd: return KeyboardShortcut(key: "end", modifiers: [])
            case .stepForward: return KeyboardShortcut(key: "right", modifiers: [])
            case .stepBackward: return KeyboardShortcut(key: "left", modifiers: [])
            case .stepForward10: return KeyboardShortcut(key: "right", modifiers: [.shift])
            case .stepBackward10: return KeyboardShortcut(key: "left", modifiers: [.shift])
            case .loop: return KeyboardShortcut(key: "l", modifiers: [.command])
            case .increaseSpeed: return KeyboardShortcut(key: "l", modifiers: [])
            case .decreaseSpeed: return KeyboardShortcut(key: "j", modifiers: [])
            
            // Editing
            case .cut: return KeyboardShortcut(key: "x", modifiers: [.command])
            case .copy: return KeyboardShortcut(key: "c", modifiers: [.command])
            case .paste: return KeyboardShortcut(key: "v", modifiers: [.command])
            case .delete: return KeyboardShortcut(key: "delete", modifiers: [])
            case .selectAll: return KeyboardShortcut(key: "a", modifiers: [.command])
            case .deselectAll: return KeyboardShortcut(key: "a", modifiers: [.command, .shift])
            case .splitClip: return KeyboardShortcut(key: "b", modifiers: [.command])
            case .joinClips: return KeyboardShortcut(key: "j", modifiers: [.command])
            case .rippleDelete: return KeyboardShortcut(key: "delete", modifiers: [.shift])
            case .lift: return KeyboardShortcut(key: "delete", modifiers: [.option])
            case .overwrite: return KeyboardShortcut(key: "f10", modifiers: [.command])
            case .insert: return KeyboardShortcut(key: "f9", modifiers: [.command])
            case .replace: return KeyboardShortcut(key: "f11", modifiers: [.command])
            case .blade: return KeyboardShortcut(key: "b", modifiers: [])
            case .trimStart: return KeyboardShortcut(key: "[", modifiers: [])
            case .trimEnd: return KeyboardShortcut(key: "]", modifiers: [])
            case .extendEdit: return KeyboardShortcut(key: "x", modifiers: [])
            
            // Navigation
            case .nextClip: return KeyboardShortcut(key: "down", modifiers: [])
            case .previousClip: return KeyboardShortcut(key: "up", modifiers: [])
            case .nextEdit: return KeyboardShortcut(key: "right", modifiers: [.command])
            case .previousEdit: return KeyboardShortcut(key: "left", modifiers: [.command])
            case .zoomIn: return KeyboardShortcut(key: "=", modifiers: [.command])
            case .zoomOut: return KeyboardShortcut(key: "-", modifiers: [.command])
            case .zoomToFit: return KeyboardShortcut(key: "z", modifiers: [.command, .option])
            case .zoomToSelection: return KeyboardShortcut(key: "z", modifiers: [.command, .shift])
            
            // View
            case .toggleViewer: return KeyboardShortcut(key: "1", modifiers: [.command, .option])
            case .toggleTimeline: return KeyboardShortcut(key: "2", modifiers: [.command, .option])
            case .toggleBrowser: return KeyboardShortcut(key: "3", modifiers: [.command, .option])
            case .toggleInspector: return KeyboardShortcut(key: "4", modifiers: [.command, .option])
            case .toggleFullscreen: return KeyboardShortcut(key: "f", modifiers: [.command, .control])
            case .increaseViewerSize: return KeyboardShortcut(key: "+", modifiers: [.command, .option])
            case .decreaseViewerSize: return KeyboardShortcut(key: "-", modifiers: [.command, .option])
            
            // Tools
            case .selectTool: return KeyboardShortcut(key: "a", modifiers: [])
            case .bladeTool: return KeyboardShortcut(key: "b", modifiers: [])
            case .trimTool: return KeyboardShortcut(key: "t", modifiers: [])
            case .rangeTool: return KeyboardShortcut(key: "r", modifiers: [])
            case .handTool: return KeyboardShortcut(key: "h", modifiers: [])
            case .zoomTool: return KeyboardShortcut(key: "z", modifiers: [])
            case .textTool: return KeyboardShortcut(key: "t", modifiers: [.shift])
            
            // Window
            case .newProject: return KeyboardShortcut(key: "n", modifiers: [.command])
            case .openProject: return KeyboardShortcut(key: "o", modifiers: [.command])
            case .saveProject: return KeyboardShortcut(key: "s", modifiers: [.command])
            case .closeWindow: return KeyboardShortcut(key: "w", modifiers: [.command])
            case .minimizeWindow: return KeyboardShortcut(key: "m", modifiers: [.command])
            case .nextWindow: return KeyboardShortcut(key: "`", modifiers: [.command])
            case .previousWindow: return KeyboardShortcut(key: "`", modifiers: [.command, .shift])
            
            // Export
            case .export: return KeyboardShortcut(key: "e", modifiers: [.command, .shift])
            case .share: return KeyboardShortcut(key: "s", modifiers: [.command, .shift, .option])
            case .batchExport: return KeyboardShortcut(key: "e", modifiers: [.command, .option])
            case .exportCurrentFrame: return KeyboardShortcut(key: "e", modifiers: [.command, .control])
            }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var eventMonitor: Any?
    private var actionHandlers: [String: () -> Void] = [:]
    
    private init() {
        setupDefaultShortcuts()
        setupEventMonitor()
        loadCustomBindings()
    }
    
    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    private func setupDefaultShortcuts() {
        shortcuts = ShortcutAction.allCases.map { action in
            KeyboardShortcutItem(
                action: action.rawValue,
                category: action.category,
                defaultShortcut: action.defaultShortcut,
                description: actionDescription(action)
            )
        }
    }
    
    private func actionDescription(_ action: ShortcutAction) -> String {
        switch action {
        case .playPause: return "Start or pause playback"
        case .playReverse: return "Play in reverse"
        case .stop: return "Stop playback"
        case .goToStart: return "Go to beginning"
        case .goToEnd: return "Go to end"
        case .stepForward: return "Step forward one frame"
        case .stepBackward: return "Step backward one frame"
        case .stepForward10: return "Step forward 10 frames"
        case .stepBackward10: return "Step backward 10 frames"
        case .loop: return "Toggle loop playback"
        case .increaseSpeed: return "Increase playback speed"
        case .decreaseSpeed: return "Decrease playback speed"
        case .cut: return "Cut selection"
        case .copy: return "Copy selection"
        case .paste: return "Paste"
        case .delete: return "Delete selection"
        case .selectAll: return "Select all"
        case .deselectAll: return "Deselect all"
        case .splitClip: return "Split clip at playhead"
        case .joinClips: return "Join selected clips"
        case .rippleDelete: return "Ripple delete"
        case .lift: return "Lift from storyline"
        case .overwrite: return "Overwrite edit"
        case .insert: return "Insert edit"
        case .replace: return "Replace edit"
        case .blade: return "Blade tool"
        case .trimStart: return "Trim to start"
        case .trimEnd: return "Trim to end"
        case .extendEdit: return "Extend edit"
        case .nextClip: return "Next clip"
        case .previousClip: return "Previous clip"
        case .nextEdit: return "Next edit point"
        case .previousEdit: return "Previous edit point"
        case .zoomIn: return "Zoom in"
        case .zoomOut: return "Zoom out"
        case .zoomToFit: return "Zoom to fit"
        case .zoomToSelection: return "Zoom to selection"
        case .toggleViewer: return "Toggle viewer visibility"
        case .toggleTimeline: return "Toggle timeline visibility"
        case .toggleBrowser: return "Toggle browser visibility"
        case .toggleInspector: return "Toggle inspector visibility"
        case .toggleFullscreen: return "Toggle fullscreen"
        case .increaseViewerSize: return "Increase viewer size"
        case .decreaseViewerSize: return "Decrease viewer size"
        case .selectTool: return "Select tool"
        case .bladeTool: return "Blade tool"
        case .trimTool: return "Trim tool"
        case .rangeTool: return "Range selection tool"
        case .handTool: return "Hand tool"
        case .zoomTool: return "Zoom tool"
        case .textTool: return "Text tool"
        case .newProject: return "New project"
        case .openProject: return "Open project"
        case .saveProject: "Save project"
        case .closeWindow: return "Close window"
        case .minimizeWindow: return "Minimize window"
        case .nextWindow: return "Next window"
        case .previousWindow: return "Previous window"
        case .export: return "Export"
        case .share: return "Share"
        case .batchExport: return "Batch export"
        case .exportCurrentFrame: return "Export current frame"
        }
    }
    
    private func setupEventMonitor() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { [weak self] event in
            self?.handleKeyEvent(event)
            return event
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
        guard !isRecordingShortcut else {
            if let action = recordingAction {
                recordShortcut(for: action, from: event)
            }
            return nil
        }
        
        let key = event.keyCode.keyString
        let modifiers = getModifiers(from: event.modifierFlags)
        let shortcut = KeyboardShortcut(key: key, modifiers: modifiers)
        
        for item in shortcuts {
            if item.currentShortcut == shortcut {
                executeAction(item.action)
                return nil
            }
        }
        
        return event
    }
    
    private func getModifiers(from flags: NSEvent.ModifierFlags) -> [ModifierKey] {
        var modifiers: [ModifierKey] = []
        if flags.contains(.command) { modifiers.append(.command) }
        if flags.contains(.option) { modifiers.append(.option) }
        if flags.contains(.control) { modifiers.append(.control) }
        if flags.contains(.shift) { modifiers.append(.shift) }
        return modifiers
    }
    
    public func registerAction(_ action: String, handler: @escaping () -> Void) {
        actionHandlers[action] = handler
    }
    
    public func executeAction(_ action: String) {
        actionHandlers[action]?()
    }
    
    public func setCustomShortcut(for action: String, shortcut: KeyboardShortcut?) {
        if let index = shortcuts.firstIndex(where: { $0.action == action }) {
            shortcuts[index].customShortcut = shortcut
        }
        customBindings[action] = shortcut
        saveCustomBindings()
    }
    
    public func resetToDefaults() {
        for index in shortcuts.indices {
            shortcuts[index].customShortcut = nil
        }
        customBindings.removeAll()
        saveCustomBindings()
    }
    
    public func resetShortcut(for action: String) {
        if let index = shortcuts.firstIndex(where: { $0.action == action }) {
            shortcuts[index].customShortcut = nil
        }
        customBindings.removeValue(forKey: action)
        saveCustomBindings()
    }
    
    public func startRecording(for action: String) {
        isRecordingShortcut = true
        recordingAction = action
    }
    
    public func stopRecording() {
        isRecordingShortcut = false
        recordingAction = nil
    }
    
    private func recordShortcut(for action: String, from event: NSEvent) {
        let key = event.keyCode.keyString
        let modifiers = getModifiers(from: event.modifierFlags)
        let shortcut = KeyboardShortcut(key: key, modifiers: modifiers)
        
        setCustomShortcut(for: action, shortcut: shortcut)
        stopRecording()
    }
    
    public func checkForConflicts(shortcut: KeyboardShortcut) -> [KeyboardShortcutItem] {
        return shortcuts.filter { $0.currentShortcut == shortcut && !$0.currentShortcut.isEmpty }
    }
    
    public func getShortcut(for action: String) -> KeyboardShortcut? {
        return shortcuts.first { $0.action == action }?.currentShortcut
    }
    
    public func exportShortcuts() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try? encoder.encode(shortcuts)
    }
    
    public func importShortcuts(from data: Data) -> Bool {
        let decoder = JSONDecoder()
        if let imported = try? decoder.decode([KeyboardShortcutItem].self, from: data) {
            shortcuts = imported
            return true
        }
        return false
    }
    
    private func saveCustomBindings() {
        if let data = try? JSONEncoder().encode(customBindings) {
            UserDefaults.standard.set(data, forKey: "keyboardShortcuts.customBindings")
        }
    }
    
    private func loadCustomBindings() {
        guard let data = UserDefaults.standard.data(forKey: "keyboardShortcuts.customBindings"),
              let bindings = try? JSONDecoder().decode([String: KeyboardShortcut].self, from: data) else {
            return
        }
        customBindings = bindings
        for (action, shortcut) in bindings {
            if let index = shortcuts.firstIndex(where: { $0.action == action }) {
                shortcuts[index].customShortcut = shortcut
            }
        }
    }
}

// MARK: - Key Code Extension

extension UInt16 {
    var keyString: String {
        switch self {
        case 0x00: return "a"
        case 0x01: return "s"
        case 0x02: return "d"
        case 0x03: return "f"
        case 0x04: return "h"
        case 0x05: return "g"
        case 0x06: return "z"
        case 0x07: return "x"
        case 0x08: return "c"
        case 0x09: return "v"
        case 0x0B: return "b"
        case 0x0C: return "q"
        case 0x0D: return "w"
        case 0x0E: return "e"
        case 0x0F: return "r"
        case 0x10: return "y"
        case 0x11: return "t"
        case 0x12: return "1"
        case 0x13: return "2"
        case 0x14: return "3"
        case 0x15: return "4"
        case 0x16: return "6"
        case 0x17: return "5"
        case 0x18: return "="
        case 0x19: return "9"
        case 0x1A: return "7"
        case 0x1B: return "-"
        case 0x1C: return "8"
        case 0x1D: return "0"
        case 0x1E: return "]"
        case 0x1F: return "o"
        case 0x20: return "u"
        case 0x21: return "["
        case 0x22: return "i"
        case 0x23: return "p"
        case 0x24: return "return"
        case 0x25: return "l"
        case 0x26: return "j"
        case 0x27: return "'"
        case 0x28: return "k"
        case 0x29: return ";"
        case 0x2A: return "\\"
        case 0x2B: return ","
        case 0x2C: return "/"
        case 0x2D: return "n"
        case 0x2E: return "m"
        case 0x2F: return "."
        case 0x30: return "tab"
        case 0x31: return " "
        case 0x33: return "delete"
        case 0x34: return "enter"
        case 0x35: return "esc"
        case 0x37: return "command"
        case 0x38: return "shift"
        case 0x3A: return "option"
        case 0x3B: return "control"
        case 0x3C: return "right"
        case 0x3D: return "left"
        case 0x3E: return "down"
        case 0x3F: return "up"
        case 0x48: return "volumeup"
        case 0x49: return "volumedown"
        case 0x4A: return "mute"
        case 0x4F: return "f18"
        case 0x50: return "f19"
        case 0x5A: return "f20"
        case 0x60: return "f5"
        case 0x61: return "f6"
        case 0x62: return "f7"
        case 0x63: return "f3"
        case 0x64: return "f8"
        case 0x65: return "f9"
        case 0x67: return "f11"
        case 0x69: return "f13"
        case 0x6A: return "f16"
        case 0x6B: return "f14"
        case 0x6D: return "f10"
        case 0x6F: return "f12"
        case 0x71: return "f15"
        case 0x72: return "help"
        case 0x73: return "home"
        case 0x74: return "pageup"
        case 0x75: return "delete"
        case 0x76: return "f4"
        case 0x77: return "end"
        case 0x78: return "f2"
        case 0x79: return "pagedown"
        case 0x7A: return "f1"
        case 0x7B: return "left"
        case 0x7C: return "right"
        case 0x7D: return "down"
        case 0x7E: return "up"
        default: return String(format: "%02X", self)
        }
    }
}

// MARK: - Keyboard Shortcuts Settings View

public struct KeyboardShortcutsSettingsView: View {
    @StateObject private var manager = KeyboardShortcutsManager.shared
    @State private var selectedCategory: KeyboardShortcutsManager.ShortcutCategory?
    @State private var searchText = ""
    @State private var showingResetAlert = false
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Search", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                
                Spacer()
                
                Button("Reset All") {
                    showingResetAlert = true
                }
                .alert("Reset all shortcuts to defaults?", isPresented: $showingResetAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Reset", role: .destructive) {
                        manager.resetToDefaults()
                    }
                }
            }
            .padding()
            
            HStack(spacing: 0) {
                List(KeyboardShortcutsManager.ShortcutCategory.allCases, id: \.self, selection: $selectedCategory) { category in
                    HStack {
                        Image(systemName: category.icon)
                        Text(category.rawValue)
                    }
                    .tag(category as KeyboardShortcutsManager.ShortcutCategory?)
                }
                .frame(width: 150)
                .listStyle(.sidebar)
                
                Divider()
                
                List(filteredShortcuts) { item in
                    ShortcutRow(item: item)
                }
                .listStyle(.plain)
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
    
    private var filteredShortcuts: [KeyboardShortcutsManager.KeyboardShortcutItem] {
        var result = manager.shortcuts
        
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.action.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
}

public struct ShortcutRow: View {
    let item: KeyboardShortcutsManager.KeyboardShortcutItem
    @StateObject private var manager = KeyboardShortcutsManager.shared
    @State private var isRecording = false
    
    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.action)
                    .font(.subheadline)
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                if let custom = item.customShortcut {
                    Text("Custom:")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                ShortcutKeyView(shortcut: item.currentShortcut, isRecording: isRecording)
                    .onTapGesture {
                        if isRecording {
                            manager.stopRecording()
                            isRecording = false
                        } else {
                            manager.startRecording(for: item.action)
                            isRecording = true
                        }
                    }
                
                if item.customShortcut != nil {
                    Button("Reset") {
                        manager.resetShortcut(for: item.action)
                    }
                    .buttonStyle(.borderless)
                    .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
        .background(isRecording ? Color.blue.opacity(0.1) : Color.clear)
        .onChange(of: manager.isRecordingShortcut) { _, newValue in
            if !newValue {
                isRecording = false
            }
        }
    }
}

public struct ShortcutKeyView: View {
    let shortcut: KeyboardShortcutsManager.KeyboardShortcut
    let isRecording: Bool
    
    public var body: some View {
        HStack(spacing: 2) {
            ForEach(shortcut.modifiers, id: \.self) { modifier in
                Text(modifier.displayString)
                    .font(.system(size: 14, weight: .medium))
            }
            
            Text(shortcut.key.uppercased())
                .font(.system(size: 12, weight: .bold))
                .frame(minWidth: 24, minHeight: 24)
                .padding(.horizontal, 6)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
        }
        .padding(6)
        .background(isRecording ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isRecording ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Preview

#Preview {
    KeyboardShortcutsSettingsView()
}
