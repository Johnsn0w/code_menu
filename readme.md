# dev setup

so you can actully debug the single-lettered files, but retain their short name for short url, hardlink the files with ps1 extensions so IDE will actually parse them
    `New-Item -ItemType HardLink -Path ".W.ps1" -Target "W"`
    `New-Item -ItemType HardLink -Path ".L.sh"  -Target "L"`


Then you can add the origional files to the files.exclude setting, to avoid problems