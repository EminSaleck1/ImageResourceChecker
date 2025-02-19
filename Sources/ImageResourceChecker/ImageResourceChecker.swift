import Foundation
import ArgumentParser

@main
struct ImageResourceChecker: ParsableCommand {
    
    // MARK: - Arguments
    @Argument(help: "Path to Assets.xcassets directory.")
    var assetCatalogPath: String
    
    @Argument(help: "Path to your project directory to check image usage.")
    var projectPath: String
    
    @Argument(help: "Number of times each image resource will be found at least.")
    var allowNbTimes: Int
    
    // MARK: - Options
    @Option(name: [.customLong("extensions"), .long],
            help: "Set extensions of files to search in (e.g., swift,swift.html). Separate with comma.",
            transform: { str in
        if str.contains(",") {
            return str.split(separator: ",").map({ String($0) })
        }
        else {
            return [str]
        }
    })
    var allowedFilesExtensions: [String] = []
    
    @Flag(help: "Add this option to print each time an image resource is found.")
    var anxiousMode: Bool = false
    
    // MARK: - Main
    func run() {
        print("👋 Welcome to ImageResourceChecker")
        print("This tool will check if image assets are unused in your project.")
        print("--------------------------------------------------------\n")
        
        print("Will check images from Asset Catalog...\n\t\(assetCatalogPath)")
        printMessageExtensions()
        
        if anxiousMode {
            print("ℹ️ Anxious mode is enabled. It will print a lot of text.\n")
        }
        
        print("🚀 running ...\n")
        
        // Check input paths
        if !FileManager.default.fileExists(atPath: assetCatalogPath) {
            print("⛔️ Asset Catalog at \(assetCatalogPath) does not exist. Could not start tool.")
            return
        }
        
        if !FileManager.default.fileExists(atPath: projectPath) {
            print("⛔️ Directory \(projectPath) does not exist. Could not start tool.")
            return
        }
        
        // Extract image names from asset catalog
        let imageNames = extractImageNames(from: assetCatalogPath)
        print("Found \(imageNames.count) images to check.\n")
        
        // Check each image
        for imageName in imageNames {
            checkUnusedImage(imageName, inFilesInDirectory: projectPath, withExtensions: allowedFilesExtensions, expectedMinimalNbTimes: allowNbTimes)
        }
        
        print("\n🎉 finished!")
    }
    
    // MARK: - Asset Catalog Processing
    private func extractImageNames(from catalogPath: String) -> Set<String> {
        var imageNames: Set<String> = []
        
        guard let enumerator = FileManager.default.enumerator(
            at: URL(fileURLWithPath: catalogPath),
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }
        
        for case let fileURL as URL in enumerator {
            if fileURL.pathExtension == "imageset" {
                let imageName = fileURL.deletingPathExtension().lastPathComponent
                imageNames.insert(imageName)
                
                if anxiousMode {
                    print("📝 Found image asset: \(imageName)")
                }
            }
        }
        
        return imageNames
    }
    
    // MARK: - Image Usage Check
    private func checkUnusedImage(_ imageName: String, inFilesInDirectory directory: String, withExtensions: [String], expectedMinimalNbTimes: Int) {
        var nbFound = 0
        
        let resourceName = formatToImageResourceName(imageName)
        
        foreachFile(inDirectory: directory, withExtensions: allowedFilesExtensions, recursive: true) { filePath in
            guard let fileContents = try? String(contentsOfFile: filePath) else { return }
            
            if fileContents.contains(".\(resourceName)") {
                nbFound += 1
                if anxiousMode {
                    print("📍 Found '\(resourceName)' in \(filePath)")
                }
            }
        }
        
        if nbFound <= expectedMinimalNbTimes {
            print("🛑 Resource '\(resourceName)' Name: '\(imageName)' is unused (found \(nbFound) \(nbFound > 1 ? "times" : "time")).")
        } else if anxiousMode {
            print("✅ Resource '\(resourceName)' is used \(nbFound) \(nbFound > 1 ? "times" : "time")).")
        }
    }
    
    private func formatToImageResourceName(_ imageName: String) -> String {
        let parts = imageName.split { $0 == "_" || $0 == " " || $0 == "-" || $0 == "." }
        
        let allParts = parts.flatMap { part -> [String] in
            let str = String(part)
            if str.contains(where: { $0.isUppercase }) {
                var word = ""
                var result: [String] = []
                
                for char in str {
                    if char.isUppercase && !word.isEmpty {
                        result.append(word)
                        word = String(char)
                    } else {
                        word.append(char)
                    }
                }
                if !word.isEmpty {
                    result.append(word)
                }
                return result
            }
            return [str]
        }
        
        guard !allParts.isEmpty else { return imageName }
        
        let first = allParts[0].lowercased()
        let rest = allParts.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
        let combined = ([first] + rest).joined()
        
        if let firstChar = combined.first, firstChar.isNumber {
            return "_" + combined
        }
        
        return combined
    }
    // MARK: - Helpers
    
    private func foreachFile(inDirectory directory: String, withExtensions allowedExtensions: [String], recursive: Bool = false, apply: (String) -> Void) {
        let fileManager = FileManager.default
        
        guard let directoryContent = try? fileManager.contentsOfDirectory(atPath: directory) else {
            fatalError("Could not open directory \(directory).")
        }
        
        for item in directoryContent {
            let itemURL = URL(fileURLWithPath: directory).appendingPathComponent(item)
            if isDirectory(itemURL) {
                if recursive {
                    foreachFile(inDirectory: itemURL.path, withExtensions: allowedExtensions, recursive: recursive, apply: apply)
                }
            } else {
                if allowedExtensions.isEmpty || allowedExtensions.contains(itemURL.pathExtension.lowercased()) {
                    apply(itemURL.path)
                }
            }
        }
    }
    
    private func isDirectory(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
    
    private func printMessageExtensions() {
        var str = "in"
        
        if allowedFilesExtensions.isEmpty {
            str += " all files"
        } else if allowedFilesExtensions.count == 1 {
            str += " files with extension \(allowedFilesExtensions.first!)"
        } else if allowedFilesExtensions.count > 1 {
            str += " files with extensions \(allowedFilesExtensions.joined(separator: ", "))"
        }
        
        str += " from directory...\n\t\(projectPath)\n"
        print(str)
    }
}

// MARK: - String Extensions
extension String {
    func camelCased() -> String {
        let parts = self.split(separator: "_")
        let first = String(parts.first ?? "").lowercased()
        let rest = parts.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
        return ([first] + rest).joined()
    }
}
