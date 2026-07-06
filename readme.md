# vscode IDE setup

    Hardlink the files with ps1 extensions so IDE will actually parse them - so you can actully debug the single-lettered files, but retain their short name for short url, 
        `New-Item -ItemType HardLink -Path ".W.ps1" -Target "W"`
        `New-Item -ItemType HardLink -Path ".L.sh"  -Target "L"`
        
    Also windows hardlinks don't seem to stay updated properly until read from. Meaning git doesn't detect them.

    Then you can add the origional files to the files.exclude setting, to avoid problems