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
  @State var sel:GreynoiseResponse?
  var body: some Scene {
    WindowGroup {
      ContentView(sel:$sel)
        .environmentObject(model)
    }.commands {
      CommandGroup(after: .newItem) {
        Divider()
        Button(action: {
          
          let panel = NSSavePanel()
          
          panel.nameFieldLabel = "Export IP list as:"
          panel.nameFieldStringValue = "greywatch-export.json"
          panel.canCreateDirectories = true
          
          panel.begin { response in
            if response == NSApplication.ModalResponse.OK, let fileUrl = panel.url {
              
              do {
                if (!FileManager.default.fileExists(atPath: fileUrl.path)){
                  FileManager.default.createFile(atPath: fileUrl.path, contents: nil, attributes: nil)
                }
                let exportFile = FileHandle(forWritingAtPath: fileUrl.path)
                for gnresp in model.seen {
                  let jsonData = try JSONEncoder().encode(gnresp)
                  let jsonString = String(data: jsonData, encoding: .utf8)!
                  exportFile?.write("\(jsonString)\n")
                }
                try exportFile?.close()
              } catch {
                debugPrint("Error")
              }
            }
            
          }
        }) {
          Text("Export…")
        }
        .keyboardShortcut("e", modifiers: [.command, .shift])
      }
    }
  }
}
