//
//  ViewController.swift
//  Divvun Language Installer
//
//  Created by Charlotte Tortorella on 14/2/17.
//  Copyright © 2017 Monadic Consulting. All rights reserved.
//

import Cocoa
import Decodable

let vendor = "MacVoikko"
let spellerFolder = URL(fileURLWithPath: "\(NSHomeDirectory())/Library/Speller/\(vendor)", isDirectory: true)
let jsonUrl = URL(string: "https://www.dropbox.com/s/min9015tba4o167/bundles.json?dl=1")

struct LanguageBundle: Decodable, Equatable, Hashable {
    let name: [String: String]?
    let langCode: String
    let version: String
    let location: URL
    
    static func decode(_ json: Any) throws -> LanguageBundle {
        return try LanguageBundle(name: json => "name",
                                  langCode: json => "code",
                                  version: json => "version",
                                  location: json => "location")
    }
    
    var hashValue: Int {
        return langCode.hash
    }
    
    static func ==(lhs: LanguageBundle, rhs: LanguageBundle) -> Bool {
        return lhs.langCode == rhs.langCode
    }
}

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet var tableView: NSTableView!
    
    var availableBundles: [LanguageBundle] = []
    
    var installedBundles: [LanguageBundle] {
        let contents = (try? FileManager.default.contentsOfDirectory(atPath: spellerFolder.path)) ?? []
        let bundles = contents.filter { $0.hasSuffix(".bundle") }
        return bundles.flatMap { bundleName in
            let url = spellerFolder.appendingPathComponent(bundleName)
            let bundle = Bundle(url: url)
            let name = bundleName.components(separatedBy: ".").first
            return Optional<LanguageBundle>.map(name, bundle?.infoDictionary?["CFBundleShortVersionString"] as? String) {
                LanguageBundle(name: nil, langCode: $0, version: $1, location: url)
            }
        }
    }
    
    var downloadsInProgress: Set<LanguageBundle> = Set()

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global().async {
            do {
                self.availableBundles = try jsonUrl.flatMap { url -> Any? in
                    try JSONSerialization.jsonObject(with: Data(contentsOf: url), options: [])
                }.flatMap {
                    $0 as? [String: AnyObject]
                }.flatMap {
                    $0["bundles"] as? [Any]
                }.flatMap {
                    try [LanguageBundle].decode($0)
                } ?? []
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Network error: \(error)")
            }
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if availableBundles.count != 0 {
            return availableBundles.count
        }
        return 1
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return nil
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        switch tableColumn.flatMap(tableView.tableColumns.index) {
        case 0?:
            return leftColumnView(forRow: row)
        default:
            return rightColumnView(forRow: row)
        }
    }
    
    func leftColumnView(forRow row: Int) -> NSView? {
        guard !availableBundles.isEmpty else {
            let label = NSTextField(labelWithString: "Loading...")
            label.font = NSFont.systemFont(ofSize: 24)
            return label
        }
        return Optional<NSView>.map(availableBundles[row].name, Locale.current.languageCode) { name, code in
            let string = "\(name[code] ?? name["en"] ?? "") (\(availableBundles[row].version))"
            let label = NSTextField(labelWithString: string)
            label.font = NSFont.systemFont(ofSize: 24)
            return label
        }
    }
    
    func rightColumnView(forRow row: Int) -> NSView? {
        guard !availableBundles.isEmpty else {
            return nil
        }
        
        let availableBundle = availableBundles[row]
        let installedVersionOfBundle = installedBundles.first(where: { $0.langCode == availableBundle.langCode })?.version
        let button: NSButton
        
        switch (downloadsInProgress.contains(availableBundle), installedVersionOfBundle) {
        case (true, _):
            button = NSButton(title: "Downloading", target: nil, action: nil)
            button.isEnabled = false
        case (_, let installedVersion?):
            if installedVersion.versionToInt().lexicographicallyPrecedes(availableBundle.version.versionToInt()) {
                print(installedVersion.versionToInt(), availableBundle.version.versionToInt())
                button = NSButton(title: "Update", target: self, action: #selector(self.installBundle))
                button.tag = row
            } else {
                button = NSButton(title: "Installed", target: nil, action: nil)
                button.isEnabled = false
            }
        case (_, nil):
            button = NSButton(title: "Install", target: self, action: #selector(self.installBundle))
            button.tag = row
        }
        return button
    }
    
    func installBundle(sender: AnyObject) {
        if let index = (sender as? NSControl)?.tag {
            let bundle = availableBundles[index]
            downloadsInProgress.insert(bundle)
            tableView.reloadData()
            
            DispatchQueue.global().async {
                DMGUnarchiver.unarchive(url: bundle.location, outputFolder: spellerFolder, callback: {
                    self.downloadsInProgress.remove(bundle)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }, failure: {
                    print($0)
                })
            }
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }
}

