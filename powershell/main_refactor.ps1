using namespace System.Collections
using namespace System.Collections.ObjectModel
using namespace System.Collections.Generic
using namespace System.Management.Automation.Host
using namespace System.Runtime.CompilerServices
Set-StrictMode -Version Latest 
$ErrorActionPreference = "Stop"
enum IsWildcard { true = $true; false = $false }
# [Console]::CursorVisible = $false

#region typedata
$ScriptBlock_Items = {
    $result = [ordered]@{}
    foreach ( $property in $this.psobject.Properties.Name ) {
        $result[$property] = $this.$property
    }
    return $result.GetEnumerator()
}
$TypeData = @{
    TypeName   = 'SamsHelperFuncs'
    MemberType = 'ScriptMethod'
    MemberName = 'Items'
    Value      = $ScriptBlock_Items
    Force      = $true
}
Update-TypeData @TypeData

#endregion typedata

$logfile = Join-Path $PWD ".log.txt"
Clear-Content -Path $logfile
function Log {
    param( [string]$_msg)
    $_msg | Out-File -FilePath $logfile -Append

}


function RecursivelySetTypeData([PSCustomObject]$_Object) {
    $_Object.pstypenames.Insert(0, 'SamsHelperFuncs')
    foreach ($item in $_Object.PSObject.properties) {
        if ($item.Value.GetType().Name -eq "PSCustomObject") {
            RecursivelySetTypeData($item.Value)
            # Log($item)
        }
    }
}


class Singletons {
    static [Singletons] $Instance
    static [Renderer] $Renderer
    static [InputHandler] $InputHandler
    static [StateData] $StateData
    static [DataBase] $Database
    static InitializeSingletons() {
        [Singletons]::Renderer = [Renderer]::GetInstance()
        [Singletons]::InputHandler = [InputHandler]::GetInstance()
        [Singletons]::StateData = [StateData]::GetInstance()
        [Singletons]::Database = [DataBase]::GetInstance()
    }
    #region init
    static [Singletons] GetInstance() {
        if (-not [Singletons]::Instance) { 
            [Singletons]::Instance = [Singletons]::new()
            [Singletons]::InitializeSingletons()
        }
        return [Singletons]::Instance
    }
    #endregion init
}

class StateData {
    # $_DB
    [int]       $CursorPos
    [List[Object]] $CurrentItems
    [string]    $TypedUserInput
    [string]    $CurrentScreenText

    Init() {
        # $this.CurrentItems = $this._DB.menus.'main menu'
    }
    #region init
    static [StateData] $Instance
    static [StateData] GetInstance() {
        if (-not [StateData]::Instance) { 
            [StateData]::Instance = [StateData]::new()
            [StateData]::Instance.init()
        }
        return [StateData]::Instance
    }
    #endregion init
    
}


class Renderer {
    #region init
    $testvar = 0
    static [Renderer] $Instance
    Init() {}
    static [Renderer] GetInstance() {
        if (-not [Renderer]::Instance) { 
            [Renderer]::Instance = [Renderer]::new()
            [Renderer]::Instance.init()
        }
        return [Renderer]::Instance
    }
    #endregion init

    RenderBlankWindow() {
        $windowSize = $global:Host.UI.RawUI.WindowSize
        $blankLines = [int]$windowSize.Height

        for ($i = 1; $i -lt $blankLines; $i++) {
            Write-Host (' ' * $global:Host.UI.RawUI.WindowSize.Width)
        }
        [Console]::SetCursorPosition(0, 0)
    }
    
    ReRenderWindow() {
        [Console]::SetCursorPosition(0, 0)
        $this.RenderBlankWindow()
        Write-Host (
            [string]([Singletons]::StateData.TypedUserInput) +
            [string]([Singletons]::DataBase.GetSelectedItemsAsString())
        )
        [Console]::SetCursorPosition(0, 0)
        $CursorPos = [Singletons]::StateData.CursorPos
        if ($CursorPos) {
            $this.HighlightRange(
                ([Coordinates]::new($CursorPos[0], 0)),
                ([Coordinates]::new($CursorPos[0], 5)),
                ([System.ConsoleColor]::DarkYellow)
            )
        }
    }

