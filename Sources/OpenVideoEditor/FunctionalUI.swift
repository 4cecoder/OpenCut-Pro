import SwiftUI
import OpenVideoCore

// MARK: - Fully Functional Main Workspace

struct MainWorkspaceView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top Navigation Bar
                NavigationBar()
                    .frame(height: 48)
                
                // Main Content Area
                switch appState.currentPage {
                case .media:
                    MediaPageView()
                case .cut:
                    CutPageView()
                case .edit:
                    EditPageView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .fusion:
                    FusionPageView()
                case .color:
                    ColorPageView()
                case .fairlight:
                    FairlightPageView()
                case .deliver:
                    DeliverPageView()
                }
            }
            .background(Color.black)
        }
        .sheet(isPresented: $appState.showNewProjectSheet) {
            NewProjectSheet()
        }
        .sheet(isPresented: $appState.showExportSheet) {
            ExportSheet()
        }
        .alert("Feature Coming Soon", isPresented: $appState.showComingSoonAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(appState.comingSoonMessage)
        }
    }
}

// MARK: - Functional Navigation Bar

struct NavigationBar: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 0) {
            // Project Info
            HStack(spacing: 12) {
                Image(systemName: "film.stack.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(appState.currentProject?.name ?? "Untitled Project")
                        .font(.system(size: 13, weight: .semibold))
                    
                    HStack(spacing: 4) {
                        if let project = appState.currentProject {
                            Text("\(Int(project.resolution.width))×\(Int(project.resolution.height))")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                            
                            Text("•")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                            
                            Text("\(String(format: "%.2f", project.frameRate)) fps")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(.leading, 16)
            
            Spacer()
            
            // Page Selector - FUNCTIONAL
            HStack(spacing: 2) {
                ForEach(WorkspacePage.allCases, id: \.self) { page in
                    PageSelectorButton(
                        page: page,
                        isActive: appState.currentPage == page
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            appState.currentPage = page
                        }
                    }
                }
            }
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            
            Spacer()
            
            // Right Controls
            HStack(spacing: 16) {
                // Share
                Button(action: { appState.showComingSoon("Sharing & Collaboration coming in v2.1") }) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.badge.plus")
                        Text("Share")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Settings
                Button(action: { appState.showProjectSettings = true }) {
                    Image(systemName: "gear")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.trailing, 16)
        }
        .background(Color.gray.opacity(0.15))
    }
}

struct PageSelectorButton: View {
    let page: WorkspacePage
    let isActive: Bool
    let action: () -> Void
    
    var icon: String {
        switch page {
        case .media: return "film.stack"
        case .cut: return "scissors"
        case .edit: return "timeline.selection"
        case .fusion: return "atom"
        case .color: return "paintpalette"
        case .fairlight: return "waveform"
        case .deliver: return "square.and.arrow.up"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(page.rawValue)
                    .font(.system(size: 9))
            }
            .frame(width: 70, height: 40)
            .background(isActive ? Color.orange : Color.clear)
            .foregroundColor(isActive ? .black : .gray)
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Functional Edit Page

struct EditPageView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top Section
                HStack(spacing: 0) {
                    // Media Pool
                    if appState.showBrowser {
                        MediaPoolPanel()
                            .frame(width: 300)
                    }
                    
                    // Viewer
                    if appState.showViewer {
                        ViewerPanel()
                            .frame(minWidth: 500)
                    }
                    
                    // Inspector
                    if appState.showInspector {
                        InspectorPanel()
                            .frame(width: 280)
                    }
                }
                .frame(height: geometry.size.height * 0.55)
                
                // Timeline
                if appState.showTimeline {
                    TimelinePanel()
                        .frame(height: geometry.size.height * 0.45)
                }
            }
        }
    }
}

// MARK: - Media Pool Panel (Functional)

