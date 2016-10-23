//
//  APITests.swift
//  Sealion
//
//  Created by Dima Bart on 2016-10-05.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import XCTest
@testable import Sealion

class APITests: XCTestCase {
    
    let token = "ab837378789f2a87"
    
    let nonPollingHandler: API.PollingHandler = {
        return { result, response in
            return false
        }
    }()
    
    // ----------------------------------
    //  MARK: - Init -
    //
    func testInit() {
        let token = "a1a2a3a4a5a6"
        let version: API.Version = .v2
        
        let api = API(version: version, token: token)
        
        XCTAssertNotNil(api)
        XCTAssertEqual(api.version, version)
        XCTAssertEqual(api.token,   token)
    }
    
    // ----------------------------------
    //  MARK: - URL Generation -
    //
    func testURLGenerationWithoutParameters() {
        let suite = self.create()
        
        let expected = URL(string: "\(API.Version.v2.rawValue)account")!
        let url      = suite.api.urlTo(endpoint: .account)
        
        XCTAssertEqual(expected, url)
    }
    
    func testURLGenerationWithParameters() {
        let suite = self.create()
        
        let parameters = [
            "id"    : "2",
            "image" : "200",
        ]
        
        let expectedWithoutPage = URL(string: "\(API.Version.v2.rawValue)droplets/123456?id=2&image=200")!
        let urlWithoutPage      = suite.api.urlTo(endpoint: .dropletWithID(123456), parameters: parameters)
        
        XCTAssertEqual(expectedWithoutPage, urlWithoutPage)
        
        let page = Page(index: 0, count: 50)
        
        let expectedWithPage = URL(string: "\(API.Version.v2.rawValue)droplets/123456?page=1&per_page=50&id=2&image=200")!
        let urlWithPage      = suite.api.urlTo(endpoint: .dropletWithID(123456), page: page, parameters: parameters)
        
        XCTAssertEqual(expectedWithPage, urlWithPage)
    }
    
    // ----------------------------------
    //  MARK: - Request Generation -
    //
    func testRequestGenerationWithoutPayload() {
        let suite   = self.create()
        let request = suite.api.requestTo(endpoint: .actionWithID(123), method: .get)
        
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(self.token)")
    }
    
    func testRequestGenerationWithPayload() {
        let suite   = self.create()
        let payload = [
            "name"        : "volume",
            "description" : "Test volume",
        ]
        
        let request  = suite.api.requestTo(endpoint: .volumeWithID("volume-identifier"), method: .post, payload: payload)
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(self.token)")
        
        let bodyData     = request.httpBody!
        let expectedData = try! JSONSerialization.data(withJSONObject: payload, options: [])
        
        XCTAssertEqual(bodyData, expectedData)
    }
    
    // ----------------------------------
    //  MARK: - Response Serialization -
    //
    func testResponseWithPayload() {
        
        let suite   = self.create()
        let payload = [
            "item" : [
                "firstName" : "John",
                "lastName"  : "Smith",
            ]
        ]
        suite.session.activateStub(stub: Stub(status: 200, json: payload))
        let handle = self.runTask(api: suite.api, pollHandler: self.nonPollingHandler)
        
        XCTAssertNotNil(handle.response)
        XCTAssertEqual(handle.response!.statusCode, 200)
        
        switch handle.result {
        case .success(let object):
            
            XCTAssertNotNil(object)
            XCTAssertNotNil(object as? JSON, "JSON object is not an expected type.")
            
            let json = object as! JSON
            
            XCTAssertNotNil(json["item"])
            
            let dictionary = json["item"] as! [String : String]
            
            XCTAssertEqual(dictionary["firstName"], "John")
            XCTAssertEqual(dictionary["lastName"],  "Smith")
            
        case .failure:
            XCTFail("Expecting successful response.")
        }
        
        suite.session.deactiveStub()
    }
    
