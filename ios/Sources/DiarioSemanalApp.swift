import PhotosUI
import SwiftUI
import UIKit

@main
struct DiarioSemanalApp: App {
    var body: some Scene {
        WindowGroup {
            DiaryHome().preferredColorScheme(.light)
        }
    }
}

struct DiaryHome: View {
    @State private var diary = DiaryState()
    @State private var viewer: Person?
    @State private var handle = ""
    @State private var name = ""
    @State private var search = ""
    @State private var error: String?
    @State private var draftWeek: Date?
    @State private var openMemory: Memory?
    @State private var tab = 0

    var body: some View {
        Group {
            if let viewer {
                TabView(selection: $tab) {
                    page("Semana " + weekNumber(for: .now)) { feed(viewer) }
                        .tabItem { Label("Novidades", systemImage: "house") }.tag(0)
                    page("Meu diário") { journal(viewer) }
                        .tabItem { Label("Diário", systemImage: "person.crop.circle") }.tag(1)
                    page("Amigos") { friends(viewer) }
                        .tabItem { Label("Amigos", systemImage: "person.2") }.tag(2)
                }
            } else {
                page("Diário semanal") { profile }
            }
        }
        #if DEBUG
        .task { prepareScreenshot() }
        #endif
        .tint(DiaryPalette.accent)
        .sheet(isPresented: Binding(
            get: { draftWeek != nil },
            set: { if !$0 { draftWeek = nil } }
        )) {
            if let draftWeek, let viewer {
                PublishPhoto(week: draftWeek) { photo in
                    guard self.viewer == viewer else { return }
                    diary.memories.append(Memory(id: UUID(), owner: viewer.id,
                                                 week: draftWeek, published: .now, photo: photo))
                    self.draftWeek = nil
                }
            }
        }
        .sheet(item: $openMemory) { memory in
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: DiaryLayout.sectionSpacing) {
                        if let viewer, diary.canRead(memory, as: viewer.id),
                           let photo = UIImage(data: memory.photo) {
                            authorHeading(memory)
                            Image(uiImage: photo).resizable().scaledToFit()
                                .accessibilityLabel("Lembrança publicada por " + personName(memory.owner))
                        } else {
                            DiaryFeedback(title: "Lembrança indisponível",
                                          detail: "Volte às novidades para ver outras semanas.")
                        }
                    }
                    .padding(DiaryLayout.gutter)
                }
                .background(DiaryPalette.bg.ignoresSafeArea())
                .navigationTitle("Lembrança")
                .toolbar {
                    Button("Fechar") { openMemory = nil }
                }
            }
        }
    }

    #if DEBUG
    private func prepareScreenshot() {
        guard let screen = UserDefaults.standard.string(forKey: "DiaryScreenshot"),
              viewer == nil, let person = diary.people.first else { return }
        let week = DiaryState.weekStart(for: .now)
        diary.request(from: "caio", to: person.id)
        if let invitation = diary.friendships.first {
            diary.accept(invitation.id, as: person.id)
        }
        diary.request(from: "noa", to: person.id)
        let fixture = URL.documentsDirectory.appendingPathComponent("screenshot-fixture.png")
        if let photo = try? Data(contentsOf: fixture) {
            diary.memories = [person.id, "caio"].map {
                Memory(id: UUID(), owner: $0, week: week, published: .now, photo: photo)
            }
        }
        viewer = person
        switch screen {
        case "journal": tab = 1
        case "friends": tab = 2
        case "publish": draftWeek = week
        case "viewer": openMemory = diary.feed(for: person.id).first
        default: break
        }
    }
    #endif

    private func page<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DiaryLayout.sectionSpacing) {
                    Text(title)
                        .font(.system(.largeTitle, design: .serif, weight: .bold))
                        .accessibilityAddTraits(.isHeader)
                    content()
                }
                    .padding(DiaryLayout.gutter)
                    .frame(maxWidth: DiaryLayout.maxContent)
                    .frame(maxWidth: .infinity)
            }
            .background(DiaryPalette.bg.ignoresSafeArea())
            .foregroundStyle(DiaryPalette.text)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewer != nil {
                    Button("Trocar perfil") {
                        viewer = nil
                        search = ""
                        tab = 0
                    }
                }
            }
        }
    }

    private var profile: some View {
        Group {
            DiaryFeedback(title: "Perfis de demonstração",
                          detail: "Troque de perfil para testar a publicação entre amigos.")
            DiaryCard {
                ForEach(diary.people) { person in
                    DiaryAction(title: "Entrar como " + person.name, primary: false) { viewer = person }
                }
            }
            DiaryCard {
                Text("Seu próprio diário").font(.headline).accessibilityAddTraits(.isHeader)
                DiaryField(title: "Seu nome", text: $name)
                DiaryField(title: "Seu identificador", text: $handle, error: error)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                DiaryAction(title: "Criar perfil local") {
                    let id = handle.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    let displayName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard id.range(of: "^[a-z0-9_]{3,24}$", options: .regularExpression) != nil,
                          !diary.people.contains(where: { $0.id == id }),
                          (1...80).contains(displayName.count) else {
                        error = "Informe um nome e um identificador único de 3 a 24 letras ASCII, números ou sublinhados."
                        return
                    }
                    let person = Person(id: id, name: displayName)
                    diary.people.append(person)
                    viewer = person
                    error = nil
                    name = ""
                    handle = ""
                }
            }
        }
    }

    @ViewBuilder
    private func feed(_ person: Person) -> some View {
        let week = DiaryState.weekStart(for: .now)
        let items = diary.feed(for: person.id)
        weekStrip(week, allowAdding: true)
        if items.isEmpty {
            DiaryFeedback(title: "A semana começa aqui",
                          detail: "As fotos dos seus amigos aparecem quando eles publicarem.")
            DiaryAction(title: "Encontrar amigos") { tab = 2 }
        }
        ForEach(items) { memory in
            DiaryCard {
                authorHeading(memory)
                tile(memory)
            }
        }
    }

    private func journal(_ person: Person) -> some View {
        let week = DiaryState.weekStart(for: .now)
        let items = diary.memories.filter { $0.owner == person.id }
        return Group {
            DiaryCard {
                DiaryWeekHeading(title: "Esta semana", range: weekLabel(week))
                weekStrip(week, allowAdding: false)
                if items.isEmpty {
                    DiaryFeedback(title: "Seu diário está em branco",
                                  detail: "Escolha uma foto para começar a guardar suas semanas.")
                }
                DiaryAction(title: "Adicionar lembrança") { draftWeek = week }
                ForEach(items.filter { $0.week == week }.reversed()) { tile($0) }
            }
            ForEach(Array(Set(items.map(\.week))).filter { $0 != week }.sorted(by: >), id: \.self) { past in
                DiaryCard {
                    DiaryWeekHeading(title: "Semana " + weekNumber(for: past), range: weekLabel(past))
                    weekStrip(past, allowAdding: false)
                    ForEach(items.filter { $0.week == past }.reversed()) { tile($0) }
                }
            }
        }
    }

    private func friends(_ person: Person) -> some View {
        let query = search.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let links = diary.friendships.filter { $0.sender == person.id || $0.recipient == person.id }
        return Group {
            DiaryField(title: "Buscar pelo identificador", text: $search)
                .textInputAutocapitalization(.never).autocorrectionDisabled()
            if let found = diary.people.first(where: { $0.id == query && $0.id != person.id }) {
                Text(found.name)
                if !links.contains(where: { $0.connects(person.id, found.id) }) {
                    DiaryAction(title: "Convidar " + found.name) {
                        diary.request(from: person.id, to: found.id)
                        search = ""
                    }
                }
            } else if !query.isEmpty {
                DiaryFeedback(title: "Perfil não encontrado",
                              detail: "Confira o identificador e tente novamente.")
            }
            if links.isEmpty {
                DiaryFeedback(title: "Seu círculo ainda está vazio",
                              detail: "Busque um identificador para enviar um convite.")
            }
            ForEach(links) { link in
                DiaryCard {
                    let received = link.recipient == person.id
                    let other = personName(received ? link.sender : link.recipient)
                    DiaryWeekHeading(title: other, range: link.accepted ? "Amizade" :
                                     received ? "Pedido recebido" : "Pedido enviado")
                    if received && !link.accepted {
                        DiaryAction(title: "Aceitar pedido de " + other) {
                            diary.accept(link.id, as: person.id)
                        }
                    }
                    DiaryAction(title: link.accepted ? "Desfazer amizade" :
                                received ? "Recusar pedido" : "Cancelar pedido", primary: false) {
                        diary.remove(link.id, as: person.id)
                    }
                }
            }
        }
    }

    private func weekStrip(_ week: Date, allowAdding: Bool) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: DiaryLayout.calendarGap) {
                if allowAdding {
                    Button {
                        draftWeek = week
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.weight(.semibold))
                            .frame(width: DiaryLayout.calendarWidth, height: DiaryLayout.calendarHeight)
                            .background(DiaryPalette.surface)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Adicionar lembrança")
                }
                ForEach(0..<7) { offset in
                    if let date = Calendar.current.date(byAdding: .day, value: offset, to: week) {
                        VStack(spacing: DiaryLayout.calendarGap) {
                            Text(date.formatted(.dateTime.month(.abbreviated)))
                                .font(.caption)
                            Text(date.formatted(.dateTime.day()))
                                .font(.title2.monospacedDigit().weight(.semibold))
                            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                                .font(.caption)
                        }
                        .frame(width: DiaryLayout.calendarWidth, height: DiaryLayout.calendarHeight)
                        .foregroundStyle(DiaryPalette.textMuted)
                        .background(DiaryPalette.bg)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(date.formatted(date: .complete, time: .omitted))
                    }
                }
            }
            .padding(DiaryLayout.calendarGap)
        }
        .background(DiaryPalette.border)
        .clipShape(RoundedRectangle(cornerRadius: DiaryLayout.cardRadius))
        .scrollIndicators(.hidden)
    }

    private func authorHeading(_ memory: Memory) -> some View {
        let name = personName(memory.owner)
        let initials = name.split(separator: " ").prefix(2).compactMap(\.first)
        return HStack(spacing: DiaryLayout.cardSpacing) {
            DiaryAvatar(initials: String(initials).uppercased())
            DiaryWeekHeading(title: name, range: weekLabel(memory.week))
        }
    }

    private func tile(_ memory: Memory) -> some View {
        DiaryMediaTile(label: "Abrir lembrança de " + personName(memory.owner), selected: false) {
            openMemory = memory
        } content: {
            if let photo = UIImage(data: memory.photo) {
                Image(uiImage: photo).resizable().scaledToFit()
            } else {
                Image(systemName: "photo").accessibilityHidden(true)
            }
        }
    }

    private func personName(_ id: String) -> String {
        diary.people.first(where: { $0.id == id })?.name ?? id
    }
}

