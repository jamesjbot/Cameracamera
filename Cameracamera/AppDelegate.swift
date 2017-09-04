//
//  AppDelegate.swift
//  Cameracamera
//
//  Created by James Jongsurasithiwat on 8/8/17.
//  Copyright © 2017 James Jongsurasithiwat. All rights reserved.
//

import UIKit
import CoreData
import SwiftyBeaver

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    override init() {
        super.init()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }


}

// MARK: -
// MARK: SwiftyBeaver Logging Implementation

extension AppDelegate {

    fileprivate func checkIfFirstLaunched() {

        setupSwiftyBeaverLogging()
        createLogEntryForPathToDocumentsDirectory()
    }


    private func setupSwiftyBeaverLogging() {

        deletePreviousSwiftyBeaverLogfile()
        createNewSwiftyBeaverLogfile()
    }


    private func deletePreviousSwiftyBeaverLogfile() {

        let fileManager = FileManager.default
        let cachedirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        var swiftybeaverPath = cachedirectory[0].appendingPathComponent("swiftybeaver")
        swiftybeaverPath = swiftybeaverPath.appendingPathExtension("log")
        try? fileManager.removeItem(at: swiftybeaverPath)
    }


    private func createNewSwiftyBeaverLogfile() {

        let file = FileDestination()
        file.format = "$DEEEE MMMM dd yyyy HH:mm:sss$d $L: $M: "
        SwiftyBeaver.addDestination(file)
        SwiftyBeaver.info("Starting New Run.....")
    }


    private func createLogEntryForPathToDocumentsDirectory() {

        #if arch(i386) || arch(x86_64)
            if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
                SwiftyBeaver.info("Documents Directory: \(documentsPath)")
            }
        #endif
    }
}








