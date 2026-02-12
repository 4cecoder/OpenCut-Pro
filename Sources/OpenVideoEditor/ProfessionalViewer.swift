import SwiftUI
import OpenVideoCore

// MARK: - Professional Viewer with Scopes

struct ProfessionalViewer: View {
    @EnvironmentObject var appState: AppState
    @State private var showOverlays = true
    @State private var showSafeZones = true
    @State private var showRuleOfThirds = false
    @State private var showCenterCross = true
    @State private var showSurroundScope = false
    @State private var currentScope = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Viewer Toolbar
            HStack {
                // Left: Display Settings
                HStack(spacing: 10) {
                    Menu("Fit") {
                        Button("Fit") {}
                        Button("Fill") {}
                        Button("25%") {}
                        Button("50%") {}
                        Button("100%") {}
                        Button("200%") {}
                    }
                    .font(.system(size: 11))
                    
                    Divider()
                        .frame(height: 16)
                    
                    ToolbarToggle(icon: "eye", isActive: showOverlays) {
                        showOverlays.toggle()
                    }
                    
                    ToolbarToggle(icon: "shield", isActive: showSafeZones) {
                        showSafeZones.toggle()
                    }
                    
                    ToolbarToggle(icon: "grid", isActive: showRuleOfThirds) {
                        showRuleOfThirds.toggle()
                    }
                    
                    Menu("Overlays") {
                        Toggle("Safe Zones", isOn: $showSafeZones)
                        Toggle("Rule of Thirds", isOn: $showRuleOfThirds)
                        Toggle("Center Crosshair", isOn: $showCenterCross)
                        Toggle("Surround Scope", isOn: $showSurroundScope)
                        Toggle("Timecode Burn-in", isOn: .constant(true))
                    }
                }
                
                Spacer()
                
                // Center: Viewer Mode
                Picker("", selection: .constant(0)) {
                    Text("Source").tag(0)
                    Text("Timeline").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 140)
                
                Spacer()
                
                // Right: Scopes Toggle
                HStack(spacing: 8) {
                    Button(action: { appState.showScopes.toggle() }) {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 13))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(appState.showScopes ? Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21) : .gray)
                    .help("Toggle Scopes")
                    
                    Divider()
                        .frame(height: 16)
                    
                    Button(action: { }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 13))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.gray)
                    
                    Button(action: { }) {
                        Image(systemName: "rectangle.inset.filled")
                            .font(.system(size: 13))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.sRGB, red: 0.10, green: 0.10, blue: 0.10))
            
            // Main Viewer Area
            HStack(spacing: 0) {
                // Video Canvas
                GeometryReader { geometry in
                    ZStack {
                        // Background
                        Color.black
                        
                        // Video Placeholder with Letterboxing
                        Rectangle()
                            .fill(Color(.sRGB, red: 0.05, green: 0.05, blue: 0.05))
                            .aspectRatio(16/9, contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .overlay(
                                ZStack {
                                    // Video placeholder
                                    Image(systemName: "play.rectangle.on.rectangle.fill")
                                        .font(.system(size: 80))
                                        .foregroundColor(Color(.sRGB, red: 0.16, green: 0.16, blue: 0.16))
                                    
                                    // Overlays
                                    if showOverlays {
                                        if showSafeZones {
                                            SafeZoneOverlay()
                                        }
                                        
                                        if showRuleOfThirds {
                                            RuleOfThirdsOverlay()
                                        }
                                        
                                        if showCenterCross {
                                            CenterCrossOverlay()
                                        }
                                        
                                        // Timecode Burn-in
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                TimecodeBurnIn()
                                                    .padding(16)
                                            }
                                        }
                                    }
                                }
                            )
                        
                        // In/Out Points
                        if showOverlays {
                            InOutPoints()
                        }
                    }
                }
                
                // Scopes Panel (Collapsible)
                if appState.showScopes {
                    ProfessionalScopesPanel()
                        .frame(width: 260)
                        .transition(.move(edge: .trailing))
                }
            }
            
            // Bottom Transport Info
            HStack {
                // Current Time
                TimecodeDisplay(hours: 0, minutes: 1, seconds: 23, frames: 15)
                
                Spacer()
                
                // Clip Info
                HStack(spacing: 12) {
                    Label("Scene_001_Take3", systemImage: "film")
                        .font(.system(size: 11))
                    
                    Divider()
                        .frame(height: 20)
                    
                    Text("In: 00:00:00:00")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.gray)
                    
                    Text("Dur: 00:01:23:15")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Duration
                TimecodeDisplay(hours: 0, minutes: 1, seconds: 23, frames: 15, highlightFrames: false)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.sRGB, red: 0.10, green: 0.10, blue: 0.10))
        }
        .background(Color(.sRGB, red: 0.08, green: 0.08, blue: 0.08))
    }
}

struct ToolbarToggle: View {
    let icon: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .frame(width: 28, height: 28)
                .background(isActive ? Color(.sRGB, red: 0.16, green: 0.16, blue: 0.16) : Color.clear)
                .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(isActive ? Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21) : .gray)
    }
}

