import SwiftUI
import Combine

// MARK: - Inspector View Model

@MainActor
public final class InspectorViewModel: ObservableObject {
    @Published public var selectedClip: VideoClip?
    @Published public var selectedEffect: Effect?
    @Published public var selectedExportSettings: ExportSettings = ExportSettings()
    @Published public var activeTab: InspectorTab = .video
    @Published public var isShowingKeyframes = false
    @Published public var keyframeValues: [KeyframeValue] = []
    @Published public var propertyHistory: [PropertyChange] = []
    @Published public var canUndo = false
    @Published public var canRedo = false
    @Published public var presetName: String = ""
    @Published public var isModified = false
    
    public enum InspectorTab: String, CaseIterable {
        case video = "Video"
        case audio = "Audio"
        case effects = "Effects"
        case transitions = "Transitions"
        case info = "Info"
        case export = "Export"
    }
    
    public struct KeyframeValue: Identifiable {
        public let id = UUID()
        public var time: TimeInterval
        public var value: Double
        public var property: String
    }
    
    public struct PropertyChange: Identifiable {
        public let id = UUID()
        public let property: String
        public let oldValue: Any
        public let newValue: Any
        public let timestamp: Date
    }
    
    private var undoStack: [PropertyChange] = []
    private var redoStack: [PropertyChange] = []
    private var cancellables = Set<AnyCancellable>()
    
    public init() {}
    
    public func selectClip(_ clip: VideoClip?) {
        selectedClip = clip
        if let clip = clip {
            loadKeyframes(for: clip)
        }
        isModified = false
    }
    
    public func selectEffect(_ effect: Effect?) {
        selectedEffect = effect
    }
    
    public func updateClipProperty<T>(_ keyPath: WritableKeyPath<VideoClip, T>, value: T) {
        guard var clip = selectedClip else { return }
        let oldValue = clip[keyPath: keyPath]
        clip[keyPath: keyPath] = value
        selectedClip = clip
        
        let change = PropertyChange(
            property: String(describing: keyPath),
            oldValue: oldValue,
            newValue: value,
            timestamp: Date()
        )
        undoStack.append(change)
        redoStack.removeAll()
        updateUndoRedoState()
        isModified = true
    }
    
    public func updateEffectParameter(key: String, value: Double) {
        guard var effect = selectedEffect else { return }
        let oldValue = effect.parameters[key] ?? 0.0
        effect.parameters[key] = value
        selectedEffect = effect
        
        let change = PropertyChange(
            property: "effect.\(key)",
            oldValue: oldValue,
            newValue: value,
            timestamp: Date()
        )
        undoStack.append(change)
        redoStack.removeAll()
        updateUndoRedoState()
        isModified = true
    }
    
    public func updateExportSettings(_ settings: ExportSettings) {
        selectedExportSettings = settings
        isModified = true
    }
    
    public func undo() {
        guard let change = undoStack.popLast() else { return }
        redoStack.append(change)
        applyUndo(change)
        updateUndoRedoState()
    }
    
    public func redo() {
        guard let change = redoStack.popLast() else { return }
        undoStack.append(change)
        applyRedo(change)
        updateUndoRedoState()
    }
    
    private func applyUndo(_ change: PropertyChange) {
        // Apply the old value based on property type
        // This would require reflection or a more sophisticated system
    }
    
    private func applyRedo(_ change: PropertyChange) {
        // Apply the new value based on property type
    }
    
    private func updateUndoRedoState() {
        canUndo = !undoStack.isEmpty
        canRedo = !redoStack.isEmpty
    }
    
    public func addKeyframe(at time: TimeInterval, value: Double, for property: String) {
        let keyframe = KeyframeValue(time: time, value: value, property: property)
        keyframeValues.append(keyframe)
        keyframeValues.sort { $0.time < $1.time }
    }
    
    public func removeKeyframe(id: UUID) {
        keyframeValues.removeAll { $0.id == id }
    }
    
