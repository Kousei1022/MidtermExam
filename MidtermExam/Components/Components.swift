import SwiftUI

struct FitTextField: View {
    let title: String
    let text: Binding<String>
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        Group {
            if isSecure {
                SecureField(title, text: text)
            } else {
                TextField(title, text: text)
            }
        }
        .keyboardType(keyboardType)
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.96, green: 0.97, blue: 0.99).opacity(0.98))
        .foregroundStyle(.black)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.black.opacity(0.10), lineWidth: 1)
        )
    }
}

struct WorkoutTypePicker: View {
    let types: [String]
    @Binding var selection: String
    var placeholder: String = "Choose workout"

    var body: some View {
        Menu {
            ForEach(types, id: \.self) { type in
                Button {
                    selection = type
                } label: {
                    if selection == type {
                        Label(type, systemImage: "checkmark")
                    } else {
                        Text(type)
                    }
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundStyle(FitColors.background)
                Text(selection.isEmpty ? placeholder : selection)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                Spacer(minLength: 8)
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.black.opacity(0.65))
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color(red: 0.96, green: 0.97, blue: 0.99))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.black.opacity(0.10), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .accessibilityLabel("Workout type")
    }
}

struct FitButton: View {
    let title: String
    let action: () -> Void
    var destructive: Bool = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(destructive ? .white : .black)
                .background(destructive ? FitColors.danger : FitColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

struct FitCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 0.18, green: 0.22, blue: 0.28).opacity(0.90))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
            if subtitle != nil {
                Text(subtitle ?? "")
                    .font(.system(size: 12))
                    .foregroundStyle(FitColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
