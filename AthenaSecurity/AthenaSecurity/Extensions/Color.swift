//
//  Color.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import Foundation
import SwiftUI

extension Color {
    
    static let theme = ColorTheme()
    
}


struct ColorTheme {
    
//    Button Color
    
    let accent = Color("AccentColor")
    
//    Background Color
    
    let background = Color("BackgroundColor")
    let lightGrey = Color("LightGreyColor")
    
//    Warning Colors
    
    let green = Color("GreenColor")
    let yellow = Color("YellowColor")
    let red = Color("RedColor")
    
//    Text Color
    
    let primaryText = Color("PrimaryTextColor")
    let secondaryText = Color("SecondaryTextColor")
    let grey = Color("GreyColor")
    
//    TextField Color
    
    let pink = Color("PinkColor")
    let pinkRing = Color("PinkRing")
    
//    Button Color
    
    let button = Color("ButtonColor")
    
//    Shadow Color
    
    let shadow = Color("ShadowColor")

}
