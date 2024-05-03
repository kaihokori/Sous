import CoreData
import SwiftUI

struct EditRecipeView: View {
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
    @State var old: Recipe
    
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
                    moc.delete(old)
                    try? moc.save()
                    
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
                }, header: {
                    Text("Ingredients")
                })
                .textCase(nil)
                
                Section(content: {
                    TextEditor(text: $method)
                }, header: {
                    Text("Method")
                })
                .textCase(nil)
                
                Section(content: {
                    TextEditor(text: $notes)
                }, header: {
                    Text("Notes")
                })
                .textCase(nil)
            }
        }
        .sheet(isPresented: $selectingImage) {
            ImagePickerView(images: $image, show: $selectingImage, cameraSelected: $cameraSelected)
                .edgesIgnoringSafeArea(.top)
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}
