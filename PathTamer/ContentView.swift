//
//  ContentView.swift
//  PathTamer
//
//  Created by Kieran Brown on 6/4/20.
//  Copyright © 2020 Kieran Brown. All rights reserved.
//

import SwiftUI
import bez
import Shapes

struct ContentView: View {
    @State var strokeWidth: Double = 1
    @State var height: Double = 200
    @ObservedObject var parser: SVGPath = .init(path: "")
    @State var input: String = ""
    @ObservedObject var polyBezier: PolyBezier = .init(Circle().path(in: .init(x: 0, y: 0, width: 100, height: 100)))
    @State var bounds: CGSize = .init(width: 100, height: 100)
    @State var arcLenght: Double = 628.4
    
    var normalized: String {
        self.polyBezier.string
    }
    
    static var formatter: NumberFormatter {
        let f = NumberFormatter.init()
        f.allowsFloats = true
        f.maximumFractionDigits = 4
        return f
    }
    
    static var lineWidthFormatter: NumberFormatter {
        let f = NumberFormatter.init()
        f.allowsFloats = true
        f.maximumFractionDigits = 2
        return f
    }
    
    var body: some View {
        HStack {
            List {
                Section(header: Text("Size")) {
                    Text("Width").bold() + Text(": ") + Text(String(format: "%.3f" , self.bounds.width + CGFloat(strokeWidth)))
                    Text("Height").bold() + Text(": ") + Text(String(format: "%.3f" , self.bounds.height + CGFloat(strokeWidth)))
                }
                Section(header: Text("Arc Length")) {
                    Text(String(format: "%.3f", self.arcLenght))
                }
                Section(header: Text("Path Commands")) {
                    ForEach(parser.path) { (element) in
                        Text(element.description)
                    }
                }
            }.frame(maxWidth: 300)
            Divider()
            VStack {
                ZStack(alignment: .topLeading) {
                    self.polyBezier.path
                        .stroke(lineWidth: CGFloat(self.strokeWidth))
                        .offset(x: CGFloat(self.strokeWidth/2), y: CGFloat(self.strokeWidth/2))
                    Rectangle()
                        .stroke(Color.blue)
                        .frame(width: self.bounds.width + CGFloat(strokeWidth),
                               height: self.bounds.height  + CGFloat(strokeWidth))
                        .overlay(GeometryReader { proxy in
                            ZStack {
                                Arrow(arrowOffset: proxy.size.width > 100 ? 1/(2*1.414) : 0,
                                      length: proxy.size.width)
                                    .stroke(Color.purple, lineWidth: 1)
                                    .frame(width: 30)
                                    
                                    .rotationEffect(Angle(degrees: 90))
                                    .position(x: proxy.size.width/2, y: proxy.size.height + 20)
                                    .animation(.linear)
                                
                                Text("\(String(format: "%.0f", self.bounds.width + CGFloat(self.strokeWidth)))")
                                    .font(.title)
                                    .frame(width: 150)
                                    .position(x: proxy.size.width/2-5, y: 1.2*proxy.size.height + 20)
                                
                            }
                        })
                        .overlay(GeometryReader { proxy in
                            ZStack {
                                Arrow(arrowOffset: proxy.size.height > 100 ? 1/(2*1.414) : 0,
                                      length: proxy.size.height )
                                    .stroke(Color.purple, lineWidth: 1)
                                    .frame(width: 30)
                                    .animation(.linear)
                                    .position(x: proxy.size.width+20,y: proxy.size.height/2)
                                Text("\(String(format: "%.0f", self.bounds.height + CGFloat(self.strokeWidth)))")
                                    .font(.title)
                                    .frame(width: 150)
                                    .position(x: proxy.size.width + 50, y: proxy.size.height/2-5)
                            }
                        })
                }.padding()
                Divider()
                
                HStack {
                    Text("Height Scale").bold()
                    TextField("input height for scale", value: $height, formatter: ContentView.formatter, onCommit:  {
                        let normalized = normalize(path: self.polyBezier.string, size: CGFloat(self.height))
                        self.polyBezier.update(string: normalized)
                        self.bounds = calculateBoundingBox(path: normalized)
                        self.arcLenght = quickLengths(path: self.polyBezier.path).reduce(0, +)
                        
                    })
                        .fixedSize()
                    Text("Line Width").bold()
                    TextField("input height for scale", value: $strokeWidth, formatter: ContentView.lineWidthFormatter)
                        .fixedSize()
                    
                    
                    Spacer()
                }
                Divider()
                
                TextField("Paste \"d\" attribute here", text: $input, onCommit: {
                    
                    self.parser.update(path: self.input)
                    DispatchQueue.main.async {
                        self.polyBezier.elements = self.parser.path
                        let normalized = normalize(path: self.polyBezier.string, size: CGFloat(self.height))
                        self.polyBezier.update(string: normalized)
                        self.bounds = calculateBoundingBox(path: normalized)
                        self.arcLenght = quickLengths(path: self.polyBezier.path).reduce(0, +)
                    }
                    
                }).frame(maxHeight: 400, alignment: .bottomLeading).fixedSize(horizontal: false, vertical: true).padding()
                
                
                
            }
            
            
            
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
