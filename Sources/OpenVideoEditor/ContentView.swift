import SwiftUI
import OpenVideoCore

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top Section: Browser + Viewer + Inspector
                HStack(spacing: 0) {
                    // Left: Media Browser
                    if appState.showBrowser {
                        BrowserPanel()
                            .frame(width: 300)
                            .transition(.move(edge: .leading))
                    }
                    
                    // Center: Viewer
                    if appState.showViewer {
                        ViewerPanel()
                            .frame(minWidth: 400)
                    }
                    
                    // Right: Inspector
                    if appState.showInspector {
                        InspectorPanel()
                            .frame(width: 280)
                            .transition(.move(edge: .trailing))
                    }
                }
                .frame(height: geometry.size.height * 0.6)
                
                // Divider
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // Bottom Section: Timeline
                if appState.showTimeline {
                    TimelinePanel()
                        .frame(height: geometry.size.height * 0.4)
                        .transition(.move(edge: .bottom))
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
    }
}

// MARK: - Browser Panel

struct BrowserPanel: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Picker("", selection: $selectedTab) {
                    Image(systemName: "photo.on.rectangle").tag(0)
                    Image(systemName: "music.note").tag(1)
                    Image(systemName: "text.quote").tag(2)
                    Image(systemName: "paintbrush").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 160)
                
                Spacer()
                
                Button(action: { }) {
                    Image(systemName: "plus")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black)
            
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(8)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(6)
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
            
            // Content
            List {
                Section(header: Text("Libraries").foregroundColor(.gray)) {
                    Label("All Media", systemImage: "film")
                    Label("Photos", systemImage: "photo")
                    Label("Music", systemImage: "music.note")
                }
                
                Section(header: Text("Projects").foregroundColor(.gray)) {
                    ForEach(0..<5) { i in
                        Label("Project \(i + 1)", systemImage: "folder")
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .background(Color.black)
        .foregroundColor(.white)
    }
}

// MARK: - Viewer Panel

struct ViewerPanel: View {
    @EnvironmentObject var appState: AppState
    @State private var showOverlays = true
    @State private var quality: Double = 100
    
    var body: some View {
        ZStack {
            // Video Canvas
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .aspectRatio(16/9, contentMode: .fit)
                .overlay(
                    ZStack {
                        // Placeholder for video
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        // Overlays
                        if showOverlays {
                            // Safe zones
                            Rectangle()
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                .frame(width: 100 * 0.9, height: 100 * 0.9)
                            
                            // Center crosshair
                            HStack {
                                Rectangle().frame(width: 20, height: 1)
                                Spacer()
                                Rectangle().frame(width: 20, height: 1)
                            }
                            VStack {
                                Rectangle().frame(width: 1, height: 20)
                                Spacer()
                                Rectangle().frame(width: 1, height: 20)
                            }
                        }
                    }
                )
            
            // Playback Controls Overlay
            VStack {
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: { }) {
                        Image(systemName: "backward.fill")
                            .font(.title2)
                    }
                    
                    Button(action: { appState.isPlaying.toggle() }) {
                        Image(systemName: appState.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 40))
                    }
                    
                    Button(action: { }) {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                    }
                }
                .foregroundColor(.white)
                .padding(.bottom, 40)
                
                // Timecode display
                Text(timecodeString(from: appState.currentTime))
                    .font(.system(size: 24, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
            }
        }
        .background(Color.black)
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button(action: { showOverlays.toggle() }) {
                    Image(systemName: showOverlays ? "eye" : "eye.slash")
                }
                
                Menu("Quality: \(Int(quality))%") {
                    Button("Draft (25%)") { quality = 25 }
                    Button("Medium (50%)") { quality = 50 }
                    Button("High (100%)") { quality = 100 }
                }
            }
        }
    }
    
    func timecodeString(from time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        let frames = Int((time.truncatingRemainder(dividingBy: 1)) * 30)
        return String(format: "%02d:%02d:%02d:%02d", hours, minutes, seconds, frames)
    }
}

// MARK: - Inspector Panel

