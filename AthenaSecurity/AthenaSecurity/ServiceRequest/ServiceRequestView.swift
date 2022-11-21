//
//  ServiceRequestView.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import SwiftUI
import ComposableArchitecture

struct ServiceRequestView: View {
    let store: Store<ServiceRequestFeature.State, ServiceRequestFeature.Action>
    
    var body: some View {
        /*TODO: Use TCA to only display this view when some value != nil
         The current method works but we dont want the view to even be in memory if its not needed
         */
        WithViewStore(self.store) { viewStore in
            ZStack {
                VStack {
                    Capsule()
                        .foregroundColor(Color(.systemGray6))
                        .frame(width: 40, height: 6)
                        .padding(.top, 8)
                    
                    switch viewStore.state.route {
                    case .idle:
                        Text("Swipe to select your preferred option")
                            .font(.custom(FontManager.Poppins.regular, size: 10))
                            .foregroundColor(Color.theme.secondaryText)
                            .padding(.top)
                        
                        // Security Responder Information View
                        ResponderView()
                        
                        // Payment Option View
                        PaymentOptionView()
                        
                        // Request Service button
                        AuthButtonView(buttonLabel: "Confirm ARES") {
                            viewStore.send(.confirm)
                        }
                    case .confirmed:
                        Text("Requesting Help...")
                            .padding(.top)
                        Button("Move to accepted") {
                            viewStore.send(.accept)
                        }
                    case .accepted:
                        Text("Help is on the way...")
                            .padding(.top)
                        ResponderView()
                    case .completed:
                        Text("Trip Completed")
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.bottom, 50)
            .background(Color.theme.background.clipShape(CustomCorner(corners: [.topLeft, .topRight])))
        }
    }
}

struct ServiceRequestView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceRequestView(store: Store(initialState: ServiceRequestFeature.State(),
                                        reducer: AnyReducer(ServiceRequestFeature()),
                                        environment: ()))
    }
}

struct CustomCorner: Shape {
    let corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: 25, height: 25))
        
        return Path(path.cgPath)
    }
}

struct ResponderView: View {
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack (spacing: 12){
                ForEach(0 ..< 3, id: \.self) { _ in
                    HStack (alignment: .top) {
                        // Security Profile Image
                        Image(uiImage: UIImage(imageLiteralResourceName: "security"))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 132.66, height: 200)
                            .cornerRadius(15)
                        //                            .shadow(color: Color.theme.shadow, radius: 2)
                        
                        VStack (alignment: .leading, spacing: 8) {
                            // Security Name
                            Text("Soap Mactavish")
                                .font(.custom(FontManager.Poppins.semiBold, size: 16))
                                .foregroundColor(Color.theme.primaryText)
                                .padding(.bottom, 8)
                            
                            // Security Unit
                            Text("Task Force 141")
                                .font(.custom(FontManager.Poppins.light, size: 12))
                                .foregroundColor(Color.theme.grey)
                            
                            // Security Vehicle
                            Text("BMW M8 Competition - ")
                                .font(.custom(FontManager.Poppins.light, size: 12))
                                .foregroundColor(Color.theme.grey)
                            
                            +
                            // Vehicle Color
                            Text("Black")
                                .font(.custom(FontManager.Poppins.semiBold, size: 12))
                                .foregroundColor(Color.theme.primaryText)
                            
                            // Vehicle Registration
                            Text("GHOST141 GP")
                                .font(.custom(FontManager.Poppins.light, size: 12))
                                .foregroundColor(Color.theme.grey)
                            
                            // Estimated Time Of Arrival
                            Text("ETA: ")
                                .font(.custom(FontManager.Poppins.light, size: 12))
                                .foregroundColor(Color.theme.grey)
                            
                            +
                            
                            Text("3 MIN")
                                .font(.custom(FontManager.Poppins.light, size: 12))
                                .foregroundColor(Color.theme.accent)
                            
                            // Service Price
                            HStack {
                                
                                Text("R ")
                                    .font(.custom(FontManager.Poppins.semiBold, size: 16))
                                    .foregroundColor(.primary)
                                +
                                
                                Text("159,00")
                                    .font(.custom(FontManager.Poppins.semiBold, size: 16))
                                    .foregroundColor(.primary)
                            }
                            .padding(.top, 40)
                        }
                        .padding(.leading)
                    }
                    .padding(.top)
                }
            }
        }.padding(.horizontal, 30)
    }
}

struct PaymentOptionView: View {
    var body: some View {
        HStack (spacing: 12) {
            Image(systemName: "creditcard.fill")
                .font(.subheadline)
                .foregroundColor(.primary)
                .padding(.leading)
            
            Text("** 5117")
                .font(.custom(FontManager.Poppins.regular, size: 20))
                .foregroundColor(Color.theme.primaryText)
            
            Spacer()
            Image(systemName: "chevron.right")
                .imageScale(.medium)
                .foregroundColor(Color.theme.accent)
                .padding()
            
        }
        .frame(height: 50)
        .cornerRadius(10)
        .padding(.horizontal, 30)
        .padding(.top)
    }
}
