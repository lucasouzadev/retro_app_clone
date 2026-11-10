import SwiftUI

// Light appearance for this catalog. Values mirror tokens.json.
enum DiaryPalette {
    static let bg = rgb(0xF8F6F1)
    static let surface = rgb(0xFFFFFF)
    static let border = rgb(0xDEDBD3)
    static let borderInput = rgb(0x77736B)
    static let text = rgb(0x252421)
    static let textMuted = rgb(0x59564F)
    static let accent = rgb(0x393832)
    static let onAccent = rgb(0xFFFFFF)
    static let danger = rgb(0x9B312C)
    static let success = rgb(0x29603F)
    static let warning = rgb(0x744911)

    private static func rgb(_ value: UInt32) -> Color {
        Color(red: Double((value >> 16) & 255) / 255,
              green: Double((value >> 8) & 255) / 255,
              blue: Double(value & 255) / 255)
    }
}

enum DiaryLayout {
    static let gutter: CGFloat = 16
    static let cardSpacing: CGFloat = 12
    static let cardRadius: CGFloat = 20
    static let sectionSpacing: CGFloat = 24
    static let maxContent: CGFloat = 520
    static let minimumTarget: CGFloat = 44
}

struct DiaryCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: DiaryLayout.cardSpacing, content: content)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DiaryLayout.gutter)
            .background(DiaryPalette.surface, in: RoundedRectangle(cornerRadius: DiaryLayout.cardRadius))
            .overlay {
                RoundedRectangle(cornerRadius: DiaryLayout.cardRadius)
                    .strokeBorder(DiaryPalette.border)
                    .allowsHitTesting(false)
            }
    }
}

struct DiaryAction: View {
    let title: String
    var primary = true
    var isBusy = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if isBusy {
                    ProgressView().tint(primary ? DiaryPalette.onAccent : DiaryPalette.text)
                        .accessibilityHidden(true)
                }
                Text(title).font(.body.weight(.semibold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 44)
            .foregroundStyle(primary ? DiaryPalette.onAccent : DiaryPalette.text)
            .background(primary ? DiaryPalette.accent : DiaryPalette.surface,
                        in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                if !primary {
                    RoundedRectangle(cornerRadius: 12).strokeBorder(DiaryPalette.borderInput)
                }
            }
        }
        .disabled(isBusy)
        .accessibilityValue(isBusy ? "Em andamento" : "")
    }
}

struct DiaryField: View {
    let title: String
    @Binding var text: String
    var error: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.subheadline.weight(.semibold)).accessibilityHidden(true)
            TextField(title, text: $text)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .frame(minHeight: 44)
                .background(DiaryPalette.surface, in: RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(error == nil ? DiaryPalette.borderInput : DiaryPalette.danger)
                }
                .accessibilityLabel(title)
            if let error {
                Label(error, systemImage: "exclamationmark.circle")
                    .font(.footnote)
                    .foregroundStyle(DiaryPalette.danger)
            }
        }
    }
}

struct DiaryAvatar: View {
    let initials: String

    var body: some View {
        Text(initials)
            .font(.subheadline.weight(.semibold))
            .padding(8)
            .frame(minWidth: 44, minHeight: 44)
            .background(DiaryPalette.surface, in: Circle())
            .accessibilityHidden(true)
    }
}

struct DiaryWeekHeading: View {
    let title: String
    let range: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.title2.bold()).accessibilityAddTraits(.isHeader)
            Text(range).font(.subheadline).foregroundStyle(DiaryPalette.textMuted)
        }
    }
}

struct DiaryMediaTile<Content: View>: View {
    let label: String
    let selected: Bool
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        Button(action: action) {
            content()
                .frame(minWidth: 44, minHeight: 44)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(alignment: .topTrailing) {
                    if selected {
                        Image(systemName: "checkmark")
                            .padding(8)
                            .foregroundStyle(DiaryPalette.onAccent)
                            .background(DiaryPalette.accent, in: Circle())
                            .padding(8)
                    }
                }
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct DiaryFeedback: View {
    let title: String
    let detail: String
    var isError = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.headline)
                .foregroundStyle(isError ? DiaryPalette.danger : DiaryPalette.text)
                .accessibilityAddTraits(.isHeader)
            Text(detail).font(.subheadline).foregroundStyle(DiaryPalette.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(DiaryPalette.surface, in: RoundedRectangle(cornerRadius: 20))
    }
}

struct DiaryCatalog: View {
    @State private var handle = ""
    @State private var selected = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DiaryWeekHeading(title: "Esta semana", range: "9 a 15 de novembro")
                HStack {
                    DiaryAvatar(initials: "LM")
                    Text("Lia Martins")
                }
                DiaryField(title: "Seu identificador", text: $handle,
                           error: handle.contains(" ") ? "Remova os espaços." : nil)
                DiaryMediaTile(label: "Foto de exemplo", selected: selected) {
                    selected.toggle()
                } content: {
                    Image(systemName: "photo")
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .background(DiaryPalette.surface)
                }
                DiaryAction(title: "Adicionar lembrança") { selected = true }
                DiaryAction(title: "Publicando", primary: false, isBusy: true) {}
                DiaryFeedback(title: "Uma semana em branco",
                              detail: "Escolha uma foto para guardar aqui.")
                DiaryFeedback(title: "Envio interrompido",
                              detail: "Sua seleção ainda está aqui.", isError: true)
            }
            .foregroundStyle(DiaryPalette.text)
            .padding(16)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .background(DiaryPalette.bg.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

struct DiaryCatalog_Previews: PreviewProvider {
    static var previews: some View {
        DiaryCatalog()
    }
}