    public func loadKeyframes(for clip: VideoClip) {
        keyframeValues = []
        // Load keyframes from clip metadata
    }
    
    public func savePreset(name: String) {
        guard let clip = selectedClip else { return }
        // Save clip settings as preset
        presetName = name
    }
    
    public func resetToDefaults() {
        guard var clip = selectedClip else { return }
        // Reset all properties to defaults
        selectedClip = clip
    }
    
    public var formattedDuration: String {
        guard let clip = selectedClip else { return "--:--" }
        let duration = clip.duration
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    public var formattedFileSize: String {
        // Calculate based on resolution and duration
        return "Unknown"
    }
}

// MARK: - Inspector View

public struct Inspector: View {
    @StateObject public var viewModel: InspectorViewModel
    
    public init(viewModel: InspectorViewModel = InspectorViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            InspectorTabBar(viewModel: viewModel)
                .frame(height: 40)
            
            Divider()
            
            ScrollView {
                switch viewModel.activeTab {
                case .video:
                    VideoPropertiesPanel(viewModel: viewModel)
                case .audio:
                    AudioPropertiesPanel(viewModel: viewModel)
                case .effects:
                    EffectsPanel(viewModel: viewModel)
                case .transitions:
                    TransitionsPanel(viewModel: viewModel)
                case .info:
                    InfoPanel(viewModel: viewModel)
                case .export:
                    ExportPanel(viewModel: viewModel)
                }
            }
            .padding()
            
            if viewModel.isModified {
                HStack {
                    Spacer()
                    Text("Modified")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Button("Revert") {
                        viewModel.resetToDefaults()
                    }
                    .buttonStyle(.borderless)
                    Button("Apply") {
                        viewModel.isModified = false
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
            }
        }
        .background(Color.black.opacity(0.95))
        .frame(minWidth: 280)
    }
}

// MARK: - Inspector Tab Bar

public struct InspectorTabBar: View {
    @ObservedObject public var viewModel: InspectorViewModel
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(InspectorViewModel.InspectorTab.allCases, id: \.self) { tab in
                Button(action: { viewModel.activeTab = tab }) {
                    VStack(spacing: 2) {
                        Image(systemName: iconForTab(tab))
                            .font(.system(size: 14))
                        Text(tab.rawValue)
                            .font(.system(size: 9))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(viewModel.activeTab == tab ? Color.blue.opacity(0.3) : Color.clear)
                    .foregroundColor(viewModel.activeTab == tab ? .blue : .white)
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color.gray.opacity(0.15))
    }
    
    private func iconForTab(_ tab: InspectorViewModel.InspectorTab) -> String {
        switch tab {
        case .video: return "video.fill"
        case .audio: return "waveform"
        case .effects: return "wand.and.stars"
        case .transitions: return "arrow.right.arrow.left"
        case .info: return "info.circle"
        case .export: return "square.and.arrow.up"
        }
    }
}

// MARK: - Video Properties Panel

public struct VideoPropertiesPanel: View {
    @ObservedObject public var viewModel: InspectorViewModel
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let clip = viewModel.selectedClip {
                SectionHeader(title: "Transform")
                
                PropertyGroup {
                    SliderProperty(
                        label: "Position X",
                        value: .constant(0),
                        range: -1000...1000
                    )
                    SliderProperty(
                        label: "Position Y",
                        value: .constant(0),
                        range: -1000...1000
                    )
                    SliderProperty(
                        label: "Scale",
                        value: .constant(100),
                        range: 0...200,
                        unit: "%"
                    )
                    SliderProperty(
                        label: "Rotation",
                        value: .constant(0),
                        range: -180...180,
                        unit: "°"
                    )
                    SliderProperty(
                        label: "Opacity",
                        value: .constant(100),
                        range: 0...100,
                        unit: "%"
                    )
                }
                
                SectionHeader(title: "Crop")
                
                PropertyGroup {
                    SliderProperty(
                        label: "Left",
                        value: .constant(0),
                        range: 0...100,
                        unit: "px"
                    )
                    SliderProperty(
                        label: "Right",
                        value: .constant(0),
                        range: 0...100,
                        unit: "px"
                    )
                    SliderProperty(
                        label: "Top",
                        value: .constant(0),
                        range: 0...100,
                        unit: "px"
                    )
                    SliderProperty(
                        label: "Bottom",
                        value: .constant(0),
                        range: 0...100,
                        unit: "px"
                    )
                }
                
                SectionHeader(title: "Timing")
                
                PropertyGroup {
                    HStack {
                        Text("Start")
                            .frame(width: 60, alignment: .leading)
                        TextField("", value: .constant(clip.startTime), format: .number)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Text("End")
                            .frame(width: 60, alignment: .leading)
                        TextField("", value: .constant(clip.endTime), format: .number)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Text("Duration")
                            .frame(width: 60, alignment: .leading)
                        Text(viewModel.formattedDuration)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Speed")
                            .frame(width: 60, alignment: .leading)
                        Slider(value: .constant(100), in: 10...400, step: 10)
                        Text("100%")
                            .font(.caption)
                            .frame(width: 40)
                    }
                    
                    Toggle("Reverse", isOn: .constant(false))
                    Toggle("Maintain Pitch", isOn: .constant(true))
                }
                
                SectionHeader(title: "Blend Mode")
                
                PropertyGroup {
                    Picker("", selection: .constant(0)) {
                        Text("Normal").tag(0)
                        Text("Add").tag(1)
                        Text("Multiply").tag(2)
                        Text("Screen").tag(3)
                        Text("Overlay").tag(4)
                    }
                    .pickerStyle(.menu)
                }
            } else {
                EmptyStateView(message: "Select a clip to view properties")
            }
        }
    }
}

// MARK: - Audio Properties Panel

public struct AudioPropertiesPanel: View {
    @ObservedObject public var viewModel: InspectorViewModel
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Volume")
            
