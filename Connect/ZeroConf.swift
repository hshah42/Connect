//
//  ZeroConf.swift
//  Connect
//
//  Created by Hem shah on 10/03/19.
//  Copyright © 2019 Hem shah. All rights reserved.
//

import Foundation

class ZeroConf: NSObject, NetServiceBrowserDelegate, NetServiceDelegate{
    
    var browser: NetServiceBrowser!
    var services = [NetService]()
    let domain = "local"
    let name = "_http._tcp"
    
    func startSearch(){
        self.services.removeAll()
        self.browser = NetServiceBrowser()
        self.browser.delegate = self
        self.browser.searchForServices(ofType: name, inDomain: domain)
    }
    
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        debugPrint(errorDict)
    }
    
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        print("starting search..")
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        print("Stoped search")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("error in search")
        debugPrint(errorDict)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("found service")
        services.append(service)
        debugPrint(service)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        if let ix = self.services.index(of:service) {
            self.services.remove(at:ix)
            print("removing a service")
        }
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("did resolve address")
    }
    
}
