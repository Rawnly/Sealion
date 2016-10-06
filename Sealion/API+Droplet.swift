//
//  API+Droplet.swift
//  Sealion
//
//  Created by Dima Bart on 2016-10-05.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

public extension API {
    
    public func droplets(completion: @escaping (_ result: Result<[Droplet]>) -> Void) -> Handle {
        let request = self.requestTo(endpoint: .droplets, method: .get)
        let handle  = self.taskWith(request: request, keyPath: "droplets", completion: completion)
        
        handle.resume()
        return handle
    }
    public func dropletWith(id: Int, completion: @escaping (_ result: Result<[Droplet]>) -> Void) -> Handle {
        let request = self.requestTo(endpoint: .dropletWith(id), method: .get)
        let handle  = self.taskWith(request: request, keyPath: "droplet", completion: completion)
        
        handle.resume()
        return handle
    }
}