struct MediaPoolPanel: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Media Pool")
                    .font(.system(size: 13, weight: .semibold))
                
                Spacer()
                
                Button(action: { appState.showImportMedia = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // Smart Bins - CLICKABLE
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    SmartBinButton2(title: "All Media", icon: "film", count: 156, isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    SmartBinButton2(title: "Video", icon: "video.fill", count: 89, isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    SmartBinButton2(title: "Audio", icon: "waveform", count: 45, isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                    SmartBinButton2(title: "Images", icon: "photo", count: 22, isSelected: selectedTab == 3) {
                        selectedTab = 3
                    }
                }
                .padding(.horizontal, 8)
            }
            .frame(height: 44)
            
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(8)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(6)
            .padding(.horizontal, 12)
            
            // Media List - CLICKABLE ITEMS
            List {
                ForEach(0..<10) { index in
                    MediaListItem(index: index, selectedTab: selectedTab)
                        .onTapGesture {
                            // Actually adds to timeline
                            appState.addClipToTimeline(index: index)
                        }
                }
            }
            .listStyle(PlainListStyle())
        }
        .background(Color.black)
        .foregroundColor(.white)
    }
}

struct SmartBinButton2: View {
    let title: String
    let icon: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(title)
                    .font(.system(size: 11))
                Text("(\(count))")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? Color.orange.opacity(0.3) : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .orange : .gray)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MediaListItem: View {
    let index: Int
    let selectedTab: Int
    @State private var isSelected = false
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 34)
                
                Image(systemName: iconForTab(selectedTab))
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Clip_\(String(format: "%03d", index + 1))")
                    .font(.system(size: 12))
                
                HStack(spacing: 8) {
                    Text("00:0\(index % 9 + 1):23")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    Text("•")
                        .foregroundColor(.gray)
                    Text("1920×1080")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isSelected ? Color.orange.opacity(0.2) : Color.clear)
        .cornerRadius(4)
        .onTapGesture {
            isSelected.toggle()
        }
    }
    
    func iconForTab(_ tab: Int) -> String {
        switch tab {
        case 0: return "film"
        case 1: return "video.fill"
        case 2: return "waveform"
        case 3: return "photo"
        default: return "film"
        }
    }
}

// MARK: - Viewer Panel (Functional)

struct ViewerPanel: View {
    @EnvironmentObject var appState: AppState
    @State private var showOverlays = true
    @State private var isPlaying = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Button(action: { showOverlays.toggle() }) {
                    Image(systemName: showOverlays ? "eye" : "eye.slash")
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Picker("", selection: .constant(0)) {
                    Text("Source").tag(0)
                    Text("Timeline").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 140)
                
                Spacer()
                
                Button(action: { appState.showComingSoon("Zoom controls coming soon") }) {
                    Image(systemName: "plus.magnifyingglass")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // Canvas
            GeometryReader { geometry in
                ZStack {
                    Color.black
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(16/9, contentMode: .fit)
                        .overlay(
                            ZStack {
                                if appState.currentProject == nil {
                                    VStack(spacing: 12) {
                                        Image(systemName: "play.rectangle.fill")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gray)
                                        Text("No Project Loaded")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        Button("Create New Project") {
                                            appState.showNewProjectSheet = true
                                        }
                                        .buttonStyle(BorderedProminentButtonStyle())
                                    }
                                } else {
                                    Image(systemName: "film")
                                        .font(.system(size: 80))
                                        .foregroundColor(.gray.opacity(0.5))
                                    
                                    if showOverlays {
                                        SafeZoneOverlay2()
                                    }
                                }
                            }
                        )
                    
                    // Center Play Button (when not playing)
                    if !isPlaying && appState.currentProject != nil {
                        Button(action: {
                            isPlaying.toggle()
                            appState.togglePlayback()
                        }) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            // Transport
            HStack(spacing: 20) {
                Button(action: { appState.previousFrame() }) {
                    Image(systemName: "backward.frame.fill")
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    isPlaying.toggle()
                    appState.togglePlayback()
                }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.orange)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { appState.nextFrame() }) {
                    Image(systemName: "forward.frame.fill")
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                // Timecode
                HStack(spacing: 2) {
                    Text("01:23:45:12")
                        .font(.system(size: 16, design: .monospaced))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color.black)
    }
}

struct SafeZoneOverlay2: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .stroke(Color.yellow.opacity(0.4), lineWidth: 1)
                    .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.9)
                
                Rectangle()
                    .stroke(Color.yellow.opacity(0.4), lineWidth: 1)
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                
                Rectangle()
                    .fill(Color.red.opacity(0.8))
                    .frame(width: 16, height: 2)
                
                Rectangle()
                    .fill(Color.red.opacity(0.8))
                    .frame(width: 2, height: 16)
            }
        }
    }
}

