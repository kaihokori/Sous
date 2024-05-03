import SwiftUI

struct OnboardingView: View {
    let dataController: DataController
    @State private var showingContentView = false
    
    var body: some View {
        VStack {
            Text("Welcome to Sous!")
                .font(.largeTitle.weight(.bold))
                .frame(width: 220)
                .clipped()
                .multilineTextAlignment(.center)
                .padding(.top, 82)
                .padding(.bottom, 52)
            VStack(spacing: 28) {
                HStack {
                    Image(systemName: "text.book.closed")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.accentColor)
                        .font(.title.weight(.regular))
                        .frame(width: 60, height: 50)
                        .clipped()
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Create Your Own Cookbook")
                            .font(.footnote.weight(.semibold))
                        Text("Easily create a new recipe with the \(Image(systemName: "plus")) icon. Recipes have the option to not include images or notes. ")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                HStack {
                    Image(systemName: "pencil.and.outline")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.accentColor)
                        .font(.title.weight(.regular))
                        .frame(width: 60, height: 50)
                        .clipped()
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Edit Recipes On The Go")
                            .font(.footnote.weight(.semibold))
                        Text("Adjust any aspect of existing recipes with the \"Edit Recipe\" button. ")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                HStack {
                    Image(systemName: "shared.with.you")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.accentColor)
                        .font(.title.weight(.regular))
                        .frame(width: 60, height: 50)
                        .clipped()
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Share Delicious Meals")
                            .font(.footnote.weight(.semibold))
                        Text("Use the share button to send recipes to friends and family. Hold down on images to copy them. ")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
            }
            Spacer()
            Button(action: {
                self.showingContentView = true
            }) {
                Text("Continue")
                    .font(.callout.weight(.semibold))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .mask(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.bottom, 60)
            }
            .fullScreenCover(isPresented: $showingContentView) {
                ContentView()
                    .environment(\.managedObjectContext, dataController.container.viewContext)
            }
        }
        .frame(maxWidth: .infinity)
        .clipped()
        .padding(.horizontal, 50)
    }
}
