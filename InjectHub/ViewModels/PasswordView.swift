//
//  PasswordView.swift
//  InjectHub
//
//  Created by NKR on 14/07/25.
//


import SwiftUI

struct PasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var password: String = ""
    @State private var isLoading = false
    @State private var showError = false

    let passwordManager = PasswordManager()
    var onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            header
            passwordInput
            actions
        }
        .frame(width: 400)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThickMaterial)
                .shadow(radius: 8)
        )
        .alert("Authentication Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The administrator password you entered is incorrect.")
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 50))
                .foregroundColor(.accentColor)

            Text("Administrator Access Required")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Please enter your administrator password to continue.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
        }
    }

    private var passwordInput: some View {
        HStack(spacing: 8) {
            Image(systemName: "key.fill")
                .foregroundColor(.secondary)

            SecureField("Administrator Password", text: $password)
                .textFieldStyle(PlainTextFieldStyle())
                .frame(minWidth: 200)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(NSColor.controlBackgroundColor)))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    private var actions: some View {
        HStack(spacing: 12) {
            Button("Cancel") {
                dismiss()
            }
            .keyboardShortcut(.cancelAction)
            .frame(minWidth: 80)

            Button(action: handleSubmit) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.9)
                        .frame(width: 80)
                } else {
                    Label("Unlock", systemImage: "lock.open.fill")
                        .labelStyle(TitleOnlyLabelStyle())
                        .frame(minWidth: 80)
                }
            }
            .keyboardShortcut(.defaultAction)
            .disabled(password.isEmpty || isLoading)
        }
        .padding(.bottom, 8)
    }

    private func handleSubmit() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            ShellManager.shared.isRunningAsRootViaAppleScript(password: password) { isRoot in
                let success = isRoot ? passwordManager.savePassword(password) : false
                isLoading = false
                
                if success {
                    onSubmit()
                    dismiss()
                } else {
                    showError = true
                }
            }
        }
    }
}


