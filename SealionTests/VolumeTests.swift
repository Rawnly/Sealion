//
//  VolumeTests.swift
//  Sealion
//
//  Created by Dima Bart on 2016-10-07.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import XCTest
import Sealion

class VolumeTests: ModelTestCase {
    
    // ----------------------------------
    //  MARK: - JsonCreatable -
    //
    func testJsonCreation() {
        let model:  Volume = self.modelNamed(name: "volume")
        let region: Region = self.modelNamed(name: "region")
        
        XCTAssertEqual(model.id,          "123")
        XCTAssertEqual(model.name,        "test")
        XCTAssertEqual(model.description, "test volume")
        XCTAssertEqual(model.size,        1)
        XCTAssertEqual(model.dropletIDs,  [123])
        XCTAssertEqual(model.region,      region)
        XCTAssertEqual(model.createdAt,   Date(ISOString: "2016-10-07T12:08:02Z"))
    }
    
    func testEquality() {
        self.assertEqualityForModelNamed(type: Volume.self, name: "volume")
    }
    
    // ----------------------------------
    //  MARK: - Create Request -
    //
    func testCreateRequest() {
        let size        = 100
        let name        = "volume"
        let region      = "nyc3"
        let description = "A large volume"
        let request     = Volume.CreateRequest(size: size, name: name, region: region, description: description)
        
        let json = request.json
        
        XCTAssertEqual(json["size_gigabytes"] as! Int,    size)
        XCTAssertEqual(json["name"]           as! String, name)
        XCTAssertEqual(json["region"]         as! String, region)
        XCTAssertEqual(json["description"]    as! String, description)
    }
    
    // ----------------------------------
    //  MARK: - Snapshot Request -
    //
    func testSnapshotRequest() {
        let name    = "volume snapshot"
        let request = Volume.SnapshotRequest(name: name)
        
        let json = request.json
        
        XCTAssertEqual(json["name"] as! String, name)
    }
    
    // ----------------------------------
    //  MARK: - Name Request -
    //
    func testNameRequest() {
        let name    = "volume"
        let region  = "nyc3"
        let request = Volume.Name(name: name, region: region)
        
        let json = request.parameters
        
        XCTAssertEqual(json["name"],   name)
        XCTAssertEqual(json["region"], region)
    }
}
