import CoreData
import SwiftUI

struct AddRecipeView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    let categories = ["Breakfast", "Appetizers", "Main Courses", "Soups", "Salads", "Desserts", "Snacks", "Beverages"]
    
    @State var name: String
    @State var category: String
    @State var preptime: Double
    @State var cooktime: Double
    @State var ingredients: String
    @State var method: String
    @State var notes: String
    @State var image: Data
    
    @State private var showPasteboardAlert = false
    @State private var showFormatAlert = false
    
    @State var selectingImage = false
    @State var cameraSelected = false
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                Spacer()
                Button("Save") {
                    let recipe = Recipe(context: moc)
                    recipe.id = UUID()
                    recipe.name = name
                    recipe.category = category
                    recipe.preptime = preptime
                    recipe.cooktime = cooktime
                    recipe.totaltime = preptime + cooktime
                    recipe.ingredients = ingredients
                    recipe.method = method
                    recipe.notes = notes
                    recipe.image = image
                    
                    try? moc.save()
                    dismiss()
                }
                .disabled(name.isEmpty || preptime == 0 || cooktime == 0 || ingredients.isEmpty || method.isEmpty)
            }
            .padding(.top, 15)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.bottom, 5)
            
            Form {
                Section(content: {
                    TextField("", text: $name)
                        .limitInputLength(value: $name, length: 35)
                }, header: {
                    Text("Name")
                })
                .textCase(nil)
                
                Section(content: {
                    Picker("Select a category", selection: $category) {
                        ForEach(categories, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.menu)
                }, header: {
                    Text("Category")
                })
                .textCase(nil)
                
                Section(content: {
                    Menu("Select an Image") {
                        Button {
                            selectingImage = true
                            cameraSelected = true
                        } label: {
                            Label("Camera", systemImage: "camera.fill")
                        }
                        Button {
                            selectingImage = true
                            cameraSelected = false
                        } label: {
                            Label("Photo Library", systemImage: "photo.fill.on.rectangle.fill")
                        }
                        
                    }
                    if image != (UIImage(named: "Placeholder.png")?.pngData())! {
                        Group {
                            Image(uiImage: UIImage(data: image)!)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: 325, maxHeight: 200, alignment: .center)
                                .cornerRadius(10)
                        }
                        .padding(.vertical, 5)
                    }
                }, header: {
                    Text("Image")
                })
                .textCase(nil)
                
                Section(content: {
                    Slider(value: $preptime, in: 0...120, step: 5)
                }, header: {
                    if (preptime < 60) {
                        Text("Preperation Time: \(Int(preptime)) Minutes")
                    } else if (preptime == 60) {
                        Text("Preperation Time: 1 Hour")
                    } else if (preptime == 120) {
                        Text("Preperation Time: 2 Hours")
                    } else {
                        Text("Preperation Time: 1 Hour, \(Int(preptime)%60) Minutes")
                    }
                })
                .textCase(nil)
                
                Section(content: {
                    Slider(value: $cooktime, in: 0...120, step: 5)
                }, header: {
                    if (cooktime < 60) {
                        Text("Cooking Time: \(Int(cooktime)) Minutes")
                    } else if (cooktime == 60) {
                        Text("Cooking Time: 1 Hour")
                    } else if (cooktime == 120) {
                        Text("Cooking Time: 2 Hours")
                    } else {
                        Text("Cooking Time: 1 Hour, \(Int(cooktime)%60) Minutes")
                    }
                })
                .textCase(nil)
                
                Section(content: {
                    TextEditor(text: $ingredients)
                        .frame(minHeight: 200, maxHeight: 500)
                }, header: {
                    Text("Ingredients")
                })
                .textCase(nil)
                
                Section(content: {
                    TextEditor(text: $method)
                        .frame(minHeight: 300, maxHeight: 500)
                }, header: {
                    Text("Method")
                })
                .textCase(nil)
                
                Section(content: {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }, header: {
                    Text("Notes")
                })
                .textCase(nil)
            }
            
            Button {
                if let pastedString = UIPasteboard.general.string {
                    if pastedString.components(separatedBy: "ㅤ").count == 6 {
                        let result = parseExistingRecipe(input: pastedString)
                        name = result.0
                        preptime = Double(result.1) ?? 0
                        cooktime = Double(result.2) ?? 0
                        ingredients = result.3
                        method = result.4
                        notes = result.5
                    } else {
                        showFormatAlert.toggle()
                    }
                } else {
                    showPasteboardAlert.toggle()
                }
            } label: {
                Label("Import Shared Recipe", systemImage: "square.and.arrow.down")
                    .padding(.bottom, 10)
            }
        }
        .sheet(isPresented: $selectingImage) {
            ImagePickerView(images: $image, show: $selectingImage, cameraSelected: $cameraSelected)
                .edgesIgnoringSafeArea(.top)
                .edgesIgnoringSafeArea(.bottom)
        }
        .alert(isPresented: $showPasteboardAlert) {
            Alert(title: Text("Pasteboard Error"), message: Text("No contents were found on pasteboard."), dismissButton: .default(Text("Dismiss")))
        }
        .alert(isPresented: $showFormatAlert) {
            Alert(title: Text("Format Error"), message: Text("Contents in pasteboard didn't match expected format."), dismissButton: .default(Text("Dismiss")))
        }
    }
    
    func parseExistingRecipe(input: String) -> (String, String, String, String, String, String) {
        let seperated_input = input.components(separatedBy: "ㅤ")
        
        return (seperated_input[0], seperated_input[1].components(separatedBy: " ")[2], seperated_input[2].components(separatedBy: " ")[2], String(seperated_input[3].dropFirst(13).dropLast(1)), String(seperated_input[4].dropFirst(8).dropLast(1)), String(seperated_input[5].dropFirst(7)))
    }
}
