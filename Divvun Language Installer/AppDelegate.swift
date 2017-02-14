//
//  AppDelegate.swift
//  Divvun Language Installer
//
//  Created by Charlotte Tortorella on 14/2/17.
//  Copyright © 2017 Monadic Consulting. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let process = Process()
        process.launchPath = "/bin/mkdir"
        process.arguments = ["-p", spellerFolder.path]
        process.launch()
        process.waitUntilExit()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

