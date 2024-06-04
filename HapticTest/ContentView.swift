//
//  ContentView.swift
//  HapticTest
//
//  Created by Conner Yoon on 6/4/24.
//

import SwiftUI
import SwiftData
import CoreHaptics
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var counter = 0
    @State private var engine : CHHapticEngine?
    var body: some View {
        NavigationSplitView {
            Button {
                complexSuccess()
            } label: {
                Text("Test haptic")
            }.onAppear(perform: prepareHaptics)//Important
            List {
                
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton().sensoryFeedback(.selection, trigger: items)
                }
                ToolbarItem {
                    Button {
                        addItem()
                        counter+=1
                        
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }.sensoryFeedback(.increase, trigger: counter)
                    
                    
                }
            }
        } detail: {
            Text("Select an item")
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
    func prepareHaptics(){
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {return}
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error with CHHapticEngine : \(error.localizedDescription)")
        }
    }
    func complexSuccess(){
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {return}
        var events = [CHHapticEvent]()
        for i in stride(from: 0, to: 1, by: 0.1){
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(i))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(i))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
            
            events.append(event)
        }
        for i in stride(from: 1, to: 0, by: -0.1){
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(i))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(i))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
            
            events.append(event)
        }
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
            
        }catch {
            print("Failed to play pattern \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
