// Test syntax check
struct TestMonster {
    let url: String?
}

func testURL(monster: TestMonster) {
    if let url = monster.url, !url.isEmpty {
        if let urlObject = URL(string: url) {
            print("URL is valid")
        }
    }
}

print("Syntax check completed")
