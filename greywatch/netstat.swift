//
//  netstat.swift
//  greywatch
//
//  Created by boB Rudis on 3/28/21.
//

import Foundation
import SwiftShell

let GREYNOISE_API_HOST = "viz.greynoise.io"

func netstat() -> String {
  
  let task = run("/usr/sbin/netstat", "-anp", "TCP")
  print(task.stdout)
  return(task.stdout)
  
}

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
