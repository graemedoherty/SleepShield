//
//  StatusItemController.swift
//  SleepShield
//
//  Created by Graeme Doherty on 29/11/2025.
//


import Cocoa
import SwiftUI


class StatusItemController {
private var statusItem: NSStatusItem
private var popover: NSPopover
private let deviceController: DeviceController


init(deviceController: DeviceController) {
self.deviceController = deviceController
statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
popover = NSPopover()
popover.contentSize = NSSize(width: 300, height: 220)
popover.behavior = .transient


let contentView = ContentView(viewModel: deviceController)
popover.contentViewController = NSViewController()
popover.contentViewController?.view = NSHostingView(rootView: contentView)


if let button = statusItem.button {
let icon = NSImage(systemSymbolName: "wifi.slash", accessibilityDescription: "SleepShield") ?? NSImage()
icon.isTemplate = true
button.image = icon
button.action = #selector(togglePopover(_:))
button.target = self
}
}


@objc func togglePopover(_ sender: Any?) {
guard let button = statusItem.button else { return }
if popover.isShown {
popover.performClose(sender)
} else {
popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
}
}
}
