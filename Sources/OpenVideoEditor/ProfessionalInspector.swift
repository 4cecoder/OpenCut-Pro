import SwiftUI
import OpenVideoCore

// MARK: - Professional Inspector Panel

struct ProfessionalInspector: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var isInspectorExpanded = true
    
    let tabs = ["Video", "Audio", "Color", "Effects", "Fusion", "Metadata"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Inspector Header
            HStack {
                Text("Inspector")
                    .font(.system(size: 14, weight: .semibold))
                
                Spacer()
                
                Button(action: { isInspectorExpanded.toggle() }) {
                    Image(systemName: isInspectorExpanded ? "chevron.down" : "chevron.up")
                        .font(.system(size: 12))
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.sRGB, red: 0.10, green: 0.10, blue: 0.10))
            
            if isInspectorExpanded {
                // Tab Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(0..<tabs.count, id: \.self) { index in
                            InspectorTabButton2(
                                title: tabs[index],
                                isSelected: selectedTab == index
                            ) {
                                selectedTab = index
                            }
                        }
                    }
                }
                .frame(height: 34)
                .background(Color(.sRGB, red: 0.12, green: 0.12, blue: 0.12))
                
                // Inspector Content
                TabView(selection: $selectedTab) {
                    VideoInspector2()
                        .tag(0)
                    
                    AudioInspector2()
                        .tag(1)
                    
                    ColorInspector2()
                        .tag(2)
                    
                    EffectsInspector2()
                        .tag(3)
                    
                    FusionInspector()
                        .tag(4)
                    
                    MetadataInspector2()
                        .tag(5)
                }
                .tabViewStyle(DefaultTabViewStyle())
            }
        }
        .background(Color(.sRGB, red: 0.08, green: 0.08, blue: 0.08))
        .foregroundColor(.white)
    }
}

struct InspectorTabButton2: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21) : Color.clear)
                .foregroundColor(isSelected ? .black : .gray)
                .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Video Inspector (DaVinci Resolve Style)