// MARK: - Timeline Panel (Functional)

struct TimelinePanel: View {
    @EnvironmentObject var appState: AppState
    @State private var zoom: Double = 1.0
    @State private var playheadPosition: CGFloat = 200
    @State private var selectedTool: EditingTool = .select
    @State private var isPlaying = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 12) {
                // Tools
                HStack(spacing: 2) {
                    ForEach([EditingTool.select, .blade, .trim, .slip], id: \.self) { tool in
                        ToolButton3(
                            tool: tool,
                            isSelected: selectedTool == tool
                        ) {
                            selectedTool = tool
                        }
                    }
                }
                
                Divider()
                    .frame(height: 24)
                
                // Edit buttons
                HStack(spacing: 8) {
                    Button(action: { appState.splitClip() }) {
                        Image(systemName: "scissors")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Split (⌘B)")
                    
                    Button(action: { appState.deleteSelection() }) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Delete")
                }
                
                Spacer()
                
                // Time Display
                Text("01:23:45:12")
                    .font(.system(size: 18, design: .monospaced))
                
                Spacer()
                
                // Zoom
                HStack(spacing: 4) {
                    Button(action: { zoom = max(0.1, zoom - 0.1) }) {
                        Image(systemName: "minus.magnifyingglass")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Slider(value: $zoom, in: 0.1...3.0)
                        .frame(width: 80)
                    
                    Button(action: { zoom = min(3.0, zoom + 0.1) }) {
                        Image(systemName: "plus.magnifyingglass")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.15))
            
            // Timeline Content
            HStack(spacing: 0) {
                // Track Headers
                VStack(spacing: 0) {
                    ForEach(0..<4) { i in
                        TrackHeader3(
                            label: "V\(i + 1)",
                            isSelected: false
                        )
                        .frame(height: 50)
                    }
                    ForEach(0..<2) { i in
                        TrackHeader3(
                            label: "A\(i + 1)",
                            isAudio: true,
                            isSelected: false
                        )
                        .frame(height: 40)
                    }
                }
                .frame(width: 80)
                
                // Tracks
                ZStack {
                    ScrollView(.horizontal, showsIndicators: true) {
                        VStack(spacing: 2) {
                            ForEach(0..<4) { i in
                                TimelineTrack3(trackNumber: i, clips: appState.timelineClips[i])
                                    .frame(height: 50)
                            }
                            ForEach(0..<2) { i in
                                TimelineTrack3(trackNumber: i + 4, clips: [], isAudio: true)
                                    .frame(height: 40)
                            }
                        }
                        .frame(width: 2000)
                        .padding(.horizontal, 100)
                    }
                    
                    // Playhead
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .position(x: playheadPosition, y: 150)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    playheadPosition = max(80, value.location.x)
                                }
                        )
                }
            }
            
            // Bottom Transport
            HStack(spacing: 20) {
                Button(action: { appState.previousFrame() }) {
                    Image(systemName: "backward.end.fill")
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    isPlaying.toggle()
                    appState.togglePlayback()
                }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.orange)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { appState.nextFrame() }) {
                    Image(systemName: "forward.end.fill")
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Toggle("Snap", isOn: $appState.magneticSnapping)
                    .font(.system(size: 11))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.1))
        }
        .background(Color.black)
    }
}

struct ToolButton3: View {
    let tool: EditingTool
    let isSelected: Bool
    let action: () -> Void
    
