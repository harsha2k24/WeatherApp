//
//  Utils.swift
//  WeatherApp
//
//  Created by Harsha on 11/06/24.
//

import Foundation
// For test case execution added global functions
func runOnMainThread(_ work: @escaping () -> Void) {
    if Thread.isMainThread {
        work()
        return
    }
    DispatchQueue.main.async(execute: work)
}