struct SafeZoneOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Action Safe (93%)
                Rectangle()
                    .stroke(Color.yellow.opacity(0.4), lineWidth: 1)
                    .frame(
                        width: geometry.size.width * 0.93,
                        height: geometry.size.height * 0.93
                    )
                
                // Title Safe (90%)
                Rectangle()
                    .stroke(Color.yellow.opacity(0.4), lineWidth: 1)
                    .frame(
                        width: geometry.size.width * 0.9,
                        height: geometry.size.height * 0.9
                    )
                
                // Labels
                VStack {
                    HStack {
                        Text("ACTION SAFE")
                            .font(.system(size: 8))
                            .foregroundColor(Color.yellow.opacity(0.5))
                        Spacer()
                    }
                    .padding(.leading, 8)
                    
                    Spacer()
                    
                    HStack {
                        Text("TITLE SAFE")
                            .font(.system(size: 8))
                            .foregroundColor(Color.yellow.opacity(0.5))
                        Spacer()
                    }
                    .padding(.leading, geometry.size.width * 0.05)
                }
                .padding(.vertical, 4)
            }
        }
    }
}

struct RuleOfThirdsOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Vertical lines
                HStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 1)
                    Spacer()
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 1)
                    Spacer()
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 1)
                }
                
                // Horizontal lines
                VStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 1)
                    Spacer()
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 1)
                    Spacer()
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 1)
                }
            }
        }
    }
}

struct CenterCrossOverlay: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.red.opacity(0.8))
                .frame(width: 20, height: 2)
            
            Rectangle()
                .fill(Color.red.opacity(0.8))
                .frame(width: 2, height: 20)
        }
    }
}

struct TimecodeBurnIn: View {
    var body: some View {
        HStack(spacing: 4) {
            Text("TC:")
                .font(.system(size: 12, weight: .medium))
            
            Text("01:23:45:12")
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.6))
        .cornerRadius(4)
    }
}

struct InOutPoints: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // In Point
                VStack {
                    Spacer()
                    HStack {
                        InOutMarker(label: "I", color: .green)
                        Spacer()
                    }
                    .padding(.leading, 20)
                    .padding(.bottom, 40)
                }
                
                // Out Point
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        InOutMarker(label: "O", color: .red)
                    }
                    .padding(.trailing, 40)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct InOutMarker: View {
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(color)
                .frame(width: 2, height: 30)
            
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
                .frame(width: 24, height: 24)
                .background(Color.black.opacity(0.5))
                .cornerRadius(12)
        }
    }
}

struct TimecodeDisplay: View {
    let hours: Int
    let minutes: Int
    let seconds: Int
    let frames: Int
    var highlightFrames: Bool = true
    
    var body: some View {
        HStack(spacing: 2) {
            TimeDigit(value: hours)
            Text(":")
                .foregroundColor(.gray)
            TimeDigit(value: minutes)
            Text(":")
                .foregroundColor(.gray)
            TimeDigit(value: seconds)
            Text(":")
                .foregroundColor(.gray)
            TimeDigit(value: frames, highlight: highlightFrames)
        }
    }
}

// MARK: - Professional Scopes Panel

struct ProfessionalScopesPanel: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedScope = 0
    @State private var show2xZoom = false
    
    let scopes = ["Waveform", "Vectorscope", "Histogram", "RGB Parade", "Luma Parade"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Scope Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(0..<scopes.count, id: \.self) { index in
                        Button(action: { selectedScope = index }) {
                            Text(scopes[index])
                                .font(.system(size: 10, weight: selectedScope == index ? .semibold : .regular))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(selectedScope == index ? Color(.sRGB, red: 0.16, green: 0.16, blue: 0.16) : Color.clear)
                                .foregroundColor(selectedScope == index ? Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21) : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .frame(height: 28)
            .background(Color(.sRGB, red: 0.10, green: 0.10, blue: 0.10))
            
            // Scope Display
            TabView(selection: $selectedScope) {
                WaveformScope2()
                    .tag(0)
                
                Vectorscope2()
                    .tag(1)
                
                HistogramScope2()
                    .tag(2)
                
                RGBParadeScope2()
                    .tag(3)
                
                LumaParadeScope2()
                    .tag(4)
            }
            .tabViewStyle(DefaultTabViewStyle())
            .frame(maxHeight: .infinity)
            
            // Scope Controls
            HStack {
                Toggle("2x", isOn: $show2xZoom)
                    .font(.system(size: 10))
                
                Spacer()
                
                Button(action: { }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12))
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.gray)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(.sRGB, red: 0.10, green: 0.10, blue: 0.10))
        }
        .background(Color(.sRGB, red: 0.08, green: 0.08, blue: 0.08))
    }
}