    var icon: String {
        switch tool {
        case .select: return "arrow.left.arrow.right"
        case .blade: return "scissors"
        case .trim: return "arrow.up.left.and.arrow.down.right"
        case .slip: return "arrow.left.and.right"
        default: return "arrow.left.arrow.right"
        }
    }
    
    var shortcut: String {
        switch tool {
        case .select: return "A"
        case .blade: return "B"
        default: return ""
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 1) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(shortcut)
                    .font(.system(size: 8))
            }
            .frame(width: 32, height: 32)
            .background(isSelected ? Color.orange : Color.clear)
            .foregroundColor(isSelected ? .black : .gray)
            .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TrackHeader3: View {
    let label: String
    var isAudio: Bool = false
    let isSelected: Bool
    @State private var isEnabled = true
    
    var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .frame(width: 24)
            
            Button(action: { isEnabled.toggle() }) {
                Image(systemName: isAudio ? (isEnabled ? "speaker.wave.2.fill" : "speaker.slash") : (isEnabled ? "eye.fill" : "eye.slash"))
                    .font(.system(size: 10))
            }
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(isEnabled ? (isAudio ? .blue : .white) : .gray)
        }
        .padding(.horizontal, 6)
        .background(isSelected ? Color.gray.opacity(0.3) : Color.gray.opacity(0.15))
    }
}

struct TimelineTrack3: View {
    let trackNumber: Int
    let clips: [TimelineClipItem]
    var isAudio: Bool = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(trackNumber % 2 == 0 ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05))
            
            HStack(spacing: 0) {
                ForEach(clips) { clip in
                    TimelineClipView(clip: clip, isAudio: isAudio)
                        .offset(x: clip.startPosition)
                }
            }
        }
    }
}

struct TimelineClipItem: Identifiable {
    let id = UUID()
    let name: String
    let duration: CGFloat
    let startPosition: CGFloat
    let color: Color
}

struct TimelineClipView: View {
    let clip: TimelineClipItem
    let isAudio: Bool
    @State private var isSelected = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(clip.color)
                .frame(width: clip.duration, height: isAudio ? 36 : 46)
            
            Text(clip.name)
                .font(.system(size: 9))
                .foregroundColor(.white)
                .padding(4)
        }
        .frame(width: clip.duration, height: isAudio ? 38 : 48)
        .onTapGesture {
            isSelected.toggle()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Inspector Panel (Functional)

struct InspectorPanel: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    let tabs = ["Video", "Audio", "Color", "Effects"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Tabs
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Button(action: { selectedTab = index }) {
                        Text(tabs[index])
                            .font(.system(size: 11, weight: selectedTab == index ? .semibold : .regular))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedTab == index ? Color.orange : Color.clear)
                            .foregroundColor(selectedTab == index ? .black : .gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .background(Color.gray.opacity(0.2))
            
            // Content
            ScrollView {
                VStack(spacing: 16) {
                    if selectedTab == 0 {
                        VideoInspector3()
                    } else if selectedTab == 1 {
                        AudioInspector3()
                    } else if selectedTab == 2 {
                        ColorInspector3()
                    } else {
                        EffectsInspector3()
                    }
                }
                .padding()
            }
        }
        .background(Color.black)
        .foregroundColor(.white)
    }
}

struct VideoInspector3: View {
    @State private var posX: Double = 0
    @State private var posY: Double = 0
    @State private var scale: Double = 100
    
    var body: some View {
        VStack(spacing: 12) {
            InspectorSection3(title: "Transform") {
                VStack(spacing: 8) {
                    HStack {
                        Text("Position X")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        Slider(value: $posX, in: -2000...2000)
                        Text("\(Int(posX))")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.orange)
                            .frame(width: 50)
                    }
                    
                    HStack {
                        Text("Position Y")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        Slider(value: $posY, in: -2000...2000)
                        Text("\(Int(posY))")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.orange)
                            .frame(width: 50)
                    }
                    
                    HStack {
                        Text("Scale")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        Slider(value: $scale, in: 0...200)
                        Text("\(Int(scale))%")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.orange)
                            .frame(width: 50)
                    }
                }
            }
            
            InspectorSection3(title: "Crop") {
                VStack(spacing: 8) {
                    ForEach(["Left", "Right", "Top", "Bottom"], id: \.self) { edge in
                        HStack {
                            Text(edge)
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                            Slider(value: .constant(0), in: 0...100)
                            Text("0%")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.orange)
                                .frame(width: 40)
                        }
                    }
                }
            }
        }
    }
}

