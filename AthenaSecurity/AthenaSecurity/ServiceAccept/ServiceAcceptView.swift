//
//  ServiceAcceptView.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import SwiftUI
import ComposableArchitecture

struct ServiceAcceptView: View {
    let store: Store<ServiceAcceptFeature.State, ServiceAcceptFeature.Action>
    
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
                        
                    case .respond:
                        Text("This user has requested your services")
                            .font(.custom(FontsManager.Poppins.regular, size: 10))
                            .foregroundColor(Color.theme.secondaryText)
                            .padding(.top)
                        
                        ResponderView()
                        
                        PaymentOptionView()
                        
                        HStack (spacing: 15) {
                            AcceptRejectButtonView(buttonType: .accept, buttonLabel: "Accept") {
                                viewStore.send(.accept)
                            }
                            
                            AcceptRejectButtonView(buttonType: .reject, buttonLabel: "Reject") {
                                viewStore.send(.reject)
                            }
                        }
                        .padding(.horizontal, 30)
                        
                    case .accepted:
                        AcceptRejectButtonView(buttonType: .accept, buttonLabel: "Get Directions") {
                            viewStore.send(.getDirections)
                        }
                        .padding(.horizontal, 30)
                        
                    case .enRoute:
                        AcceptRejectButtonView(buttonType: .accept, buttonLabel: "Arrived") {
                            viewStore.send(.arrive)
                        }
                        .padding(.horizontal, 30)
                    case .arrived:
                        AcceptRejectButtonView(buttonType: .accept, buttonLabel: "Complete Services") {
                            viewStore.send(.complete)
                        }
                        .padding(.horizontal, 30)

                    case .completed:
                        
                        // This Logic Is Wrong... But i'm like super tired lol..
                        AcceptRejectButtonView(buttonType: .accept, buttonLabel: "Set Back To Idle..") {
                            viewStore.send(.complete)
                        }
                        .padding(.horizontal, 30)
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.bottom, 50)
            .background(Color.theme.background.clipShape(CustomCorner(corners: [.topLeft, .topRight])))
        }
    }
}

struct ServiceAcceptView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceAcceptView(store: Store(initialState: ServiceAcceptFeature.State(),
                                        reducer: AnyReducer(ServiceAcceptFeature()),
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
                    HStack (alignment: .top) {
                        // Security Profile Image
                        Image(uiImage: UIImage(imageLiteralResourceName: "sabrina"))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 132.66, height: 200)
                            .cornerRadius(15)
                        //                            .shadow(color: Color.theme.shadow, radius: 2)
                        
                        VStack (alignment: .leading, spacing: 8) {
                            // Security Name
                            Text("Sabrina Morreno")
                                .font(.custom(FontsManager.Poppins.semiBold, size: 16))
                                .foregroundColor(Color.theme.primaryText)
                                .padding(.bottom, 8)
                            
                            // Security Unit
                            Text("Douglasdale, Fourways")
                                .font(.custom(FontsManager.Poppins.light, size: 12))
                                .foregroundColor(Color.theme.grey)
                            
                            // Security Vehicle
                            Text("8 Gereonemo Avenue - ")
                                .font(.custom(FontsManager.Poppins.light, size: 12))
                                .foregroundColor(Color.theme.grey)
                            
                            +
                            // Vehicle Color
                            Text("1045")
                                .font(.custom(FontsManager.Poppins.semiBold, size: 12))
                                .foregroundColor(Color.theme.primaryText)
                            
                            // Vehicle Registration
                            Text("JB 77 77 GP")
                                .font(.custom(FontsManager.Poppins.light, size: 12))
                                .foregroundColor(Color.theme.grey)
                            
                            // Estimated Time Of Arrival
                            Text("ETA: ")
                                .font(.custom(FontsManager.Poppins.light, size: 12))
                                .foregroundColor(Color.theme.grey)
                            
                            +
                            
                            Text("3 MIN")
                                .font(.custom(FontsManager.Poppins.light, size: 12))
                                .foregroundColor(Color.theme.accent)
                            
                            // Service Price
                            HStack {
                                
                                Text("R ")
                                    .font(.custom(FontsManager.Poppins.semiBold, size: 16))
                                    .foregroundColor(.primary)
                                +
                                
                                Text("159,00")
                                    .font(.custom(FontsManager.Poppins.semiBold, size: 16))
                                    .foregroundColor(.primary)
                            }
                            .padding(.top, 40)
                        }
                        .padding(.leading)
                    }
                    .padding(.top)
    }
}

struct PaymentOptionView: View {
    var body: some View {
        HStack (spacing: 12) {
            
            Text("Selected Payment Method")
                .font(.custom(FontsManager.Poppins.regular, size: 20))
                .foregroundColor(Color.theme.primaryText)
            Spacer()
            Image(systemName: "creditcard.fill")
                .font(.subheadline)
                .foregroundColor(.primary)
                .padding(.leading)
            
        }
        .frame(height: 50)
        .cornerRadius(10)
        .padding(.horizontal, 30)
        .padding(.top)
    }
}
