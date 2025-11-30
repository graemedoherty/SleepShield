//
//  ContentView.swift
//  SleepShield
//
//  Created by Graeme Doherty on 29/11/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: DeviceController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $viewModel.enabled) {
                Text("Enable SleepShield")
            }
            Toggle(isOn: $viewModel.disableWiFiOnSleep) {
                Text("Turn off Wi‑Fi on sleep")
            }
            
            Divider()
            
            HStack {
                Text("Last action:")
                Spacer()
                Text(viewModel.lastActionMessage)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            HStack {
                Button(action: testSleep) { Text("Simulate Sleep") }
                Spacer()
                Button(action: testWake) { Text("Simulate Wake") }
            }
        }
        .padding()
        .frame(width: 300)
    }
    
    func testSleep() {
        viewModel.handleSystemSleep()
    }

    func testWake() {
        viewModel.handleSystemWake()
    }
}
