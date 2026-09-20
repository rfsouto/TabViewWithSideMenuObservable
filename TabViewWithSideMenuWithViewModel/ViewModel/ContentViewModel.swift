//
//  ContentViewModel.swift
//  TabViewWithSlideMenu
//
//  Created by rfsouto on 6/3/24.
//
import Foundation
import Combine


class ContentViewModel: ObservableObject {
    @Published var isMenuOpen = false

    @Published
    var option: BarOptions = BarOptions.firstTab {
        didSet {
            if option == BarOptions.menuButton {
                option = originalOption
                isMenuOpen.toggle()
            } else {
                originalOption = option
            }
        }
    }
    
    private var originalOption: BarOptions = BarOptions.firstTab
}