            PropertyGroup {
                SliderProperty(
                    label: "Volume",
                    value: .constant(0),
                    range: -96...12,
                    unit: "dB"
                )
                
                HStack {
                    Text("L")
                    VUChannel(level: 0.7)
                    VUChannel(level: 0.7)
                    Text("R")
                }
                .frame(height: 60)
            }
            
            SectionHeader(title: "EQ")
            
            PropertyGroup {
                EQView()
                    .frame(height: 100)
            }
            
            SectionHeader(title: "Fades")
            
            PropertyGroup {
                SliderProperty(
                    label: "Fade In",
                    value: .constant(0),
                    range: 0...10,
                    unit: "s"
                )
                SliderProperty(
                    label: "Fade Out",
                    value: .constant(0),
                    range: 0...10,
                    unit: "s"
                )
            }
            
            SectionHeader(title: "Audio Enhancements")
            
            PropertyGroup {
                Toggle("Noise Removal", isOn: .constant(false))
                Toggle("Hum Removal", isOn: .constant(false))
                Toggle("Voice Isolation", isOn: .constant(false))
            }
        }
    }
}

public struct VUChannel: View {
    let level: Double
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                level > 0.9 ? Color.red : Color.green,
                                level > 0.7 ? Color.yellow : Color.green
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(height: geometry.size.height * level)
            }
            .cornerRadius(2)
        }
        .frame(width: 12)
    }
}

public struct EQView: View {
    public var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
            
            Path { path in
                let width = 200
                let height = 100
                
                path.move(to: CGPoint(x: 0, y: height / 2))
                
                for x in stride(from: 0, through: width, by: 10) {
                    let normalizedX = Double(x) / Double(width)
                    let y = Double(height) / 2 + sin(normalizedX * .pi * 4) * 20
                    path.addLine(to: CGPoint(x: x, y: Int(y)))
                }
            }
            .stroke(Color.blue, lineWidth: 2)
            