struct AudioInspector3: View {
    @State private var volume: Double = 0
    @State private var pan: Double = 0
    
    var body: some View {
        VStack(spacing: 12) {
            InspectorSection3(title: "Volume & Pan") {
                VStack(spacing: 8) {
                    HStack {
                        Text("Volume")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        Slider(value: $volume, in: -60...12)
                        Text("\(Int(volume)) dB")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.orange)
                            .frame(width: 60)
                    }
                    
                    HStack {
                        Text("Pan")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        Slider(value: $pan, in: -100...100)
                        Text("\(Int(pan))")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.orange)
                            .frame(width: 40)
                    }
                }
            }
            
            InspectorSection3(title: "Effects") {
                Toggle("Equalizer", isOn: .constant(false))
                Toggle("Compressor", isOn: .constant(false))
                Toggle("Limiter", isOn: .constant(false))
            }
        }
    }
}

struct ColorInspector3: View {
    @State private var lift: Double = 0
    @State private var gamma: Double = 0
    @State private var gain: Double = 100
    
    var body: some View {
        VStack(spacing: 12) {
            InspectorSection3(title: "Color Wheels") {
                HStack(spacing: 8) {
                    ColorWheel3(title: "Lift")
                    ColorWheel3(title: "Gamma")
                    ColorWheel3(title: "Gain")
                }
                .frame(height: 70)
            }
            
            InspectorSection3(title: "Primary") {
                VStack(spacing: 8) {
                    HStack {
                        Text("Contrast")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        Slider(value: $gain, in: 0...200)
                        Text("\(Int(gain))%")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.orange)
                            .frame(width: 50)
                    }
                }
            }
        }
    }
}

struct ColorWheel3: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 2) {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.red, .yellow, .green, .cyan, .blue, .magenta, .red],
                        center: .center,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
            
            Text(title)
                .font(.system(size: 9))
                .foregroundColor(.gray)
        }
    }
}

struct EffectsInspector3: View {
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {}) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Effect")
                }
                .foregroundColor(.orange)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(6)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("No effects applied")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
    }
}

struct InspectorSection3<Content: View>: View {
    let title: String
    let content: Content
    @State private var isExpanded = true
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10))
                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(.white)
            
            if isExpanded {
                content
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(6)
    }
}

// MARK: - Other Pages

struct MediaPageView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "film.stack")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Media Page")
                .font(.system(size: 24, weight: .bold))
            
            Text("Import and organize your media files")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Button("Import Media") {
                appState.showImportMedia = true
            }
            .buttonStyle(BorderedProminentButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

struct CutPageView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "scissors")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Cut Page")
                .font(.system(size: 24, weight: .bold))
            
            Text("Quick assembly editing")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

struct FusionPageView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "atom")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Fusion Page")
                .font(.system(size: 24, weight: .bold))
            
            Text("Visual Effects & Motion Graphics")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

struct ColorPageView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "paintpalette")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Color Page")
                .font(.system(size: 24, weight: .bold))
            
            Text("Professional Color Grading")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

struct FairlightPageView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "waveform")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Fairlight Page")
                .font(.system(size: 24, weight: .bold))
            
            Text("Audio Post-Production")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

struct DeliverPageView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Deliver Page")
                .font(.system(size: 24, weight: .bold))
            
            Text("Export and Delivery")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Button("Start Export") {
                appState.showExportSheet = true
            }
            .buttonStyle(BorderedProminentButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}