struct VideoInspector2: View {
    @State private var positionX: Double = 0
    @State private var positionY: Double = 0
    @State private var zoom: Double = 100
    @State private var rotation: Double = 0
    @State private var anchorX: Double = 50
    @State private var anchorY: Double = 50
    @State private var opacity: Double = 100
    @State private var blendMode = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Transform Section
                InspectorSection2(title: "Transform") {
                    VStack(spacing: 14) {
                        InspectorSlider2(label: "Position X", value: $positionX, range: -4000...4000, unit: "px")
                        InspectorSlider2(label: "Position Y", value: $positionY, range: -4000...4000, unit: "px")
                        InspectorSlider2(label: "Zoom", value: $zoom, range: 0...500, unit: "%")
                        InspectorSlider2(label: "Rotation", value: $rotation, range: -360...360, unit: "°")
                        
                        // Anchor Point
                        HStack {
                            Text("Anchor Point")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                                .frame(width: 90, alignment: .leading)
                            
                            HStack(spacing: 8) {
                                HStack(spacing: 4) {
                                    Text("X")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                    TextField("50", value: $anchorX, formatter: NumberFormatter())
                                        .frame(width: 50)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                HStack(spacing: 4) {
                                    Text("Y")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                    TextField("50", value: $anchorY, formatter: NumberFormatter())
                                        .frame(width: 50)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                // Composite Section
                InspectorSection2(title: "Composite") {
                    VStack(spacing: 14) {
                        InspectorSlider2(label: "Opacity", value: $opacity, range: 0...100, unit: "%")
                        
                        HStack {
                            Text("Blend Mode")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                                .frame(width: 90, alignment: .leading)
                            
                            Picker("", selection: $blendMode) {
                                Text("Normal").tag(0)
                                Text("Add").tag(1)
                                Text("Multiply").tag(2)
                                Text("Screen").tag(3)
                                Text("Overlay").tag(4)
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            Spacer()
                        }
                    }
                }
                
                // Crop Section
                InspectorSection2(title: "Crop") {
                    VStack(spacing: 14) {
                        InspectorSlider2(label: "Crop Left", value: .constant(0), range: 0...100, unit: "%")
                        InspectorSlider2(label: "Crop Right", value: .constant(0), range: 0...100, unit: "%")
                        InspectorSlider2(label: "Crop Top", value: .constant(0), range: 0...100, unit: "%")
                        InspectorSlider2(label: "Crop Bottom", value: .constant(0), range: 0...100, unit: "%")
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}

struct AudioInspector2: View {
    @State private var volume: Double = 0
    @State private var pan: Double = 0
    @State private var pitch: Double = 0
    @State private var enableEQ = false
    @State private var enableCompressor = false
    @State private var enableLimiter = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Volume & Pan
                InspectorSection2(title: "Volume & Pan") {
                    VStack(spacing: 14) {
                        InspectorSlider2(label: "Volume", value: $volume, range: -60...12, unit: "dB")
                        InspectorSlider2(label: "Pan", value: $pan, range: -100...100, unit: "")
                        InspectorSlider2(label: "Pitch", value: $pitch, range: -12...12, unit: "st")
                    }
                }
                
                // Dynamics
                InspectorSection2(title: "Dynamics") {
                    VStack(spacing: 10) {
                        Toggle("Equalizer (EQ)", isOn: $enableEQ)
                            .font(.system(size: 12))
                        
                        if enableEQ {
                            EQVisualizer()
                                .frame(height: 100)
                                .padding(.vertical, 8)
                        }
                        
                        Toggle("Compressor", isOn: $enableCompressor)
                            .font(.system(size: 12))
                        
                        Toggle("Limiter", isOn: $enableLimiter)
                            .font(.system(size: 12))
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}

struct EQVisualizer: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid
                VStack(spacing: geometry.size.height / 4) {
                    ForEach(0..<5) { _ in
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 1)
                    }
                }
                
                // EQ Curve
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    path.move(to: CGPoint(x: 0, y: height * 0.6))
                    path.addCurve(
                        to: CGPoint(x: width * 0.25, y: height * 0.7),
                        control1: CGPoint(x: width * 0.1, y: height * 0.65),
                        control2: CGPoint(x: width * 0.2, y: height * 0.7)
                    )
                    path.addCurve(
                        to: CGPoint(x: width * 0.5, y: height * 0.4),
                        control1: CGPoint(x: width * 0.35, y: height * 0.3),
                        control2: CGPoint(x: width * 0.45, y: height * 0.35)
                    )
                    path.addCurve(
                        to: CGPoint(x: width * 0.75, y: height * 0.5),
                        control1: CGPoint(x: width * 0.6, y: height * 0.45),
                        control2: CGPoint(x: width * 0.7, y: height * 0.48)
                    )
                    path.addCurve(
                        to: CGPoint(x: width, y: height * 0.55),
                        control1: CGPoint(x: width * 0.85, y: height * 0.52),
                        control2: CGPoint(x: width * 0.95, y: height * 0.54)
                    )
                }
                .stroke(Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21), lineWidth: 2)
                .fill(Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21).opacity(0.1))
                
                // Frequency labels
                HStack {
                    Text("30Hz")
                    Spacer()
                    Text("100Hz")
                    Spacer()
                    Text("1kHz")
                    Spacer()
                    Text("10kHz")
                    Spacer()
                    Text("20kHz")
                }
                .font(.system(size: 8))
                .foregroundColor(.gray)
                .position(x: geometry.size.width / 2, y: geometry.size.height - 8)
            }
        }
    }
}

struct ColorInspector2: View {
    @State private var liftY: Double = 0
    @State private var liftR: Double = 0
    @State private var liftG: Double = 0
    @State private var liftB: Double = 0
    @State private var gammaY: Double = 0
    @State private var gainY: Double = 100
    @State private var offsetY: Double = 0
    @State private var saturation: Double = 100
    @State private var contrast: Double = 100
    @State private var highlight: Double = 0
    @State private var shadow: Double = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Color Wheels
                InspectorSection2(title: "Color Wheels") {
                    VStack(spacing: 16) {
                        // Color wheel visualization
                        HStack(spacing: 12) {
                            ColorWheel2(title: "Lift", color: .red)
                            ColorWheel2(title: "Gamma", color: .green)
                            ColorWheel2(title: "Gain", color: .blue)
                        }
                        .frame(height: 80)
                    }
                    
                    // Wheel values
                    VStack(spacing: 12) {
                        InspectorSlider2(label: "Lift Y", value: $liftY, range: -1...1, unit: "")
                        InspectorSlider2(label: "Gamma Y", value: $gammaY, range: -1...1, unit: "")
                        InspectorSlider2(label: "Gain Y", value: $gainY, range: 0...2, unit: "")
                    }
                }
                
                // Primary Controls
                InspectorSection2(title: "Primary") {
                    VStack(spacing: 14) {
                        InspectorSlider2(label: "Saturation", value: $saturation, range: 0...200, unit: "%")
                        InspectorSlider2(label: "Contrast", value: $contrast, range: 0...200, unit: "%")
                        InspectorSlider2(label: "Highlight", value: $highlight, range: -100...100, unit: "%")
                        InspectorSlider2(label: "Shadow", value: $shadow, range: -100...100, unit: "%")
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}

struct ColorWheel2: View {
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Wheel background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.red, .yellow, .green, .cyan, .blue, .magenta, .red],
                            center: .center,
                            startRadius: 0,
                            endRadius: 35
                        )
                    )
                    .frame(width: 70, height: 70)
                
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .frame(width: 70, height: 70)
                
                // Center indicator
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
            }
            
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
    }
}

