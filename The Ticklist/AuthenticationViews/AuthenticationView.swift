//
//  AuthenticationView.swift
//  The Ticklist
//
//  Created by Torbjørn Wiik on 28/10/2023.
//

import SwiftUI

struct AuthenticationView: View {
    
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        switch authViewModel.authFlow{
        case .signIn:
            SignInView().environmentObject(authViewModel)
        case .signUp:
            SignUpView().environmentObject(authViewModel)
        }
    }
}

#Preview {
    AuthenticationView().environmentObject(AuthenticationViewModel())
}
