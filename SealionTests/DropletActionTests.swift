//
//  DropletActionTests.swift
//  Sealion
//
//  Created by Dima Bart on 2016-10-11.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import XCTest
import Sealion

class DropletActionTests: XCTestCase {
    
    func testPasswordReset() {
        self.assertDropletAction(action: .passwordReset, against: [
            "type" : "password_reset",
        ])
    }
    
    func testEnableBackups() {
        self.assertDropletAction(action: .enableBackups, against: [
            "type" : "enable_backups",
        ])
    }
    
    func testEnableIpv6() {
        self.assertDropletAction(action: .enableIpv6, against: [
            "type" : "enable_ipv6",
        ])
    }
    
    func testEnablePrivateNetworking() {
        self.assertDropletAction(action: .enablePrivateNetworking, against: [
            "type" : "enable_private_networking",
        ])
    }
    
    func testDisableBackups() {
        self.assertDropletAction(action: .disableBackups, against: [
            "type" : "disable_backups",
        ])
    }
    
    func testReboot() {
        self.assertDropletAction(action: .reboot, against: [
            "type" : "reboot",
        ])
    }
    
    func testPowerCycle() {
        self.assertDropletAction(action: .powerCycle, against: [
            "type" : "power_cycle",
        ])
    }
    
    func testShutdown() {
        self.assertDropletAction(action: .shutdown, against: [
            "type" : "shutdown",
        ])
    }
    
    func testPowerOff() {
        self.assertDropletAction(action: .powerOff, against: [
            "type" : "power_off",
        ])
    }
    
    func testPowerOn() {
        self.assertDropletAction(action: .powerOn, against: [
            "type" : "power_on",
        ])
    }
    
    func testRestore() {
        self.assertDropletAction(action: .restore(image: 123), against: [
            "type"  : "restore",
            "image" : 123,
        ])
    }
    
    func testResize() {
        let disk = true
        let size = "1gb"
        self.assertDropletAction(action: .resize(disk: disk, sizeSlug: size), against: [
            "type" : "resize",
            "disk" : disk,
            "size" : size,
        ])
    }
    
    func testRebuild() {
        let image = "123"
        self.assertDropletAction(action: .rebuild(image: image), against: [
            "type"  : "rebuild",
            "image" : image,
        ])
    }
    
    func testRename() {
        let name = "New Droplet"
        self.assertDropletAction(action: .rename(name: name), against: [
            "type" : "rename",
            "name" : name,
        ])
    }
    
    func testChangeKernel() {
        let id = 123
        self.assertDropletAction(action: .changeKernel(id: id), against: [
            "type"   : "change_kernel",
            "kernel" : id,
        ])
    }
    
    func testCreateSnapshot() {
        let name = "New Snapshot"
        self.assertDropletAction(action: .createSnapshot(name: name), against: [
            "type" : "snapshot",
            "name" : name,
        ])
    }
    
    // ----------------------------------
    //  MARK: - Private -
    //
    private func assertDropletAction(action: DropletAction, against expectation: Any) {
        XCTAssertTrue(action.json == expectation as! JSON)
    }
}
