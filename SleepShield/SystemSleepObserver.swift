//
//  SystemSleepObserver.swift
//  SleepShield
//
//  Created by Graeme Doherty on 29/11/2025.
//

import Foundation
import AppKit


class SystemSleepObserver {
private var observers = [NSObjectProtocol]()
private weak var deviceController: DeviceController?


init(deviceController: DeviceController) {
self.deviceController = deviceController
let nc = NSWorkspace.shared.notificationCenter


observers.append(nc.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: .main) { [weak self] _ in
self?.handleSleep()
})


observers.append(nc.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
self?.handleWake()
})


// Also listen for system power notifications using IOKit: lid-close is typically a sleep event, so willSleep covers that.
}


deinit {
for o in observers { NotificationCenter.default.removeObserver(o) }
}


private func handleSleep() {
deviceController?.handleSystemSleep()
}


private func handleWake() {
deviceController?.handleSystemWake()
}
}
