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
        VStack(alignment: .leading, spacing: 16) {

            Toggle(isOn: $viewModel.enabled) {
                HStack {
                    Text("Enable SleepShield")
                        .font(.headline)
                    Spacer()
                }
            }
            .toggleStyle(.switch)
            
            Divider()

            Toggle(isOn: $viewModel.disableWiFiOnSleep) {
                HStack {
                    Text("Turn off Wi-Fi on sleep")
                    Spacer()
                }
            }
            .disabled(!viewModel.enabled)
            .toggleStyle(.switch)

            // MARK: - Launch at Login Toggle
            Toggle(isOn: Binding(
                get: { viewModel.launchAtLogin },
                set: { newValue in
                    viewModel.launchAtLogin = newValue
                    viewModel.setLaunchAtLogin(enabled: newValue)
                }
            )) {
                HStack {
                    Text("Start SleepShield at login")
                    Spacer()   // ← pushes the toggle to the far right
                }
            }
            .toggleStyle(.switch)


            Divider()

            // MARK: - Battery Statistics
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

            // MARK: - Status Row
            HStack {
                Text("Status:")
                    .font(.caption)
                Spacer()
                Text(viewModel.lastActionMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            // MARK: - Test Buttons
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

