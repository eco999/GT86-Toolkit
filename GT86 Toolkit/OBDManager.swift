import Foundation
import SwiftOBD2
import Combine

class OBDManager: ObservableObject {
    @Published var output: String = ""
    @Published var isConnected: Bool = false
    
    private var obdService = OBDService(connectionType: .bluetooth)
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        obdService.$connectionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.isConnected = (state == .connectedToVehicle)
                
                let stateDescription: String
                switch state {
                case .disconnected:
                    stateDescription = "Disconnected"
                case .connectedToAdapter:
                    stateDescription = "Connected to Adapter"
                case .connectedToVehicle:
                    stateDescription = "Connected to Vehicle"
                @unknown default:
                    stateDescription = "Unknown State"
                }
                
                self?.output += "\nConnection state: \(stateDescription)"
            }
            .store(in: &cancellables)
    }
    
    func toggleConnection() {
        Task {
            if isConnected {
                obdService.stopConnection()
                await MainActor.run {
                    output += "\nDisconnected.\n"
                }
            } else {
                do {
                    let info = try await obdService.startConnection(preferedProtocol: .protocol6)
                    await MainActor.run {
                        let pidDescriptions = (info.supportedPIDs ?? []).map { "\($0)" }.joined(separator: ", ")
                        output += "\nConnected. Supported PIDs: \(pidDescriptions)"
                    }
                } catch {
                    await MainActor.run {
                        output += "\nConnection failed: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    func readAndClearFaults() {
        Task {
            do {
                let codes = try await obdService.scanForTroubleCodes()
                await MainActor.run {
                    output += "\nTrouble Codes:\n"
                    for (ecuid, troubleCodes) in codes {
                        output += "ECU: \(ecuid)\n"
                        for code in troubleCodes {
                            output += " - \(code.code): \(code.description)\n"
                        }
                    }
                }
                
                try await obdService.clearTroubleCodes()
                await MainActor.run {
                    output += "\nFault codes cleared."
                }
            } catch {
                await MainActor.run {
                    output += "\nError: \(error.localizedDescription)"
                }
            }
        }
    }
    
    
    func dumpVehicleInfo() {
        Task {
            do {
                let info = try await obdService.startConnection(preferedProtocol: .protocol6)
                let pidDescriptions = (info.supportedPIDs ?? []).map { "\($0)" }.joined(separator: ", ")
                output = ""
                await MainActor.run {
                    output += """
                    
                    Vehicle Info:
                    Supported PIDs: \(pidDescriptions)
                    """
                }
            } catch {
                await MainActor.run {
                    output += "\nError retrieving vehicle info: \(error.localizedDescription)"
                }
            }
        }
    }
}
