//
//  netstat.swift
//  greywatch
//
//  Created by boB Rudis on 3/28/21.
//

import Foundation
// import SwiftShell // keeping this around in the event it comes in handy

let GREYNOISE_API_HOST = "viz.greynoise.io"

// Get's IPv4 ESTABLISHED connection (remote addresses)
func netstat() -> [String] {
  
  let x = read_tcp_stat()! as! [String]
  
  //  let task = run("/usr/sbin/netstat", "-anp", "TCP")
  //  print(task.stdout)
  //  return(task.stdout)
  
  return(x.unique())
  
}

// Does an A record query (can return multiple)
func dig() -> [String] {
  
  let host = CFHostCreateWithName(nil, GREYNOISE_API_HOST as CFString).takeRetainedValue()
  
  CFHostStartInfoResolution(host, .addresses, nil)
  
  var success: DarwinBoolean = false
  var out: [String] = []
  
  if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray? {
    
    out.reserveCapacity(addresses.count)
    
    for case let addr as NSData in addresses {
      
      var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
      
      let res = getnameinfo(
        addr.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(addr.length),
        &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST
      )
      
      if res == 0 {  out.append(String(cString: hostname)) }
      
    }
  }
  
  //  let task = run("/usr/bin/dig", "+short", "viz.greynoise.io", "@9.9.9.9")
  //  print(task.stdout)
  //  return(task.stdout)
  
  return(out)
  
}

// Does a PTR record query; returns the IP address if there is no PTR record
func ptr(ip: String) -> String {
  
  var res: UnsafeMutablePointer<addrinfo>? = nil
  
  defer { if let res = res { freeaddrinfo(res) } }
  
  let err = getaddrinfo(ip, nil, nil, &res)
  
  if (err != 0) { return (ip) }
  
  for addrinfo in sequence(first: res, next: { $0?.pointee.ai_next }) {
    
    guard let pointee = addrinfo?.pointee else { return(ip) }
    
    let ptr = UnsafeMutablePointer<Int8>.allocate(capacity: Int(NI_MAXHOST))
    defer { ptr.deallocate() }
    
    let error = getnameinfo(pointee.ai_addr, pointee.ai_addrlen, ptr, socklen_t(NI_MAXHOST), nil, 0, 0)
    if (error != 0) { continue }
    
    return(String(cString: ptr))
    
  }
  
  return(ip)
  
}
