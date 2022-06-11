//
//  ContentView.swift
//  greywatch
//
//  Created by boB Rudis on 3/28/21.
//

import SwiftUI

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

struct GNRow : View {
  
  @EnvironmentObject var model: GNModel
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
        .fixedSize()
        .frame(alignment: .leading)
        .help((gnresp.riot ?? false) ? "IP found in RIOT dataset" : "IP not in RIOT dataset")
      
      Image(systemName: "info.circle.fill")
        .foregroundColor(categoryColor(gnresp.classification))
        .fixedSize()
        .frame(alignment: .leading)
        .help((gnresp.classification == nil) ? "unknown" : gnresp.classification!)
      
      Text(.init(gnresp.md))
        .font(.system(.body, design: .monospaced))
        .fixedSize()
        .frame(alignment: .leading)
        .help((gnresp.link == nil) ? "https://ipinfo.io/\(gnresp.ip)" : gnresp.link!)
      
      Text(makeName(gnresp.name))
        .fixedSize()
        .frame(alignment: .leading)
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
    .alert(isPresented: $model.queryLimitExceeded) {
      Alert(
        title: Text("Daily Query Limit Exceeded"),
        message: Text("Your daily RIOT query limit has been reached. Use the app preferences to add a GreyNoise API key to increase daily limits."),
        dismissButton: .default(Text("OK"))
      )
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

