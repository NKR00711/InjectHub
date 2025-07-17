//
//  ShellManager.swift
//  InjectHub
//
//  Created by NKR on 15/07/25.
//

import Foundation
import SwiftUI
import AppKit

final class ShellManager {

    static let shared = ShellManager()
    private let passwordManager = PasswordManager()

    @AppStorage("stripCodeSign") private var stripCodeSign = false
    @AppStorage("noBackup") private var noBackup = false
    @AppStorage("autoDeQuarantine") private var autoDeQuarantine = true
    @AppStorage("dummyCodeSign") private var dummyCodeSign = true
    @AppStorage("specialInject") private var specialInject = false
    @ObservedObject var logManager: LogManager

    private init(logManager: LogManager = .shared) {
        self.logManager = logManager
    }

    /// Check if the current user is root
    func isRunningAsRootViaAppleScript(password: String? = nil, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            let finalPassword: String

            if let pwd = password {
                finalPassword = pwd
            } else if let stored = self.passwordManager.getPassword() {
                finalPassword = stored
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            let script = """
            do shell script "whoami" with administrator privileges password "\(finalPassword)"
            """
            
            let appleScript = "osascript -e '\(script)'"
            let process = Process()
            process.launchPath = "/bin/zsh" // or "/bin/bash"
            process.arguments = ["-c", appleScript]
            
            // Set up pipes to capture output and error
            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe
            
            process.launch()
            process.waitUntilExit() // Optional: Wait for the script to finish
            
            // Capture output
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            
            let outputString = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let errorString = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                if process.terminationStatus == 0 {
//                    self.logManager.addLog("Output: \(outputString)", type: .info)
                    completion(outputString == "root")
                } else {
//                    self.logManager.addLog("Error: \(errorString)", type: .error)
                    print("Error: \(errorString)")
                    completion(false)
                }
            }

//            var errorDict: NSDictionary? = nil
//            if let result = NSAppleScript(source: script)?.executeAndReturnError(&errorDict) {
//                let user = result.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines)
//                DispatchQueue.main.async {
//                    completion(user == "root")
//                }
//            } else {
//                let errorMessage = errorDict?[NSAppleScript.errorMessage] as? String ?? "Unknown"
//                DispatchQueue.main.async {
//                    self.logManager.addLog("AppleScript error: \(errorMessage)", type: .error)
//                    completion(false)
//                }
//            }
        }
    }

    /// Run a shell command as root using stored password
    func runCommandAsRoot(_ command: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let password = passwordManager.getPassword() else {
            logManager.addLog("❌ Password not found for root execution", type: .error)
            completion(.failure(ShellError.passwordNotFound))
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let fullCommand = """
        do shell script "\(command.replacingOccurrences(of: "\"", with: "\\\""))" with administrator privileges password "\(password)" without altering line endings
        """
            
            let appleScript = "osascript -e '\(fullCommand)'"
            let process = Process()
            process.launchPath = "/bin/zsh" // or "/bin/bash"
            process.arguments = ["-c", appleScript]
            
            // Set up pipes to capture output and error
            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe
            
            process.launch()
            process.waitUntilExit() // Optional: Wait for the script to finish
            
            // Capture output
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            
            let outputString = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let errorString = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                if process.terminationStatus == 0 {
                    self.logManager.addLog("✅ Command Successfull", type: .success)
                    completion(.success(outputString))
                } else {
                    self.logManager.addLog("❌ Command failed:\n\(errorString)", type: .error)
                    completion(.failure(ShellError.appleScriptError(errorString)))
                }
            }
            
//            let appleScript = NSAppleScript(source: fullCommand)
//            
//            var errorDict: NSDictionary? = nil
//            if let result = appleScript?.executeAndReturnError(&errorDict) {
//                let output = result.stringValue ?? "(no output)"
//                self.logManager.addLog("✅ Command Successfull", type: .success)
//                completion(.success(output))
//            } else {
//                let errorMessage = (errorDict?[NSAppleScript.errorMessage] as? String) ?? "Unknown AppleScript error"
//                self.logManager.addLog("❌ Command failed:\n\(errorMessage)", type: .error)
//                completion(.failure(ShellError.appleScriptError(errorMessage)))
//            }
        }
    }
    
    func runCommandInTerminal(_ command: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Create a new thread to run the command
        DispatchQueue.global(qos: .userInitiated).async {
            // Prepare the process
            let process = Process()
            let pipe = Pipe()
            self.logManager.addLog("\(command)", type: .info)
            // Set the command to run
            process.executableURL = URL(fileURLWithPath: "/bin/bash") // or "/bin/bash"
            process.arguments = ["-c", command]
            process.standardOutput = pipe
            process.standardError = pipe
            
            // Launch the process
            do {
                try process.run()
            } catch {
                self.logManager.addLog("Failed to start process: \(error.localizedDescription)", type: .error)
                completion(.failure(ShellError.appleScriptError("Failed to start process: \(error.localizedDescription)")))
                return
            }
            
            // Read the output
            let outputHandle = pipe.fileHandleForReading
            var outputData = Data()
            
            // Read the output asynchronously
            outputHandle.readabilityHandler = { fileHandle in
                let data = fileHandle.availableData
                if data.count > 0 {
                    outputData.append(data)
                    self.logManager.addLog(String(data: data, encoding: .utf8) ?? "", type: .debug)
                } else {
                    // End of file
                    fileHandle.readabilityHandler = nil
                    let outputString = String(data: outputData, encoding: .utf8) ?? ""
                    completion(.success(outputString))
                }
            }
            
            // Wait for the process to finish
            process.waitUntilExit()
        }
    }

    enum ShellError: Error, LocalizedError {
        case passwordNotFound
        case appleScriptError(String)

        var errorDescription: String? {
            switch self {
            case .passwordNotFound:
                return "No password stored. Please enter your admin password."
            case .appleScriptError(let msg):
                return msg
            }
        }
    }
    
    func isSIPDisabled() -> Bool {
        let process = Process()
        let pipe = Pipe()

        process.launchPath = "/usr/bin/csrutil"
        process.arguments = ["status"]
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
        } catch {
            self.logManager.addLog("Failed to run csrutil: \(error)", type: .error)
            print("Failed to run csrutil: \(error)")
            return false
        }

        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        return output.lowercased().contains("disabled")
    }
    
    func InjectDylib(targetPath: URL?, dylibPath: URL?) {
            let sourcePath = dylibPath!.path
            let destinationDir = targetPath!.deletingLastPathComponent().path
            let destinationPath = "\(destinationDir)/\(dylibPath!.lastPathComponent)"

            var copyCommand = "cp \"\(sourcePath)\" \"\(destinationPath)\""

            guard let optoolPath = Bundle.main.path(forResource: "insert_dylib", ofType: "") else {
                self.logManager.addLog("❌ insert_dylib binary not found", type: .error)
                print("❌ insert_dylib binary not found")
                return
            }
            let dyLibPathArg = if ShellManager.shared.isSIPDisabled() && specialInject { "\"\(dylibPath!.path)\"" } else { "@executable_path/\(dylibPath!.lastPathComponent)" }
        
            if specialInject {
                copyCommand = "echo Special Inject Enabled"
            }
            self.runCommandAsRoot(copyCommand) {  copyResult in
                self.logManager.addLog("✅ DyLib Placed.", type: .success)
                print("✅ dylib copied:", copyResult)
                var fullCommand = "\"\(optoolPath)\" \(dyLibPathArg) \"\(targetPath!.path)\""

                if !self.noBackup {
                    let backupCommand = """
                    cp "\(targetPath!.path)" "\(targetPath!.path).backup"
                    """
                    
                    self.runCommandAsRoot(backupCommand) {  copyResult in
                        self.logManager.addLog("✅ Backup Done", type: .success)
                        print("✅ backUp Done:", copyResult)
                    }
                }
                
                fullCommand += " --inplace"
                
                if self.stripCodeSign {
                    fullCommand += " --strip-codesig"
                }

                ShellManager.shared.runCommandAsRoot(fullCommand) { result in
                    self.logManager.addLog("✅ Inject Successfull", type: .success)
                    print("✅ Inject Successfull")
                }
                
                if self.autoDeQuarantine {
                    ShellManager.shared.runCommandAsRoot("xattr -rc \"\(targetPath!.path)\"") { result in
                        switch result {
                        case .success(let output):
//                            self.logManager.addLog("Output: \(output)", type: .info)
                            print("Output: \(output)")
                        case .failure(let error):
                            self.logManager.addLog("Error: \(error.localizedDescription)", type: .error)
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }
                
                if self.dummyCodeSign && !self.isSIPDisabled() {
                    ShellManager.shared.runCommandAsRoot("codesign -f -s - --deep \"\(targetPath!.path)\"") { result in
                        switch result {
                        case .success(let output):
//                            self.logManager.addLog("Output: \(output)", type: .info)
                            print("Output: \(output)")
                        case .failure(let error):
                            self.logManager.addLog("Error: \(error.localizedDescription)", type: .error)
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }
            }
//            let process = Process()
//            process.executableURL = optoolPath
//            process.arguments = [dyLibPath, targetPath!.path]
//            process.arguments?.append(contentsOf: noBackup ? ["--inplace"] : [])
//            process.arguments?.append(contentsOf: stripCodeSign ? ["--strip-codesig"] : [])
//            do {
//                try process.run()
//            } catch {
//                print("Failed to run : \(error)")
//                return
//            }
//            process.waitUntilExit()
    }

}
