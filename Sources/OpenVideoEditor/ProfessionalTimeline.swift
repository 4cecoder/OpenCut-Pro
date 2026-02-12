import SwiftUI
import OpenVideoCore

// MARK: - Professional Timeline (DaVinci Resolve + Final Cut Pro style)

struct ProfessionalTimeline: View {
    @EnvironmentObject var appState: AppState
    @State private var zoom: Double = 1.0
    @State private var playheadPosition: CGFloat = 300
    @State private var isDraggingPlayhead = false
    @State private var timelineHeight: CGFloat = 400
    @State private var selectedTrack: Int? = nil
    @State private var isPlaying = false
    @State private var loopPlayback = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Timeline Toolbar
            TimelineToolbar(
                zoom: $zoom,
                isPlaying: $isPlaying,
                loopPlayback: $loopPlayback,
                selectedTool: $appState.selectedTool
            )
            .frame(height: 44)
            
            // Timeline Content
            HStack(spacing: 0) {
                // Track Headers
                TrackHeaderPanel(selectedTrack: $selectedTrack)
                    .frame(width: 120)
                
                // Timeline Tracks with Playhead
                ZStack {
                    // Background
                    Color(.sRGB, red: 0.04, green: 0.04, blue: 0.04)
                    
                    ScrollView(.horizontal, showsIndicators: true) {
                        ZStack(alignment: .topLeading) {
                            // Timeline Ruler
                            TimelineRuler2(zoom: zoom)
                                .frame(height: 28)
                                .position(x: 2000, y: 14)
                            
                            // Tracks Container
                            VStack(spacing: 2) {
                                // Video Tracks Section
                                VStack(spacing: 0) {
                                    Text("VIDEO")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 8)
                                        .padding(.vertical, 2)
                                    
                                    ForEach(0..<4) { index in
                                        VideoTrack(
                                            trackNumber: index + 1,
                                            isSelected: selectedTrack == index,
                                            zoom: zoom
                                        )
                                        .frame(height: 62)
                                        .onTapGesture {
                                            selectedTrack = index
                                        }
                                    }
                                }
                                
                                // Audio Tracks Section
                                VStack(spacing: 0) {
                                    Text("AUDIO")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 8)
                                        .padding(.vertical, 2)
                                    
                                    ForEach(0..<4) { index in
                                        AudioTrack(
                                            trackNumber: index + 1,
                                            isSelected: selectedTrack == index + 4,
                                            zoom: zoom
                                        )
                                        .frame(height: 52)
                                        .onTapGesture {
                                            selectedTrack = index + 4
                                        }
                                    }
                                }
                            }
                            .position(x: 2000, y: 210)
                            
                            // Playhead
                            Playhead2(position: playheadPosition)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            playheadPosition = max(120, value.location.x)
                                        }
                                )
                        }
                        .frame(width: 4000, height: timelineHeight)
                    }
                }
            }
            
            // Bottom Transport Bar
            TimelineTransportBar(
                isPlaying: $isPlaying,
                loopPlayback: $loopPlayback,
                currentTime: $playheadPosition
            )
            .frame(height: 42)
        }
        .background(Color(.sRGB, red: 0.08, green: 0.08, blue: 0.08))
        .foregroundColor(.white)
    }
}

