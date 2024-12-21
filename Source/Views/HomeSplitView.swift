//
//  SplitView.swift
//  Prope
//
//  Created by ARUN PANNEERSELVAM on 14/12/2024.
//

import Foundation
import SwiftUI

// Data Structures (replace with your actual data)
struct Listing: Identifiable, Codable {
    var id = UUID()
    let title: String
    let description: String
    // ... other properties
}


struct Conversation: Identifiable, Codable {
    var id = UUID()
    let title: String
    let messages: [String]
    // ... other properties
}

struct Advert: Identifiable, Codable {
    var id = UUID()
    let title: String
    var image: String
    let messages: [String]
    // ... other properties
}
// ... (Similar structures for Conversation and Advert)

class DataManager: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var conversations: [Conversation] = []
    @Published var adverts: [Advert] = []


    init() {
        // Load initial data from your source (e.g., Core Data, Firebase)
         listings = [Listing(title: "Listing 1", description: "Desc 1"),Listing(title: "Listing 2", description: "Desc 2")]
        conversations = [Conversation(title: "Convo 1", messages: ["Message 1", "Message 2"])]
        adverts = [Advert(title: "Advert 1", image: "text.bubble.badge.clock", messages: ["Message 1", "Message 2"])]
        
    }
}

class ListingViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var selectedListing: Listing? = nil //For passing data to other tabs
    
    init() {
        // Load initial listings from your data source here (e.g., Core Data, Firestore)
        listings = [
            Listing(title: "Listing 1", description: "Description 1"),
            Listing(title: "Listing 2", description: "Description 2"),
            // Add more listings
        ]

    }
}

class ConversationViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var selectedConversation: Conversation? = nil //For passing data to other tabs

    init() {
        // Load initial conversations from your data source (e.g., Core Data, Firestore)
        conversations = [
            Conversation(title: "Conversation 1", messages: ["Message 1", "Message 2"]),
            Conversation(title: "Conversation 2", messages: ["Message 3"]),
           ]
    }
}

class AdvertViewModel: ObservableObject {
    @Published var adverts: [Advert] = []
    @Published var image: String = ""
    @Published var selectedAdvert: Advert? = nil

    init(selectedAdver: Advert) {
        adverts = [
            Advert(title: "Advert 1", image: "text.bubble.badge.clock", messages: ["Message 1", "Message 2"]), //nil is important for no image
            Advert(title: "Advert 2", image: "text.bubble.badge.clock", messages: ["Message 1", "Message 2"]),
        ]
        
        self.selectedAdvert = selectedAdver
        
      }

}



struct HomeSplitView: View {
    @StateObject private var dataManager = DataManager()

    var body: some View {
        NavigationView { // Important: NavigationView for SplitView functionality
            TabView { //Main tab view
                ListingsView(dataManager: dataManager)
                    .tabItem {
                        Label("Listings", systemImage: "list.star")
                    }
                ConversationsView(dataManager: dataManager)
                    .tabItem {
                        Label("Convos", systemImage: "message")
                    }
                AdvertsView(dataManager: dataManager)
                    .tabItem {
                        Label("Adverts", systemImage: "photo")
                    }
            }
            .onAppear{  //Initial Data Load
               
            }
            .navigationTitle("My App")
        }
        
    }
}

struct ListingsView: View {
    @ObservedObject var dataManager: DataManager
    var body: some View {
        NavigationView{ //NavigationView required for SplitView
            List(dataManager.listings) { listing in
                Text(listing.title)
            }
            .navigationTitle("Listings")
        }
    }
}
struct ConversationsView: View {
    @ObservedObject var dataManager: DataManager
    var body: some View {
        NavigationView{ //NavigationView required for SplitView
            List(dataManager.conversations) { convo in
                Text(convo.title)
            }
            .navigationTitle("Recents")
        }
    }
}

struct AdvertsView: View {
    @ObservedObject var dataManager: DataManager
    var body: some View {
        NavigationView{ //NavigationView required for SplitView
            List(dataManager.adverts) { advert in
                Text(advert.title)
            }
            .navigationTitle("Adverts")
        }
    }
}



// ... (Similar views for ConversationsView and AdvertsView)
// Make sure these have the @ObservedObject var dataManager: DataManager
