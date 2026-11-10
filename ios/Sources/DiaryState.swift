import Foundation

struct Person: Codable, Identifiable, Hashable {
    let id: String
    let name: String
}

struct Friendship: Codable, Identifiable {
    let id: UUID
    let sender: String
    let recipient: String
    var accepted: Bool

    func connects(_ first: String, _ second: String) -> Bool {
        (sender == first && recipient == second) || (sender == second && recipient == first)
    }
}

struct Memory: Codable, Identifiable {
    let id: UUID
    let owner: String
    let week: Date
    let published: Date
    let photo: Data
}

struct DiaryState: Codable {
    var people = [
        Person(id: "lia", name: "Lia Martins"),
        Person(id: "caio", name: "Caio Lima"),
        Person(id: "noa", name: "Noa Ribeiro")
    ]
    var friendships: [Friendship] = []
    var memories: [Memory] = []

    func canRead(_ memory: Memory, as viewer: String) -> Bool {
        memory.owner == viewer || friendships.contains {
            $0.accepted && $0.connects(memory.owner, viewer)
        }
    }

    mutating func request(from sender: String, to recipient: String) {
        guard sender != recipient,
              people.contains(where: { $0.id == sender }),
              people.contains(where: { $0.id == recipient }),
              !friendships.contains(where: { $0.connects(sender, recipient) }) else { return }
        friendships.append(Friendship(id: UUID(), sender: sender, recipient: recipient, accepted: false))
    }

    mutating func accept(_ id: UUID, as viewer: String) {
        guard let index = friendships.firstIndex(where: {
            $0.id == id && $0.recipient == viewer && !$0.accepted
        }) else { return }
        friendships[index].accepted = true
    }

    mutating func remove(_ id: UUID, as viewer: String) {
        friendships.removeAll { $0.id == id && ($0.sender == viewer || $0.recipient == viewer) }
    }

    func feed(for viewer: String) -> [Memory] {
        memories.filter { $0.owner != viewer && canRead($0, as: viewer) }
            .sorted { $0.published > $1.published }
    }

    static func weekStart(for date: Date) -> Date {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        return calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? calendar.startOfDay(for: date)
    }
}