    func testResponseWithKeyPaths() {
        
        let suite   = self.create()
        let payload = [
            "company" : [
                "department" : [
                    "employee" : [
                        "name" : "John Smith"
                    ]
                ]
            ]
        ]
        suite.session.activateStub(stub: Stub(status: 200, json: payload))
        let handle = self.runTask(api: suite.api, keyPath: "company.department.employee", pollHandler: self.nonPollingHandler)
        
        XCTAssertNotNil(handle.response)
        XCTAssertEqual(handle.response!.statusCode, 200)
        
        switch handle.result {
        case .success(let object):
            
            XCTAssertNotNil(object)
            XCTAssertNotNil(object as? JSON, "JSON object is not an expected type.")
            
            let json = object as! [String : String]
            
            XCTAssertEqual(json["name"], "John Smith")
            
        case .failure:
            XCTFail("Expecting successful response.")
        }
        
        suite.session.deactiveStub()
    }
    
    func testResponseWithoutPayload() {
        let suite = self.create()
        
        suite.session.activateStub(stub: Stub(status: 204, json: nil))
        let handle = self.runTask(api: suite.api, pollHandler: self.nonPollingHandler)
        
        XCTAssertNotNil(handle.response)
        XCTAssertEqual(handle.response!.statusCode, 204)
        
        switch handle.result {
        case .success(let object):
            XCTAssertNil(object)
        case .failure:
            XCTFail("Expecting successful response.")
        }

        suite.session.deactiveStub()
    }
    
    func testErrorResponseWithoutPayload() {
        let suite = self.create()
        
        suite.session.activateStub(stub: Stub(status: 404, json: nil))
        let handle = self.runTask(api: suite.api, pollHandler: self.nonPollingHandler)
        
        XCTAssertNotNil(handle.response)
        XCTAssertEqual(handle.response!.statusCode, 404)
        
        switch handle.result {
        case .success:
            XCTFail("Expecting an error response.")
        case .failure(let error, _):
            XCTAssertNil(error)
        }
        
        suite.session.deactiveStub()
    }
    
    func testErrorResponseWithPayload() {
        
        let suite       = self.create()
        let error       = MockError(code: -100, description: "Something went wrong")
        let id          = "1234"
        let name        = "auth_error"
        let description = "You're not allowed in here"
        let payload     = [
            "request_id" : id,
            "id"         : name,
            "message"    : description
        ]
        
        suite.session.activateStub(stub: Stub(status: 403, json: payload, error: error))
        let handle = self.runTask(api: suite.api, pollHandler: self.nonPollingHandler)
        
        XCTAssertNotNil(handle.response)
        XCTAssertEqual(handle.response!.statusCode, 403)
        
        switch handle.result {
        case .success:
            XCTFail("Expecting an error response.")
        case .failure(let error, _):
            XCTAssertNotNil(error)
            XCTAssertEqual(error!.code,        handle.response!.statusCode)
            XCTAssertEqual(error!.id,          id)
            XCTAssertEqual(error!.name,        name)
            XCTAssertEqual(error!.description, description)
        }
        
        suite.session.deactiveStub()
    }
    
    func testNetworkErrorResponse() {
        
        let suite = self.create()
        let error = MockError(code: NSURLErrorNotConnectedToInternet)
        
        suite.session.activateStub(stub: Stub(error: error))
        let handle = self.runTask(api: suite.api, pollHandler: self.nonPollingHandler)
        
        XCTAssertNil(handle.response)
        
        switch handle.result {
        case .success:
            XCTFail("Expecting an error response.")
        case .failure(let error, let reason):
            
            XCTAssertNil(error)
            XCTAssertEqual(reason, .notConnectedToInternet)
        }
        
        suite.session.deactiveStub()
    }
    
    func testPolling() {
        let suite = self.create()
        
        let assertResult: (Result<Any>) -> Void = { result in
            
            switch result {
            case .success(let object):
                
                XCTAssertNotNil(object)
                let json = object as! JSON
                XCTAssertEqual(json["message"] as! String, "OK")
                
            case .failure:
                XCTFail("Expecting a success response.")
            }
        }
        
        let payload = ["message" : "OK"]
        var count   = 0
        
        suite.session.activateStub(stub: Stub(status: 204, json: payload))
        let handle = self.runTask(api: suite.api, pollHandler: { result, response in
            
            assertResult(result)
            count += 1
            
            // Poll while count is less than 3
            return count < 3
        })
        
        XCTAssertEqual(count, 3)
        assertResult(handle.result)
        
        suite.session.deactiveStub()
    }
    
