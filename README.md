# OpenCut Pro

<p align="center">
  <img src="assets/logo.png" alt="OpenCut Pro Logo" width="200"/>
</p>

<p align="center">
  <strong>A professional, open-source video editor inspired by Final Cut Pro</strong>
</p>

<p align="center">
  <a href="https://github.com/opencut/opencut-pro/actions"><img src="https://github.com/opencut/opencut-pro/workflows/CI/badge.svg" alt="Build Status"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-GPL%20v3-blue.svg" alt="License: GPL v3"/></a>
  <a href="https://github.com/opencut/opencut-pro/releases"><img src="https://img.shields.io/github/v/release/opencut/opencut-pro" alt="Latest Release"/></a>
  <a href="https://opencut.dev"><img src="https://img.shields.io/badge/docs-website-green" alt="Documentation"/></a>
  <a href="https://discord.gg/opencut"><img src="https://img.shields.io/discord/1234567890?color=7289DA&label=discord" alt="Discord"/></a>
</p>

---

## 📖 Overview

**OpenCut Pro** is a powerful, open-source video editing application designed for macOS. Built with modern web technologies and native integrations, it brings professional-grade video editing capabilities to creators worldwide. Whether you're a content creator, filmmaker, or video enthusiast, OpenCut Pro provides the tools you need to bring your vision to life.

> **Note:** This project is currently in active development. Features and APIs may change.

---

## ✨ Features

### 🎬 Professional Timeline Editing
- **Magnetic Timeline** - The revolutionary trackless timeline that automatically keeps clips in sync
- **Precision Trimming** - Frame-accurate trimming with ripple, roll, and slip edits
- **Multi-Camera Editing** - Sync and switch between multiple camera angles seamlessly
- **Compound Clips** - Group clips into nested sequences for better organization
- **Auditions** - Try multiple shots without affecting your timeline

### 🎨 Advanced Color & Effects
- **Color Grading** - Professional color correction with scopes (waveform, vectorscope, histogram)
- **LUT Support** - Import and apply Look-Up Tables for cinematic looks
- **Effects Library** - 50+ built-in video and audio effects
- **Motion Graphics** - Animated titles, lower thirds, and transitions
- **Keyframing** - Animate any parameter over time
- **Chroma Keying** - Professional green screen removal

### 🔊 Audio Excellence
- **Multi-Track Audio** - Support for unlimited audio tracks
- **Audio Effects** - EQ, compression, noise reduction, and more
- **Audio Sync** - Automatic synchronization of dual-system audio
- **Voice Enhancement** - AI-powered voice isolation and enhancement
- **Audio Meters** - Real-time level monitoring with peak detection

### 🚀 Performance & Workflow
- **Background Rendering** - Continue editing while exports process
- **Proxy Media** - Automatic proxy creation for smooth 4K/8K editing
- **Native Apple Silicon** - Optimized for M1/M2/M3 Macs
- **Hardware Acceleration** - Metal-based rendering for maximum performance
- **Project Templates** - Start quickly with customizable templates

### 💾 Import & Export
- **Format Support** - Import from 300+ formats including ProRes, RED, ARRI, HEVC
- **360° Video** - Full support for VR and 360° video editing
- **HDR Workflows** - Dolby Vision and HDR10+ support
- **Export Presets** - YouTube, Vimeo, Instagram, and custom presets
- **Batch Export** - Queue multiple exports for unattended processing

---

## 📸 Screenshots

<p align="center">
  <img src="assets/screenshot-main.png" alt="Main Interface" width="800"/>
  <br/>
  <em>Main editing interface with magnetic timeline</em>
</p>

<p align="center">
  <img src="assets/screenshot-color.png" alt="Color Grading" width="400"/>
  <img src="assets/screenshot-effects.png" alt="Effects Panel" width="400"/>
  <br/>
  <em>Color grading workspace and effects library</em>
</p>

---

## 💻 Installation

### System Requirements

- **macOS:** 12.0 (Monterey) or later
- **Processor:** Apple Silicon (M1/M2/M3) or Intel Core i5/i7/i9
- **Memory:** 8 GB RAM minimum (16 GB recommended)
- **Storage:** 5 GB available space (SSD recommended)
- **Graphics:** Metal-capable GPU
- **Display:** 1920x1080 or higher resolution

### Installation Methods

#### Option 1: Download Pre-built Binary (Recommended)

