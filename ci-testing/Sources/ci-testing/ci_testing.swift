import Foundation

struct Sh {
    static func run(_ arguments: [String], paras: [String: String] = [:]) throws -> (code: Int32, res: Data) {
        let task = Process()
        let pipe = Pipe()
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        task.environment = ProcessInfo.processInfo.environment.merging(paras) { (_, new) in new }
        task.arguments = arguments
        task.standardOutput = pipe
        task.standardError = pipe
        try task.run()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return (task.terminationStatus, data)
    }
    
    static func run(_ command: String, paras: [String: String] = [:]) throws -> (code: Int32, res: Data) {
        try run(["-c", command], paras: paras)
    }

    static func run(in path: String, paras: [String: String] = [:]) throws -> (code: Int32, res: Data) {
        try run([path], paras: paras)
    }
}
