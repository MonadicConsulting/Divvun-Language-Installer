//
//  DMGUnarchiver.swift
//  Divvun Language Installer
//
//  Created by Charlotte Tortorella on 15/2/17.
//  Copyright © 2017 Monadic Consulting. All rights reserved.
//

import Foundation

struct DMGUnarchiver {
    static func unarchive(url: URL, outputFolder: URL, password: String? = nil, callback: @escaping () -> Void, failure: @escaping (String) -> Void) {
        let mountPoint = URL(fileURLWithPath: "/Volumes").appendingPathComponent(NSUUID().uuidString)
        
        DispatchQueue.global().async {
            let path = URL(fileURLWithPath: "/tmp").appendingPathComponent(NSUUID().uuidString)
            guard (try? Data(contentsOf: url).write(to: path)) != nil else { return }

            var arguments = ["attach", path.path, "-mountpoint", mountPoint.path, "-nobrowse", "-noautoopen"]
            var promptData = "yes\n".data(using: .ascii)!
            
            if let password = password, let terminator = "\0".data(using: .ascii), var data = password.data(using: .utf8) {
                data.append(terminator)
                promptData = data
                arguments.append("-stdinpass")
            }
            
            let mountProcess = Process()
            mountProcess.launchPath = "/usr/bin/hdiutil"
            mountProcess.currentDirectoryPath = "/"
            mountProcess.arguments = arguments
            
            let input = Pipe()
            let output = Pipe()
            mountProcess.standardInput = input
            mountProcess.standardOutput = output
            
            mountProcess.launch()
            
            input.fileHandleForWriting.write(promptData)
            input.fileHandleForWriting.closeFile()
            
            let outputData = output.fileHandleForReading.readDataToEndOfFile()
            
            mountProcess.waitUntilExit()
            
            let terminationStatus = mountProcess.terminationStatus
            
            guard terminationStatus == 0 else {
                failure("hdiutil failed with code: \(terminationStatus) data: <<\(outputData.map { String(format: "%c", $0) }.joined())>>")
                return
            }
            
            guard let contents = try? FileManager.default.contentsOfDirectory(atPath: mountPoint.path) else {
                return
            }
            
            contents.forEach { item in
                let inputPath = mountPoint.appendingPathComponent(item)
                let outputPath = outputFolder.appendingPathComponent(item)
                guard FileManager.default.isReadableFile(atPath: inputPath.path) else { return }
                try? FileManager.default.copyItem(at: inputPath, to: outputPath)
            }
            
            callback()
            
            let unmountProcess = Process()
            unmountProcess.launchPath = "/usr/bin/hdiutil"
            unmountProcess.arguments = ["detach", mountPoint.path, "-force"]
            unmountProcess.standardOutput = Pipe()
            unmountProcess.standardError = Pipe()
            unmountProcess.launch()
        }
    }
}
