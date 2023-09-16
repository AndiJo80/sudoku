// https://stackoverflow.com/a/56858112/14952324
import SwiftUI
/*
struct NavigationTestView: View { // ContentView: View {

	var body: some View {
		NavigationView {
			TopView().navigationBarTitle(Text("Top View"))
		}
	}
}

struct TopView: View {
	@State private var viewTypeA = true

	let detailViewA = DynamicNavigationDestinationLink(id: \String.self) { data in
			ListA(passedData: data)
	}

	let detailViewB = DynamicNavigationDestinationLink(id: \String.self) { data in
			ListB(passedData: data)
	}

	var body: some View {
			List(0..<5) { item in
				NavigationLink(destination: ListC(passedData: "FROM ROW #\(item)")) {
					HStack {
						Text("Row #\(item)")
						Spacer()
						Text("edit")
							.tapAction {
								self.detailViewA.presentedData?.value = "FROM TAP ACTION Row #\(item)"
						}
					}
				}
			}.navigationBarItems(trailing: Button(action: {
							self.detailViewB.presentedData?.value = "FROM PLUS CIRCLE"
			}, label: {
					Image(systemName: "plus.circle.fill")
				}))
	}
}

struct ListA: View {
	let passedData: String

	var body: some View {
		VStack {
			Text("VIEW A")
			Text(passedData)
		}
	}
}

struct ListB: View {
	let passedData: String

	var body: some View {
		VStack {
			Text("VIEW B")
			Text(passedData)
		}
	}
}

struct ListC: View {
	let passedData: String

	var body: some View {
		VStack {
			Text("VIEW C")
			Text(passedData)
		}
	}
}
*/


struct DetailView: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	var body: some View {
		Button("Here is Detail View. Tap to go back.",
			action: {
				self.presentationMode.wrappedValue.dismiss()
			}
		)
	}
}

struct RootView: View {
	var body: some View {
		VStack {
			NavigationLink(destination: DetailView()) {
				Text("I am Root. Tap for Detail View.")
			}
		}
	}
}

struct NavigationTestView: View {
	var body: some View {
		NavigationView {
			RootView()
		}
	}
}

struct NavigationTestView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationTestView()
	}
}
