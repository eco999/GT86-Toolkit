import XCTest
@testable import GT86_Toolkit

final class GT86_ToolkitTests: XCTestCase {

    var obdManager: OBDManager!

    override func setUpWithError() throws {
        obdManager = OBDManager()
    }

    override func tearDownWithError() throws {
        obdManager = nil
    }

    func testInitialConnectionState() throws {
        XCTAssertFalse(obdManager.isConnected, "OBDManager should start disconnected.")
    }

    func testOutputClearsOnConnectToggle() throws {
        obdManager.output = "Previous output"
        obdManager.toggleConnection()
        XCTAssertNotEqual(obdManager.output, "Previous output", "Output should be cleared or updated on connect.")
    }

    func testDumpVehicleInfoUpdatesOutput() throws {
        let expectation = XCTestExpectation(description: "Vehicle info dumped")

        obdManager.output = ""
        obdManager.dumpVehicleInfo()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertFalse(self.obdManager.output.isEmpty, "Output should contain vehicle info after dump.")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testReadAndClearFaultsUpdatesOutput() throws {
        let expectation = XCTestExpectation(description: "Fault codes read and cleared")

        obdManager.output = ""
        obdManager.readAndClearFaults()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertFalse(self.obdManager.output.isEmpty, "Output should contain fault code info after read/clear.")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
}