struct TimelineToolbar: View {
    @Binding var zoom: Double
    @Binding var isPlaying: Bool
    @Binding var loopPlayback: Bool
    @Binding var selectedTool: EditingTool
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 12) {
            // Tools Palette (DaVinci Resolve style)
            HStack(spacing: 2) {
                ForEach(EditingTool.allCases, id: \.self) { tool in
                    ToolButton2(
                        tool: tool,
                        isSelected: selectedTool == tool
                    ) {
                        selectedTool = tool
                    }
                }
            }
            
            Divider()
                .frame(height: 24)
            
            // Edit Buttons
            HStack(spacing: 8) {
                TimelineActionButton(icon: "arrow.uturn.backward", tooltip: "Undo") { }
                TimelineActionButton(icon: "arrow.uturn.forward", tooltip: "Redo") { }
                
                Divider()
                    .frame(height: 20)
                
                TimelineActionButton(icon: "scissors", tooltip: "Split (⌘B)") { }
                TimelineActionButton(icon: "link", tooltip: "Join (⌘J)") { }
                TimelineActionButton(icon: "rectangle.stack", tooltip: "Compound") { }
            }
            
            Spacer()
            
            // Time Display (Center)
            HStack(spacing: 2) {
                TimecodeDigit(value: 1)
                Text(":")
                    .foregroundColor(.gray)
                TimecodeDigit(value: 23)
                Text(":")
                    .foregroundColor(.gray)
                TimecodeDigit(value: 45, highlight: true)
                Text(":")
                    .foregroundColor(.gray)
                TimecodeDigit(value: 12)
            }
            
            Spacer()
            
            // Right Controls
            HStack(spacing: 10) {
                // Magnetic snapping
                ToggleButton(
                    icon: "magnet",
                    isActive: appState.magneticSnapping,
                    tooltip: "Magnetic Snapping (N)"
                ) {
                    appState.magneticSnapping.toggle()
                }
                
                // Waveforms
                ToggleButton(
                    icon: "waveform",
                    isActive: appState.showAudioWaveforms,
                    tooltip: "Audio Waveforms"
                ) {
                    appState.showAudioWaveforms.toggle()
                }
                
                // Thumbnails
                ToggleButton(
                    icon: "photo",
                    isActive: appState.showVideoThumbnails,
                    tooltip: "Video Thumbnails"
                ) {
                    appState.showVideoThumbnails.toggle()
                }
                
                Divider()
                    .frame(height: 20)
                
                // Zoom Controls
                HStack(spacing: 4) {
                    Button(action: { zoom = max(0.1, zoom - 0.1) }) {
                        Image(systemName: "minus.magnifyingglass")
                            .font(.system(size: 11))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Slider(value: $zoom, in: 0.1...5.0)
                        .frame(width: 80)
                    
                    Button(action: { zoom = min(5.0, zoom + 0.1) }) {
                        Image(systemName: "plus.magnifyingglass")
                            .font(.system(size: 11))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.sRGB, red: 0.10, green: 0.10, blue: 0.10))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.black.opacity(0.5)),
            alignment: .bottom
        )
    }
}

struct ToolButton2: View {
    let tool: EditingTool
    let isSelected: Bool
    let action: () -> Void
    
    var icon: String {
        switch tool {
        case .select: return "arrow.left.arrow.right"
        case .blade: return "scissors"
        case .razor: return "xmark"
        case .trim: return "arrow.up.left.and.arrow.down.right"
        case .slip: return "arrow.left.and.right"
        case .slide: return "arrow.left.and.right.square"
        case .roll: return "arrow.left.arrow.right.circle"
        case .range: return "line.3.horizontal"
        }
    }
    
    var shortcut: String {
        switch tool {
        case .select: return "A"
        case .blade: return "B"
        case .razor: return "R"
        case .trim: return "T"
        case .slip: return "Y"
        case .slide: return "U"
        case .roll: return "N"
        case .range: return "⌘R"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 1) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(shortcut)
                    .font(.system(size: 8))
            }
            .frame(width: 34, height: 34)
            .background(isSelected ? Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21) : Color.clear)
            .foregroundColor(isSelected ? .black : .gray)
            .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())
        .help("\(tool.rawValue) (\(shortcut))")
    }
}

struct TimelineActionButton: View {
    let icon: String
    let tooltip: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .frame(width: 26, height: 26)
                .foregroundColor(.gray)
        }
        .buttonStyle(PlainButtonStyle())
        .help(tooltip)
    }
}

struct ToggleButton: View {
    let icon: String
    let isActive: Bool
    let tooltip: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .frame(width: 26, height: 26)
                .background(isActive ? Color(.sRGB, red: 0.16, green: 0.16, blue: 0.16) : Color.clear)
                .foregroundColor(isActive ? Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21) : .gray)
                .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())
        .help(tooltip)
    }
}

