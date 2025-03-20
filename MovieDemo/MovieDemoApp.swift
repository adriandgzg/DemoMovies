//
//  MovieDemoApp.swift
//  MovieDemo
//
//  Created by Adrian Pascual Dominguez Gomez on 19/03/25.
//

import SwiftUI

@main
struct MovieDemoApp: App {
    let persistenceController = PersistenceController.shared

    @State private var isLoggedIn = false // Track the login state

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if isLoggedIn {
                    setupMovieListModule() // Show MovieList after login
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                } else {
                    LoginRouter.setupLoginModule(isLoggedIn: $isLoggedIn) // Pass the binding for login state
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
            }
        }
    }
}
