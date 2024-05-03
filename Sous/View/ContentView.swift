import SwiftUI

 struct TextFieldLimitModifer: ViewModifier {
     @Binding var value: String
     var length: Int

     func body(content: Content) -> some View {
         content
             .onReceive(value.publisher.collect()) {
                 value = String($0.prefix(length))
             }
     }
 }

 extension View {
     func limitInputLength(value: Binding<String>, length: Int) -> some View {
         self.modifier(TextFieldLimitModifer(value: value, length: length))
     }
 }

 struct ContentView: View {
     @Environment(\.managedObjectContext) var moc
     @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var recipes: FetchedResults<Recipe>

     let categories = ["Breakfast", "Appetizers", "Main Courses", "Soups", "Salads", "Desserts", "Snacks", "Beverages"]

     @State private var isAddingRecipe = false
     @State private var totalTime = 0
     @State private var searchText = ""
     @State private var selectedCategory: String?

     @State var isSmallDevice: Bool = {
         if UIScreen.main.bounds.height < 950 {
             return true
         } else {
             return false
         }
     }()

     var filteredRecipes: [Recipe] {
         if let category = selectedCategory {
             return recipes.filter { $0.category == category }
         } else {
             return Array(recipes)
         }
     }

     var body: some View {
         NavigationSplitView {
             if recipes.count == 0 || filteredRecipes.isEmpty {
                 Text("Add a new recipe with the \(Image(systemName: "plus")) icon")
                     .padding(.top, 15)
                     .navigationTitle("Recipes")
                     .navigationBarTitleDisplayMode(.large)
                     .scrollContentBackground(.hidden)
                     .toolbar {
                         if isSmallDevice { // iPad
                             ToolbarItem {
                                 Menu {
                                     Button("All") {
                                         selectedCategory = nil
                                     }
                                     ForEach(categories, id: \.self) { category in
                                         Button(action: {
                                             selectedCategory = category
                                         }) {
                                             Label(category, systemImage: category == selectedCategory ? "checkmark.circle.fill" : "circle")
                                         }
                                     }
                                 } label: {
                                     Label("Filter", systemImage: "slider.horizontal.3")
                                 }
                             }
                         }
                         ToolbarItem {
                             Button {
                                 isAddingRecipe.toggle()
                             } label: {
                                 Label("Add", systemImage: "plus")
                             }
                             .sheet(isPresented: $isAddingRecipe) {
                                 AddRecipeView(
                                     name: "",
                                     category: "Breakfast",
                                     preptime: 0,
                                     cooktime: 0,
                                     ingredients: "",
                                     method: "",
                                     notes: "",
                                     image: (UIImage(named: "Placeholder.png")?.pngData())!)
                             }
                         }
                     }
             } else {
                 List {
                     ForEach(filteredRecipes.filter { searchText.isEmpty || $0.name!.localizedCaseInsensitiveContains(searchText) }) { recipe in
                         NavigationLink {
                             RecipeDetailView(recipe: recipe)
                                 .navigationTitle(Text(recipe.name ?? "Unknown Recipe Name"))
                                 .navigationBarTitleDisplayMode(.inline)
                         } label: {
                             HStack(spacing: 20.0) {
                                 if recipe.image != (UIImage(named: "Placeholder.png")?.pngData())! {
                                     Image(uiImage: UIImage(data: recipe.image ?? (UIImage(named: "Placeholder.png")?.pngData())!)!)
                                         .resizable()
                                         .scaledToFill()
                                         .frame(width: 130, height: 120, alignment: .leading)
                                         .clipped()
                                         .cornerRadius(5)
                                 }
                                 VStack (alignment: .leading) {
                                     Text(recipe.name ?? "Unknown Recipe Name")
                                         .fontWeight(.semibold)
                                         .font(.body)
                                         .multilineTextAlignment(.leading)
                                         .padding(.bottom, 5)
                                     Text("Total Time: " + String(Int(recipe.totaltime)) + " mins")
                                         .font(.callout)
                                 }
                                 .padding(.bottom, 7.5)
                                 .padding(.trailing, 5)
                             }
                             .frame(height: 120)
                         }
                     }
                     .onDelete(perform: removeRecipes)
                 }
                 .navigationTitle("Recipes")
                 .navigationBarTitleDisplayMode(.large)
                 .scrollContentBackground(.hidden)
                 .toolbar {
                     ToolbarItem {
                         Menu {
                             Button("All") {
                                 selectedCategory = nil
                             }
                             ForEach(categories, id: \.self) { category in
                                 Button(action: {
                                     selectedCategory = category
                                 }) {
                                     Label(category, systemImage: category == selectedCategory ? "checkmark.circle.fill" : "circle")
                                 }
                             }
                         } label: {
                             Label("Filter", systemImage: "slider.horizontal.3")
                         }
                     }
                     ToolbarItem {
                         Button {
                             isAddingRecipe.toggle()
                         } label: {
                             Label("Add", systemImage: "plus")
                         }
                         .sheet(isPresented: $isAddingRecipe) {
                             AddRecipeView(
                                 name: "",
                                 category: selectedCategory ?? "",
                                 preptime: 0,
                                 cooktime: 0,
                                 ingredients: "",
                                 method: "",
                                 notes: "",
                                 image: (UIImage(named: "Placeholder.png")?.pngData())!)
                         }
                     }
                 }
                 .searchable(text: $searchText, prompt: "Search for Recipes")
             }
         }
         detail: {
             Text("Please select a recipe")
         }
     }

     func removeRecipes(at offsets: IndexSet) {
         for index in offsets {
             let recipe = recipes[index]
             moc.delete(recipe)
         }
         do {
             try moc.save()
         } catch {
             print("Error while removing")
         }
     }
 }
