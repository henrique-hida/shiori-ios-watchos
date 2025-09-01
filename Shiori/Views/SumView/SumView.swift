//
//  SumView.swift
//  Shiori
//
//  Created by Henrique Hida on 04/08/25.
//

import SwiftUI
import UIKit

struct SumView: View {
    
    @StateObject private var viewModel: SumViewModel

    init(id: String, type: String) {
        _viewModel = StateObject(wrappedValue: SumViewModel(id: id, sumType: type))
    }

    let mainColor: Color = Color.purple
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var speedLabel: String = "1.0"
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false){
                    VStack(alignment: .leading) {
                        MarkdownLabelView(markdownString: viewModel.removeMarkdownBlockMarkers(from: viewModel.currentSummary?.content ?? ""))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                
                ZStack {
                    Color(#colorLiteral(red: 0.8993570181, green: 0.8993570181, blue: 0.8993570181, alpha: 1))
                        .ignoresSafeArea()
                        .frame(height: 100)
                    
                    HStack {
                        Circle()
                            .foregroundColor(mainColor)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: viewModel.audioPlaying ? "pause.fill" : "play.fill")
                                    .foregroundColor(.white)
                            )
                            .offset(y: 5.0)
                            .onTapGesture {
                                viewModel.pressAudioButton()
                            }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Menu {
                                Button("0.5x") {
                                    viewModel.changeSpeed(to: 0.25)
                                    speedLabel = "0.5"
                                }
                                .tag("0.5x")
                                Button("1.0x") {
                                    viewModel.changeSpeed(to: 0.5)
                                    speedLabel = "1.0"
                                }
                                .tag("1.0x")
                                Button("1.25x") {
                                    viewModel.changeSpeed(to: 0.625)
                                    speedLabel = "1.25"
                                }
                                .tag("1.25x")
                                Button("1.5x") {
                                    viewModel.changeSpeed(to: 0.75)
                                    speedLabel = "1.5"
                                }
                                .tag("1.5x")
                            } label: {
                                Text("\(speedLabel)x")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.trailing, 5)
                                    .accentColor(mainColor)
                            }
                            
                            PlaySlider(value: $viewModel.audioProgress, range: 0...1.0) { isEditing in
                                viewModel.sliderChanged(to: viewModel.audioProgress, isEditing: isEditing)
                            }
                            .scaleEffect(y: 1.5)
                            
                            Text("- \(viewModel.timeDisplay)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 5)
                        }
                    }
                    .padding(.horizontal)
                }
                .onDisappear {
                    viewModel.onDisappear()
                    speedLabel = "1.0"
                }
                
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("Resumo", displayMode: .inline)
        .navigationBarItems(
            leading:
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "chevron.left")
                })
                .accentColor(.primary),
            trailing:
                HStack(alignment: .center, spacing: nil) {
                    Image(systemName: "line.horizontal.3")
                }
        )
    }
}

struct PlaySlider: UIViewRepresentable {
    
    @Binding var value: Double
    var range: ClosedRange<Double>
    var onEditingChanged: (Bool) -> Void
    
    var thumbSize: CGSize = CGSize(width: 15, height: 10)
    
    var minTrackColor: UIColor = UIColor(red: 0.68, green: 0.32, blue: 0.87, alpha: 1.0)
    var maxTrackColor: UIColor = .white
    var thumbColor: UIColor = UIColor(red: 0.68, green: 0.32, blue: 0.87, alpha: 1.0)
    
    func makeUIView(context: Context) -> UISlider {
        let slider = UISlider()
        slider.minimumValue = Float(range.lowerBound)
        slider.maximumValue = Float(range.upperBound)
        slider.value = Float(value)
        
        let thumbImage = UIImage.createThumbImage(size: thumbSize, color: thumbColor)
        
        slider.setThumbImage(thumbImage, for: .normal)
        slider.setThumbImage(thumbImage, for: .highlighted)
        
        slider.minimumTrackTintColor = minTrackColor
        slider.maximumTrackTintColor = maxTrackColor
        
        slider.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged), for: .valueChanged)
        slider.addTarget(context.coordinator, action: #selector(Coordinator.editingDidBegin), for: .touchDown)
        slider.addTarget(context.coordinator, action: #selector(Coordinator.editingDidEnd), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return slider
    }
    
    func updateUIView(_ uiView: UISlider, context: Context) {
        uiView.setValue(Float(value), animated: false)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: PlaySlider
        
        init(_ parent: PlaySlider) {
            self.parent = parent
        }
        
        @objc func valueChanged(_ sender: UISlider) {
            parent.value = Double(sender.value)
        }
        
        @objc func editingDidBegin(_ sender: UISlider) {
            parent.onEditingChanged(true)
        }
        
        @objc func editingDidEnd(_ sender: UISlider) {
            parent.onEditingChanged(false)
        }
    }
}

extension UIImage {
    static func createThumbImage(size: CGSize, color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size))
            color.setFill()
            path.fill()
        }
    }
}

struct SumView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SumView(id: "w24t5f8jnWvNPL5auDO2", type: "url")
        }
    }
}

