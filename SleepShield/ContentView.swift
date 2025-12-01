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
                    .font(.headline)
            }
            
            Toggle(isOn: $viewModel.disableWiFiOnSleep) {
                Text("Turn off Wi‑Fi on sleep")
            }
            .disabled(!viewModel.enabled)
            
            Divider()
            
            // Battery Statistics
            if let sleepBattery = viewModel.sleepBatteryLevel,
               let wakeBattery = viewModel.wakeBatteryLevel,
               let drain = viewModel.batteryDrainPercentage,
               let sleepTime = viewModel.sleepTime,
               let wakeTime = viewModel.wakeTime {
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Last Sleep Session")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("Slept:")
                        Spacer()
                        Text(formatTimestamp(sleepTime))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Woke:")
                        Spacer()
                        Text(formatTimestamp(wakeTime))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                        .padding(.vertical, 2)
                    
                    HStack {
                        Text("Sleep:")
                        Spacer()
                        Text("\(sleepBattery)%")
                            .foregroundColor(.green)
                    }
                    .font(.caption)
                    
                    HStack {
                        Text("Wake:")
                        Spacer()
                        Text("\(wakeBattery)%")
                            .foregroundColor(wakeBattery < 20 ? .red : .primary)
                    }
                    .font(.caption)
                    
                    HStack {
                        Text("Drain:")
                        Spacer()
                        Text("\(drain)%")
                            .foregroundColor(drain > 10 ? .red : drain > 5 ? .orange : .green)
                            .fontWeight(.semibold)
                    }
                    .font(.caption)
                }
                .padding(8)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(6)
                
                Divider()
            }
            
            HStack {
                Text("Status:")
                    .font(.caption)
                Spacer()
                Text(viewModel.lastActionMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            HStack {
                Button(action: testSleep) {
                    Text("Simulate Sleep")
                }
                .disabled(!viewModel.enabled)
                
                Spacer()
                
                Button(action: testWake) {
                    Text("Simulate Wake")
                }
                .disabled(!viewModel.enabled)
            }
        }
        .padding()
        .frame(width: 350)
    }
    
    func testSleep() {
        viewModel.handleSystemSleep()
    }

    func testWake() {
        viewModel.handleSystemWake()
    }
    
    func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
}
