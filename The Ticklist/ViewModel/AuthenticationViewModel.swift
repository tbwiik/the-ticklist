//
//  AuthenticationViewModel.swift
//  The Ticklist
//
//  Created by Torbjørn Wiik on 27/10/2023.
//

import Foundation
import FirebaseAuth


/// What state the authentication is in
enum AuthState {
    case authenticated
    case authenticating
    case unAuthenticated
}


/// Costum Authentication-error
enum AuthError: LocalizedError{
    case emptyConfirmPassword
    case noMatchConfirmPassword
    
    var errorDescription: String? {
        switch self {
        case .emptyConfirmPassword:
            return NSLocalizedString("The field \"Confirm Password\" cannot be emtpy", comment: "Confirm Password is empty")
        case .noMatchConfirmPassword:
            return NSLocalizedString("The field \"Confirm password\" doesn't match \"Password\" ", comment: "NonMatching \"Confirm Password\"")
        }
    }
}

@MainActor
/// Handle authentication of user
class AuthenticationViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var passwd = ""
    @Published var confirmPasswd = ""
    
    @Published var user: User?
    @Published var authState: AuthState = .unAuthenticated
    
    
    /// Init errorWrapper
    @Published var errorWrapper: ErrorWrapper?
    
    
    /// Define handler for authentication state
    private var authHandler: AuthStateDidChangeListenerHandle?
    
    
    /// Find whether the Authentication controller currently is handling the request
    /// - Returns: true if authenticating
    func isAuthenticating() -> Bool{
        return authState == .authenticating
    }
    
    init() {
        addAuthHandler()
    }
    
    
    /// Add handler for user and authentication state
    func addAuthHandler() {
        
        if authHandler == nil { // If not already defined
            authHandler = Auth.auth().addStateDidChangeListener({ auth, user in
                self.user = user
                self.authState = user == nil ? .unAuthenticated : .authenticated // Set authentication-state on whether user exists
            })
        }
        
    }
    
    
    /// Clear all user fields and set non-authenticated
    func reset() {
        self.authState = .unAuthenticated
        self.email = ""
        self.passwd = ""
        self.confirmPasswd = ""
    }
    
    
    /// Sign In using Email and Password
    /// - Returns: Whether the Sign In was successfull
    func signInEmailPasswd() async -> Bool {
        
        authState = .authenticating
        
        do {
            try await Auth.auth().signIn(withEmail: email, password: passwd)
            return true
        } catch {
            errorWrapper = ErrorWrapper(error: error, solution: "Try to Sign In again")
            authState = .unAuthenticated
            return false
        }
    }
    
    
    /// Sign Up a User using Email and Password
    ///
    /// Will return false if confirm password doesn't match
    ///
    /// - Returns: Whether the signup was succesfull
    func signUpEmailPasswd() async -> Bool {
        
        authState = .authenticating
        
        do {
            
            guard !confirmPasswd.isEmpty else {
                throw AuthError.emptyConfirmPassword
            }
            
            guard confirmPasswd == passwd else {
                throw AuthError.noMatchConfirmPassword
            }
            
            try await Auth.auth().createUser(withEmail: email, password: passwd)
            return true
        } catch {
            errorWrapper = ErrorWrapper(error: error, solution: "Try to Sign Up again")
            authState = .unAuthenticated
            return false
        }
        
    }
    
    
    /// Sign out current user
    /// - Returns: true if successfull signout
    func signOut() async -> Bool {
        
        do {
            try Auth.auth().signOut()
            return true
        } catch {
            errorWrapper = ErrorWrapper(error: error, solution: "Try to Sign out again")
            return false
        }
        
    }
    
    
    /// Delete current user from Database
    /// - Returns: true if succesfull deletion
    func deleteUser() async -> Bool {
        do {
            try await user?.delete()
            return true
        } catch {
            errorWrapper = ErrorWrapper(error: error, solution: "Try to Delete User again")
            return false
        }
    }
    
}

