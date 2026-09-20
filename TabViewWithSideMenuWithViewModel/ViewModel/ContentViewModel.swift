//
//  ContentViewModel.swift
//  TabViewWithSlideMenu
//
//  Created by rfsouto on 6/3/24.
//
import Foundation
import Observation

@Observable
final class ContentViewModel {
    var isMenuOpen = false
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
    @ObservationIgnored
    private var originalOption: BarOptions = BarOptions.firstTab
}
