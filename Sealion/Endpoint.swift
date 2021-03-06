//
//  Endpoint.swift
//  Sealion
//
//  Copyright (c) 2016 Dima Bart
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those
//  of the authors and should not be interpreted as representing official policies,
//  either expressed or implied, of the FreeBSD Project.
//

import Foundation

public enum Endpoint {
    case account
    case actions
    case actionWithID(Int)
    case volumes
    case volumeWithID(String)
    case volumeActions
    case volumeActionsWithID(String)
    case snapshotsForVolume(String)
    case domains
    case domainWithName(String)
    case recordsForDomain(String)
    case recordForDomain(String, Int)
    case droplets
    case dropletWithID(Int)
    case dropletActionsWithID(Int)
    case kernelsForDroplet(Int)
    case snapshotsForDroplet(Int)
    case backupsForDroplet(Int)
    case neighborsForDroplet(Int)
    case neighbors
    case images
    case imageWithID(Int)
    case imageWithSlug(String)
    case imageActionsWithID(Int)
    case snapshots
    case snapshotWithID(Int)
    case sshKeys
    case sshKeyWithID(Int)
    case sshKeyWithFingerprint(String)
    case regions
    case sizes
    case floatingIPs
    case floatingIPWithIP(String)
    case floatingIPActionsWithIP(String)
    case tags
    case tagWithName(String)
    
    public var path: String {
        switch self {
        case .account:                           return "account"
        case .actions:                           return "actions"
        case .actionWithID(let id):              return "actions/\(id)"
        case .volumes:                           return "volumes"
        case .volumeWithID(let id):              return "volumes/\(id)"
        case .volumeActions:                     return "volumes/actions"
        case .volumeActionsWithID(let id):       return "volumes/\(id)/actions"
        case .snapshotsForVolume(let id):        return "volumes/\(id)/snapshots"
        case .domains:                           return "domains"
        case .domainWithName(let name):          return "domains/\(name)"
        case .recordsForDomain(let name):        return "domains/\(name)/records"
        case .recordForDomain(let name, let id): return "domains/\(name)/records/\(id)"
        case .droplets:                          return "droplets"
        case .dropletWithID(let id):             return "droplets/\(id)"
        case .dropletActionsWithID(let id):      return "droplets/\(id)/actions"
        case .kernelsForDroplet(let id):         return "droplets/\(id)/kernels"
        case .snapshotsForDroplet(let id):       return "droplets/\(id)/snapshots"
        case .backupsForDroplet(let id):         return "droplets/\(id)/backups"
        case .neighborsForDroplet(let id):       return "droplets/\(id)/neighbors"
        case .neighbors:                         return "reports/droplet_neighbors"
        case .images:                            return "images"
        case .imageWithID(let id):               return "images/\(id)"
        case .imageWithSlug(let slug):           return "images/\(slug)"
        case .imageActionsWithID(let id):        return "images/\(id)/actions"
        case .snapshots:                         return "snapshots"
        case .snapshotWithID(let id):            return "snapshots/\(id)"
        case .sshKeys:                           return "account/keys"
        case .sshKeyWithID(let id):              return "account/keys/\(id)"
        case .sshKeyWithFingerprint(let f):      return "account/keys/\(f)"
        case .regions:                           return "regions"
        case .sizes:                             return "sizes"
        case .floatingIPs:                       return "floating_ips"
        case .floatingIPWithIP(let ip):          return "floating_ips/\(ip)"
        case .floatingIPActionsWithIP(let ip):   return "floating_ips/\(ip)/actions"
        case .tags:                              return "tags"
        case .tagWithName(let name):             return "tags/\(name)"
        }
    }
}
