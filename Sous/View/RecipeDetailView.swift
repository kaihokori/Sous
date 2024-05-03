//
//  RecipeDetailView.swift
//  Sous
//
//  Created by Kyle Graham on 4/5/2024.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @State var hasCopied = false
    @State var isEditingRecipe = false
    
    @State var isLargeDevice: Bool = {
        if UIScreen.main.bounds.height > 950 {
            return true
        } else {
            return false
        }
    }()
    
    var body: some View {
        ScrollView {
            VStack () {
                // MARK: Recipe Image
                if recipe.image != (UIImage(named: "Placeholder.png")?.pngData())! {
                    if isLargeDevice { // iPad
                        Image(uiImage: UIImage(data: recipe.image ?? (UIImage(named: "Placeholder.png")?.pngData())!)!)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 450, maxHeight: 300)
                            .cornerRadius(5)
                            .shadow(radius: 10)
                            .padding(.top, 15)
                            .onLongPressGesture {
                                UIPasteboard.general.image = UIImage(data: recipe.image!)
                                hasCopied.toggle()
                            }
                            .alert("Image Copied to Clipboard", isPresented: $hasCopied) {
                                Button("Got it!", role: .cancel) { }
                            }
                    } else { // iPhone
                        Image(uiImage: UIImage(data: recipe.image ?? (UIImage(named: "Placeholder.png")?.pngData())!)!)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 325, maxHeight: 250)
                            .cornerRadius(5)
                            .shadow(radius: 10)
                            .padding(.top, 15)
                            .onLongPressGesture {
                                UIPasteboard.general.image = UIImage(data: recipe.image!)
                                hasCopied.toggle()
                            }
                            .alert("Image Copied to Clipboard", isPresented: $hasCopied) {
                                Button("Got it!", role: .cancel) { }
                            }
                    }
                }
                
                HStack {
                    VStack {
                        Text("Prep")
                            .fontWeight(.semibold)
                            .font(.headline)
                            .padding(.bottom, 2.5)
                        if (recipe.preptime == 60) {
                            Text("1")
                                .fontWeight(.regular)
                                .font(.headline)
                            Text("Hour")
                                .fontWeight(.regular)
                                .font(.headline)
                        } else if (recipe.preptime == 120) {
                            Text("2")
                                .fontWeight(.regular)
                                .font(.headline)
                            Text("Hours")
                                .fontWeight(.regular)
                                .font(.headline)
                        } else {
                            Text("\(Int(recipe.preptime))")
                                .fontWeight(.regular)
                                .font(.headline)
                            Text("Minutes")
                                .fontWeight(.regular)
                                .font(.body)
                        }
                    }.frame(width: 90)
                    Divider().frame(height:60)
                    VStack {
                        Text("Cook")
                            .fontWeight(.semibold)
                            .font(.headline)
                            .padding(.bottom, 2.5)
                        if (recipe.cooktime == 60) {
                            Text("1")
                                .fontWeight(.regular)
                                .font(.headline)
                            Text("Hour")
                                .fontWeight(.regular)
                                .font(.headline)
                        } else if (recipe.cooktime == 120) {
                            Text("2")
                                .fontWeight(.regular)
                                .font(.headline)
                            Text("Hours")
                                .fontWeight(.regular)
                                .font(.headline)
                        } else {
                            Text("\(Int(recipe.cooktime))")
                                .fontWeight(.regular)
                                .font(.headline)
                            Text("Minutes")
                                .fontWeight(.regular)
                                .font(.body)
                        }
                    }.frame(width: 90)
                }
                .padding(.top, 10)
                
                VStack(alignment: .leading) {
                    // MARK: Ingredients
                    Text("Ingredients")
                        .font(.headline)
                        .padding([.bottom, .top], 5)
                    
                    Text(recipe.ingredients ?? "Unknown Ingredients")
                        .fontWeight(.light)
                        .font(.body)
                        .textSelection(.enabled)
                    
                    // MARK: Divider
                    Divider()
                    
                    // MARK: Directions
                    Text("Method")
                        .font(.headline)
                        .padding([.bottom, .top], 5)
                    
                    Text(recipe.method ?? "Unknown Method")
                        .fontWeight(.light)
                        .font(.body)
                        .textSelection(.enabled)
                    
                    if (recipe.notes != "") {
                        if (recipe.notes != "No Notes") {
                            // MARK: Divider
                            Divider()
                            
                            // MARK: Notes
                            Text("Notes")
                                .font(.headline)
                                .padding([.bottom, .top], 5)
                            
                            Text(recipe.notes ?? "No Notes")
                                .fontWeight(.light)
                                .font(.body)
                                .textSelection(.enabled)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 5)
                
                if !isLargeDevice {
                    VStack {
                        Button {
                            isEditingRecipe.toggle()
                            dismiss()
                        } label: {
                            Text("Edit Recipe")
                        }
                        .sheet(isPresented: $isEditingRecipe) {
                            EditRecipeView(
                                name: recipe.name ?? "",
                                category: recipe.category ?? "",
                                preptime: recipe.preptime,
                                cooktime: recipe.cooktime,
                                ingredients: recipe.ingredients ?? "",
                                method: recipe.method ?? "",
                                notes: recipe.notes ?? "",
                                image: recipe.image ?? (UIImage(named: "Placeholder.png")?.pngData())!,
                                old: recipe)
                        }
                    }
                    .padding(.top, 10)
                }
            }
            .padding(.bottom, 30)
        }
        .toolbar {
            ShareLink(item: """
            \(recipe.name ?? "Unknown Recipe Name")ㅤ
            Preperation Time: \(Int(recipe.preptime)) minutesㅤ
            Cooking Time: \(Int(recipe.cooktime)) minutes
            ㅤ
            Ingredients
            \(recipe.ingredients ?? "Unknown Ingredients")
            ㅤ
            Method
            \(recipe.method ?? "Unknown Method")
            ㅤ
            Notes
            \(recipe.notes ?? "No Notes")
            """, preview: SharePreview(recipe.name ?? "Unknown Recipe Name", image: "AppIcon"))
        }
    }
    
    func removeRecipe() {
        moc.delete(recipe)
        try? moc.save()
        dismiss()
    }
    
    func check() {
        print(UIScreen.main.bounds.height)
    }
}