struct EffectsInspector2: View {
    @State private var effects: [AppliedEffect] = [
        AppliedEffect(name: "Color Balance", isEnabled: true, isExpanded: false),
        AppliedEffect(name: "Blur - Gaussian", isEnabled: false, isExpanded: false),
        AppliedEffect(name: "Transform", isEnabled: true, isExpanded: false),
        AppliedEffect(name: "LUT - Teal & Orange", isEnabled: true, isExpanded: false)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Add Effect Button
                Button(action: { }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 14))
                        Text("Add Effect")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21).opacity(0.1))
                    .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Effects List
                VStack(spacing: 6) {
                    ForEach(effects.indices, id: \.self) { index in
                        EffectRow2(effect: $effects[index])
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}

struct AppliedEffect: Identifiable {
    let id = UUID()
    var name: String
    var isEnabled: Bool
    var isExpanded: Bool
}

struct EffectRow2: View {
    @Binding var effect: AppliedEffect
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                // Toggle
                Toggle("", isOn: $effect.isEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21)))
                    .scaleEffect(0.8)
                
                // Name
                Text(effect.name)
                    .font(.system(size: 12))
                    .foregroundColor(effect.isEnabled ? .white : .gray)
                
                Spacer()
                
                // Expand button
                Button(action: { effect.isExpanded.toggle() }) {
                    Image(systemName: effect.isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Delete
                Button(action: { }) {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(.sRGB, red: 0.12, green: 0.12, blue: 0.12))
            .cornerRadius(4)
            
            if effect.isExpanded {
                // Effect parameters would go here
                Text("Effect parameters...")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .padding(.leading, 20)
            }
        }
    }
}

struct FusionInspector: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "atom")
                .font(.system(size: 48))
                .foregroundColor(Color(.sRGB, red: 0.29, green: 0.62, blue: 1.0))
            
            Text("Fusion Page")
                .font(.system(size: 16, weight: .semibold))
            
            Text("Node-based compositing and visual effects")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

struct MetadataInspector2: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // File Info
                InspectorSection2(title: "File Information") {
                    VStack(spacing: 8) {
                        MetadataRow2(label: "File Name", value: "Scene_001_Take3_ProRes.mov")
                        MetadataRow2(label: "Duration", value: "00:01:23:15")
                        MetadataRow2(label: "Frame Rate", value: "59.94 fps")
                        MetadataRow2(label: "Resolution", value: "3840 × 2160 (4K UHD)")
                        MetadataRow2(label: "Codec", value: "Apple ProRes 422 HQ")
                        MetadataRow2(label: "Color Space", value: "Rec. 2020 HDR")
                        MetadataRow2(label: "Bit Depth", value: "10-bit")
                    }
                }
                
                // Camera Info
                InspectorSection2(title: "Camera Metadata") {
                    VStack(spacing: 8) {
                        MetadataRow2(label: "Camera", value: "Sony FX6")
                        MetadataRow2(label: "Lens", value: "Sony FE 24-70mm f/2.8 GM")
                        MetadataRow2(label: "ISO", value: "800")
                        MetadataRow2(label: "Aperture", value: "f/2.8")
                        MetadataRow2(label: "Shutter", value: "1/120s")
                        MetadataRow2(label: "White Balance", value: "5600K")
                        MetadataRow2(label: "Focus Distance", value: "2.5m")
                    }
                }
                
                // Production
                InspectorSection2(title: "Production") {
                    VStack(spacing: 8) {
                        MetadataRow2(label: "Scene", value: "Scene 1")
                        MetadataRow2(label: "Take", value: "Take 3")
                        MetadataRow2(label: "Reel", value: "A001")
                        MetadataRow2(label: "Date", value: "2026-02-12")
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}

struct MetadataRow2: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.gray)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.system(size: 11))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Spacer()
        }
    }
}

struct InspectorSection2: View {
    let title: String
    let content: AnyView
    @State private var isExpanded = true
    
    init<Content: View>(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = AnyView(content())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
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
        .padding(10)
        .background(Color(.sRGB, red: 0.10, green: 0.10, blue: 0.10))
        .cornerRadius(6)
    }
}

struct InspectorSlider2: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .frame(width: 90, alignment: .leading)
                
                Slider(value: $value, in: range)
                    .frame(height: 12)
                
                Text("\(Int(value))\(unit)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21))
                    .frame(width: 55, alignment: .trailing)
            }
        }
    }
}
