import Foundation
import Combine

// MARK: - Cache Manager
class CacheManager: ObservableObject {
    static let shared = CacheManager()
    
    // MARK: - Properties
    private let memoryCache = NSCache<NSString, AnyObject>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    // MARK: - Cache Keys
    enum CacheKey: String, CaseIterable {
        case quotes = "quotes_cache"
        case spells = "spells_cache"
        case feats = "feats_cache"
        case backgrounds = "backgrounds_cache"
        case classes = "classes_cache"
        case bestiary = "bestiary_cache"
        case monsters = "monsters_cache"
        case relationships = "relationships_cache"
        case notes = "notes_cache"
        case character = "character_cache"
    }
    
    // MARK: - Cache Configuration
    private let maxMemoryCacheSize = 50 * 1024 * 1024 // 50MB
    private let maxDiskCacheSize = 100 * 1024 * 1024 // 100MB
    private let cacheExpirationTime: TimeInterval = 24 * 60 * 60 // 24 hours
    
    // MARK: - Initialization
    private init() {
        // Настройка памяти кэша
        memoryCache.totalCostLimit = maxMemoryCacheSize
        
        // Создание директории кэша
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentsPath.appendingPathComponent("DNDAppCache")
        
        // Создание директории если не существует
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Очистка устаревших файлов при запуске
        cleanupExpiredCache()
    }
    
    // MARK: - Public Methods
    
    /// Сохранить данные в кэш (память + диск)
    func set<T: Codable>(_ object: T, forKey key: CacheKey) {
        // Сохранение в память
        let memoryKey = NSString(string: key.rawValue)
        memoryCache.setObject(object as AnyObject, forKey: memoryKey)
        
        // Сохранение на диск
        saveToDisk(object, forKey: key)
    }
    
    /// Получить данные из кэша
    func get<T: Codable>(_ type: T.Type, forKey key: CacheKey) -> T? {
        // Сначала проверяем память
        let memoryKey = NSString(string: key.rawValue)
        if let cachedObject = memoryCache.object(forKey: memoryKey) as? T {
            return cachedObject
        }
        
        // Если нет в памяти, загружаем с диска
        if let diskObject = loadFromDisk(type, forKey: key) {
            // Возвращаем в память для быстрого доступа
            memoryCache.setObject(diskObject as AnyObject, forKey: memoryKey)
            return diskObject
        }
        
        return nil
    }
    
    /// Проверить существование кэша
    func exists(forKey key: CacheKey) -> Bool {
        // Проверяем память
        let memoryKey = NSString(string: key.rawValue)
        if memoryCache.object(forKey: memoryKey) != nil {
            return true
        }
        
        // Проверяем диск
        let fileURL = cacheDirectory.appendingPathComponent("\(key.rawValue).json")
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    /// Удалить кэш для конкретного ключа
    func remove(forKey key: CacheKey) {
        // Удаляем из памяти
        let memoryKey = NSString(string: key.rawValue)
        memoryCache.removeObject(forKey: memoryKey)
        
        // Удаляем с диска
        let fileURL = cacheDirectory.appendingPathComponent("\(key.rawValue).json")
        try? fileManager.removeItem(at: fileURL)
    }
    
    /// Очистить весь кэш
    func clearAll() {
        // Очищаем память
        memoryCache.removeAllObjects()
        
        // Очищаем диск
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    /// Получить размер кэша
    func getCacheSize() -> (memory: Int, disk: Int) {
        let memorySize = memoryCache.totalCostLimit
        let diskSize = getDiskCacheSize()
        return (memory: memorySize, disk: diskSize)
    }
    
    // MARK: - Private Methods
    
    /// Сохранить на диск
    private func saveToDisk<T: Codable>(_ object: T, forKey key: CacheKey) {
        let fileURL = cacheDirectory.appendingPathComponent("\(key.rawValue).json")
        
        do {
            let data = try JSONEncoder().encode(object)
            try data.write(to: fileURL)
            
            // Добавляем метаданные о времени создания
            let metadata = CacheMetadata(createdAt: Date(), size: data.count)
            let metadataURL = cacheDirectory.appendingPathComponent("\(key.rawValue)_metadata.json")
            let metadataData = try JSONEncoder().encode(metadata)
            try metadataData.write(to: metadataURL)
            
        } catch {
            print("Ошибка сохранения кэша на диск: \(error)")
        }
    }
    
    /// Загрузить с диска
    private func loadFromDisk<T: Codable>(_ type: T.Type, forKey key: CacheKey) -> T? {
        let fileURL = cacheDirectory.appendingPathComponent("\(key.rawValue).json")
        
        // Проверяем существование файла
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        // Проверяем метаданные на устаревание
        if isCacheExpired(forKey: key) {
            remove(forKey: key)
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let object = try JSONDecoder().decode(type, from: data)
            return object
        } catch {
            print("Ошибка загрузки кэша с диска: \(error)")
            return nil
        }
    }
    
    /// Проверить устаревание кэша
    private func isCacheExpired(forKey key: CacheKey) -> Bool {
        let metadataURL = cacheDirectory.appendingPathComponent("\(key.rawValue)_metadata.json")
        
        guard fileManager.fileExists(atPath: metadataURL.path) else {
            return true
        }
        
        do {
            let data = try Data(contentsOf: metadataURL)
            let metadata = try JSONDecoder().decode(CacheMetadata.self, from: data)
            return Date().timeIntervalSince(metadata.createdAt) > cacheExpirationTime
        } catch {
            return true
        }
    }
    
    /// Очистить устаревший кэш
    private func cleanupExpiredCache() {
        for key in CacheKey.allCases {
            if isCacheExpired(forKey: key) {
                remove(forKey: key)
            }
        }
    }
    
    /// Получить размер кэша на диске
    private func getDiskCacheSize() -> Int {
        var totalSize = 0
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
            for url in contents {
                let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
                totalSize += resourceValues.fileSize ?? 0
            }
        } catch {
            print("Ошибка получения размера кэша: \(error)")
        }
        
        return totalSize
    }
}

// MARK: - Cache Metadata
private struct CacheMetadata: Codable {
    let createdAt: Date
    let size: Int
}

// MARK: - Cache Extensions
extension CacheManager {
    
    /// Асинхронная загрузка с кэшированием
    func loadWithCache<T: Codable>(
        _ type: T.Type,
        forKey key: CacheKey,
        loader: @escaping () async throws -> T
    ) async throws -> T {
        
        // Проверяем кэш
        if let cached = get(type, forKey: key) {
            return cached
        }
        
        // Загружаем данные
        let data = try await loader()
        
        // Сохраняем в кэш
        set(data, forKey: key)
        
        return data
    }
    
    /// Загрузка с кэшированием через Combine
    func loadWithCachePublisher<T: Codable>(
        _ type: T.Type,
        forKey key: CacheKey,
        loader: @escaping () -> AnyPublisher<T, Error>
    ) -> AnyPublisher<T, Error> {
        
        // Проверяем кэш
        if let cached = get(type, forKey: key) {
            return Just(cached)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        // Загружаем и кэшируем
        return loader()
            .handleEvents(receiveOutput: { [weak self] data in
                self?.set(data, forKey: key)
            })
            .eraseToAnyPublisher()
    }
}
