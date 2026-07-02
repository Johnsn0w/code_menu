# dev setup

so you can actully debug the single-lettered files, but retain their short name for short url, hardlink the files so IDE will actually parse them
`New-Item -ItemType HardLink -Path ".W.ps1" -Target "W"`
`New-Item -ItemType HardLink -Path ".L.sh"  -Target "L"`