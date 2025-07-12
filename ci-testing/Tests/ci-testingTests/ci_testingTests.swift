import Testing
import Foundation
@testable import ci_testing

@Test func connectToPostgres() async throws {
    let res = try Sh.run("psql -h localhost -p 5432 -d testing -U testing", paras: ["PGPASSWORD" : "123456"])
    
    if let res = String(data: res.res, encoding: .utf8) {
        print(res)
    }
    
    #expect(res.code == 0)
}

@Test func connectToPostgres2() async throws {
    let res = try Sh.run("psql -h localhost -p 5432 -d testing2 -U testing", paras: ["PGPASSWORD" : "pass1"])
    
    if let res = String(data: res.res, encoding: .utf8) {
        print(res)
    }
    
    #expect(res.code == 0)
}

@Test func connectToPostgres3() async throws {
    let res = try Sh.run("psql -h localhost -p 5433 -d db1 -U user1", paras: ["PGPASSWORD" : "pass1"])
    
    if let res = String(data: res.res, encoding: .utf8) {
        print(res)
    }
    
    #expect(res.code == 0)
}