private func weekNumber(for date: Date) -> String {
    String(Calendar(identifier: .iso8601).component(.weekOfYear, from: date))
}

private func weekLabel(_ start: Date) -> String {
    let end = Calendar.current.date(byAdding: .day, value: 6, to: start) ?? start
    return start.formatted(.dateTime.day().month().year()) + " – " +
        end.formatted(.dateTime.day().month().year())
}

private struct PublishPhoto: View {
    let week: Date
    let publish: (Data) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selection: PhotosPickerItem?
    @State private var photo: Data?
    @State private var error: String?
    @State private var loading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DiaryLayout.sectionSpacing) {
                    DiaryCard {
                        DiaryWeekHeading(title: "Guardar lembrança", range: weekLabel(week))
                        PhotosPicker(selection: $selection, matching: .images) {
                            Label("Escolher foto", systemImage: "photo.on.rectangle")
                                .frame(minHeight: DiaryLayout.minimumTarget)
                        }
                        if let photo, let image = UIImage(data: photo) {
                            Image(uiImage: image).resizable().scaledToFit()
                                .accessibilityLabel("Foto selecionada")
                        }
                    }
                    if loading { ProgressView("Preparando foto") }
                    if let error {
                        DiaryFeedback(title: "Não foi possível abrir a foto", detail: error, isError: true)
                    }
                    DiaryAction(title: "Publicar na semana") {
                        if let photo { publish(photo) }
                    }
                    .disabled(photo == nil || loading)
                }
                .padding(DiaryLayout.gutter)
            }
            .background(DiaryPalette.bg.ignoresSafeArea())
            .navigationTitle("Nova lembrança")
            .toolbar { Button("Cancelar") { dismiss() } }
        }
        .task(id: selection) {
            photo = nil
            error = nil
            guard let selection else {
                loading = false
                return
            }
            loading = true
            do {
                let bytes = try await selection.loadTransferable(type: Data.self)
                guard !Task.isCancelled else { return }
                if let bytes, bytes.count <= 20_000_000, UIImage(data: bytes) != nil {
                    photo = bytes
                } else {
                    error = "Escolha uma imagem válida de até 20 MB."
                }
            } catch {
                guard !Task.isCancelled else { return }
                self.error = "Escolha outra imagem ou tente novamente."
            }
            if !Task.isCancelled { loading = false }
        }
    }
}
