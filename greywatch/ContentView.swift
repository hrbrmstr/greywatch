//
//  ContentView.swift
//  greywatch
//
//  Created by boB Rudis on 3/28/21.
//

import SwiftUI

let IPv4Regex = "(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
let privateIPv4Regex = "(^127\\.)|(^10\\.)|(^172\\.1[6-9]\\.)|(^172\\.2[0-9]\\.)|(^172\\.3[0-1]\\.)|(^192\\.168\\.)"

func categoryColor(_ gnclass: String?) -> Color {
  let theClassification = (gnclass ?? "unknown")
  if (theClassification == "unknown") {
    return(Color(.systemGray))
  } else if (theClassification == "malicious") {
    return(Color(.systemPink))
  } else if (theClassification == "benign") {
    return(Color(.systemGreen))
  } else {
    return(Color(.systemGray))
  }
}

func makeName(_ name: String?) -> String {
  return((name == nil) ? "" : "(\(name!))")
}

func scanning(_ lastSeen: String?) -> String {
  return((lastSeen == nil) ? "IP observed scanning in last 30 days" : "IP observed scanning; last seen: \(lastSeen!)")
}

struct ContentView: View {
  
  @EnvironmentObject var model: GNModel
  
  var body: some View {
    List {
      ForEach(model.seen.reversed()) { gnip in
        HStack {
          Image(systemName: "circlebadge.fill")
            .foregroundColor((gnip.noise ?? false) ? Color(.systemBlue) : Color(.systemGray))
            .fixedSize()
            .frame(alignment: .leading)
            .help((gnip.noise ?? false) ? scanning(gnip.lastSeen) : "IP not observed scanning in last 30 days")
          Image(systemName: "circlebadge.fill")
            .foregroundColor((gnip.riot ?? false) ? Color(.systemBlue) : Color(.systemGray))
            .foregroundColor(Color(.systemPink))
            .fixedSize()
            .frame(alignment: .leading)
            .help((gnip.riot ?? false) ? "IP found in RIOT dataset" : "IP not in RIOT dataset")
          Image(systemName: "info.circle.fill")
            .foregroundColor(categoryColor(gnip.classification))
            .foregroundColor(Color(.systemPink))
            .fixedSize()
            .frame(alignment: .leading)
            .help((gnip.classification == nil) ? "unknown" : gnip.classification!)
          Text(gnip.ip)
            .font(.system(.body, design: .monospaced))
            .fixedSize()
            .frame(alignment: .leading)
          Text(makeName(gnip.name))
            .fixedSize()
            .frame(alignment: .leading)
        }
        .onTapGesture(count: 2) {
          if (gnip.link != nil) {
            if let url = URL(string: gnip.link!) { NSWorkspace.shared.open(url) }
          } else {
            if let url = URL(string: "https://ipinfo.io/\(gnip.ip)") { NSWorkspace.shared.open(url) }
          }
        }
        .frame(alignment: .leading)
      }
      .fixedSize()
      .frame(alignment: .leading)
    }
    .padding()
    .listStyle(InsetListStyle())
  }
  
}

//"noise": false,
//"riot": true,
//"classification": "benign",
//"name": "Apple",
//"link": "https://viz.greynoise.io/riot/17.125.250.130",
//"last_seen": "2021-03-28",

