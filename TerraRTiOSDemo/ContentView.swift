//
//  ContentView.swift
//  TerraRTiOSLocal
//
//  Created by Elliott Yu on 07/06/2022.
//

import SwiftUI
import CoreBluetooth
import TerraRTiOS

public struct TokenPayload: Decodable{
    let token: String
}

public func generateToken(devId: String, xAPIKey: String, userId: String) -> TokenPayload?{
        let url = URL(string: "https://ws.tryterra.co/auth/user?id=\(userId)")
        
        guard let requestUrl = url else {fatalError()}
        var request = URLRequest(url: requestUrl)
        var result: TokenPayload? = nil
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "terra.token.generation")
        request.httpMethod = "POST"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue(devId, forHTTPHeaderField: "dev-id")
        request.setValue(xAPIKey, forHTTPHeaderField: "X-API-Key")
        
        let task = URLSession.shared.dataTask(with: request){(data, response, error) in
            if let data = data{
                let decoder = JSONDecoder()
                do{
                    result = try decoder.decode(TokenPayload.self, from: data)
                    group.leave()
                }
                catch{
                    print(error)
                    group.leave()
                }
            }
        }
        group.enter()
        queue.async(group: group) {
            task.resume()
        }
        group.wait()
        return result
}

public func generateSDKToken(devId: String, xAPIKey: String) -> TokenPayload?{
    
        let url = URL(string: "https://api.tryterra.co/v2/auth/generateAuthToken")
        
        guard let requestUrl = url else {fatalError()}
        var request = URLRequest(url: requestUrl)
        var result: TokenPayload? = nil
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "terra.token.generation")
        request.httpMethod = "POST"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue(devId, forHTTPHeaderField: "dev-id")
        request.setValue(xAPIKey, forHTTPHeaderField: "x-api-key")
        
        let task = URLSession.shared.dataTask(with: request){(data, response, error) in
            if let data = data{
                let decoder = JSONDecoder()
                do{
                    result = try decoder.decode(TokenPayload.self, from: data)
                    group.leave()
                }
                catch{
                    print(error)
                    group.leave()
                }
            }
        }
        group.enter()
        queue.async(group: group) {
            task.resume()
        }
        group.wait()
        return result
}

struct Globals {
    static var shared = Globals()
    var shownDevices: [Device] = []
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
    @State private var heartRate = 0.0
    
    let terraRT = TerraRT(devId: DEVID, referenceId: "user2") { succ in
        print("TerraRT init: \(succ)")
    }
        
