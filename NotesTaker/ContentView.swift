//
//  ContentView.swift
//  NotesTaker
//
//  Created by JOSEF RICHTER on 15/06/2020.
//  Copyright © 2020 JOSEF RICHTER. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var text: String = ""
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Write a note:")
            TextView(text: $text)
                .frame(width: 400, height: 385)
            Spacer()
            Button(action: {SaveNote(text: self.text)}) {
                Text("Save")
            }
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func SaveNote(text: String) {
    let myAppleScript = """
        tell application "Notes"
            tell account "iCloud"
                make new note at folder "Notes" with properties {name:"New note", body:"\(text)"}
            end tell
        end tell
    """
    var error: NSDictionary?
    if let scriptObject = NSAppleScript(source: myAppleScript) {
        if let outputString = scriptObject.executeAndReturnError(&error).stringValue {
            print(outputString)
        } else if (error != nil) {
            print("error: ", error!)
        }
    }
}