struct WaveformScope2: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                
                // Grid
                VStack(spacing: geometry.size.height / 5) {
                    ForEach(0..<6) { i in
                        HStack {
                            Rectangle()
                                .fill(Color.gray.opacity(i == 0 || i == 5 ? 0.5 : 0.2))
                                .frame(height: 1)
                        }
                        
                        if i < 5 {
                            Spacer()
                        }
                    }
                }
                
                // Waveform
                HStack(spacing: 0) {
                    ForEach(0..<80) { i in
                        let intensity = Double.random(in: 0.3...1.0)
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.green.opacity(intensity * 0.8),
                                        Color.yellow.opacity(intensity * 0.6),
                                        Color.red.opacity(intensity * 0.4)
                                    ],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(width: geometry.size.width / 80)
                    }
                }
                .blendMode(.screen)
                
                // Labels
                VStack(alignment: .leading, spacing: 0) {
                    Text("100%")
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("50%")
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("0%")
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                }
                .padding(.leading, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct Vectorscope2: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                
                let centerX = geometry.size.width / 2
                let centerY = geometry.size.height / 2
                let radius = min(geometry.size.width, geometry.size.height) * 0.4
                
                // Skin tone line
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 2, height: radius * 2)
                    .rotationEffect(.degrees(30))
                
                // Circles
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .frame(width: radius * 2, height: radius * 2)
                
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .frame(width: radius, height: radius)
                
                // Center cross
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: geometry.size.width, height: 1)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: geometry.size.height)
                
                // Color targets
                ForEach(ColorTarget.allCases) { target in
                    Text(target.label)
                        .font(.system(size: 8))
                        .foregroundColor(target.color)
                        .position(
                            x: centerX + cos(target.angle) * radius * 0.85,
                            y: centerY + sin(target.angle) * radius * 0.85
                        )
                }
                
                // Signal blob
                Ellipse()
                    .fill(Color.green.opacity(0.5))
                    .frame(width: 60, height: 50)
                    .position(x: centerX + 20, y: centerY - 10)
                    .blur(radius: 10)
            }
        }
    }
}

enum ColorTarget: CaseIterable, Identifiable {
    case red, yellow, green, cyan, blue, magenta
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .red: return "R"
        case .yellow: return "Yl"
        case .green: return "G"
        case .cyan: return "Cy"
        case .blue: return "B"
        case .magenta: return "Mg"
        }
    }
    
    var color: Color {
        switch self {
        case .red: return .red
        case .yellow: return .yellow
        case .green: return .green
        case .cyan: return .cyan
        case .blue: return .blue
        case .magenta: return .pink
        }
    }
    
    var angle: Double {
        switch self {
        case .red: return 0
        case .yellow: return Double.pi / 3
        case .green: return 2 * Double.pi / 3
        case .cyan: return Double.pi
        case .blue: return 4 * Double.pi / 3
        case .magenta: return 5 * Double.pi / 3
        }
    }
}

struct HistogramScope2: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                
                // RGB Histogram
                HStack(spacing: 1) {
                    ForEach(0..<100) { i in
                        let red = Double.random(in: 0...1)
                        let green = Double.random(in: 0...1)
                        let blue = Double.random(in: 0...1)
                        let height = max(red, max(green, blue))
                        
                        VStack(spacing: 0) {
                            Spacer()
                            
                            ZStack(alignment: .bottom) {
                                Rectangle()
                                    .fill(Color.red.opacity(0.7))
                                    .frame(height: CGFloat(red) * geometry.size.height * 0.9)
                                
                                Rectangle()
                                    .fill(Color.green.opacity(0.7))
                                    .frame(height: CGFloat(green) * geometry.size.height * 0.9)
                                
                                Rectangle()
                                    .fill(Color.blue.opacity(0.7))
                                    .frame(height: CGFloat(blue) * geometry.size.height * 0.9)
                            }
                            .blendMode(.screen)
                        }
                        .frame(width: (geometry.size.width - 99) / 100)
                    }
                }
            }
        }
    }
}

struct RGBParadeScope2: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                
                HStack(spacing: 2) {
                    ChannelParade(color: .red, geometry: geometry)
                    ChannelParade(color: .green, geometry: geometry)
                    ChannelParade(color: .blue, geometry: geometry)
                }
                .padding(.horizontal, 2)
            }
        }
    }
}

struct ChannelParade: View {
    let color: Color
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach((0..<50).reversed(), id: \.self) { _ in
                let height = CGFloat.random(in: 2...10)
                Rectangle()
                    .fill(color.opacity(0.8))
                    .frame(height: height)
            }
        }
        .frame(width: geometry.size.width / 3 - 2)
    }
}

struct LumaParadeScope2: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                
                VStack(spacing: 0) {
                    ForEach((0..<50).reversed(), id: \.self) { _ in
                        let height = CGFloat.random(in: 2...12)
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.green, .yellow, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: height)
                    }
                }
                .frame(width: geometry.size.width)
            }
        }
    }
}

// Additional professional components...

struct TimeDigit: View {
    let value: Int
    var highlight: Bool = false
    
    var body: some View {
        Text(String(format: "%02d", value))
            .font(.system(size: 22, weight: .semibold, design: .monospaced))
            .foregroundColor(highlight ? Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21) : .white)
    }
}
