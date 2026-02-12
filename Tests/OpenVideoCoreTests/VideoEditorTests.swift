import XCTest
@testable import OpenVideoCore

final class VideoEditorTests: XCTestCase {
    
    var videoEditor: VideoEditor!
    var mockVideoProcessor: MockVideoProcessor!
    
    override func setUp() {
        super.setUp()
        let project = VideoProject(
            name: "Test Project",
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0,
            duration: 120.0
        )
        mockVideoProcessor = MockVideoProcessor()
        videoEditor = VideoEditor(project: project, videoProcessor: mockVideoProcessor)
    }
    
    override func tearDown() {
        videoEditor = nil
        mockVideoProcessor = nil
        super.tearDown()
    }
    
    func testVideoEditorInitialization() {
        XCTAssertNotNil(videoEditor)
    }
    
    func testAddVideoClip() {
        let clip = VideoClip(
            id: UUID(),
            filePath: "/path/to/video.mp4",
            duration: 60.0,
            startTime: 0.0,
            endTime: 60.0,
            resolution: CGSize(width: 1920, height: 1080),
            frameRate: 30.0
        )
        
        videoEditor.addVideoClip(clip)
        
        // Verify through export or preview that clips are added
        XCTAssertTrue(mockVideoProcessor.processCalled)
    }
    
    func testExport() throws {
        let exportURL = URL(fileURLWithPath: "/tmp/test_export.mp4")
        
        try videoEditor.export(to: exportURL)
        
        XCTAssertTrue(mockVideoProcessor.exportCalled)
        XCTAssertEqual(mockVideoProcessor.lastExportURL, exportURL)
    }
    
    func testPreview() throws {
        _ = try videoEditor.preview()
        
        XCTAssertTrue(mockVideoProcessor.processCalled)
    }
}

// MARK: - Mock Classes

class MockVideoProcessor: VideoProcessor {
    var processCalled = false
    var exportCalled = false
    var lastExportURL: URL?
    
    func process(videoProject: VideoProject, timeline: Timeline) throws -> Data {
        processCalled = true
        return Data()
    }
    
    func export(videoProject: VideoProject, timeline: Timeline, to url: URL) throws {
        exportCalled = true
        lastExportURL = url
    }
}
