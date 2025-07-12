import Testing
import Foundation
@testable import ci_testing

@Test func connectToPostgres() async throws {
    #if os(macOS)
    let res = try Sh.run("/opt/homebrew/opt/postgresql@17/bin/psql -h localhost -p 5432 -d testing -U testing", paras: ["PGPASSWORD" : "123456"])
    #else
    let res = try Sh.run("psql -h localhost -p 5432 -d testing -U testing", paras: ["PGPASSWORD" : "123456"])
    #endif
    
    if let res = String(data: res.res, encoding: .utf8) {
        print(res)
    }
    
    #expect(res.code == 0)
}

@Test func connectToPostgres2() async throws {
    #if os(macOS)
    let res = try Sh.run("/opt/homebrew/opt/postgresql@17/bin/psql -h localhost -p 5432 -d testing2 -U testing", paras: ["PGPASSWORD" : "pass1"])
    #else
    let res = try Sh.run("psql -h localhost -p 5432 -d testing2 -U testing", paras: ["PGPASSWORD" : "pass1"])
    #endif
    
    if let res = String(data: res.res, encoding: .utf8) {
        print(res)
    }
    
    #expect(res.code == 0)
}

@Test func connectToPostgres3() async throws {
    #if os(macOS)
    let res = try Sh.run("/opt/homebrew/opt/postgresql@17/bin/psql -h localhost -p 5433 -d db1 -U user1", paras: ["PGPASSWORD" : "pass1"])
    #else
    let res = try Sh.run("psql -h localhost -p 5433 -d db1 -U user1", paras: ["PGPASSWORD" : "pass1"])
    #endif
    
    if let res = String(data: res.res, encoding: .utf8) {
        print(res)
    }
    
    #expect(res.code == 0)
}
