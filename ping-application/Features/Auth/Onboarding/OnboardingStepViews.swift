//
//  OnboardingStepViews.swift
//  PingNative
//
//  Source: ping/apps/src/screens/auth/onboarding/components/
//  All step views matching RN implementation
//

import SwiftUI

// MARK: - Auth Options Step
struct AuthOptionsStepView: View {
    let onEmailSignup: () -> Void
    let onGoogleSignup: () -> Void
    let onAppleSignup: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Create your account")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.white)
                
                Text("Choose how you'd like to sign up for Ping")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: 320, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 24)
            
            Spacer()
            
            VStack(spacing: 16) {
                // Google Sign Up
                Button(action: onGoogleSignup) {
                    HStack {
                        Image(systemName: "globe")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "4285F4"))
                        Text("Sign up with Google")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(hex: "2D3436"))
                    }
                    .frame(width: 340)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                
                // Apple Sign Up
                Button(action: onAppleSignup) {
                    HStack {
                        Image(systemName: "applelogo")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        Text("Sign up with Apple")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .frame(width: 340)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                
                // Divider
                HStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 1)
                    Text("or")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 16)
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 1)
                }
                .frame(width: 340)
                .padding(.vertical, 16)
                
                // Email Sign Up
                Button(action: onEmailSignup) {
                    HStack {
                        Image(systemName: "envelope")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "1FC9C3"))
                        Text("Sign up with Email")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(hex: "2D3436"))
                    }
                    .frame(width: 340)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Email Step
struct EmailStepView: View {
    @Binding var email: String
    let errors: [String: String]
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What's your email?")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.white)
                
                Text("We'll use this to create your account and keep you signed in.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: 320, alignment: .leading)
            }
            .padding(.top, 24)
            
            Spacer()
            
            VStack(spacing: 8) {
                TextField("Enter your email address", text: $email)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(hex: "2D3436"))
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .frame(width: 340)
                    .padding()
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(20)
                    .onAppear {
                        isFocused = true
                    }
                
                if let error = errors["email"] {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "EF4444"))
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Password Step
struct PasswordStepView: View {
    @Binding var password: String
    let errors: [String: String]
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Create a password")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.white)
                
                Text("Choose a strong password to keep your account secure.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: 320, alignment: .leading)
            }
            .padding(.top, 24)
            
            Spacer()
            
            VStack(spacing: 8) {
                SecureField("Enter your password", text: $password)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(hex: "2D3436"))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .frame(width: 340)
                    .padding()
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(20)
                    .onAppear {
                        isFocused = true
                    }
                
                if let error = errors["password"] {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "EF4444"))
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Name Step
struct NameStepView: View {
    @Binding var fullName: String
    let errors: [String: String]
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What's your name?")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.white)
                
                Text("We use your name so friends can recognize and connect with you easily.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: 320, alignment: .leading)
            }
            .padding(.top, 24)
            
            Spacer()
            
            VStack(spacing: 8) {
                TextField("Enter your full name", text: $fullName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(hex: "2D3436"))
                    .textInputAutocapitalization(.words)
                    .focused($isFocused)
                    .frame(width: 340)
                    .padding()
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(20)
                    .onAppear {
                        isFocused = true
                    }
                
                if let error = errors["fullName"] {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "EF4444"))
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Birthday Step
struct BirthdayStepView: View {
    @Binding var birthday: Date
    @Binding var showDatePicker: Bool
    let errors: [String: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("When's your birthday?")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.white)
                
                Text("Your birthday helps us verify your age and provide age-appropriate content.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: 320, alignment: .leading)
            }
            .padding(.top, 24)
            
            Spacer()
            
            VStack(spacing: 8) {
                Button(action: {
                    showDatePicker = true
                }) {
                    HStack {
                        Text(formatDate(birthday))
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(hex: "2D3436"))
                        Spacer()
                        Image(systemName: "calendar")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.mint)
                    }
                    .frame(width: 340)
                    .padding()
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                
                if let error = errors["birthday"] {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "EF4444"))
                }
            }
            
            Spacer()
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(birthday: $birthday, showDatePicker: $showDatePicker)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

struct DatePickerSheet: View {
    @Binding var birthday: Date
    @Binding var showDatePicker: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Select Birthday")
                .font(.system(size: 20, weight: .semibold))
                .padding(.top, 24)
            
