//
//  greywatchApp.swift
//  greywatch
//
//  Created by boB Rudis on 3/28/21.
//

import SwiftUI

var model = GNModel() // initialize the app model

@main
struct greywatchApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(model)
        .frame(minWidth: 400.0, idealWidth: 400.0, minHeight: 400.0)
    }
  }
}
