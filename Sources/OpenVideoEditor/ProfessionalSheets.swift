import SwiftUI
import OpenVideoCore

// MARK: - Professional New Project Sheet

struct ProfessionalNewProjectSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    
    @State private var projectName = ""
    @State private var selectedPreset = 1
    @State private var customWidth = "1920"
    @State private var customHeight = "1080"
    @State private var frameRate = 60
    @State private var colorSpace = 0
    
    let presets = [
        ("Custom", 0, 0),
        ("1080p HD", 1920, 1080),
        ("4K UHD", 3840, 2160),
        ("4K DCI", 4096, 2160),
        ("8K UHD", 7680, 4320),
        ("Social Media 9:16", 1080, 1920),
        ("Social Media 1:1", 1080, 1080),
        ("2K DCI", 2048, 1080)
    ]
    
    var body: some View {
        VStack(spacing: 28) {
            // Header
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21).opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "film.stack.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21))
                }
                
                Text("New Project")
                    .font(.system(size: 24, weight: .bold))
                
                Text("Create a new video editing project")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            // Form
            VStack(spacing: 20) {
                // Project Name
                VStack(alignment: .leading, spacing: 6) {
                    Text("Project Name")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    TextField("Untitled Project", text: $projectName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 14))
                }
                
                // Resolution Preset
                VStack(alignment: .leading, spacing: 6) {
                    Text("Resolution Preset")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Picker("", selection: $selectedPreset) {
                        ForEach(0..<presets.count, id: \.self) { index in
                            let preset = presets[index]
                            if preset.1 == 0 {
                                Text(preset.0).tag(index)
                            } else {
                                Text("\(preset.0) (\(preset.1)×\(preset.2))").tag(index)
                            }
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Custom Resolution
                if selectedPreset == 0 {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Width")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                            TextField("1920", text: $customWidth)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 100)
                        }
                        
                        Text("×")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Height")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                            TextField("1080", text: $customHeight)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 100)
                        }
                    }
                }
                
                // Frame Rate
                VStack(alignment: .leading, spacing: 6) {
                    Text("Frame Rate")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Picker("", selection: $frameRate) {
                        Text("24 fps (Cinema)").tag(24)
                        Text("25 fps (PAL)").tag(25)
                        Text("30 fps (NTSC)").tag(30)
                        Text("48 fps").tag(48)
                        Text("50 fps").tag(50)
                        Text("60 fps").tag(60)
                        Text("120 fps").tag(120)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Color Space
                VStack(alignment: .leading, spacing: 6) {
                    Text("Color Space")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Picker("", selection: $colorSpace) {
                        Text("Rec. 709 (SDR)").tag(0)
                        Text("Rec. 2020 (HDR)").tag(1)
                        Text("DCI-P3").tag(2)
                        Text("ACES").tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .frame(width: 360)
            
            // Buttons
            HStack(spacing: 12) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Create Project") {
                    let preset = presets[selectedPreset]
                    let w = selectedPreset == 0 ? (Double(customWidth) ?? 1920) : Double(preset.1)
                    let h = selectedPreset == 0 ? (Double(customHeight) ?? 1080) : Double(preset.2)
                    let name = projectName.isEmpty ? "Untitled Project" : projectName
                    
                    appState.createNewProject(
                        name: name,
                        resolution: VideoSize(width: w, height: h),
                        frameRate: Double(frameRate)
                    )
                    
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(BorderedProminentButtonStyle())
            }
        }
        .padding(32)
        .frame(width: 460)
    }
}

// MARK: - Professional Export Sheet