struct TimecodeDigit: View {
    let value: Int
    var highlight: Bool = false
    
    var body: some View {
        Text(String(format: "%02d", value))
            .font(.system(size: 20, weight: .medium, design: .monospaced))
            .foregroundColor(highlight ? Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21) : .white)
    }
}

// MARK: - Track Header Panel

struct TrackHeaderPanel: View {
    @Binding var selectedTrack: Int?
    
    var body: some View {
        VStack(spacing: 0) {
            // Video Track Headers
            VStack(spacing: 0) {
                Text("V-TRACKS")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
                    .padding(.vertical, 4)
                
                ForEach(0..<4) { index in
                    TrackHeader2(
                        label: "V\(index + 1)",
                        type: .video,
                        isSelected: selectedTrack == index
                    )
                    .frame(height: 62)
                }
            }
            
            // Audio Track Headers
            VStack(spacing: 0) {
                Text("A-TRACKS")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
                    .padding(.vertical, 4)
                
                ForEach(0..<4) { index in
                    TrackHeader2(
                        label: "A\(index + 1)",
                        type: .audio,
                        isSelected: selectedTrack == index + 4
                    )
                    .frame(height: 52)
                }
            }
        }
        .background(Color(.sRGB, red: 0.10, green: 0.10, blue: 0.10))
    }
}

enum TrackType {
    case video, audio
}

struct TrackHeader2: View {
    let label: String
    let type: TrackType
    let isSelected: Bool
    @State private var isEnabled = true
    @State private var isLocked = false
    @State private var volume: Double = 0.0
    
    var body: some View {
        HStack(spacing: 6) {
            // Track Number
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .frame(width: 28)
                .foregroundColor(isSelected ? Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21) : .white)
            
            // Enable Toggle
            Button(action: { isEnabled.toggle() }) {
                Image(systemName: type == .video ? (isEnabled ? "eye.fill" : "eye.slash") : (isEnabled ? "speaker.wave.2.fill" : "speaker.slash"))
                    .font(.system(size: 10))
                    .foregroundColor(isEnabled ? (type == .video ? Color(.sRGB, red: 0.29, green: 0.62, blue: 1.0) : Color(.sRGB, red: 0.29, green: 0.62, blue: 1.0)) : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Lock Toggle
            Button(action: { isLocked.toggle() }) {
                Image(systemName: isLocked ? "lock.fill" : "lock.open")
                    .font(.system(size: 10))
                    .foregroundColor(isLocked ? Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21) : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Audio Fader (only for audio tracks)
            if type == .audio {
                Slider(value: $volume, in: -60...12)
                    .frame(width: 40)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 20, height: 40)
            }
        }
        .padding(.horizontal, 6)
        .background(isSelected ? Color(.sRGB, red: 0.16, green: 0.16, blue: 0.16) : Color(.sRGB, red: 0.12, green: 0.12, blue: 0.12))
        .border(Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21).opacity(isSelected ? 0.5 : 0), width: 1)
    }
}

// MARK: - Video Track

struct VideoTrack: View {
    let trackNumber: Int
    let isSelected: Bool
    let zoom: Double
    