            HStack {
                ForEach(0..<6) { i in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
}

// MARK: - Effects Panel

public struct EffectsPanel: View {
    @ObservedObject public var viewModel: InspectorViewModel
    @State private var showEffectBrowser = false
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SectionHeader(title: "Applied Effects")
                Spacer()
                Button("+ Add") {
                    showEffectBrowser = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            
            if let clip = viewModel.selectedClip {
                ForEach(clip.effects) { effect in
                    EffectRow(effect: effect, viewModel: viewModel)
                }
                
                if clip.effects.isEmpty {
                    EmptyStateView(message: "No effects applied")
                }
            } else {
                EmptyStateView(message: "Select a clip to edit effects")
            }
            
            if showEffectBrowser {
                EffectBrowserSheet(isPresented: $showEffectBrowser)
            }
        }
    }
}

public struct EffectRow: View {
    let effect: Effect
    @ObservedObject var viewModel: InspectorViewModel
    @State private var isExpanded = false
    
    public var body: some View {
        DisclosureGroup(effect.name, isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(effect.parameters.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                    HStack {
                        Text(key.capitalized)
                            .frame(width: 80, alignment: .leading)
                        Slider(value: Binding(
                            get: { value },
                            set: { newValue in
                                viewModel.updateEffectParameter(key: key, value: newValue)
                            }
                        ), in: 0...1)
                        Text(String(format: "%.2f", value))
                            .font(.caption.monospacedDigit())
                            .frame(width: 40)
                    }
                }
                
                HStack {
                    Button("Reset") { }
                        .buttonStyle(.borderless)
                    Spacer()
                    Button("Remove") { }
                        .buttonStyle(.borderless)
                        .foregroundColor(.red)
                }
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 4)
    }
}

public struct EffectBrowserSheet: View {
    @Binding var isPresented: Bool
    
    public var body: some View {
        VStack {
            Text("Effect Browser")
                .font(.headline)
            
            List(EffectType.allCases, id: \.self) { type in
                Button(type.rawValue) {
                    isPresented = false
                }
            }
            
            Button("Cancel") {
                isPresented = false
            }
        }
        .frame(width: 300, height: 400)
        .padding()
    }
}

// MARK: - Transitions Panel

public struct TransitionsPanel: View {
    @ObservedObject public var viewModel: InspectorViewModel
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Transitions")
            
            if let clip = viewModel.selectedClip {
                ForEach(clip.transitions) { transition in
                    TransitionRow(transition: transition)
                }
                
                if clip.transitions.isEmpty {
                    EmptyStateView(message: "No transitions applied")
                }
                
                Button("Add Transition") { }
                    .buttonStyle(.borderedProminent)
            } else {
                EmptyStateView(message: "Select a clip to add transitions")
            }
        }
    }
}

public struct TransitionRow: View {
    let transition: Transition
    
    public var body: some View {
        HStack {
            Image(systemName: "arrow.right.arrow.left")
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(transition.name)
                    .font(.subheadline)
                Text(transition.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(String(format: "%.1fs", transition.duration))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(4)
    }
}

// MARK: - Info Panel

public struct InfoPanel: View {
    @ObservedObject public var viewModel: InspectorViewModel
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let clip = viewModel.selectedClip {
                SectionHeader(title: "File Information")
                
                PropertyGroup {
                    InfoRow(label: "Name", value: clip.filePath.components(separatedBy: "/").last ?? "Unknown")
                    InfoRow(label: "Path", value: clip.filePath)
                    InfoRow(label: "Duration", value: viewModel.formattedDuration)
                    
                    if let resolution = clip.resolution {
                        InfoRow(label: "Resolution", value: "\(Int(resolution.width))x\(Int(resolution.height))")
                    }
                    
                    if let frameRate = clip.frameRate {
                        InfoRow(label: "Frame Rate", value: "\(String(format: "%.2f", frameRate)) fps")
                    }
                }
                
                SectionHeader(title: "Clip Properties")
                
                PropertyGroup {
                    InfoRow(label: "In Point", value: String(format: "%.2fs", clip.startTime))
                    InfoRow(label: "Out Point", value: String(format: "%.2fs", clip.endTime))
                    InfoRow(label: "Enabled", value: clip.isEnabled ? "Yes" : "No")
                    InfoRow(label: "Effects", value: "\(clip.effects.count)")
                    InfoRow(label: "Transitions", value: "\(clip.transitions.count)")
                }
            } else {
                EmptyStateView(message: "Select a clip to view information")
            }
        }
    }
}

