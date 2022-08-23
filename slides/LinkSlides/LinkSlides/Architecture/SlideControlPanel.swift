import SwiftUI

private let timeDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .medium
    formatter.dateFormat = .none
    return formatter
}()

struct SlideControlPanel: View {

    @EnvironmentObject var presentation: PresentationProperties
    @Environment(\.openWindow) private var openWindow
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var now: Date = Date()
    @State var stateTime: Date?
    
    @State var focusManualEntry: String = ""
    
    @State var screenXManualEntry: String = ""
    @State var screenYManualEntry: String = ""
    
    @State var slideXManualEntry: String = ""
    @State var slideYManualEntry: String = ""

    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    dateCounter
                    Spacer()
                    timeCounter
                    runButton
                }
                Spacer()
                    .frame(maxHeight: .infinity)
                Text("Ovládání prezentace").bold().frame(maxWidth: .infinity, alignment: .leading)
                presentationControl
            }
            Divider()
            VStack(spacing: 16) {
                Text("Poznámky pro zaostřené").bold().frame(maxWidth: .infinity, alignment: .leading)
                if let hint = presentation.hint {
                    ScrollView { Text(LocalizedStringKey(hint)) }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                } else {
                    Spacer()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }.padding()
    }

    private var runButton: some View {
        Button {
            stateTime = Date()
            openWindow(id: "slides")
        } label: {
            Image(systemName: "play.circle.fill")
                .resizable()
                .foregroundStyle(.primary, .secondary, .green)
                .frame(width: 50, height: 50)
        }
        .buttonStyle(.plain)
        .frame(width: 50, height: 50)
    }
    
    private var dateCounter: some View {
        Text(timeDateFormatter.string(from: now)).onReceive(timer) { _ in
            now = Date()
        }.font(.largeTitle)
    }
    
    @ViewBuilder private var timeCounter: some View {
        if let stateTime {
            Text(
                timeDateFormatter.string(
                    from: Date(timeIntervalSince1970: -stateTime.timeIntervalSinceNow - 3600)
                )
            ).font(.largeTitle)
        } else {
            Text("00:00:00").font(.largeTitle)
        }
    }
    
    @ViewBuilder private var presentationControl: some View {
        VStack {
            Grid {
                GridRow {
                    Text("Zaměřený slide:")
                    Button("Předchozí") {
                        presentation.selectedFocus -= 1
                    }.keyboardShortcut("n")
                    Button("Následující") {
                        presentation.selectedFocus += 1
                    }.keyboardShortcut("m")
                    HStack {
                        TextField("Manuální", text: $focusManualEntry)
                            .onChange(of: presentation.selectedFocus) { focusManualEntry = String($0) }
                        Button("Přejít") {
                            Int(focusManualEntry).flatMap { presentation.selectedFocus = $0 }
                        }
                    }
                }
                GridRow {
                    Text("Pozice kamery")
                    Grid {
                        GridRow {
                            Text("Scale: \(presentation.scale)")
                            Slider(value: $presentation.scale, in: ClosedRange<CGFloat>(0.1...2))
                        }
                        GridRow {
                            Text("X \(presentation.offset.dx)")
                            Slider(value: $presentation.offset.dx, in: ClosedRange<CGFloat>(-3...3))
                        }
                        GridRow {
                            Text("Y \(presentation.offset.dy)")
                            Slider(value: $presentation.offset.dy, in: ClosedRange<CGFloat>(-3...3))
                        }
                    }.gridCellColumns(3)
                }
                GridRow {
                    Text("Velikost obrazovky")
                    Toggle(isOn: $presentation.automaticScreenSize, label: { Text("Automaticky") })
                    TextField("X", text: $screenXManualEntry)
                        .disabled(presentation.automaticScreenSize)
                        .onChange(of: presentation.screenSize) { screenXManualEntry = "\($0.width)" }
                    TextField("Y", text: $screenYManualEntry)
                        .disabled(presentation.automaticScreenSize)
                        .onChange(of: presentation.screenSize) { screenYManualEntry = "\($0.height)" }
                    Button("Použít") {
                        if let w = Double(screenXManualEntry), let h = Double(screenYManualEntry) {
                            presentation.screenSize = CGSize(width: CGFloat(w), height: CGFloat(h))
                        }
                    }
                }
                GridRow {
                    Text("Velikost slidu")
                    Toggle(isOn: $presentation.automaticFameSize, label: { Text("Automaticky") })
                    TextField("X", text: $slideXManualEntry)
                        .disabled(presentation.automaticFameSize)
                        .onChange(of: presentation.frameSize) { slideXManualEntry = "\($0.width)" }
                    TextField("Y", text: $slideYManualEntry)
                        .disabled(presentation.automaticFameSize)
                        .onChange(of: presentation.frameSize) { slideYManualEntry = "\($0.height)" }
                    Button("Použít") {
                        if let w = Double(slideXManualEntry), let h = Double(slideYManualEntry) {
                            presentation.frameSize = CGSize(width: CGFloat(w), height: CGFloat(h))
                        }
                    }
                }
                GridRow {
                    Text("Barevné schéma")
                    Spacer()
                    Spacer()
                    Picker(
                        "",
                        selection: .init(
                            get: {
                                presentation.colorScheme == .dark ? 0 : 1
                            },
                            set: {
                                presentation.colorScheme = $0 == 0 ? .dark : .light
                            }
                        )
                    ) {
                        Text("Dark").tag(0)
                        Text("Light").tag(1)
                    }
                    .pickerStyle(.segmented)
                }
                GridRow {
                    Text("Fonty")
                    Grid(alignment: .trailing) {
                        GridRow {
                            FontPicker("Titulek", selection: $presentation.title)
                            FontPicker("Napis", selection: $presentation.headline)
                            FontPicker("Tělo", selection: $presentation.body)
                        }
                        GridRow {
                            FontPicker("Podtitulek", selection: $presentation.subTitle)
                            FontPicker("Podnadpis", selection: $presentation.subHeadline)
                            FontPicker("Poznámka", selection: $presentation.note)
                        }
                    }.gridCellColumns(4)
                }
            }
        }
    }
}

struct SlideControlPanel_Previews: PreviewProvider {
    static var previews: some View {
        SlideControlPanel()
    }
}
