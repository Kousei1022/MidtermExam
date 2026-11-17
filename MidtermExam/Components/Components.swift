import SwiftUI

struct FitTextField: View {
    let title: String
    let text: Binding<String>
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        Group {
            if isSecure {
                SecureField("", text: text, prompt: Text(title).foregroundStyle(FitColors.placeholder))
            } else {
                TextField("", text: text, prompt: Text(title).foregroundStyle(FitColors.placeholder))
            }
        }
        .font(.system(size: 15, weight: .medium))
        .foregroundStyle(FitColors.text)
        .accentColor(FitColors.primary)
        .tint(FitColors.primary)
        .keyboardType(keyboardType)
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 52)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(FitColors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.16), radius: 10, x: 0, y: 6)
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
                    .foregroundStyle(FitColors.primary)
                Text(selection.isEmpty ? placeholder : selection)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Spacer(minLength: 8)
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(FitColors.textSecondary)
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(FitColors.border, lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(destructive ? .white : .black)
                .background(
                    LinearGradient(
                        colors: destructive ? [FitColors.danger, FitColors.danger.opacity(0.85)] : [FitColors.primary, FitColors.primary.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: (destructive ? FitColors.danger : FitColors.primary).opacity(0.30), radius: 10, x: 0, y: 8)
        }
        .buttonStyle(.plain)
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
            .background(
                LinearGradient(
                    colors: [FitColors.panel, FitColors.surfaceElevated],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(FitColors.border, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 12)
    }
}

struct FitFormSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content

    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        FitCard {
            VStack(alignment: .leading, spacing: 15) {
                HStack(spacing: 9) {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(FitColors.primary)
                    Text(title.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(FitColors.textSecondary)
                }
                content
            }
        }
    }
}

struct FormStepperRow: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var step: Int = 1
    var suffix = ""

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(FitColors.textSecondary)
            Spacer()
            Stepper(value: $value, in: range, step: step) {
                Text(suffix.isEmpty ? "\(value)" : "\(value) \(suffix)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
            .tint(FitColors.primary)
        }
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