public struct InfoRow: View {
    let label: String
    let value: String
    
    public var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundColor(.gray)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .lineLimit(2)
                .truncationMode(.middle)
            Spacer()
        }
        .font(.caption)
    }
}

// MARK: - Export Panel

public struct ExportPanel: View {
    @ObservedObject public var viewModel: InspectorViewModel
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Export Settings")
            
            PropertyGroup {
                PickerRow(label: "Format", selection: $viewModel.selectedExportSettings.format)
                
                PickerRow(label: "Quality", selection: $viewModel.selectedExportSettings.quality)
                
                PickerRow(label: "Codec", selection: $viewModel.selectedExportSettings.codec)
                
                Toggle("Include Audio", isOn: $viewModel.selectedExportSettings.includeAudio)
                
                if viewModel.selectedExportSettings.includeAudio {
                    SliderProperty(
                        label: "Audio Bitrate",
                        value: .constant(Double(viewModel.selectedExportSettings.audioBitrate) / 1000),
                        range: 64...320,
                        unit: "kbps"
                    )
                }
                
                SliderProperty(
                    label: "Video Bitrate",
                    value: .constant(Double(viewModel.selectedExportSettings.videoBitrate) / 1_000_000),
                    range: 1...50,
                    unit: "Mbps"
                )
            }
            
            SectionHeader(title: "Destination")
            
            PropertyGroup {
                HStack {
                    Text("Output Folder")
                        .frame(width: 90, alignment: .leading)
                    Text("~/Movies/Exports")
                        .foregroundColor(.gray)
                    Spacer()
                    Button("Choose...") { }
                        .buttonStyle(.borderless)
                }
                
                HStack {
                    Text("Filename")
                        .frame(width: 90, alignment: .leading)
                    TextField("", text: .constant("Export_001"))
                        .textFieldStyle(.roundedBorder)
                }
            }
            
            Spacer()
            
            HStack {
                Button("Save Preset") { }
                    .buttonStyle(.borderless)
                Spacer()
                Button("Export") { }
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

// MARK: - Helper Views

public struct SectionHeader: View {
    let title: String
    
    public var body: some View {
        Text(title.uppercased())
            .font(.caption.bold())
            .foregroundColor(.gray)
    }
}

public struct PropertyGroup<Content: View>: View {
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
    }
}

public struct SliderProperty: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var unit: String = ""
    var step: Double.Stride? = nil
    
    public var body: some View {
        HStack {
            Text(label)
                .frame(width: 80, alignment: .leading)
            
            Slider(value: $value, in: range)
            
            Text("\(Int(value))\(unit)")
                .font(.caption.monospacedDigit())
                .frame(width: 50, alignment: .trailing)
        }
    }
}

public struct EmptyStateView: View {
    let message: String
    
    public var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(.gray)
            Text(message)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(6)
    }
}

public struct PickerRow<T: RawRepresentable & CaseIterable & Hashable>: View where T.RawValue == String {
    let label: String
    @Binding var selection: T
    
    public var body: some View {
        HStack {
            Text(label)
                .frame(width: 90, alignment: .leading)
            
            Picker("", selection: $selection) {
                ForEach(Array(T.allCases), id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

// MARK: - Preview

#Preview {
    Inspector()
        .frame(width: 320, height: 600)
}
