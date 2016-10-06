//
//  API+Volumes.swift
//  Sealion
//
//  Created by Dima Bart on 2016-10-04.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

public extension API {
    
    typealias VolumeFilter = (name: String, regionSlug: String)
    
    public func volumes(completion: @escaping (_ result: Result<[Volume]>) -> Void) -> Handle {
        let request = self.requestTo(endpoint: .volumes, method: .get)
        let handle    = self.taskWith(request: request, keyPath: "volumes", completion: completion)
        
        handle.resume()
        return handle
    }
    
    public func create(volume: Volume.CreateRequest, completion: @escaping (_ result: Result<[Volume]>) -> Void) -> Handle {
        let request = self.requestTo(endpoint: .volumes, method: .post, payload: volume)
        let handle    = self.taskWith(request: request, keyPath: "volumes", completion: completion)
        
        handle.resume()
        return handle
    }
    
    public func volumeWith(id: String, completion: @escaping (_ result: Result<Volume>) -> Void) -> Handle {
        let request = self.requestTo(endpoint: .volumeWith(id), method: .get)
        let handle    = self.taskWith(request: request, keyPath: "volume", completion: completion)
        
        handle.resume()
        return handle
    }
    
    public func volumeWith(filter: VolumeFilter, completion: @escaping (_ result: Result<[Volume]>) -> Void) -> Handle {
        let parameters = [
            "name"   : filter.name,
            "region" : filter.regionSlug,
        ]
        let request = self.requestTo(endpoint: .volumes, method: .get, parameters: parameters)
        let handle    = self.taskWith(request: request, keyPath: "volumes", completion: completion)
        
        handle.resume()
        return handle
    }
    
    public func delete(volume id: String, completion: @escaping (_ result: Result<Volume>) -> Void) -> Handle {
        let request = self.requestTo(endpoint: .volumeWith(id), method: .delete)
        let handle    = self.taskWith(request: request, completion: completion)
        
        handle.resume()
        return handle
    }
    
    public func delete(volume filter: VolumeFilter, completion: @escaping (_ result: Result<Volume>) -> Void) -> Handle {
        let parameters = [
            "name"   : filter.name,
            "region" : filter.regionSlug,
        ]
        let request = self.requestTo(endpoint: .volumes, method: .delete, parameters: parameters)
        let handle    = self.taskWith(request: request, completion: completion)
        
        handle.resume()
        return handle
    }
}