    var body: some View {
        ZStack {
            // Track background
            Rectangle()
                .fill(trackNumber % 2 == 0 ? Color(.sRGB, red: 0.08, green: 0.08, blue: 0.08) : Color(.sRGB, red: 0.09, green: 0.09, blue: 0.09))
            
            // Sample clips
            HStack(spacing: 0) {
                if trackNumber == 1 {
                    ProfessionalClip(
                        name: "INTRO_SCENE",
                        duration: 180,
                        type: .video,
                        color: Color(.sRGB, red: 0.36, green: 0.54, blue: 0.29),
                        hasEffects: true,
                        zoom: zoom
                    )
                    .offset(x: 100)
                    
                    GapView(width: 20)
                    
                    ProfessionalClip(
                        name: "MAIN_CONTENT",
                        duration: 450,
                        type: .video,
                        color: Color(.sRGB, red: 0.36, green: 0.54, blue: 0.29),
                        hasEffects: false,
                        zoom: zoom
                    )
                    .offset(x: 300)
                    
                    GapView(width: 10)
                    
                    ProfessionalClip(
                        name: "BROLL_CITY",
                        duration: 120,
                        type: .video,
                        color: Color(.sRGB, red: 0.54, green: 0.42, blue: 0.29),
                        hasEffects: true,
                        zoom: zoom
                    )
                    .offset(x: 760)
                } else if trackNumber == 2 {
                    ProfessionalClip(
                        name: "GRAPHICS_LOWER3",
                        duration: 300,
                        type: .video,
                        color: Color(.sRGB, red: 0.29, green: 0.48, blue: 0.62),
                        hasEffects: true,
                        isTransparent: true,
                        zoom: zoom
                    )
                    .offset(x: 400)
                } else if trackNumber == 3 {
                    ProfessionalClip(
                        name: "TITLE_CARD",
                        duration: 150,
                        type: .video,
                        color: Color(.sRGB, red: 0.62, green: 0.29, blue: 0.48),
                        hasEffects: true,
                        zoom: zoom
                    )
                    .offset(x: 100)
                }
            }
        }
    }
}

// MARK: - Audio Track

struct AudioTrack: View {
    let trackNumber: Int
    let isSelected: Bool
    let zoom: Double
    
    var body: some View {
        ZStack {
            // Track background
            Rectangle()
                .fill(trackNumber % 2 == 0 ? Color(.sRGB, red: 0.08, green: 0.08, blue: 0.08) : Color(.sRGB, red: 0.09, green: 0.09, blue: 0.09))
            
            if trackNumber == 1 {
                // Main audio with waveform
                AudioClipWaveform(
                    name: "DIALOGUE_TRACK_1",
                    duration: 600,
                    zoom: zoom
                )
                .offset(x: 100)
            } else if trackNumber == 2 {
                // Music
                AudioClipWaveform(
                    name: "BACKGROUND_MUSIC",
                    duration: 600,
                    zoom: zoom,
                    isMusic: true
                )
                .offset(x: 100)
            }
        }
    }
}

struct ProfessionalClip: View {
    let name: String
    let duration: CGFloat
    let type: ClipType
    let color: Color
    let hasEffects: Bool
    var isTransparent: Bool = false
    let zoom: Double
    @State private var isSelected = false
    @State private var isHovered = false
    
    enum ClipType {
        case video, audio
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Clip body
            RoundedRectangle(cornerRadius: 3)
                .fill(isTransparent ? color.opacity(0.3) : color)
                .frame(width: duration * zoom, height: type == .video ? 56 : 46)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
                )
                .overlay(
                    // Clip name at top
                    HStack {
                        Text(name)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(2)
                        Spacer()
                    }
                    .padding(.top, 3)
                    .padding(.leading, 3),
                    alignment: .topLeading
                )
            
            // Thumbnail strips (for video)
            if type == .video {
                HStack(spacing: 2) {
                    ForEach(0..<Int((duration * zoom) / 40), id: \.self) { _ in
                        Rectangle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 38, height: 32)
                            .cornerRadius(1)
                    }
                }
                .padding(.top, 20)
                .padding(.leading, 4)
            }
            
            // Effects badge
            if hasEffects {
                HStack {
                    Spacer()
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 10))
                        .foregroundColor(Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21))
                        .padding(4)
                }
            }
            
            // Transition indicators
            HStack(spacing: 0) {
                // Left transition handle
                Triangle2()
                    .fill(Color.white)
                    .frame(width: 8, height: 12)
                    .rotationEffect(.degrees(-90))
                
                Spacer()
                
                // Right transition handle
                Triangle2()
                    .fill(Color.white)
                    .frame(width: 8, height: 12)
                    .rotationEffect(.degrees(90))
            }
            .padding(.horizontal, 2)
        }
        .frame(width: duration * zoom, height: type == .video ? 58 : 48)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            isSelected.toggle()
        }
    }
}

