//
//  The_TicklistApp.swift
//  The Ticklist
//
//  Created by Torbjørn Wiik on 05/01/2023.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

// Configure database
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      
    FirebaseApp.configure()
    Auth.auth().useEmulator(withHost:"127.0.0.1", port:9099) // Run on emulator and not on production db
      
    // This code connect the simulator to a local Firebase emulator and not production db
    // Remember to $firebase emulators:start before use
    let settings = Firestore.firestore().settings;
    settings.host = "127.0.0.1:8080";
    //        settings.cacheSettings = false;
    settings.isSSLEnabled = false;
    Firestore.firestore().settings = settings;
      
    return true
  }
}

@main
struct The_TicklistApp: App {
    
    // Initialize database
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Initialize Environment-objects
    @StateObject private var databaseManager = DatabaseManager()
    @StateObject var authViewModel = AuthViewModel()
    
    // Define errorWrapper
    @State private var errorWrapper: ErrorWrapper?
    
    var body: some Scene {
        WindowGroup {
            NavigationView{
                AuthStateView {
                    TickListView(ticklist: $databaseManager.ticklist) {
                        
                        Task {
                            do {
                                try await databaseManager.save(ticklist: databaseManager.ticklist)
                            } catch {
                                errorWrapper = ErrorWrapper(error: error, solution: "Try again")
                            }
                        }
                    }
                }
                .environmentObject(authViewModel)
            }
            
            // Load from database on setup
            .task {
                do {
                    databaseManager.ticklist = try await databaseManager.load()
                } catch {
                    errorWrapper = ErrorWrapper(error: error, solution: "Loads sample data and continues")
                }
            }
            
            // Display errormessage
            .sheet(item: $errorWrapper, onDismiss: {
                databaseManager.ticklist = Tick.sampleData
            }) { wrapped in
                ErrorView(errorWrapper: wrapped)
            }
        }
    }
}
