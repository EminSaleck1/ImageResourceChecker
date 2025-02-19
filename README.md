# ImageResourceChecker
A Swift CLI to check if assets from a Assets.xcassets file are unused in your project.

This tool will print every resource name + file name from a `Assets.xcassets` file (or any `.xcassets` file) that are not used in your app.

## Usage 

### Installation
```
$ git clone https://github.com/EminSaleck1/ImageResourceChecker
$ cd ImageResourceChecker
```

### Arguments and options

There are 3 mandatory arguments:

- `source-file-path`: The path to your `Assets.xcassets` file where are the keys to check (including filename and its extension).
- `project-path`: The path to your project or directory in which each key will be check. Note that your `Assets.xcassets` file can be in this directory also.
And 3 options:

- `--extensions` or `--allowed-files-extensions`: You can choose to only search in files with specific extensions. For example, if you want to check only in Swift files, you can set this option to `swift` (do not add the dot). If you want to specify many extensions, write them spearated by a comma: `swift,m`.

### Run

Examples:

```
# Search in all files. And have probably 2 Assets.xcassets files.
$ swift run ImageResourceChecker "/Users/user/Projects/myproject/Assets.xcassets" "/Users/user/Projects/myproject" 2

# Search in files with .swift extensions only.
$ swift run ImageResourceChecker "/Users/user/Projects/myproject/myproject/Resources/en.lproj/Assets.xcassets" "/Users/user/Projects/myproject" 0 --extensions swift

# Search in files with .swift extensions only. Also log empty values.
$ swift run ImageResourceChecker "/Users/user/Projects/myproject/myproject/Resources/en.lproj/Assets.xcassets" "/Users/user/Projects/myproject" 0 --extensions swift 
```

### Output

Typical output log: 

```
👋 Welcome to ImageResourceChecker
This tool will check if image assets are unused in your project.
--------------------------------------------------------

Will check images from Asset Catalog...
    /Users/user/project/Assets.xcassets
in files with extension swift from directory...
    /Users/user/project/

🚀 running ...

Found 257 images to check.

🛑 Resource 'icNew' Name: 'ic_new' is unused (found 0 time).
🛑 Resource 'icPlus' Name: 'ic_plus' is unused (found 0 time).
🛑 Resource 'ic3dmodel' Name: 'ic_3dmodel' is unused (found 0 time).
🛑 Resource 'gdImage' Name: 'gd_image' is unused (found 0 time).
🛑 Resource 'purpleGrad' Name: 'purpleGrad' is unused (found 0 time).

🎉 finished!

```
