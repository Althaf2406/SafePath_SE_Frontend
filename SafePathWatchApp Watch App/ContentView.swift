//
//  ContentView.swift
//  SafePathWatchApp Watch App
//
//  Created by rasyel on 10/06/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var connectivityManager = iOSConnectivityManager()
    @State private var showStatusUpdate = false
    @State private var sosSent = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                if !connectivityManager.latestAlert.isEmpty {
                    Text(connectivityManager.latestAlert)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.red)
                        .cornerRadius(5)
                }
                
                Button(action: {
                    sendSOS()
                }) {
                    Text(sosSent ? "SOS Sent!" : "SOS")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, minHeight: 60)
                }
                .buttonStyle(.borderedProminent)
                .tint(sosSent ? .gray : .red)
                .disabled(sosSent)
                
                NavigationLink(destination: StatusUpdateView(connectivityManager: connectivityManager)) {
                    Text("Update Status")
                        .bold()
                }
                .buttonStyle(.bordered)
                .tint(.blue)
            }
            .navigationTitle("SafePath")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func sendSOS() {
        connectivityManager.sendActionToiOS(action: "triggerSOS")
        sosSent = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            sosSent = false
        }
    }
}

struct StatusUpdateView: View {
    @ObservedObject var connectivityManager: iOSConnectivityManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 10) {
            Button(action: {
                sendStatus("Safe")
            }) {
                Text("Safe")
                    .bold()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            
            Button(action: {
                sendStatus("Need Help")
            }) {
                Text("Need Help")
                    .bold()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            
            Button(action: {
                dismiss()
            }) {
                Text("Cancel")
            }
            .buttonStyle(.plain)
            .padding(.top, 5)
        }
        .navigationTitle("Status")
    }
    
    private func sendStatus(_ status: String) {
        connectivityManager.sendActionToiOS(action: "updateStatus", data: ["status": status])
        dismiss()
    }
}

#Preview {
    ContentView()
}
