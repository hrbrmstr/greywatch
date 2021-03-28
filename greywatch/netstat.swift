//
//  netstat.swift
//  greywatch
//
//  Created by boB Rudis on 3/28/21.
//

import Foundation
import SwiftShell

func netstat() -> String {
  
  let task = run("/usr/sbin/netstat", "-anp", "TCP")
  print(task.stdout)
  return(task.stdout)
  
}

func dig() -> String {
  
  let task = run("/usr/bin/dig", "+short", "viz.greynoise.io", "@9.9.9.9")
  print(task.stdout)
  return(task.stdout)
  
}