    HighlightRange($_Start, $_End, $_Bg) {
        $_Start.y..$_End.y | ForEach-Object {
            $row = $_
            $_Start.x..$_End.x | ForEach-Object {
                $pos = [Coordinates]::new($row, $_)
                $char = $this.GetCharacterAtPos($pos)
                $global:Host.UI.RawUI.CursorPosition = $pos
                Write-Host $char -BackgroundColor $_Bg
            }
        }
    }

    GetCharacterAtPos($_Pos) {
        $zero = $global:Host.UI.RawUI.WindowPosition   # top-left coord of visible window
        $rect = New-Object Rectangle(
            ($zero.X + $_Pos.X), 
            ($zero.Y + $_Pos.Y),
            ($zero.X + $_Pos.X), 
            ($zero.Y + $_Pos.Y)
        )
        $char = $global:Host.UI.RawUI.GetBufferContents($rect)[0, 0].Character
        $char
    }

}


class InputHandler {
    #region init
    static [InputHandler] $Instance
    Init() { }
    static [InputHandler] GetInstance() {
        if (-not [InputHandler]::Instance) { 
            [InputHandler]::Instance = [InputHandler]::new()
            [InputHandler]::Instance.init()
        }
        return [InputHandler]::Instance
    }
    #endregion init

    HandleUserInput() {
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

        $DIRECTION = ([ordered]@{"UP" = -1; "DOWN" = 1 }).AsReadOnly()

        $UserInput = $global:Host.UI.RawUI.ReadKey("IncludeKeyDown, NoEcho")
        switch ($UserInput.VirtualKeyCode) {
            $K.BACKSPACE {
                if ([Singletons]::StateData.TypedUserInput) { 
                    [Singletons]::StateData.TypedUserInput = [Singletons]::StateData.TypedUserInput.Substring(0, [Singletons]::StateData.TypedUserInput.Length - 1)
                } 
                break 
            }
            $K.ESC       { [Singletons]::Renderer.RenderBlankWindow() ; Write-Host "`nExiting...`n" ; exit 0 }
            $K.ENTER     { $this.ExecuteSelection() ; break }
            $K.UP        { $this.MoveCursor($DIRECTION.UP)   ; break }
            $K.DOWN      { $this.MoveCursor($DIRECTION.DOWN) ; break }
            $K.TILDE     { RenderItemInfo(GetSelectedItem) }
            { -not [char]::IsLetterOrDigit($_) } { break <# non-ascii #> }
            { [char]::IsWhiteSpace($_) } { break <# capture whitespace chracters #> }
            Default {
                [Singletons]::StateData.TypedUserInput += $UserInput.Character           
            }
        }
    }
    MoveCursor($_Direction) {
        # $CursorIndex[0] += $_Direction
        $CursorPos = [Singletons]::StateData.CursorPos
        
        $mv_result = $CursorPos + $_Direction

        if ($mv_result -lt 0 ) { return }
        if ($mv_result -gt [Singletons]::Database.SelectedItemsIndex.Count ) { return }
        [Singletons]::StateData.CursorPos = $mv_result
    }

    ExecuteSelection() {
        $CursorPos = [Singletons]::StateData.CursorPos
        [Singletons]::DataBase.SelectedItemsIndex[$CursorPos].call()
    }

}

class DataBase {
    $JsonData
    $SelectedItemsIndex = [ArrayList]::new()
    #region init
    static [Database] $Instance
    Init() {
    }
    static [Database] GetInstance() {
        if (-not [Database]::Instance) { 
            [Database]::Instance = [Database]::new()
            [Database]::Instance.init()
        }
        return [Database]::Instance
    }
    #endregion init


    DataBase() {
        $this.JsonData = $this.ReadJsonToObject()
        $this.AddPropertyToGroupItems( "commands", "CurrentlySelected", $false )
        $this.AddPropertyToGroupItems( "scripts", "CurrentlySelected", $false )
        $this.AddPropertyToGroupItems( "menus", "CurrentlySelected", $false )
        $this.AddMethodToGroupItems(
            "call",
            "commands",
            { $this.command | Invoke-Expression }
        )
        $this.AddMethodToGroupItems(
            "call",
            "scripts",
            { . $this.path }
        )
        $this.AddMethodToGroupItems(
            "call",
            "menus",
            { 
                Write-Host "hello"
                $this.ChildItemObjects | ForEach-Object { 
                    $_.CurrentlySelected = $true 
                }
            }
        )
        $this.AddObjReferencesForMenuChildItems()

    }
    [Object] ReadJsonToObject() {
        $JsonPath = "M:\Sam\projects\code_menu\exports\_ps.json"
        $Data = Get-Content -Raw -Path $JsonPath | ConvertFrom-Json
        return $Data
    }

    AddPropertyToGroupItems($_Group, $_Name, $_Value) {
        $this.JsonData.$_Group.PSObject.Properties |  
        ForEach-Object {
            $_.Value | Add-Member `
                -NotePropertyName $_Name `
                -NotePropertyValue $_Value
        }
    }
    
    RefreshSelectedItemsIndex() {
        $this.SelectedItemsIndex.Clear()
        $this.JsonData.PSObject.Properties | 
        ForEach-Object { $_.Value.PSObject.Properties } |
        Where-Object { $_.Value.CurrentlySelected } |
        ForEach-Object { 
            $this.SelectedItemsIndex.Add($_)
        }
    }


    SearchAndSelectFromKeyword($_Keyword, [IsWildcard]$_IsWildcardMatch) {
        # set CurrentlySelected = True for kw searced items

        $Predicate = if ($_IsWildcardMatch) { 
            { $args[0].Name -like "*$_Keyword*" }
        }
        else {
            { $args[0].Name -eq "$_Keyword" }
        }

        $this.JsonData.PSObject.Properties | 
        ForEach-Object { $_.Value.PSObject.Properties } |
        Where-Object { $Predicate.Invoke($_) } |
        ForEach-Object { 
                
            $_.Value.CurrentlySelected = $true
            $this.SelectedItemsIndex.Add($_)
        }

    }
    
    [string] GetSelectedItemsAsString() {
        $result = ($this.SelectedItemsIndex | Select-Object -ExpandProperty Name ) -join "`n"
        return $result
    }
    
    AddMethodToGroupItems($_MethodName, $_GroupName, $_MethodBlock) {
        Write-Host ($_MethodBlock.GetType())
        $this.JsonData.$_GroupName.PSObject.Properties |
        ForEach-Object {
            $_.Value | Add-Member `
                -MemberType ScriptMethod `
                -Name $_MethodName `
                -Value $_MethodBlock
        }
    }

    AddObjReferencesForMenuChildItems() {
        foreach ($_Menu in $this.JsonData.menus.PSObject.Properties) {
            $_Menu.Value | Add-Member `
                -NotePropertyName "ChildItemObjects" `
                -NotePropertyValue ([ArrayList]::new()) 
            foreach ($_ChildGroupString in @("commands", "scripts", "menus")) {
                $_Group = $_Menu.Value.$_ChildGroupString
                $_Group | ForEach-Object {
                    $_ChildObj = $this.JsonData.$_ChildGroupString.$_
                    $_Menu.Value.ChildItemObjects.Add($_ChildObj)
                    ""
                }        
                ""
            }
        }
    }


}

function Main() {
    Clear-Host
    $__ = [Singletons]::GetInstance()
    [Singletons]::DataBase.SearchAndSelectFromKeyword("i", [IsWildcard]::true) #* testcode
    [Singletons]::Renderer.RenderBlankWindow()
    [Singletons]::Renderer.ReRenderWindow()
    while ($true) {
        [Singletons]::InputHandler.HandleUserInput()
        [Singletons]::DataBase.RefreshSelectedItemsIndex() # possible redundancy, but good catch-all
        [Singletons]::Renderer.ReRenderWindow() # possible redundancy, but good catch-all
    }
}

Main