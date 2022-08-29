import SwiftUI

private let timeDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .medium
    formatter.dateFormat = .none
    return formatter
}()

private struct HashedInt: Hashable {
    var int: Int
    let hash: Int
}

@available(macOS 13.0, *)
struct SlideControlPanel: View {

    @EnvironmentObject var presentation: PresentationProperties
    @Environment(\.openWindow) private var openWindow

    @State var focusManualEntry: String = ""
    
    @State var screenXManualEntry: String = ""
    @State var screenYManualEntry: String = ""
    
    @State var slideXManualEntry: String = ""
    @State var slideYManualEntry: String = ""
    
    @State var selectedFocusHash: Int?
    @State var focusesChangeContext: [[String]]
    @State var hintEditing: [String?]
    
    init(environment: PresentationProperties) {
        _focusesChangeContext = State(initialValue: SlideControlPanel.makeFocusesChangeContext(with: environment.focuses))
        if environment.selectedFocus >= 0, environment.selectedFocus < environment.focuses.count {
            _selectedFocusHash = State(initialValue: environment.focuses[environment.selectedFocus].hashValue)
            switch environment.focuses[environment.selectedFocus] {
            case let .slides(slides):
                _hintEditing = State(initialValue: slides.map { $0.hint })
            case let .properties(properties):
                _hintEditing = State(initialValue: [properties.hint] )
            }
        } else {
            _selectedFocusHash = State(initialValue: nil)
            _hintEditing = State(initialValue: [])
        }
        
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 16) {
                runButton
                if presentation.mode != .editor {
                    Spacer()
                        .frame(maxHeight: .infinity)
                }
                Text("Klávesové zkratky").bold().frame(maxWidth: .infinity, alignment: .leading)
                Text(presentation.mode.hotkeyHint.joined(separator: "\n"))
                Text("Ovládání prezentace").bold().frame(maxWidth: .infinity, alignment: .leading)
                presentationControl
            }
            Divider()
            VStack(spacing: 16) {
                Text("Poznámky pro zaostřené").bold().frame(maxWidth: .infinity, alignment: .leading)
                hintView
                    .onChange(of: presentation.selectedFocus, perform: prepareHintEditor(for:))
                    .onChange(of: presentation.focuses) { newValue in
                        prepareHintEditor(for: presentation.selectedFocus, focuses: newValue)
                    }
                    .onChange(of: presentation.mode) { _ in
                        prepareHintEditor(for: presentation.selectedFocus)
                    }
            }
        }.padding()
    }
    
    private var runButton: some View {
        Button {
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

    @ViewBuilder private var presentationControl: some View {
        VStack {
            Grid {
                GridRow {
                    Text("Režim")
                    Picker(
                        "",
                        selection: .init(
                            get: {
                                presentation.mode.rawValue
                            },
                            set: {
                                presentation.mode = .init(rawValue: $0)!
                            }
                        )
                    ) {
                        Text("Inspekce").tag(0)
                        Text("Prezentace").tag(1)
                        Text("Editor").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .gridCellColumns(2)
                    Button("Reload placeholders") {
                        presentation.loadThumbnails.toggle()
                    }
                }
                if presentation.mode == .entry {
                    controlPanel
                }
                if presentation.mode == .editor {
                    editorCommands
                }
            }
        }
    }
    
    @ViewBuilder var controlPanel: some View {
        GridRow {
            Text("Zaměřený slide:")
            Button("Předchozí") {
                presentation.selectedFocus -= 1
            }
            Button("Následující") {
                presentation.selectedFocus += 1
            }
            HStack {
                TextField("Manuální", text: $focusManualEntry)
                Button("Přejít") {
                    Int(focusManualEntry).flatMap { presentation.selectedFocus = $0 }
                }
            }
        }
        GridRow {
            Text("Pozice kamery")
            Grid {
                GridRow {
                    Text("Scale: \(presentation.camera.scale)")
                    Slider(value: $presentation.camera.scale, in: ClosedRange<CGFloat>(0.1...2))
                }
                GridRow {
                    Text("X")
                    Text("\(presentation.camera.offset.dx)")
                }
                GridRow {
                    Text("Y")
                    Text("\(presentation.camera.offset.dy)")
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
        }
        GridRow {
            Spacer()
            Spacer()
            Spacer()
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
        }
        GridRow {
            Spacer()
            Spacer()
            Spacer()
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
                GridRow {
                    Slider(
                        value: $presentation.codeEditorFontSize,
                        in: CGFloat(15.0)...CGFloat(40.0),
                        step: 1.0,
                        label: { Text("Editor font \(presentation.codeEditorFontSize)") }
                    ).gridCellColumns(2)
                }
            }.gridCellColumns(3)
        }
    }
    
    @ViewBuilder var editorCommands: some View {
        GridRow {
            Text("Pohyby")
            Toggle(isOn: $presentation.moveCamera, label: { Text("Zaostřit na vybraný snímek") })
            Toggle(isOn: $presentation.allowHotkeys, label: { Text("Povolit zkratky") })
        }
        GridRow {
            Text("Code generation")
            Button("Save offsets") {
                let editor = OffsetCodeManipulator(slidesPath: presentation.slidesPath, knowSlides: presentation.slides)
                print(editor.saveUpdatesToSourceCode())
            }
            Button("Save focuses & Hints") {
                let editor = FocusCodeManipulator(rootPath: presentation.rootPath, knowSlides: presentation.slides, knownFocuses: presentation.focuses)
                print(editor.saveUpdatesToSourceCode())
            }
        }
        GridRow {
            focusEditor
                .gridCellColumns(4)
                .frame(idealHeight: .infinity, maxHeight: .infinity)
        }
        GridRow {
            HStack {
                Button("Přidej focus na slidy") {
                    focusesChangeContext.append([])
                    presentation.focuses.append(.slides([]))
                }
                Button("Přidej focus na souřadnice") {
                    let properties = Focus.Properties(offset: presentation.camera.offset, scale: presentation.camera.scale)
                    focusesChangeContext.append(["\(properties.offset.dx)", "\(properties.offset.dy)", "\(properties.scale)"])
                    presentation.focuses.append(.properties(properties))
                }
            }.gridCellColumns(4)
        }
    }
    
    @ViewBuilder var focusEditor: some View {
        List(
            selection: .init(
                get: {
                    selectedFocusHash
                },
                set: { newHash in
                    guard let index = presentation.focuses.firstIndex(where: { $0.hashValue == newHash }) else {
                        selectedFocusHash = nil
                        return
                    }
                    selectedFocusHash = newHash
                    presentation.selectedFocus = index
                    prepareHintEditor(for: index)
                }
            )
        ) {
            ForEach(presentation.focuses, id: \.hashValue) { focus in
                let index = presentation.focuses.firstIndex(of: focus)!
                HStack() {
                    switch focus {
                    case .slides(_):
                        slidesTokenView(at: index)
                    case let .properties(properties):
                        Button("Ulož") {
                            var copy = properties
                            let dx = Double(focusesChangeContext[index][0]).flatMap(CGFloat.init(_:))
                            let dy = Double(focusesChangeContext[index][1]).flatMap(CGFloat.init(_:))
                            let scale = Double(focusesChangeContext[index][2]).flatMap(CGFloat.init(_:))
                            copy.offset.dx = dx ?? copy.offset.dx
                            copy.offset.dy = dy ?? copy.offset.dy
                            copy.scale = scale ?? copy.scale
                            presentation.focuses[index] = .properties(copy)
                        }
                        Divider()
                        Text("X")
                        TextEditor(text: .init(get: { focusesChangeContext[index][0] }, set: { focusesChangeContext[index][0] = $0 }))
                        Text("Y")
                        TextEditor(text: .init(get: { focusesChangeContext[index][1] }, set: { focusesChangeContext[index][1] = $0 }))
                        Text("Scale")
                        TextEditor(text: .init(get: { focusesChangeContext[index][2] }, set: { focusesChangeContext[index][2] = $0 }))
                    }
                }
            }.onMove { source, destination in
                presentation.focuses.move(fromOffsets: source, toOffset: destination)
                focusesChangeContext = SlideControlPanel.makeFocusesChangeContext(with: presentation.focuses)
                prepareHintEditor(for: presentation.selectedFocus )
            }.onDelete { toDelete in
                presentation.focuses.remove(atOffsets: toDelete)
                focusesChangeContext = SlideControlPanel.makeFocusesChangeContext(with: presentation.focuses)
                prepareHintEditor(for: presentation.selectedFocus )
            }
        }
        .onChange(of: presentation.focuses) { newValue in
            focusesChangeContext = SlideControlPanel.makeFocusesChangeContext(with: newValue)
            prepareHintEditor(for: presentation.selectedFocus )
        }
    }
    
    static func makeFocusesChangeContext(with value: [Focus]) -> [[String]] {
        return value.map { item -> [String] in
            switch item {
            case let .properties(properties):
                return ["\(properties.offset.dx)", "\(properties.offset.dy)", "\(properties.scale)"]
            case let .slides(slides):
                return slides.map { $0.name }
            }
        }
    }
    
    @ViewBuilder func slidesTokenView(at index: Int) -> some View {
        Button("Ulož") {
            let types: [any Slide.Type] = focusesChangeContext[index].compactMap { name in
                presentation.slides.first { $0.name == name }
            }
            
            presentation.focuses[index] = .slides(types)
        }
        Divider()
        ForEach(focusesChangeContext[index], id: \.self) { slideName in
            let slideIndex = focusesChangeContext[index].firstIndex(of: slideName)!
            Button {
                focusesChangeContext[index].remove(at: slideIndex)
            }
            label: {
                HStack {
                    Text(slideName)
                    Image(systemName: "trash")
                }
            }
        }
        Divider()
        Menu("Přidej") {
            ForEach(presentation.slides.indices) { slideIndex in
                let name = presentation.slides[slideIndex].name
                Button(name) {
                    if !focusesChangeContext[index].contains(where: { $0 == name }) {
                        focusesChangeContext[index].append(name)
                    }
                }
            }
        }.frame(width: 100)
    }

    @ViewBuilder private var hintView: some View {
        if presentation.selectedFocus >= 0, presentation.selectedFocus < presentation.focuses.count {
            switch presentation.focuses[presentation.selectedFocus] {
            case let .properties(properties) where presentation.mode == .editor:
                VStack {
                    Button("Ulož") {
                        var copy = properties
                        copy.hint = hintEditing[0]
                        presentation.focuses[presentation.selectedFocus] = .properties(copy)
                    }
                    TextEditor(text: .init(
                        get: { hintEditing[0] ?? "" },
                        set: { hintEditing[0] = $0 })
                    )
                }
            case let .properties(properties):
                ScrollView { Text(LocalizedStringKey(properties.hint ?? "")) }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            case let .slides(slides) where presentation.mode == .editor:
                ScrollView {
                    VStack {
                        let hash = presentation.focuses[presentation.selectedFocus].hashValue
                        let hashedInts = slides.indices.map { HashedInt(int: $0, hash: hash) }
                        ForEach(hashedInts, id: \.int) { index in
                            HStack {
                                Button("Ulož") {
                                    slides[index.int].hint = hintEditing[index.int]
                                }
                                Text("\(slides[index.int].name)")
                            }
                            TextEditor(text: .init(
                                get: { hintEditing[index.int] ?? "" },
                                set: { hintEditing[index.int] = $0 })
                            )
                        }
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            case let .slides(slides):
                let text = slides.compactMap { slide in slide.hint.flatMap { "**\(slide.name)**\n\($0)" } }.joined(separator: "\n\n--\n\n")
                ScrollView { Text(LocalizedStringKey(text)) }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        } else {
            Spacer()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func prepareHintEditor(for index: Int) { prepareHintEditor(for: index, focuses: nil)}
    private func prepareHintEditor(for index: Int, focuses: [Focus]?){
        let focuses = focuses ?? presentation.focuses
        if presentation.mode == .editor, index >= 0, index < focuses.count {
            switch focuses[index] {
            case let .slides(slides):
                hintEditing = slides.map { $0.hint }
            case let .properties(properties):
                hintEditing = [properties.hint]
            }
        }
    }
}

