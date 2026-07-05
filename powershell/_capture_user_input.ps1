. "${PSScriptRoot}\_global_source.ps1"
$K = @{
    BACKSPACE     = [int][ConsoleKey]::Backspace;
    MODIFIER_KEYS = [int][ConsoleModifiers]::Alt, [ConsoleModifiers]::Control, [ConsoleModifiers]::Shift;
    ESC           = [int][ConsoleKey]::Escape;
    ENTER         = [int][ConsoleKey]::Enter;
    UP            = [int][ConsoleKey]::UpArrow;
    DOWN          = [int][ConsoleKey]::DownArrow;
    UP_DOWN       = [int][ConsoleKey]::UpArrow, [ConsoleKey]::DownArrow;
    TILDE         = 192;
    CTRL          = 17;
}

function GetUserInput() {
    $host.UI.RawUI.ReadKey("IncludeKeyDown, NoEcho")
}

function HandleUserInput {
    param([KeyInfo]$UserInput) 
    if (-not $UserInput) { throw 'sam: missing required param $UserInput' }
    switch ($UserInput.VirtualKeyCode) {
        $K.BACKSPACE {
            #backspace
            Log("trace")
            if ($CurrentUserInput[0]) { 
                $CurrentUserInput[0] = $CurrentUserInput[0].Substring(0, $CurrentUserInput[0].Length - 1)
            } 
            break 
        }
        $K.ESC       { generate_blank_window ; Write-Host "`nExiting...`n" ; exit 0 }
        $K.ENTER     { execute_selection ; break }
        $K.UP        { MoveCursor $DIRECTION.UP ; break }
        $K.DOWN      { MoveCursor $DIRECTION.DOWN; break }
        $K.TILDE     { RenderItemInfo(GetSelectedItem) }
        { -not [char]::IsLetterOrDigit($_) } { break <# non-ascii #> }
        { [char]::IsWhiteSpace($_) } { break <# capture whitespace chracters #> }
        Default {
            $CurrentUserInput[0] += $UserInput.Character           
        }
    }
}


function main {
    # ListenForKeypress -_WaitForKeyPress
    
}
If ($MyInvocation.InvocationName -ne ".") { main }