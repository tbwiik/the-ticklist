//
//  SignInView.swift
//  The Ticklist
//
//  Created by Torbjørn Wiik on 27/10/2023.
//

import SwiftUI

// TODO: To a big extent duplicate of SignUpView
struct SignInView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Get environment var that can dismiss views
    @Environment(\.dismiss) private var dismiss
    
    private func signInEmailPasswd() {
        Task {
            if await authViewModel.signInEmailPasswd() == true {
//                dismiss()
                // No modal view to remove
            }
        }
    }
    
    var body: some View {
        
        VStack {
            TextField("Email", text: $authViewModel.email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
            SecureField("Password", text: $authViewModel.passwd)
        }
        .padding()
        
        Button (action: signInEmailPasswd){
            
            if !authViewModel.isAuthenticating(){
                Text("Sign In")
            } else {
                Text("Authenticating...")
            }
            
        }
        .sheet(item: $authViewModel.errorWrapper, onDismiss: {
            authViewModel.reset()
        }) { wrapped in
            ErrorView(errorWrapper: wrapped)
        }.buttonStyle(.bordered)
        
        Button("Sign up", action: authViewModel.switchAuthFlow)
    }
}

#Preview {
    SignInView()
}