import XCTest
@testable import OpenVideoCore

@MainActor
final class VideoEditorTests: XCTestCase {
    
    var videoEditor: VideoEditor!
    var mockVideoProcessor: MockVideoProcessor!
    
    override func setUp() async throws {
        try await super.setUp()
        let project = VideoProject(
            name: "Test Project",
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0,
            duration: 120.0
        )
        mockVideoProcessor = MockVideoProcessor()
        videoEditor = try await VideoEditor(project: project, videoProcessor: mockVideoProcessor)
    }
    
    override func tearDown() async throws {
        videoEditor = nil
        mockVideoProcessor = nil
        try await super.tearDown()
    }
    
    func testVideoEditorInitialization() async {
        XCTAssertNotNil(videoEditor)
    }
    
    func testAddVideoClip() async throws {
        let clip = VideoClip(
            id: UUID(),
            filePath: "/path/to/video.mp4",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        
        await videoEditor.addVideoClip(clip)
        
        // Verify clip was added
        let project = await videoEditor.project
        XCTAssertEqual(project.timeline.videoClips.count, 1)
    }
    
    func testRemoveVideoClip() async throws {
        let clip = VideoClip(
            id: UUID(),
            filePath: "/path/to/video.mp4",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0
        )
        
        await videoEditor.addVideoClip(clip)
        
        var project = await videoEditor.project
        XCTAssertEqual(project.timeline.videoClips.count, 1)
        
        try await videoEditor.removeVideoClip(at: 0)
        
        project = await videoEditor.project
        XCTAssertEqual(project.timeline.videoClips.count, 0)
    }
    
    func testTrimVideoClip() async throws {
        let clip = VideoClip(
            id: UUID(),
            filePath: "/path/to/video.mp4",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0
        )
        
        await videoEditor.addVideoClip(clip)
        try await videoEditor.trimVideoClip(at: 0, start: 5.0, end: 30.0)
        
        let project = await videoEditor.project
        let trimmedClip = project.timeline.videoClips[0]
        XCTAssertEqual(trimmedClip.startTime, 5.0)
        XCTAssertEqual(trimmedClip.endTime, 30.0)
    }
    
    func testSplitVideoClip() async throws {
        let clip = VideoClip(
            id: UUID(),
            filePath: "/path/to/video.mp4",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0
        )
        
        await videoEditor.addVideoClip(clip)
        try await videoEditor.splitVideoClip(at: 0, time: 30.0)
        
        let project = await videoEditor.project
        XCTAssertEqual(project.timeline.videoClips.count, 2)
        XCTAssertEqual(project.timeline.videoClips[0].endTime, 30.0)
        XCTAssertEqual(project.timeline.videoClips[1].startTime, 30.0)
    }
    
    func testExport() async throws {
        let exportURL = URL(fileURLWithPath: "/tmp/test_export.mp4")
        
        // Add a clip first so the timeline isn't empty
        let clip = VideoClip(
            id: UUID(),
            filePath: "/path/to/video.mp4",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0
        )
        await videoEditor.addVideoClip(clip)
        
        try await videoEditor.export(to: exportURL)
        
        XCTAssertTrue(mockVideoProcessor.exportCalled)
        XCTAssertEqual(mockVideoProcessor.lastExportURL, exportURL)
    }
    
    func testPreview() async throws {
        // Add a clip first so the timeline isn't empty
        let clip = VideoClip(
            id: UUID(),
            filePath: "/path/to/video.mp4",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0
        )
        await videoEditor.addVideoClip(clip)
        
        _ = try await videoEditor.preview()
        
        XCTAssertTrue(mockVideoProcessor.processCalled)
    }
    
    func testInvalidClipIndex() async {
        do {
            try await videoEditor.removeVideoClip(at: 0)
            XCTFail("Expected error for invalid clip index")
        } catch let error as VideoEditorError {
            XCTAssertEqual(error, VideoEditorError.invalidClipIndex(0))
        } catch {
            XCTFail("Unexpected error type")
        }
    }
    
    func testInvalidTimeRange() async {
        let clip = VideoClip(
            id: UUID(),
            filePath: "/path/to/video.mp4",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0
        )
        
        await videoEditor.addVideoClip(clip)
        
        do {
            try await videoEditor.trimVideoClip(at: 0, start: 30.0, end: 10.0)
            XCTFail("Expected error for invalid time range")
        } catch let error as VideoEditorError {
            XCTAssertEqual(error, VideoEditorError.invalidTimeRange(start: 30.0, end: 10.0))
        } catch {
            XCTFail("Unexpected error type")
        }
    }
    
    func testApplyEffect() async throws {
        let clip = VideoClip(
            id: UUID(),
            filePath: "/path/to/video.mp4",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0
        )
        
        await videoEditor.addVideoClip(clip)
        
        let effect = Effect(
            name: "Blur",
            type: .blur,
            startTime: 0.0,
            duration: 5.0,
            intensity: 0.5
        )
        
        try await videoEditor.applyEffect(effect, toVideoClipAt: 0)
        
        let project = await videoEditor.project
        XCTAssertEqual(project.timeline.videoClips[0].effects.count, 1)
        XCTAssertEqual(project.timeline.videoClips[0].effects[0].name, "Blur")
    }
    
    func testUndo() async throws {
        let clip = VideoClip(
            id: UUID(),
            filePath: "/path/to/video.mp4",
            sourceDuration: 60.0,
            startTime: 0.0,
            endTime: 60.0
        )
        
        await videoEditor.addVideoClip(clip)
        
        var project = await videoEditor.project
        XCTAssertEqual(project.timeline.videoClips.count, 1)
        
        let undoResult = await videoEditor.undo()
        XCTAssertTrue(undoResult)
        
        project = await videoEditor.project
        XCTAssertEqual(project.timeline.videoClips.count, 0)
    }
}

// MARK: - Mock Classes

actor MockVideoProcessor: VideoProcessor {
    var processCalled = false
    var exportCalled = false
    var lastExportURL: URL?
    
    func process(videoProject: VideoProject, timeline: Timeline) async throws -> Data {
        processCalled = true
        return Data()
    }
    
    func export(videoProject: VideoProject, timeline: Timeline, to url: URL) async throws {
        exportCalled = true
        lastExportURL = url
    }
    
    func generateThumbnail(videoProject: VideoProject, timeline: Timeline, at time: TimeInterval, size: CGSize) async throws -> Data {
        return Data()
    }
    
    func extractAudio(from timeline: Timeline, to url: URL) async throws {
        // Mock implementation
    }
    
    func analyzeVideoMetadata(at fileURL: URL) async throws -> [String: Any] {
        return [:]
    }
}