1. Visit the [Releases](https://github.com/opencut/opencut-pro/releases) page
2. Download the latest `.dmg` file
3. Open the DMG and drag OpenCut Pro to your Applications folder
4. Launch from Applications or Spotlight

#### Option 2: Homebrew

```bash
brew install --cask opencut-pro
```

#### Option 3: Build from Source

```bash
# Clone the repository
git clone https://github.com/opencut/opencut-pro.git
cd opencut-pro

# Install dependencies
npm install

# Build the application
npm run build

# Package for distribution
npm run package
```

### Development Setup

```bash
# Install development dependencies
npm install

# Start development server
npm run dev

# Run tests
npm test

# Lint code
npm run lint
```

---

## 🎓 Usage Guide

### Quick Start

1. **Create a New Project**
   - Launch OpenCut Pro
   - Click "New Project" or press `Cmd + N`
   - Choose your project settings (resolution, frame rate, color space)

2. **Import Media**
   - Drag and drop files into the browser panel
   - Or use `Cmd + I` to import from the file system
   - Organize clips into events and keyword collections

3. **Edit Your Timeline**
   - Drag clips to the magnetic timeline
   - Use the blade tool (`B`) to make cuts
   - Trim clips by dragging their edges
   - Add transitions from the effects browser

4. **Add Effects & Color Grade**
   - Apply effects from the effects browser
   - Open the color board (`Cmd + 6`) for color grading
   - Use the inspector to adjust effect parameters

5. **Export Your Project**
   - Click the share button or press `Cmd + E`
   - Choose your destination preset
   - Configure export settings and click "Export"

### Workspace Layout

```
┌─────────────────────────────────────────────────────────────┐
│  Browser (Media, Effects, Titles, Transitions)             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                    Viewer (Preview)                         │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│              Magnetic Timeline (Edit Area)                  │
├─────────────────────────────────────────────────────────────┤
│  Timeline Index  │  Inspector (Properties & Effects)        │
└─────────────────────────────────────────────────────────────┘
```

### Learning Resources

- 📚 [Official Documentation](https://opencut.dev/docs)
- 🎥 [Video Tutorials](https://opencut.dev/tutorials)
- 💬 [Community Forum](https://forum.opencut.dev)
- 🐦 [Twitter Updates](https://twitter.com/opencutpro)

---

## ⌨️ Keyboard Shortcuts

### Essential Shortcuts

| Action | Shortcut |
|--------|----------|
| New Project | `Cmd + N` |
| Open Project | `Cmd + O` |
| Save Project | `Cmd + S` |
| Import Media | `Cmd + I` |
| Export | `Cmd + E` |
| Undo | `Cmd + Z` |
| Redo | `Shift + Cmd + Z` |
| Cut | `Cmd + X` |
| Copy | `Cmd + C` |
| Paste | `Cmd + V` |

### Editing Shortcuts

| Action | Shortcut |
|--------|----------|
| Blade Tool | `B` |
| Select Tool | `A` |
| Trim Tool | `T` |
| Position Tool | `P` |
| Range Selection | `R` |
| Blade at Playhead | `Cmd + B` |
| Delete Selection | `Delete` |
| Ripple Delete | `Shift + Delete` |
| Extend Edit | `Shift + X` |
| Add Default Transition | `Cmd + T` |

### Navigation Shortcuts

| Action | Shortcut |
|--------|----------|
| Play/Pause | `Space` |
| Go to Beginning | `Home` |
| Go to End | `End` |
| Next Edit | `↓` |
| Previous Edit | `↑` |
| Next Frame | `→` |
| Previous Frame | `←` |
| Nudge Clip Right | `.` |
| Nudge Clip Left | `,` |
| Zoom In Timeline | `Cmd + =` |
| Zoom Out Timeline | `Cmd + -` |

### Window Shortcuts

| Action | Shortcut |
|--------|----------|
| Show/Hide Browser | `Cmd + 1` |
| Show/Hide Viewer | `Cmd + 2` |
| Show/Hide Timeline | `Cmd + 3` |
| Show/Hide Inspector | `Cmd + 4` |
| Show/Hide Timeline Index | `Cmd + 5` |
| Show/Hide Color Board | `Cmd + 6` |
| Show/Hide Effects Browser | `Cmd + 7` |
| Show/Hide Transitions | `Cmd + 8` |
| Show/Hide Titles/Generators | `Cmd + 9` |

### Advanced Shortcuts

| Action | Shortcut |
|--------|----------|
| Mark Selection | `X` |
| Mark Clip Range | `Shift + X` |
| Create Compound Clip | `Option + G` |
| Create Audition | `Cmd + Y` |
| Audio Inspector | `Cmd + Option + 4` |
| Video Inspector | `Cmd + Option + 1` |
| Color Inspector | `Cmd + Option + 6` |
| Toggle Snap | `N` |
| Toggle Skimming | `S` |
| Full Screen Viewer | `Cmd + Shift + F` |
| Background Tasks | `Cmd + 9` |

> **Tip:** Customize shortcuts in `OpenCut Pro > Keyboard > Customize...`

---

## 🏗️ Architecture Overview

### Technology Stack

```
┌─────────────────────────────────────────────────────────┐
│                    OpenCut Pro                           │
│                   (Electron + React)                     │
├─────────────────────────────────────────────────────────┤
│  UI Layer (React + TypeScript + TailwindCSS)           │
├─────────────────────────────────────────────────────────┤
│  Core Engine (WebAssembly + FFmpeg)                      │
├─────────────────────────────────────────────────────────┤
│  Video Processing (WebGL/Metal)                        │
├─────────────────────────────────────────────────────────┤
│  Storage (SQLite + File System)                          │
├─────────────────────────────────────────────────────────┤
│  Native APIs (macOS Media Frameworks)                  │
└─────────────────────────────────────────────────────────┘
```

### Core Components

#### 1. **UI Layer**
- **Framework:** React 18 with TypeScript
- **Styling:** TailwindCSS with custom design system
- **State Management:** Zustand for global state
- **Components:** Radix UI primitives for accessibility

#### 2. **Timeline Engine**
- **Architecture:** Event-driven with immutable state
- **Data Structure:** Tree-based clip hierarchy
- **Performance:** Virtualized rendering for large timelines
- **Sync:** Operational transforms for collaboration

#### 3. **Video Processing**
- **Decoder:** FFmpeg with hardware acceleration
- **Renderer:** WebGL 2.0 with Metal fallback
- **Effects:** GLSL shaders with real-time preview
- **Export:** Background processing with progress tracking

#### 4. **Storage Layer**
- **Project DB:** SQLite for metadata and edit decisions
- **Media Management:** Reference-based with proxy generation
- **Backup:** Automatic project versioning
- **Sync:** iCloud integration for cross-device access

### Project Structure

```
opencut-pro/
├── src/
│   ├── main/               # Electron main process
│   ├── renderer/           # React application
│   │   ├── components/     # React components
│   │   ├── hooks/          # Custom React hooks
│   │   ├── stores/         # State management
│   │   ├── utils/          # Utility functions
│   │   └── styles/         # CSS/Tailwind
│   ├── shared/             # Shared types and constants
│   └── workers/            # Web Workers for heavy tasks
├── assets/                 # Static assets (icons, images)
├── docs/                   # Documentation
├── scripts/                # Build and deployment scripts
└── tests/                  # Test suites
```

### Performance Considerations

- **Lazy Loading:** Components loaded on demand
- **Virtual Scrolling:** Timeline renders only visible clips
- **Web Workers:** Heavy processing off main thread
- **Proxy Media:** Automatic proxy generation for large files
- **Memory Management:** Intelligent cache eviction
- **Metal Rendering:** Native GPU acceleration on macOS

---

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### Getting Started

1. **Fork the Repository**
   ```bash
   git clone https://github.com/your-username/opencut-pro.git
   cd opencut-pro
   ```

2. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Install Dependencies**
   ```bash
   npm install
   ```

4. **Start Development**
   ```bash
   npm run dev
   ```

### Contribution Guidelines

#### Code Style
- Follow the existing code style and formatting
- Use TypeScript for all new code
- Write self-documenting code with clear variable names
- Add JSDoc comments for public APIs

#### Testing
- Write unit tests for new features
- Ensure all tests pass before submitting PR
- Aim for >80% code coverage

#### Documentation
- Update relevant documentation for new features
- Add inline comments for complex logic
- Update README if adding new dependencies

#### Pull Request Process
1. Update the README.md with details of changes if applicable
2. Reference any related issues in your PR description
3. Ensure your PR passes all CI checks
4. Request review from maintainers
5. Address review feedback promptly

### Areas for Contribution

- 🐛 **Bug Fixes** - Help fix reported issues
- ✨ **Features** - Implement new features from roadmap
- 📚 **Documentation** - Improve docs and tutorials
- 🎨 **UI/UX** - Enhance the user interface
- 🌍 **Localization** - Translate to other languages
- 🧪 **Testing** - Add test coverage
- ⚡ **Performance** - Optimize rendering and processing

### Development Workflow

```bash
# Check code style
npm run lint

# Run tests
npm test

# Build for production
npm run build

# Package application
npm run package
```

### Commit Message Format

We follow [Conventional Commits](https://conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Examples:
- `feat(timeline): add magnetic snapping`
- `fix(export): resolve HEVC encoding issue`
- `docs(readme): update installation instructions`

---

## 📄 License

OpenCut Pro is licensed under the **GNU General Public License v3.0**.

```
OpenCut Pro - A professional, open-source video editor
Copyright (C) 2024 OpenCut Pro Contributors

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
```

See [LICENSE](LICENSE) file for full license text.

---

## 🙏 Acknowledgments

OpenCut Pro stands on the shoulders of giants. We're grateful to the following open-source projects and contributors:

### Core Dependencies
- **[FFmpeg](https://ffmpeg.org/)** - The leading multimedia framework
- **[Electron](https://www.electronjs.org/)** - Cross-platform desktop framework
- **[React](https://reactjs.org/)** - UI library
- **[TypeScript](https://www.typescriptlang.org/)** - Typed JavaScript
- **[TailwindCSS](https://tailwindcss.com/)** - Utility-first CSS framework

### Video Processing
- **[WebGL](https://www.khronos.org/webgl/)** - GPU-accelerated graphics
- **[WebCodecs](https://www.w3.org/TR/webcodecs/)** - Video encoding/decoding
- **[WASM](https://webassembly.org/)** - High-performance modules

### UI Components
- **[Radix UI](https://www.radix-ui.com/)** - Accessible component primitives
- **[Framer Motion](https://www.framer.com/motion/)** - Animation library
- **[Lucide Icons](https://lucide.dev/)** - Beautiful icon set

### Development Tools
- **[Vite](https://vitejs.dev/)** - Build tool
- **[Vitest](https://vitest.dev/)** - Testing framework
- **[Playwright](https://playwright.dev/)** - E2E testing
- **[ESLint](https://eslint.org/)** - Code linting

### Special Thanks
- The FFmpeg community for their incredible multimedia tools
- The Electron team for enabling desktop web apps
- All contributors who have submitted code, reported bugs, and provided feedback

---

## 🗺️ Roadmap

### Version 1.0 (Current) - Foundation
- ✅ Basic timeline editing
- ✅ Import/export (ProRes, H.264, HEVC)
- ✅ Basic color grading
- ✅ Audio mixing
- ✅ Keyboard shortcuts
- ✅ Project management

### Version 1.1 (Q1 2025) - Performance
- 🔄 Apple Silicon optimizations
- 🔄 Background rendering
- 🔄 Proxy media workflow
- 🔄 Enhanced color tools
- 🔄 Audio noise reduction
- 🔄 Project templates

### Version 1.2 (Q2 2025) - Professional Features
- 📋 Advanced color grading (HDR, Dolby Vision)
- 📋 Multi-cam editing
- 📋 Motion tracking
- 📋 Keyframe animation
- 📋 Advanced audio mixing
- 📋 Batch export

### Version 1.3 (Q3 2025) - Collaboration
- 📋 Cloud project sharing
- 📋 Real-time collaboration
- 📋 Version control
- 📋 Team workspaces
- 📋 Review and approval workflow
- 📋 Comments and annotations

### Version 2.0 (2026) - Platform Expansion
- 📋 Windows support
- 📋 Linux support
- 📋 iPad companion app
- 📋 Cloud rendering
- 📋 AI-powered features
- 📋 Plugin ecosystem

### Future Considerations
- 🚀 AI-assisted editing
- 🚀 Automatic transcription
- 🚀 Neural style transfer
- 🚀 Real-time streaming integration
- 🚀 VR/360° video tools
- 🚀 Advanced motion graphics

---

## 💬 Community

Join our community to get help, share your work, and connect with other creators:

- 💬 [Discord](https://discord.gg/opencut)
- 🐦 [Twitter](https://twitter.com/opencutpro)
- 🐛 [GitHub Issues](https://github.com/opencut/opencut-pro/issues)
- 📧 [Email Support](mailto:support@opencut.dev)
- 🌐 [Official Website](https://opencut.dev)

### Support Us

If you find OpenCut Pro helpful, please consider:

- ⭐ Star the repository
- 🐛 Report bugs and suggest features
- 📝 Contribute code or documentation
- 💰 [Sponsor the project](https://github.com/sponsors/opencut)
- 📢 Share with your network

---

## 📊 Project Stats

<p align="center">
  <img src="https://img.shields.io/github/stars/opencut/opencut-pro?style=social" alt="GitHub Stars"/>
  <img src="https://img.shields.io/github/forks/opencut/opencut-pro?style=social" alt="GitHub Forks"/>
  <img src="https://img.shields.io/github/contributors/opencut/opencut-pro" alt="Contributors"/>
</p>

---

<p align="center">
  Made with ❤️ by the OpenCut Pro community
</p>

<p align="center">
  <a href="https://opencut.dev">Website</a> •
  <a href="https://docs.opencut.dev">Docs</a> •
  <a href="https://twitter.com/opencutpro">Twitter</a> •
  <a href="https://discord.gg/opencut">Discord</a>
</p>
