import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<4, id: \.self) { index in
                let iconName = ["house.fill", "figure.strengthtraining.traditional", "fork.knife", "chart.bar.fill"][index]
                Button {
                    selectedTab = index
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: iconName)
                            .font(.system(size: 17, weight: .semibold))
                        if selectedTab == index {
                            Circle()
                                .fill(FitColors.primary)
                                .frame(width: 5, height: 5)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .foregroundStyle(selectedTab == index ? FitColors.primary : FitColors.textSecondary)
                }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 18)
        .background(Color.black.opacity(0.2))
    }
}
