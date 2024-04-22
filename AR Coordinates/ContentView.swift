//
//  ContentView.swift
//  AR Coordinates
//
//  Created by Anthony Li on 4/18/24.
//

import SwiftUI
import ARKit
import RealityKit

struct ContentView : View {
    @State var coordinates: SIMD3<Float>?
    
    var body: some View {
        ZStack {
            ARViewContainer(coordinates: $coordinates)
            if let coordinates {
                VStack {
                    Text("x = \(coordinates.x * 100, format: .number.precision(.fractionLength(0))) cm")
                        .foregroundStyle(.red)
                    Text("y = \(coordinates.y * 100, format: .number.precision(.fractionLength(0))) cm")
                        .foregroundStyle(.green)
                    Text("z = \(coordinates.z * 100, format: .number.precision(.fractionLength(0))) cm")
                        .foregroundStyle(.blue)
                }
                    .contentTransition(.numericText())
                    .animation(.spring, value: coordinates)
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(minWidth: 200)
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(.rect(cornerRadius: 16))
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    @Binding var coordinates: SIMD3<Float>?
    
    class Coordinator: NSObject, ARSessionDelegate {
        let parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            parent.coordinates = [
                frame.camera.transform.columns.3.x,
                frame.camera.transform.columns.3.y,
                frame.camera.transform.columns.3.z
            ]
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        arView.session.delegate = context.coordinator

        // Create a cube model
        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
        let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
        let model = ModelEntity(mesh: mesh, materials: [material])
        model.transform.translation.y = 0.05

        // Create horizontal plane anchor for the content
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        // anchor.children.append(model)

        // Add the horizontal plane anchor to the scene
        arView.scene.anchors.append(anchor)

        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}



#Preview {
    ContentView()
}
