//
//  ContentViewModel.swift
//  TabViewWithSlideMenu
//
//  Created by rfsouto on 6/3/24.
//
import Foundation
import Combine
import os


class ContentViewModel: ObservableObject {
    private static let logger = Logger(subsystem: "com.rfsouto.TabViewWithSideMenuWithViewModel", category: "experiment")
    private(set) static var initCount = 0

    init() {
        Self.initCount += 1
        Self.logger.notice("ContentViewModel init #\(Self.initCount)")
    }

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

