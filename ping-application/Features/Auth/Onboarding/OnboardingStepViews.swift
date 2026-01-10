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
    let onPhoneSignup: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Create your account")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Choose how you'd like to sign up for Ping")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 24)
            
            Spacer()
            
            VStack(spacing: 16) {
                // Phone Sign Up
                Button(action: onPhoneSignup) {
                    HStack {
                        Image(systemName: "iphone")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.textPrimary)
                        Text("Sign up with Phone Number")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.borderSubtle, lineWidth: 1)
                    )
                }
                
                // Divider
                HStack {
                    Rectangle()
                        .fill(AppColors.borderSubtle)
                        .frame(height: 1)
                    Text("or")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.horizontal, 16)
                    Rectangle()
                        .fill(AppColors.borderSubtle)
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
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.borderSubtle, lineWidth: 1)
                    )
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Phone Number Step
struct PhoneNumberStepView: View {
    @Binding var phoneNumber: String
    let errors: [String: String]
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What's your number?")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("We'll use this to verify your account.")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 24)
            
            Spacer()
            
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Text("🇺🇸")
                        .font(.system(size: 20))
                    Text("+1")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Rectangle()
                        .fill(AppColors.borderSubtle)
                        .frame(width: 1, height: 24)
                        .padding(.horizontal, 8)
                    
                    TextField("Phone number", text: $phoneNumber)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(AppColors.textPrimary)
                        .keyboardType(.numberPad)
                        .focused($isFocused)
                        .onChange(of: phoneNumber) { newValue in
                            phoneNumber = formatPhoneNumber(newValue)
                        }
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(Color(hex: "F3F4F6"))
                .cornerRadius(20)
                .onAppear {
                    isFocused = true
                }
                
                if let error = errors["phoneNumber"] {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "EF4444"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            Spacer()
        }
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        let cleanNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "XXX-XXX-XXXX"
        var result = ""
        var index = cleanNumber.startIndex
        
        for ch in mask where index < cleanNumber.endIndex {
            if ch == "X" {
                result.append(cleanNumber[index])
                index = cleanNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
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
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("We'll use this to create your account and keep you signed in.")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 24)
            
            Spacer()
            
            VStack(spacing: 8) {
                TextField("Enter your email address", text: $email)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color(hex: "F3F4F6"))
                    .cornerRadius(20)
                    .onAppear {
                        isFocused = true
                    }
                
                if let error = errors["email"] {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "EF4444"))
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Choose a strong password to keep your account secure.")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 24)
            
            Spacer()
            
            VStack(spacing: 8) {
                SecureField("Enter your password", text: $password)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color(hex: "F3F4F6"))
                    .cornerRadius(20)
                    .onAppear {
                        isFocused = true
                    }
                
                if let error = errors["password"] {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "EF4444"))
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("We use your name so friends can recognize and connect with you easily.")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 24)
            
            Spacer()
            
            VStack(spacing: 8) {
                TextField("Enter your full name", text: $fullName)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                    .textInputAutocapitalization(.words)
                    .focused($isFocused)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color(hex: "F3F4F6"))
                    .cornerRadius(20)
                    .onAppear {
                        isFocused = true
                    }
                
                if let error = errors["fullName"] {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "EF4444"))
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Your birthday helps us verify your age and provide age-appropriate content.")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 24)
            
            Spacer()
            
            VStack(spacing: 8) {
                Button(action: {
                    showDatePicker = true
                }) {
                    HStack {
                        Text(formatDate(birthday))
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                        Image(systemName: "calendar")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.mint)
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color(hex: "F3F4F6"))
                    .cornerRadius(16)
                }
                
                if let error = errors["birthday"] {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "EF4444"))
                        .frame(maxWidth: .infinity, alignment: .leading)
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
        VStack(spacing: 0) {
            // Header with Close Button
            HStack {
                Spacer()
                Button(action: {
                    showDatePicker = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(10)
                        .background(Color(hex: "F3F4F6"))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            
            // Icon & Title
            VStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.system(size: 44))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.bottom, 4)
                
                Text("Select Birthday")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(.top, 8)
            .padding(.bottom, 20)
            
            // Date Picker
            DatePicker("", selection: $birthday, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding(.horizontal, 24)
            
            Spacer()
            
            // CTA Button
            Button(action: {
                showDatePicker = false
            }) {
                Text("Done")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "6EE7E7"), Color(hex: "1FC9C3")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color(hex: "1FC9C3"), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .background(Color.white)
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
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Your username is your unique identity on Ping.")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 24)
            
            Spacer()
            
            VStack(spacing: 12) {
                TextField("Enter username", text: $username)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color(hex: "F3F4F6"))
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "FEE2E2"))
                    .cornerRadius(12)
                }
                
                if let available = usernameAvailable {
                    HStack {
                        Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(.white)
                        Text(available ? "Username is available!" : "Username is already taken")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                .foregroundColor(AppColors.mint) +
             Text(titlePart2))
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(subtitle)
                .font(.system(size: 20))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .font(.system(size: 36, weight: .regular))
        .foregroundColor(AppColors.textPrimary)
    }
}

// MARK: - Category Selection Step
struct CategorySelectionStepView: View {
    @Binding var selectedCategories: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What interests you most?")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Select the categories that match your interests.")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 24)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(OnboardingData.categories) { category in
                        CategoryCard(
                            category: category,
                            isSelected: selectedCategories.contains(category.id),
                            onTap: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if selectedCategories.contains(category.id) {
                                        selectedCategories.removeAll { $0 == category.id }
                                    } else {
                                        selectedCategories.append(category.id)
                                    }
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
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Text(category.icon)
                    .font(.system(size: 26))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(height: (UIScreen.main.bounds.width - 64) / 2 * 0.48)
            .background(isSelected ? AppColors.mint : Color(hex: "F3F4F6"))
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
                            .font(.system(size: 30, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Select your specific interests")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textSecondary)
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
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if selectedSubcategories.contains(subcategory.name) {
                                            selectedSubcategories.removeAll { $0 == subcategory.name }
                                        } else {
                                            selectedSubcategories.append(subcategory.name)
                                        }
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
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? AppColors.mint : Color(hex: "F3F4F6"))
            .cornerRadius(16)
            .foregroundColor(isSelected ? .white : AppColors.textPrimary)
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
                    .fill(Color(hex: "F3F4F6"))
                    .frame(width: 80, height: 80)

                Text("🎉")
                    .font(.system(size: 40))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("You're all set!")
                .font(.system(size: 30, weight: .regular))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Welcome to the Ping community! We'll use your interests to personalize your experience.")
                .font(.system(size: 16))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

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
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(hex: "F3F4F6"))
        .cornerRadius(16)
    }
}

// MARK: - Helper Extensions
// Text concatenation is natively supported in SwiftUI