    func testPollingCancellationBeforeRequest() {
        
        let suite = self.create()
        let error = MockError(domain: NSCocoaErrorDomain, code: NSURLErrorCancelled, description: "Request was cancelled")
        
        suite.session.activateStub(stub: Stub(error: error))
        let e = self.expectation(description: "")
        
        let request           = suite.api.requestTo(endpoint: .account, method: .get) // overriden by mock
        let task: Handle<Any> = suite.api.taskWith(request: request, pollHandler: { result, response in
            
            XCTFail("Cancelled request should not execute the polling handler.")
            return true
            
        }, completion: { result, response in
            
            switch result {
            case .success:
                XCTFail("Expecting a failure response.")
            case .failure(let error, let reason):
                XCTAssertNil(error)
                XCTAssertEqual(reason, .cancelled)
            }
            e.fulfill()
        })
        
        task.resume()
        task.cancel()
        
        self.waitForExpectations(timeout: 10.0, handler: nil)
        suite.session.deactiveStub()
    }
    
    // ----------------------------------
    //  MARK: - Model Serialization -
    //
    func testModelSingleResponse() {
        
        let suite   = self.create()
        let payload = [
            "firstName" : "John",
            "lastName"  : "Smith",
        ]
        
        suite.session.activateStub(stub: Stub(status: 200, json: payload))
        let result: Result<Person> = self.runObjectTask(api: suite.api)
        
        switch result {
        case .success(let person):
            XCTAssertNotNil(person)
            XCTAssertEqual(person!.firstName, "John")
            XCTAssertEqual(person!.lastName,  "Smith")
            
        case .failure:
            XCTFail("Expecting a success response.")
        }
        
        suite.session.deactiveStub()
    }
    
    func testModelSingleError() {
        let suite = self.create()
        
        suite.session.activateStub(stub: Stub(status: 404, json: nil))
        let result: Result<Person> = self.runObjectTask(api: suite.api)
        
        switch result {
        case .success:
            XCTFail("Expecting an error response.")
        case .failure(let error, _):
            XCTAssertNil(error)
        }
        
        suite.session.deactiveStub()
    }
    
    func testModelSinglePolling() {
        
        let suite   = self.create()
        let payload = [
            "firstName" : "John",
            "lastName"  : "Smith",
        ]
        
        let assertResult: (Result<Person>) -> Void = { result in
            
            switch result {
            case .success(let person):
                
                XCTAssertNotNil(person)
                XCTAssertEqual(person!.firstName, "John")
                XCTAssertEqual(person!.lastName, "Smith")
                
            case .failure:
                XCTFail("Expecting a success response.")
            }
        }
        
        var count = 0
        
        suite.session.activateStub(stub: Stub(status: 200, json: payload))
        let result: Result<Person> = self.runObjectTask(api: suite.api, pollHandler: { result in
            
            assertResult(result)
            count += 1
            
            // Poll while count is less than 3
            return count < 3
        })
        
        XCTAssertEqual(count, 3)
        assertResult(result)
        
        suite.session.deactiveStub()
    }
    
    func testModelArrayResponse() {
        
        let suite   = self.create()
        let payload = [
            "people": [
                [
                    "firstName" : "John",
                    "lastName"  : "Smith",
                ],
                [
                    "firstName" : "Walter",
                    "lastName"  : "Appleseed",
                ]
            ]
        ]
        
        suite.session.activateStub(stub: Stub(status: 200, json: payload))
        let result: Result<[Person]> = self.runObjectTask(api: suite.api, keyPath: "people")
        
        switch result {
        case .success(let people):
            XCTAssertNotNil(people)
            XCTAssertEqual(people!.count, 2)
            
            guard let people = people else { return }
            
            XCTAssertEqual(people[0].firstName, "John")
            XCTAssertEqual(people[0].lastName,  "Smith")
            XCTAssertEqual(people[1].firstName, "Walter")
            XCTAssertEqual(people[1].lastName,  "Appleseed")
            
        case .failure:
            XCTFail("Expecting a success response.")
        }
        
        suite.session.deactiveStub()
    }
    
