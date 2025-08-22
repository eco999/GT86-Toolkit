import SwiftUI

struct ContentView: View {
    @StateObject private var obdManager = OBDManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("GT86 Toolkit")
                .font(.largeTitle)
                .bold()

            Button(obdManager.isConnected ? "Disconnect" : "Connect") {
                obdManager.output = ""
                obdManager.toggleConnection()
            }
            .buttonStyle(.borderedProminent)

            Button("Read & Clear Fault Codes") {
                obdManager.output = ""
                obdManager.readAndClearFaults()
            }
            .buttonStyle(.bordered)

            Button("Vehicle Info Dump") {
                obdManager.output = ""
                obdManager.dumpVehicleInfo()
            }
            .buttonStyle(.bordered)

            ScrollView {
                Text(obdManager.output)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
    }
}
