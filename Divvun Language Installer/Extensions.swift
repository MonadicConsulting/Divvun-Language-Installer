//
//  Extensions.swift
//  Divvun Language Installer
//
//  Created by Charlotte Tortorella on 14/2/17.
//  Copyright © 2017 Monadic Consulting. All rights reserved.
//

extension String {
    func versionToInt() -> [Int] {
        return self.components(separatedBy: ".")
            .map { Int.init($0) ?? 0 }
    }
}