struct AudioClipWaveform: View {
    let name: String
    let duration: CGFloat
    let zoom: Double
    var isMusic: Bool = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background
            RoundedRectangle(cornerRadius: 3)
                .fill(isMusic ? Color(.sRGB, red: 0.29, green: 0.36, blue: 0.54) : Color(.sRGB, red: 0.29, green: 0.54, blue: 0.36))
                .frame(width: duration * zoom, height: 44)
            
            // Waveform visualization
            HStack(spacing: 1) {
                ForEach(0..<Int((duration * zoom) / 3), id: \.self) { _ in
                    let height = CGFloat.random(in: 5...40)
                    Rectangle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 2, height: height)
                }
            }
            .padding(.horizontal, 4)
            
            // Label
            HStack {
                Text(name)
                    .font(.system(size: 9))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(2)
                Spacer()
            }
            .padding(.top, 2)
            .padding(.leading, 4)
        }
        .frame(width: duration * zoom, height: 46)
    }
}

struct GapView: View {
    let width: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: width)
    }
}

struct Triangle2: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Timeline Ruler

struct TimelineRuler2: View {
    let zoom: Double
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<200) { second in
                VStack(spacing: 2) {
                    Rectangle()
                        .fill(
                            second % 60 == 0 ? Color.white.opacity(0.7) :
                            second % 10 == 0 ? Color.gray.opacity(0.5) :
                            Color.gray.opacity(0.2)
                        )
                        .frame(
                            width: 1,
                            height: second % 60 == 0 ? 14 : (second % 10 == 0 ? 10 : 6)
                        )
                    
                    if second % 10 == 0 {
                        Text(timeString(for: second))
                            .font(.system(size: 9))
                            .foregroundColor(second % 60 == 0 ? .white : .gray)
                    }
                }
                .frame(width: 20 * zoom)
            }
        }
    }
    
    func timeString(for seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        if mins > 0 {
            return "\(mins):\(String(format: "%02d", secs))"
        }
        return "\(secs)"
    }
}

// MARK: - Playhead

struct Playhead2: View {
    let position: CGFloat
    
    var body: some View {
        ZStack {
            // Vertical line
            Rectangle()
                .fill(Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21))
                .frame(width: 2)
                .frame(maxHeight: .infinity)
            
            // Top triangle marker
            Triangle2()
                .fill(Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21))
                .frame(width: 14, height: 10)
                .position(x: 1, y: 5)
        }
        .position(x: position)
    }
}

// MARK: - Timeline Transport Bar

struct TimelineTransportBar: View {
    @Binding var isPlaying: Bool
    @Binding var loopPlayback: Bool
    @Binding var currentTime: CGFloat
    
    var body: some View {
        HStack(spacing: 20) {
            // Left: Transport Controls
            HStack(spacing: 10) {
                Button(action: { }) {
                    Image(systemName: "backward.end.fill")
                        .font(.system(size: 14))
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { }) {
                    Image(systemName: "backward.frame.fill")
                        .font(.system(size: 18))
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { isPlaying.toggle() }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21))
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { }) {
                    Image(systemName: "forward.frame.fill")
                        .font(.system(size: 18))
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { }) {
                    Image(systemName: "forward.end.fill")
                        .font(.system(size: 14))
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Center: Timecode
            HStack(spacing: 2) {
                ForEach([1, 23, 45, 12], id: \.self) { value in
                    Text(String(format: "%02d", value))
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    if value != 12 {
                        Text(":")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Right: Additional Controls
            HStack(spacing: 12) {
                ToggleButton2(icon: "repeat", isActive: loopPlayback) {
                    loopPlayback.toggle()
                }
                
                ToggleButton2(icon: "arrow.left.arrow.right", isActive: false) {
                }
                
                Divider()
                    .frame(height: 20)
                
                Button(action: { }) {
                    Image(systemName: "rectangle.inset.filled")
                        .font(.system(size: 14))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(Color(.sRGB, red: 0.10, green: 0.10, blue: 0.10))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.black.opacity(0.5)),
            alignment: .top
        )
    }
}

struct ToggleButton2: View {
    let icon: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .frame(width: 24, height: 24)
                .foregroundColor(isActive ? Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21) : .gray)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