            DatePicker("", selection: $birthday, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
            
            Button(action: {
                showDatePicker = false
            }) {
                Text("Done")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.mint)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Username Step
struct UsernameStepView: View {
    @Binding var username: String
    var usernameAvailable: Bool?
    let errors: [String: String]
    let onUsernameChanged: (String) -> Void
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose your username")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.white)
                
                Text("Your username is your unique identity on Ping.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: 320, alignment: .leading)
            }
            .padding(.top, 24)
            
            Spacer()
            
            VStack(spacing: 12) {
                TextField("Enter username", text: $username)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "2D3436"))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .frame(width: 340)
                    .padding()
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(20)
                    .onChange(of: username) { newValue in
                        onUsernameChanged(newValue)
                    }
                    .onAppear {
                        isFocused = true
                    }
                
                if let error = errors["username"] {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Color(hex: "EF4444"))
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "EF4444"))
                    }
                    .padding()
                    .background(Color(hex: "FEE2E2"))
                    .cornerRadius(12)
                }
                
                if let available = usernameAvailable {
                    HStack {
                        Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(.white)
                        Text(available ? "Username is available!" : "Username is already taken")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(available ? Color(hex: "10B981") : Color(hex: "EF4444"))
                    .cornerRadius(12)
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Marketing Step
struct MarketingStepView: View {
    let titlePart1: String
    let highlightedText: String
    let titlePart2: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            (Text(titlePart1) +
             Text(highlightedText)
                .foregroundColor(Color(hex: "FCD34D")) +
             Text(titlePart2))
            
            Text(subtitle)
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
            
            Spacer()
        }
        .font(.system(size: 36, weight: .medium))
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
    }
}

// MARK: - Category Selection Step
struct CategorySelectionStepView: View {
    @Binding var selectedCategories: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What interests you most?")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.white)
                
                Text("Select the categories that match your interests.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: 320, alignment: .leading)
            }
            .padding(.top, 24)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(OnboardingData.categories) { category in
                        CategoryCard(
                            category: category,
                            isSelected: selectedCategories.contains(category.id),
                            onTap: {
                                if selectedCategories.contains(category.id) {
                                    selectedCategories.removeAll { $0 == category.id }
                                } else {
                                    selectedCategories.append(category.id)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct CategoryCard: View {
    let category: Category
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(category.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? Color(hex: category.color) : .white)
                    .lineLimit(2)
                
                Spacer()
                
                Text(category.icon)
                    .font(.system(size: 26))
                    .foregroundColor(isSelected ? Color(hex: category.color) : .white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(height: (UIScreen.main.bounds.width - 64) / 2 * 0.48)
            .background(isSelected ? Color.white : Color(hex: category.color))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.gray.opacity(0.3) : Color.clear, lineWidth: 2)
            )
            .cornerRadius(14)
        }
    }
}

// MARK: - Subcategory Selection Step
struct SubcategorySelectionStepView: View {
    let categoryId: String
    @Binding var selectedSubcategories: [String]
    
    var category: Category? {
        OnboardingData.categories.first { $0.id == categoryId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            if let category = category {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: category.gradient.map { Color(hex: $0) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 48, height: 48)
                        
                        Text(category.icon)
                            .font(.system(size: 24))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name)
                            .font(.system(size: 30, weight: .medium))
                            .foregroundColor(.white)
                        
                        Text("Select your specific interests")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.top, 24)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(category.subcategories) { subcategory in
                            SubcategoryCard(
                                subcategory: subcategory,
                                isSelected: selectedSubcategories.contains(subcategory.name),
                                onTap: {
                                    if selectedSubcategories.contains(subcategory.name) {
                                        selectedSubcategories.removeAll { $0 == subcategory.name }
                                    } else {
                                        selectedSubcategories.append(subcategory.name)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

struct SubcategoryCard: View {
    let subcategory: Subcategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(subcategory.icon)
                    .font(.system(size: 15))
                
                Text(subcategory.name)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color.white : Color(hex: "3B82F6"))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.gray.opacity(0.3) : Color.clear, lineWidth: 2)
            )
            .cornerRadius(16)
            .foregroundColor(isSelected ? Color(hex: "3B82F6") : .white)
        }
    }
}

// MARK: - Final Step
struct FinalStepView: View {
    let errors: [String: String]

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 80, height: 80)

                Text("🎉")
                    .font(.system(size: 40))
            }

            Text("You're all set!")
                .font(.system(size: 30, weight: .medium))
                .foregroundColor(.white)

            Text("Welcome to the Ping community! We'll use your interests to personalize your experience.")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // Error message for signup failures
            if let submitError = errors["submit"] {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color(hex: "DC2626"))
                        .font(.system(size: 18))

                    Text(submitError)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "DC2626"))

                    Spacer()
                }
                .padding()
                .background(Color(hex: "FEE2E2"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "DC2626"), lineWidth: 1)
                )
                .cornerRadius(12)
                .padding(.horizontal, 16)
            }

            VStack(spacing: 12) {
                FeatureCard(
                    icon: "✓",
                    iconColor: Color(hex: "1FC9C3"),
                    title: "Ready to Explore",
                    subtitle: "Discover amazing places around you"
                )

                FeatureCard(
                    icon: "person.2.fill",
                    iconColor: Color(hex: "4ECDC4"),
                    title: "Connect & Share",
                    subtitle: "Plan activities with friends"
                )
            }
            .padding(.horizontal, 16)

            Spacer()
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor)
                    .frame(width: 40, height: 40)
                
                if icon == "✓" {
                    Text(icon)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - Helper Extensions
// Text concatenation is natively supported in SwiftUI
