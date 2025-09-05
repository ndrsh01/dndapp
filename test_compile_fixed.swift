// Test with fixed syntax
struct TestMonster {
    let name: String?
    let type: String?
    let alignment: String?
}

func testSearch(monsters: [TestMonster], query: String) -> [TestMonster] {
    return monsters.filter { monster in
        (monster.name?.localizedLowercase.contains(query.localizedLowercase) ?? false) ||
        (monster.type?.localizedLowercase.contains(query.localizedLowercase) ?? false) ||
        (monster.alignment?.localizedLowercase.contains(query.localizedLowercase) ?? false)
    }
}

print("Fixed syntax check passed")
