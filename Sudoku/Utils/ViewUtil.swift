//
//  ViewUtil.swift
//  Sudoku
//
//  Created by Andreas Job on 26.11.23.
//

import SwiftUI

/*
 * Extend Views with a visibility(boolean) method
 * see: https://swiftuirecipes.com/blog/how-to-hide-a-swiftui-view-visible-invisible-gone
 */
enum ViewVisibility: CaseIterable {
	case visible, // view is fully visible
		 invisible, // view is hidden but takes up space
		 gone // view is fully removed from the view hierarchy
}

extension View {
	@ViewBuilder func visibility(_ visibility: ViewVisibility) -> some View {
		if visibility != .gone {
			if visibility == .visible {
				self
			} else {
				hidden()
			}
		}
	}
}

