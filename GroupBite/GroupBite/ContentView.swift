//
//  ContentView.swift
//  GroupBite
//
//  Created by Natalia_Mac on 6/21/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            if authViewModel.isAuthenticated {
                HomeView()
                    .background(AppColors.background)
                    .transition(.opacity)
            } else {
                AuthView()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppColors.primary.opacity(0.1),
                                AppColors.secondary.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.isAuthenticated)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
