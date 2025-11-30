//
//  DeviceController.swift
//  SleepShield
//
//  Created by Graeme Doherty on 29/11/2025.
//

import Foundation
import Combine
import AppKit

final class DeviceController: ObservableObject {
    @Published var enabled = true
    @Published var disableWiFiOnSleep = true
    @Published var lastActionMessage: String = "Ready"
    
    // Track state so we only re-enable what we disabled
    private var shouldRestoreWiFi: Bool = false
    private var wifiInterface: String = "en0" // default
    private var wifiStateTimer: Timer?
    private var isAsleep: Bool = false // Track if system is asleep
    
    init() {
        // Try to detect the correct WiFi interface on startup
        detectAndSetWiFiInterface()
        
        // Check initial WiFi state
        shouldRestoreWiFi = isWiFiOn()
        print("🎬 Initial WiFi state: \(shouldRestoreWiFi ? "ON" : "OFF")")
        
        // Register for system sleep/wake notifications
        registerForSleepWakeNotifications()
        
        // Track WiFi state periodically (every 30 seconds)
        startWiFiStateTracking()
    }
    
    deinit {
        // Clean up notifications when object is destroyed
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        wifiStateTimer?.invalidate()
    }
    
    // MARK: - WiFi State Tracking
    
    private func startWiFiStateTracking() {
        // Check WiFi state every 30 seconds when awake
        wifiStateTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            // Only update state if we're NOT asleep
            if !self.isAsleep {
                self.shouldRestoreWiFi = self.isWiFiOn()
                print("🔄 Updated WiFi state: \(self.shouldRestoreWiFi ? "ON" : "OFF")")
            }
        }
    }
    
    // MARK: - Sleep/Wake Notification Registration
    
    private func registerForSleepWakeNotifications() {
        let workspaceNotificationCenter = NSWorkspace.shared.notificationCenter
        
        // Listen for sleep notification
        workspaceNotificationCenter.addObserver(
            self,
            selector: #selector(systemWillSleep),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
        
        // Listen for wake notification
        workspaceNotificationCenter.addObserver(
            self,
            selector: #selector(systemDidWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
        
        print("✅ Registered for sleep/wake notifications")
    }
    
    @objc private func systemWillSleep() {
        print("🔔 Received sleep notification")
        handleSystemSleep()
    }
    
    @objc private func systemDidWake() {
        print("🔔 Received wake notification")
        handleSystemWake()
    }
    
    // MARK: - Sleep/Wake Handlers
    
    func handleSystemSleep() {
        guard enabled && disableWiFiOnSleep else { return }
        
        isAsleep = true // Mark that we're asleep
        print("💤 System going to sleep...")
        print("💾 Remembered WiFi state: \(shouldRestoreWiFi ? "was ON" : "was OFF")")
        
        // Always try to turn off WiFi during sleep, regardless of current state
        // We'll rely on our tracked state to know if we should restore it
        setWiFi(powerOn: false)
        publish("Wi‑Fi turned off for sleep")
    }
    
    func handleSystemWake() {
        guard enabled && disableWiFiOnSleep else { return }
        
        isAsleep = false // Mark that we're awake
        print("☀️ System waking up...")
        print("🔍 Should restore WiFi? \(shouldRestoreWiFi ? "YES" : "NO")")
        
        if shouldRestoreWiFi {
            setWiFi(powerOn: true)
            publish("Wi‑Fi restored on wake")
            // Update state after a short delay to let WiFi reconnect
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                guard let self = self else { return }
                self.shouldRestoreWiFi = self.isWiFiOn()
                print("🔄 Verified WiFi state after wake: \(self.shouldRestoreWiFi ? "ON" : "OFF")")
            }
        } else {
            print("ℹ️ WiFi was off before sleep, leaving it off")
        }
    }
    
    // MARK: - Wi‑Fi Control
    
    func detectAndSetWiFiInterface() {
        print("🔍 Detecting Wi-Fi interface...")
        
        // List all hardware ports to find WiFi
        let output = runShell("/usr/sbin/networksetup -listallhardwareports")
        let lines = output.components(separatedBy: "\n")
        
        for i in 0..<lines.count {
            let line = lines[i]
            // Look for "Wi-Fi" or "AirPort" in hardware port name
            if (line.contains("Wi") && line.contains("Fi")) || line.lowercased().contains("airport") {
                // The next line should contain "Device: enX"
                if i + 1 < lines.count {
                    let deviceLine = lines[i + 1]
                    if deviceLine.lowercased().contains("device") {
                        let parts = deviceLine.components(separatedBy: ":")
                        if parts.count >= 2 {
                            let interface = parts[1].trimmingCharacters(in: .whitespaces)
                            print("✅ Found Wi-Fi interface: \(interface)")
                            wifiInterface = interface
                            return
                        }
                    }
                }
            }
        }
        
        print("⚠️ Could not detect Wi-Fi interface, using default: \(wifiInterface)")
    }
    
    func isWiFiOn() -> Bool {
        // Method 1: Try using networksetup -getairportpower
        let output = runShell("/usr/sbin/networksetup -getairportpower \(wifiInterface)")
        
        if output.lowercased().contains(": on") {
            print("📶 WiFi is ON")
            return true
        } else if output.lowercased().contains(": off") {
            print("📵 WiFi is OFF")
            return false
        }
        
        // If command failed, try checking if WiFi service is enabled
        let serviceOutput = runShell("/usr/sbin/networksetup -getnetworkserviceenabled 'Wi-Fi'")
        let isEnabled = serviceOutput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "enabled"
        
        print(isEnabled ? "📶 WiFi service is enabled" : "📵 WiFi service is disabled")
        return isEnabled
    }
    
    func setWiFi(powerOn: Bool) {
        let state = powerOn ? "on" : "off"
        print("🔧 Attempting to turn WiFi \(state)...")
        
        // Method 1: Try using networksetup -setairportpower (most reliable)
        print("📡 Method 1: Using -setairportpower with interface \(wifiInterface)")
        var result = runShell("/usr/sbin/networksetup -setairportpower \(wifiInterface) \(state)")
        
        // Check if it worked
        if result.isEmpty || !result.lowercased().contains("error") {
            print("✅ Successfully set WiFi to \(state) using method 1")
            return
        }
        
        print("⚠️ Method 1 failed: \(result)")
        
        // Method 2: Try the service-based approach
        print("📡 Method 2: Using -setnetworkserviceenabled")
        let enableState = powerOn ? "on" : "off"
        result = runShell("/usr/sbin/networksetup -setnetworkserviceenabled 'Wi-Fi' \(enableState)")
        
        if result.isEmpty || !result.lowercased().contains("error") {
            print("✅ Successfully set WiFi to \(state) using method 2")
            return
        }
        
        print("⚠️ Method 2 failed: \(result)")
        
        // Method 3: Try different common interface names
        print("📡 Method 3: Trying common interface names...")
        for iface in ["en0", "en1", "en2", "en3"] {
            print("  Trying \(iface)...")
            result = runShell("/usr/sbin/networksetup -setairportpower \(iface) \(state)")
            
            if result.isEmpty || !result.lowercased().contains("error") {
                print("✅ Found working interface: \(iface)")
                wifiInterface = iface // Remember this for next time
                return
            }
        }
        
        print("❌ All methods failed to control WiFi")
        publish("Failed to control Wi-Fi - check System Settings permissions")
    }
    
    // MARK: - Shell Helper
    
    @discardableResult
    func runShell(_ command: String) -> String {
        print("🔧 Executing: \(command)")
        
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            print("📤 Output: \(output.isEmpty ? "(empty)" : output)")
            print("✅ Exit code: \(task.terminationStatus)")
            
            return output
        } catch {
            print("❌ Error: \(error)")
            return "Error running command: \(error.localizedDescription)"
        }
    }
    
    // MARK: - UI Helper
    
    private func publish(_ msg: String) {
        DispatchQueue.main.async {
            self.lastActionMessage = msg
            print("📢 \(msg)")
        }
    }
}
