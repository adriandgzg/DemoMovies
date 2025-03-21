//
//  LoginViper.swift
//  MovieDemo
//
//  Created by Adrian Pascual Dominguez Gomez on 20/03/25.
//
import SwiftUI
import Foundation

struct LoginView: View {
    
    @ObservedObject var presenter: LoginPresenter
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @Binding var isLoggedIn: Bool

    init(presenter: LoginPresenter, isLoggedIn: Binding<Bool>) {
        self.presenter = presenter
        self._isLoggedIn = isLoggedIn
    }

    var body: some View {
        VStack {
            Spacer()
            
            Text("TopMovies")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.gray)  // Color gris para el encabezado
                .padding(.bottom, 40)
            
            VStack(spacing: 20) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .shadow(radius: 5)  // Agregar sombra sutil
                    .onTapGesture {
                        clearError()
                    }

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .shadow(radius: 5)  // Agregar sombra sutil
                    .onTapGesture {
                        clearError()
                    }

                if let errorMessage = presenter.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                        .opacity(errorMessage.isEmpty ? 0 : 1)
                        .transition(.opacity)
                }

                Button(action: {
                    loginUser()
                }) {
                    Text(isLoading ? "Logging in..." : "Login")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(isLoading ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(isLoading)
                .padding(.top, 30)
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .background(Color(UIColor.systemGray5).edgesIgnoringSafeArea(.all))  // Fondo gris claro
        .onAppear {
            presenter.checkLoginStatus(isLoggedIn: $isLoggedIn)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }

    private func loginUser() {
        isLoading = true
        presenter.login(email: email, password: password, isLoggedIn: $isLoggedIn)
    }

    private func clearError() {
        presenter.errorMessage = nil
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
