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

func makeURL(_ link: String?, ip: String) -> URL? {
  var out: URL?
  if (link != nil) {
    if let url = URL(string: link!) { out = url }
  } else {
    if let url = URL(string: "https://ipinfo.io/\(ip)") { out = url }
  }
  return(out)
}

struct GNRow : View {
  
  var gnresp: GreynoiseResponse
  
  var body: some View {
    HStack {
      
      Image(systemName: "circlebadge.fill")
        .foregroundColor((gnresp.noise ?? false) ? Color(.systemBlue) : Color(.systemGray))
        .fixedSize()
        .frame(alignment: .leading)
        .help((gnresp.noise ?? false) ? scanning(gnresp.lastSeen) : "IP not observed scanning in last 30 days")
      
      Image(systemName: "circlebadge.fill")
        .foregroundColor((gnresp.riot ?? false) ? Color(.systemBlue) : Color(.systemGray))
        .foregroundColor(Color(.systemPink))
        .fixedSize()
        .frame(alignment: .leading)
        .help((gnresp.riot ?? false) ? "IP found in RIOT dataset" : "IP not in RIOT dataset")
      
      Image(systemName: "info.circle.fill")
        .foregroundColor(categoryColor(gnresp.classification))
        .foregroundColor(Color(.systemPink))
        .fixedSize()
        .frame(alignment: .leading)
        .help((gnresp.classification == nil) ? "unknown" : gnresp.classification!)
      
      Text(gnresp.ip)
        .font(.system(.body, design: .monospaced))
        .fixedSize()
        .frame(alignment: .leading)
        .help((gnresp.link == nil) ? "" : gnresp.link!)
      
      Text(makeName(gnresp.name))
        .fixedSize()
        .frame(alignment: .leading)
    }
    .onTapGesture(count: 2) {
      if let url = makeURL(gnresp.link, ip: gnresp.ip) { NSWorkspace.shared.open(url) }
    }
    .frame(alignment: .leading)
    .fixedSize()
    
  }
  
}

struct ContentView: View {
  
  @EnvironmentObject var model: GNModel
  @Binding var sel: GreynoiseResponse?

  var body: some View {

    List(model.seen.reversed(), selection: $sel) {
      GNRow(gnresp: $0)
      .frame(alignment: .leading)
    }
    .frame(minWidth: 400.0, idealWidth: 400.0, maxWidth: 400.0, minHeight: 400.0, maxHeight: 700)
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