    init(){
        print("Hello World")
        let userId = terraRT.getUserid()
        print("UserId detected: \(userId ?? "None")")
        let tokenPayload = generateSDKToken(devId: DEVID, xAPIKey: XAPIKEY)
        print("TerraSDK token: \(tokenPayload!.token)")
        terraRT.initConnection(token: tokenPayload!.token) { succ in
            print("Connection formed: \(succ)")
//            let newUserId = terraRT.getUserid()
//            print("UserId: \(newUserId ?? "None")")
        }
        
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 24)]
    }
    
    @State private var showingWidget = false
    @State private var bleSwitch = false
    @State private var sensorSwitch = false

    var body: some View {
        NavigationView{
            VStack{
                connection().padding([.leading, .trailing, .top, .bottom])
                    .overlay(
                        RoundedRectangle(cornerRadius: Globals.shared.cornerradius)
                            .stroke(Color.border, lineWidth: 1)
                            .padding([.leading, .trailing], 5)
                        )
                appleConnection().padding([.leading, .trailing, .top, .bottom])
                    .overlay(
                        RoundedRectangle(cornerRadius: Globals.shared.cornerradius)
                            .stroke(Color.border, lineWidth: 1)
                            .padding([.leading, .trailing], 5)
                        )
                disconnect().padding([.leading, .trailing, .top, .bottom])
                    .overlay(
                        RoundedRectangle(cornerRadius: Globals.shared.cornerradius)
                            .stroke(Color.border, lineWidth: 1)
                            .padding([.leading, .trailing], 5)
                        )
                watchConnection().padding([.leading, .trailing, .top, .bottom])
                    .overlay(
                        RoundedRectangle(cornerRadius: Globals.shared.cornerradius)
                            .stroke(Color.border, lineWidth: 1)
                            .padding([.leading, .trailing], 5)
                        )
                startStreamingWatch().padding([.leading, .trailing, .top, .bottom])
                    .overlay(
                        RoundedRectangle(cornerRadius: Globals.shared.cornerradius)
                            .stroke(Color.border, lineWidth: 1)
                            .padding([.leading, .trailing], 5)
                        )
                Text("\(heartRate) bpm") // Display static text
                    .font(.title)
                    .padding()
                Spacer()
            }
            .navigationTitle(Text("Terra RealTime iOS")).padding(.top, 40)
        }
    }
    
    private func appleConnection() -> some View {
        HStack{
            Button(action: {
                print("Sensors selected!")
//                print("Disconnecting device!")
//                terraRT.disconnect(type: .BLE)
            }, label: {
                Text("Sensors")
                .fontWeight(.bold)
                .font(.system(size: 14))
                .foregroundColor(.inverse)
                .padding([.top, .bottom], Globals.shared.smallpadding)
                .padding([.leading, .trailing])
                .background(
                    Capsule()
                        .foregroundColor(.button)
                )
            })
            Toggle(isOn: $sensorSwitch, label: {
                Text("Real Time").fontWeight(.bold)
                    .font(.system(size: 14))
                    .foregroundColor(.inverse)
                    .padding([.top, .bottom], Globals.shared.smallpadding)
                    .padding([.leading, .trailing])
            }).onChange(of: sensorSwitch){sensorSwitch in
                if (sensorSwitch){
                    print("startRealtime - Apple")
                    let device = terraRT.getConnectedDevice()
                    if device != nil {
                        print("getConnectedDevice: \(device!.id), \(device!.deviceName)")
                    } else {
                        print("getConnectedDevice: none found")
                    }
                    
                    
//                    terraRT.startRealtime(type: Connections.BLE, dataType: Set([.STEPS, .HEART_RATE, .ACCELERATION, .CALORIES, .HRV])) { update in
//                        print(update)
//                    }
                }
                else {
                    terraRT.stopRealtime(type: .APPLE)
                }
            }
        }
    }
    
    private func disconnect() -> some View {
        HStack{
            Button(action: {
                print("Disconnecting device!")
                terraRT.disconnect(type: .BLE)
            }, label: {
                Text("Disconnect")
                    .fontWeight(.bold)
                    .font(.system(size: 14))
                    .foregroundColor(.inverse)
                    .padding([.top, .bottom], Globals.shared.smallpadding)
                    .padding([.leading, .trailing])
                    .background(
                        Capsule()
                            .foregroundColor(.button)
                    )
            })
            Toggle(isOn: $sensorSwitch, label: {
                Text("Real Time").fontWeight(.bold)
                    .font(.system(size: 14))
                    .foregroundColor(.inverse)
                    .padding([.top, .bottom], Globals.shared.smallpadding)
                    .padding([.leading, .trailing])
            }).onChange(of: sensorSwitch){sensorSwitch in
                if (sensorSwitch){
                    print("startRealtime - Apple")
                    let device = terraRT.getConnectedDevice()
                    if device != nil {
                        print("getConnectedDevice: \(device!.id), \(device!.deviceName)")
                    } else {
                        print("getConnectedDevice: none found")
                    }
                }
                else {
                    terraRT.stopRealtime(type: .APPLE)
                }
            }
        }
    }
    
    private func connection() -> some View{
        HStack{
            Button(action: {
                print("BLE selected!")
                showingWidget.toggle()
            }, label: {
                    Text("BLE")
                    .fontWeight(.bold)
                    .font(.system(size: 14))
                    .foregroundColor(.inverse)
                    .padding([.top, .bottom], Globals.shared.smallpadding)
                    .padding([.leading, .trailing])
                    .background(
                        Capsule()
                            .foregroundColor(.button)
                    )
            })
            .sheet(isPresented: $showingWidget){ terraRT.startBluetoothScan(type: .BLE, callback: {success in
                showingWidget.toggle()
                print("Device Connection Callback: \(success)")
            })}
            Toggle(isOn: $bleSwitch, label: {
                Text("Real Time").fontWeight(.bold)
                    .font(.system(size: 14))
                    .foregroundColor(.inverse)
                    .padding([.top, .bottom], Globals.shared.smallpadding)
                    .padding([.trailing])
            }).onChange(of: bleSwitch){bleSwitch in
                let userId = terraRT.getUserid()
                let token = generateToken(devId: DEVID, xAPIKey: XAPIKEY, userId: userId!)!.token
                print("UserId detected: \(userId ?? "None")")
                if (bleSwitch){
                    print("startRealtime - BLE")
                    terraRT.startRealtime(
                        type: Connections.BLE,
                        dataType: Set([.STEPS, .HEART_RATE, .CORE_TEMPERATURE]),
                        token: token,
                        callback: { update in
                            print(update)
                        }
                    )
//                    terraRT.startRealtime(type: Connections.BLE, dataType: Set([.STEPS, .HEART_RATE, .CORE_TEMPERATURE]), token: generateToken(devId: DEVID, xAPIKey: XAPIKEY, userId:"51273153-67d9-4fb8-a60d-858fc066eb64")!.token,
//                        callback: { update in
//                            print(update)
//                            print("hello")
//                        }
//                    )
                }
                else {
                    terraRT.stopRealtime(type: .BLE)
                }
            }
        }
    }
    
    private func startStreamingWatch() -> some View{
        HStack{
            Button(action: {
                print("Starting stream!")
                terraRT.startRealtime(
                    type: Connections.WATCH_OS,
                    dataType: Set([.HEART_RATE]),
//                            token: stToken?.token ?? "",
                    callback: { update in
                        heartRate = update.val ?? -1.0
                        print("Watch: \(update)")
                    }
                )
//                do {
//                    let userId = terraRT.getUserid()
////                    let stToken = generateToken(devId: DEVID, xAPIKey: XAPIKEY, userId: userId!)
//                    terraRT.startRealtime(
//                        type: Connections.WATCH_OS,
//                        dataType: Set([.HEART_RATE]),
////                            token: stToken?.token ?? "",
//                        callback: { update in
//                            heartRate = update.val ?? -1.0
//                            print("Watch: \(update)")
//                        })
//                    if let token {
//                        terraRT.startRealtime(
//                            type: Connections.WATCH_OS,
//                            dataType: Set([.HEART_RATE]),
////                            token: stToken?.token ?? "",
//                            callback: { update in
//                                heartRate = update.val ?? -1.0
//                                print("Watch: \(update)")
//                            })
//                    } else {
//                        print("Could not get token or uid")
////                        print("token: \(stToken)")
//                        print("uid: \(userId)")
//                    }
//                } catch {
//                    // Handle other unexpected errors
//                    print("An error occurred while streaming: \(error)")
//                }
                
            }, label: {
                Text("Start Stream")
                    .fontWeight(.bold)
                    .font(.system(size: 14))
                    .foregroundColor(.inverse)
                    .padding([.top, .bottom], Globals.shared.smallpadding)
                    .padding([.leading, .trailing])
                    .background(
                        Capsule()
                            .foregroundColor(.button)
                    )
            })
        }
    }
    private func watchConnection() -> some View{
        HStack{
            Button(action: {
                print("Connecting to Apple Watch!")
                do {
                    try terraRT.connectWithWatchOS()
                    // Function ran successfully, continue with your code here
                    print("Connection Success")
                } catch TerraError.FeatureNotSupported {
                    // Handle the case where watch connectivity is not supported
                    print("Watch connectivity is not supported on this device.")
                } catch {
                    // Handle other unexpected errors
                    print("An error occurred: \(error)")
                }
            }, label: {
                    Text("Apple Watch")
                    .fontWeight(.bold)
                    .font(.system(size: 14))
                    .foregroundColor(.inverse)
                    .padding([.top, .bottom], Globals.shared.smallpadding)
                    .padding([.leading, .trailing])
                    .background(
                        Capsule()
                            .foregroundColor(.button)
                    )
            })
//            .sheet(isPresented: $showingWidget){ terraRT.startBluetoothScan(type: .BLE, callback: {success in
//                showingWidget.toggle()
//                print("Device Connection Callback: \(success)")
//            })}
//            Toggle(isOn: $bleSwitch, label: {
//                Text("Real Time").fontWeight(.bold)
//                    .font(.system(size: 14))
//                    .foregroundColor(.inverse)
//                    .padding([.top, .bottom], Globals.shared.smallpadding)
//                    .padding([.trailing])
//            }).onChange(of: bleSwitch){bleSwitch in
//                let userId = terraRT.getUserid()
//                print("UserId detected: \(userId ?? "None")")
//                if (bleSwitch){
//                    print("startRealtime - WatchOS")
//                    terraRT.startRealtime(type: Connections.BLE, dataType: Set([.STEPS, .HEART_RATE, .CORE_TEMPERATURE]),
//                        callback: { update in
//                            print(update)
//                            print("hello")
//                        }
//                    )
//                }
//                else {
//                    terraRT.stopRealtime(type: .BLE)
//                }
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
