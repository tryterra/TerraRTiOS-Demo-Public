//
//  ContentView.swift
//  TerraRTiOSWatchDemo Watch App
//
//  Created by Bryan Tan on 14/08/2023.
//

import SwiftUI
import TerraRTiOS

struct Globals {
    static var shared = Globals()
//    var shownDevices: [Device] = []
    let cornerradius : CGFloat = 10
    let smallpadding: CGFloat = 12
}

extension Color {
    public static var border : Color {
        Color.init(.sRGB, red: 226/255, green: 239/255, blue: 254/255, opacity: 1)
    }
    
    public static var background : Color {
        Color.init(.sRGB, red: 255/255, green: 255/255, blue: 255/255, opacity: 1)
    }
    
    public static var button : Color {
        Color.init(.sRGB, red: 96/255, green: 165/255, blue: 250/255, opacity: 1)
    }
    
    public static var accent: Color{
        Color.init(.sRGB, red: 42/255, green: 100/255, blue: 246/255, opacity: 1)
    }
}


struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            watchConnection().padding([.leading, .trailing, .top, .bottom])
                .overlay(
                    RoundedRectangle(cornerRadius: Globals.shared.cornerradius)
                        .stroke(Color.border, lineWidth: 1)
                        .padding([.leading, .trailing], 5)
                    )
            startStreamButton().padding([.leading, .trailing, .top, .bottom])
                .overlay(
                    RoundedRectangle(cornerRadius: Globals.shared.cornerradius)
                        .stroke(Color.border, lineWidth: 1)
                        .padding([.leading, .trailing], 5)
                    )
        }
        .padding()
    }
    
    @State private var terra : Terra?
    
    private func watchConnection() -> some View{
        HStack{
            Button(action: {
                print("Initalised Terra!")
                self.terra = try? Terra()
                guard let terra else {
                    print("Error initialising Terra")
                    return
                }
                self.terra?.setWatchOSConnectionStateListener() { state in
                    print("watchState: \(state)")
                }
            }, label: {
                Text("Setup Terra")
            })
        }
    }
    
    private func startStreamButton() -> some View{
        HStack{
            Button(action: {
                print("Start streaming")
                guard let t = self.terra else {
                    print("Terra not initialised")
                    return
                }
                self.terra?.startStream(forDataTypes: Set([.STEPS, .HEART_RATE])){ update in
                    print("device: \(update)")
                }
                
            }, label: {
                Text("Start streaming")
            })
        }
    }
    
//    private func startStreamButton() -> some View{
//        HStack{
//            Button(action: {
//                print("WatchOS selected!")
//                let terra: Terra? = try? Terra()
//                guard let terra else {
//                    print("Error initialising Terra")
//                    return
//                }
//                terra.startStream(forDataTypes: Set([.STEPS, .HEART_RATE])){ update in
//                    print("device: \(update)")
//                }
//            }, label: {
//                Text("Start Stream")
//            })
//        }
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