struct InspectorPanel: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Tabs
            HStack(spacing: 0) {
                ForEach(["Video", "Audio", "Info"], id: \.self) { tab in
                    Button(tab) {
                        selectedTab = ["Video", "Audio", "Info"].firstIndex(of: tab) ?? 0
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(selectedTab == ["Video", "Audio", "Info"].firstIndex(of: tab) ? Color.gray.opacity(0.3) : Color.clear)
                }
            }
            .background(Color.gray.opacity(0.1))
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text("Transform")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Text("Position X")
                                .frame(width: 80, alignment: .leading)
                            Slider(value: .constant(0), in: -1000...1000)
                        }
                        
                        HStack {
                            Text("Position Y")
                                .frame(width: 80, alignment: .leading)
                            Slider(value: .constant(0), in: -1000...1000)
                        }
                        
                        HStack {
                            Text("Scale")
                                .frame(width: 80, alignment: .leading)
                            Slider(value: .constant(100), in: 0...200)
                            Text("%")
                        }
                        
                        HStack {
                            Text("Rotation")
                                .frame(width: 80, alignment: .leading)
                            Slider(value: .constant(0), in: -180...180)
                            Text("°")
                        }
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    Group {
                        Text("Crop")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Text("Left")
                                .frame(width: 80, alignment: .leading)
                            Slider(value: .constant(0), in: 0...100)
                        }
                        
                        HStack {
                            Text("Right")
                                .frame(width: 80, alignment: .leading)
                            Slider(value: .constant(0), in: 0...100)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .background(Color.black)
        .foregroundColor(.white)
    }
}

// MARK: - Timeline Panel

