import requests
import zipfile
import os
import shutil


#Check if cache dir exist or create it
if not os.path.isdir("cache"):
    print("Couldn't find cache folder, creating it")
    os.mkdir("cache")

arch = "32" #Could be 32

#If windows+arch folder doesn't exist
if not os.path.isdir("cache/love" + arch):
    #Download zip file
    print("Couldn't find LÖVE for Windows " + arch + "bits, downloading it")
    url = "https://bitbucket.org/rude/love/downloads/love-0.10.2-win" + arch + ".exe"
    r = requests.get(url, stream=True)
    r.raw.decode_content = True
    with open("cache/love-0.10.2.zip", "wb") as f:
        shutil.copyfileobj(r.raw, f)

    #Create extract folder
    os.mkdir("cache/love" + arch)
    #Unpack with 7z because ZipFile errors with LÖVE's zip files
    print("Extracting LÖVE")
    os.system('7z e cache/love-0.10.2.zip -ocache/love' + arch + ' *')

    #Remove zip file
    os.remove("cache/love-0.10.2.zip")

#Make the release folder
print("Creating release directory")
if not os.path.isdir("release"):
    os.mkdir("release")
#We need it clean
release = "release/windows" + arch + "/"
if os.path.isdir(release):
    shutil.rmtree(release)

os.mkdir(release)
#Copy necessary dlls and LICENSE file over to release
copy_dlls = [
    "love.dll",
    "lua51.dll",
    "OpenAL" + ("32" if arch is "32" else "") + ".dll",
    "SDL2.dll",
    "mpg123.dll",
    "msvcp120.dll",
    "msvcr120.dll"
]
copy_extras = [
    "LICENSE.md"
]

love_path = "cache/love" + arch + "/"

print("Copying necessary dll's")
for name in copy_dlls:
    with open(release + name, "wb") as destination:
        with open(love_path + name, "rb") as dll:
            shutil.copyfileobj(dll, destination)

print("Copying other necessary files")
for name in copy_extras:
    with open(release + name, "wb") as destination:
        with open(name, "rb") as extra:
            shutil.copyfileobj(extra, destination)

#Install LuaJIT 2.0.4 and LuaRocks in cache/lua

#if not os.path.isdir("cache/lua" + arch):
#    print("Couldn't find LuaJIT and LuaRocks, downloading them")
#    os.mkdir("cache/lua" + arch)
#    os.system("hererocks cache/lua" + arch + " -j2.0.4 -rlatest --target=vs_" + arch)

#I could later then compile binary modules against these

#Ignored files and directories
ignore_directories = [
    "cache",
    "release",
    "binary",
    "tests",
    "spec",
    "docs",
    "build",
    ".git"
]

ignore_files = [
#System dependant files!
    "linux.lua",
    "macosx.lua",
    "ios.lua",
    "android.lua",
#Common files
    ".gitignore",
    ".gitattributes"
    "appveyor.yml",
    ".travis.yml",
    "README.md",
    "LICENSE.md",
    "game.love"
];

#Pack .love file
cwd = os.getcwd()
with zipfile.ZipFile("game.love", "w") as game:
    print("Creating game.love")
    for root, dirs, files in os.walk(cwd):
        relative = os.path.relpath(root, cwd)

        ignore = False
        for directory in ignore_directories:
            if relative.startswith(directory):
                ignore = True

        if ignore:
            continue

        for asset in files:
            if asset in ignore_files:
                continue
            game.write(os.path.join(relative, asset))

#Merge game.love + LÖVE.exe
print("Merging game.love with love.exe")
with open(os.path.join(release, "game.exe"), "wb") as destination:
    with open("cache/love" + arch + "/love.exe", "rb") as love:
        shutil.copyfileobj(love, destination)
    with open("game.love", "rb") as game:
        shutil.copyfileobj(game, destination)

#Download rcedit if it doesn't exist
if not os.path.exists("cache/rcedit.exe"):
    #Download rcedit.exe
    print("Couldn't find rcedit, downloading it")
    url = "https://github.com/electron/rcedit/releases/download/v0.1.0/rcedit.exe"
    r = requests.get(url, stream=True)
    r.raw.decode_content = True
    with open("cache/rcedit.exe", "wb") as f:
        shutil.copyfileobj(r.raw, f)

#Modify .exe file with rcedit


#Create complete .zip file
print("Compressing release")
with zipfile.ZipFile("game-win" + arch + ".zip", "w") as compress:
    for root, dirs, files in os.walk(release):
        relative = os.path.relpath(root, os.path.join(cwd, release))
        for asset in files:
            compress.write(os.path.join(root, asset), os.path.join(relative, asset))

print("Finished compiling")
