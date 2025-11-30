//
//  AppDelegate.swift
//  SleepShield
//
//  Created by Graeme Doherty on 29/11/2025.
//

import Cocoa


class AppDelegate: NSObject, NSApplicationDelegate {
var statusItemController: StatusItemController!
var observer: SystemSleepObserver!
var controller: DeviceController!


func applicationDidFinishLaunching(_ notification: Notification) {
controller = DeviceController()
statusItemController = StatusItemController(deviceController: controller)
observer = SystemSleepObserver(deviceController: controller)
}


func applicationWillTerminate(_ notification: Notification) {
// clean up
}
}