struct TimelinePanel: View {
    @EnvironmentObject var appState: AppState
    @State private var zoom: Double = 1.0
    @State private var playheadPosition: CGFloat = 100
    @State private var isDraggingPlayhead = false
    @State private var clips: [TimelineClip] = [
        TimelineClip(id: UUID(), name: "Clip 1", duration: 5.0, startTime: 0),
        TimelineClip(id: UUID(), name: "Clip 2", duration: 3.0, startTime: 5.0),
        TimelineClip(id: UUID(), name: "Clip 3", duration: 4.0, startTime: 8.0)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                // Tools
                HStack(spacing: 12) {
                    Button(action: { }) {
                        Image(systemName: "arrow.left.arrow.right")
                            .foregroundColor(.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Select Tool (A)")
                    
                    Button(action: { }) {
                        Image(systemName: "scissors")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Blade Tool (B)")
                    
                    Button(action: { }) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Trim Tool (T)")
                    
                    Divider()
                        .frame(height: 20)
                    
                    Button(action: { }) {
                        Image(systemName: "arrow.uturn.backward")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Undo")
                    
                    Button(action: { }) {
                        Image(systemName: "arrow.uturn.forward")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Redo")
                }
                
                Spacer()
                
                // Time Display
                Text("00:00:05:15")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Zoom
                HStack {
                    Image(systemName: "minus.magnifyingglass")
                        .foregroundColor(.gray)
                    Slider(value: $zoom, in: 0.1...5.0)
                        .frame(width: 100)
                    Image(systemName: "plus.magnifyingglass")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            
            // Timeline Content
            ScrollView(.horizontal, showsIndicators: true) {
                ZStack(alignment: .topLeading) {
                    // Time Ruler
                    HStack(spacing: 0) {
                        ForEach(0..<60) { second in
                            VStack(spacing: 2) {
                                Rectangle()
                                    .fill(Color.gray.opacity(second % 5 == 0 ? 0.5 : 0.2))
                                    .frame(width: 1, height: second % 5 == 0 ? 15 : 8)
                                
                                if second % 5 == 0 {
                                    Text("\(second)s")
                                        .font(.system(size: 9))
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(width: 50 * zoom)
                        }
                    }
                    .padding(.top, 4)
                    
                    // Track Headers
                    VStack(alignment: .leading, spacing: 0) {
                        // Video tracks
                        ForEach(0..<3) { i in
                            HStack {
                                Text("V\(i + 1)")
                                    .font(.system(size: 10, weight: .bold))
                                    .frame(width: 30)
                                    .foregroundColor(.white)
                                
                                Button(action: { }) {
                                    Image(systemName: "eye.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.green)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Spacer()
                            }
                            .frame(width: 80, height: 50)
                            .background(i % 2 == 0 ? Color.gray.opacity(0.15) : Color.gray.opacity(0.1))
                        }
                        
                        // Audio tracks
                        ForEach(0..<2) { i in
                            HStack {
                                Text("A\(i + 1)")
                                    .font(.system(size: 10, weight: .bold))
                                    .frame(width: 30)
                                    .foregroundColor(.white)
                                
                                Button(action: { }) {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Spacer()
                            }
                            .frame(width: 80, height: 40)
                            .background(i % 2 == 0 ? Color.gray.opacity(0.15) : Color.gray.opacity(0.1))
                        }
                    }
                    
                    // Clips Area
                    HStack(spacing: 0) {
                        Color.clear.frame(width: 80) // Spacer for track headers
                        
                        ZStack(alignment: .topLeading) {
                            // Background tracks
                            VStack(spacing: 0) {
                                ForEach(0..<3) { i in
                                    Rectangle()
                                        .fill(i % 2 == 0 ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05))
                                        .frame(height: 50)
                                }
                                ForEach(0..<2) { i in
                                    Rectangle()
                                        .fill(i % 2 == 0 ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05))
                                        .frame(height: 40)
                                }
                            }
                            
                            // Video Clips
                            ForEach(clips) { clip in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.blue.opacity(0.7))
                                    .frame(width: clip.duration * 50 * zoom, height: 44)
                                    .overlay(
                                        HStack {
                                            Text(clip.name)
                                                .font(.system(size: 11))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                            Spacer()
                                        }
                                    )
                                    .position(
                                        x: 80 + (clip.startTime * 50 * zoom) + (clip.duration * 50 * zoom / 2),
                                        y: 25
                                    )
                            }
                            
                            // Playhead
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: 2)
                                .frame(maxHeight: .infinity)
                                .position(x: 80 + playheadPosition, y: 110)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            playheadPosition = max(0, value.location.x - 80)
                                        }
                                )
                            
                            // Playhead triangle
                            Triangle()
                                .fill(Color.red)
                                .frame(width: 12, height: 8)
                                .position(x: 80 + playheadPosition, y: 4)
                        }
                        .frame(width: 3000, height: 230)
                    }
                }
                .frame(width: 3080, height: 240)
            }
            .background(Color.black)
        }
    }
}

struct TimelineClip: Identifiable {
    let id: UUID
    let name: String
    let duration: Double
    let startTime: Double
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Sheets

struct NewProjectSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    
    @State private var projectName = "New Project"
    @State private var width = "1920"
    @State private var height = "1080"
    @State private var frameRate = "30"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("New Project")
                .font(.title)
                .fontWeight(.bold)
            
            Form {
                TextField("Project Name:", text: $projectName)
                
                HStack {
                    Text("Resolution:")
                    TextField("Width", text: $width)
                        .frame(width: 80)
                    Text("×")
                    TextField("Height", text: $height)
                        .frame(width: 80)
                }
                
                HStack {
                    Text("Frame Rate:")
                    TextField("FPS", text: $frameRate)
                        .frame(width: 60)
                    Text("fps")
                }
            }
            .frame(width: 300)
            
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                
                Button("Create") {
                    let w = Double(width) ?? 1920
                    let h = Double(height) ?? 1080
                    let fps = Double(frameRate) ?? 30
                    appState.createNewProject(name: projectName, resolution: VideoSize(width: w, height: h), frameRate: fps)
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}

struct ExportSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Export Project")
                .font(.title)
                .fontWeight(.bold)
            
            if appState.isExporting {
                ProgressView(value: appState.exportProgress)
                    .frame(width: 300)
                Text("\(Int(appState.exportProgress * 100))%")
            } else {
                Text("Ready to export \(appState.currentProject?.name ?? "Project")")
                
                Button("Export") {
                    // Start export
                }
                .keyboardShortcut(.defaultAction)
            }
            
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding()
        .frame(width: 400, height: 200)
    }
}
