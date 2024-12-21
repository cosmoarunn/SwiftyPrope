//
//  Splashscreen.swift
//  SwiftyPrope
//
//  Created by ARUN PANNEERSELVAM on 19/12/2024.
//


import SwiftUI

struct Splashscreen: View {
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var sceneState: AppStateImposer
    
    @State var appTitle: String = "Prope"
    @State var isAnimationComplete: Bool = false
    
  var body: some View {
      
    ZStack {
        
        Color.clear
            .background(Color(uiColor: .systemBlue.withAlphaComponent(0.5)))
        Text(appTitle)
            .font(.system(size: 40, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.9), radius: 15, x: 1.0, y: 1.0)
            //.rotationEffect(.degrees(0))
            .frame(maxWidth: .infinity, alignment: .center)
            //.customStroke(color: .white, width: 3)
            .reflection(opacity: 0.4, spacing: 0.1)
    }
    .ignoresSafeArea()
    .onAppear {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        
        if authStore.loginState == .signedIn {
            print("Signed in..")
            //guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
        } else {
            print("User has not signed in!")
            windowScene.windows.first?.rootViewController = UIHostingController(rootView:
            SignInVew().environmentObject(authStore))
        }
    }
    
  }
}

struct Splashscreen_Previews: PreviewProvider {
  static var previews: some View {
    Splashscreen()
  }
}