struct ProfessionalExportSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedFormat = 0
    @State private var selectedPreset = 0
    @State private var fileName = ""
    @State private var location = ""
    @State private var includeAudio = true
    @State private var exportRange = 0
    @State private var showAdvancedSettings = false
    
    let formats = ["QuickTime (.mov)", "MP4 (.mp4)", "MXF (.mxf)", "ProRes (.mov)", "DNxHD (.mxf)"]
    
    let presets = [
        "YouTube 1080p",
        "YouTube 4K",
        "Vimeo",
        "Apple ProRes 422 HQ",
        "Apple ProRes 422",
        "Apple ProRes 422 Proxy",
        "H.264 (High Quality)",
        "H.265 (HEVC)"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "square.and.arrow.up.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Deliver")
                        .font(.system(size: 20, weight: .bold))
                    
                    Text("Export your project")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Format Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Render Settings")
                            .font(.system(size: 13, weight: .semibold))
                        
                        Picker("Format", selection: $selectedFormat) {
                            ForEach(0..<formats.count, id: \.self) { index in
                                Text(formats[index]).tag(index)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Picker("Preset", selection: $selectedPreset) {
                            ForEach(0..<presets.count, id: \.self) { index in
                                Text(presets[index]).tag(index)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // Export Range
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Export Range")
                            .font(.system(size: 13, weight: .semibold))
                        
                        Picker("", selection: $exportRange) {
                            Text("Entire Timeline").tag(0)
                            Text("In/Out Range").tag(1)
                            Text("Selected Clips").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // File Location
                    VStack(alignment: .leading, spacing: 8) {
                        Text("File Location")
                            .font(.system(size: 13, weight: .semibold))
                        
                        HStack {
                            TextField("File name", text: $fileName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("Browse...") { }
                                .font(.system(size: 12))
                        }
                    }
                    
                    // Audio Options
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Audio")
                            .font(.system(size: 13, weight: .semibold))
                        
                        Toggle("Include Audio", isOn: $includeAudio)
                        
                        if includeAudio {
                            Picker("Audio Format", selection: .constant(0)) {
                                Text("AAC (256 kbps)").tag(0)
                                Text("PCM (48kHz)").tag(1)
                                Text("Dolby Digital").tag(2)
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                    
                    // Advanced Settings
                    DisclosureGroup("Advanced Settings") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Codec")
                                    .font(.system(size: 12))
                                Spacer()
                                Text("H.264")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Text("Resolution")
                                    .font(.system(size: 12))
                                Spacer()
                                Text("1920×1080")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Text("Frame Rate")
                                    .font(.system(size: 12))
                                Spacer()
                                Text("60 fps")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Text("Quality")
                                    .font(.system(size: 12))
                                Spacer()
                                Text("High")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .font(.system(size: 13))
                    
                    // Estimated Info
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Estimated Size:")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                            Text("~ 2.3 GB")
                                .font(.system(size: 13, weight: .medium))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Estimated Time:")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                            Text("~ 15 minutes")
                                .font(.system(size: 13, weight: .medium))
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(.sRGB, red: 0.10, green: 0.10, blue: 0.10))
                    .cornerRadius(6)
                }
                .padding(.horizontal, 20)
            }
            
            // Progress (if rendering)
            if appState.isExporting {
                VStack(spacing: 8) {
                    ProgressView(value: appState.exportProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21)))
                    
                    HStack {
                        Text("Rendering...")
                            .font(.system(size: 12))
                        
                        Spacer()
                        
                        Text("\(Int(appState.exportProgress * 100))%")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(.sRGB, red: 0.10, green: 0.10, blue: 0.10))
            }
            
            // Buttons
            HStack(spacing: 12) {
                Button("Add to Queue") {
                    // Add to render queue
                }
                .keyboardShortcut(.alternateAction)
                
                Spacer()
                
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button(appState.isExporting ? "Stop" : "Start Render") {
                    if !appState.isExporting {
                        appState.isExporting = true
                        // Start render simulation
                        simulateRender()
                    } else {
                        appState.isExporting = false
                    }
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(BorderedProminentButtonStyle())
                .disabled(appState.currentProject == nil)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .frame(width: 500, height: 580)
    }
    
    func simulateRender() {
        // Simulate export progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if appState.exportProgress >= 1.0 {
                timer.invalidate()
                appState.isExporting = false
                appState.exportProgress = 0
            } else {
                appState.exportProgress += 0.01
            }
        }
    }
}

// MARK: - Project Settings Sheet

struct ProjectSettingsSheet: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var timelineResolution = 0
    @State private var playbackQuality = 2
    @State private var cacheLocation = ""
    @State private var autoSave = true
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Image(systemName: "gear")
                    .font(.system(size: 24))
                    .foregroundColor(Color(.sRGB, red: 1.0, green: 0.42, blue: 0.21))
                
                Text("Project Settings")
                    .font(.system(size: 20, weight: .bold))
                
                Spacer()
                
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Settings Form
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Timeline Resolution")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Picker("", selection: $timelineResolution) {
                            Text("Full").tag(0)
                            Text("Half").tag(1)
                            Text("Quarter").tag(2)
                            Text("Eighth").tag(3)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Playback Quality")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Picker("", selection: $playbackQuality) {
                            Text("Draft").tag(0)
                            Text("Medium").tag(1)
                            Text("High").tag(2)
                            Text("Best").tag(3)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Toggle("Auto-save project", isOn: $autoSave)
                        .font(.system(size: 13))
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Cache Location")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        HStack {
                            TextField("/Users/...", text: $cacheLocation)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("Browse...") { }
                                .font(.system(size: 11))
                        }
                    }
                }
            }
            .frame(width: 360)
            
            Spacer()
            
            // Buttons
            HStack {
                Spacer()
                
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Save Settings") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(BorderedProminentButtonStyle())
            }
        }
        .padding(28)
        .frame(width: 440, height: 420)
    }
}