    func testModelArrayError() {
        let suite = self.create()
        
        suite.session.activateStub(stub: Stub(status: 404, json: nil))
        let result: Result<[Person]> = self.runObjectTask(api: suite.api)
        
        switch result {
        case .success:
            XCTFail("Expecting an error response.")
        case .failure(let error, _):
            XCTAssertNil(error)
        }
        
        suite.session.deactiveStub()
    }
    
    func testModelArrayPolling() {
        let suite   = self.create()
        let payload = [
            "people": [
                [
                    "firstName" : "John",
                    "lastName"  : "Smith",
                ],
                [
                    "firstName" : "Walter",
                    "lastName"  : "Appleseed",
                ]
            ]
        ]
        
        let assertResult: (Result<[Person]>) -> Void = { result in
            
            switch result {
            case .success(let people):
                
                XCTAssertNotNil(people)
                
                guard let people = people else { return }
                
                XCTAssertEqual(people.count, 2)
                XCTAssertEqual(people[0].firstName, "John")
                XCTAssertEqual(people[0].lastName,  "Smith")
                XCTAssertEqual(people[1].firstName, "Walter")
                XCTAssertEqual(people[1].lastName,  "Appleseed")
                
            case .failure:
                XCTFail("Expecting a success response.")
            }
        }
        
        var count = 0
        
        suite.session.activateStub(stub: Stub(status: 200, json: payload))
        let result: Result<[Person]> = self.runObjectTask(api: suite.api, keyPath: "people", pollHandler: { result in
            
            assertResult(result)
            count += 1
            
            // Poll while count is less than 3
            return count < 3
        })
        
        XCTAssertEqual(count, 3)
        assertResult(result)
        
        suite.session.deactiveStub()
    }
    
    // ----------------------------------
    //  MARK: - Conveniences -
    //
    private func runObjectTask(api: API, keyPath: String? = nil, pollHandler: ((Result<Person>) -> Bool)? = nil) -> Result<Person> {
        var resultOut: Result<Person>!
        
        let e       = self.expectation(description: "")
        let request = api.requestTo(endpoint: .account, method: .get) // overriden by mock
        let task    = api.taskWith(request: request, keyPath: keyPath, pollHandler: pollHandler) { (result: Result<Person>) in
            
            resultOut = result
            e.fulfill()
        }
        task.resume()
        
        self.waitForExpectations(timeout: 10.0, handler: nil)
        return resultOut
    }
    
    private func runObjectTask(api: API, keyPath: String? = nil, pollHandler: ((Result<[Person]>) -> Bool)? = nil) -> Result<[Person]> {
        var resultOut: Result<[Person]>!
        
        let e       = self.expectation(description: "")
        let request = api.requestTo(endpoint: .account, method: .get) // overriden by mock
        let task    = api.taskWith(request: request, keyPath: keyPath, pollHandler: pollHandler) { (result: Result<[Person]>) in
            
            resultOut = result
            e.fulfill()
        }
        task.resume()
        
        self.waitForExpectations(timeout: 10.0, handler: nil)
        return resultOut
    }
    
    private func runTask(api: API, keyPath: String? = nil, pollHandler: @escaping API.PollingHandler) -> (result: Result<Any>, response: HTTPURLResponse?) {
        var resultOut:   Result<Any>!
        var responseOut: HTTPURLResponse?
        
        let e                 = self.expectation(description: "")
        let request           = api.requestTo(endpoint: .account, method: .get) // overriden by mock
        let task: Handle<Any> = api.taskWith(request: request, keyPath: keyPath, pollHandler: pollHandler) { result, response in
            
            resultOut   = result
            responseOut = response
            e.fulfill()
        }
        task.resume()
        
        self.waitForExpectations(timeout: 10.0, handler: nil)
        return (resultOut, responseOut)
    }
    
    // ----------------------------------
    //  MARK: - Creating API -
    //
    private func create() -> (api: API, session: MockSession) {
        let session = MockSession()
        let api     = API(version: .v2, token: self.token, session: session)
        
        return (api, session)
    }
}
