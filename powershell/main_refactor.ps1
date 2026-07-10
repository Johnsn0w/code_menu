using namespace System.Collections
using namespace System.Collections.ObjectModel
using namespace System.Collections.Generic
using namespace System.Management.Automation.Host
Set-StrictMode -Version Latest 
$ErrorActionPreference = "Stop"


class Singletons {
    static [Singletons] $Instance
    static [Renderer] $Renderer
    static [InputHandler] $InputHandler
    static [StateData] $StateData
    Init() {
        [Singletons]::Renderer = [Renderer]::GetInstance()
        [Singletons]::InputHandler = [InputHandler]::GetInstance()
        [Singletons]::StateData = [StateData]::GetInstance()
    }
    #region init
    static [Singletons] GetInstance() {
        if (-not [Singletons]::Instance) { 
            [Singletons]::Instance = [Singletons]::new()
            [Singletons]::Instance.init()
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
    Init() {
        # $this.RenderBlankScreen()
        # $this.ReRenderWindow()
        
    }
    static [Renderer] GetInstance() {
        if (-not [Renderer]::Instance) { 
            [Renderer]::Instance = [Renderer]::new()
            [Renderer]::Instance.init()
        }
        return [Renderer]::Instance
    }
    #endregion init

    RenderBlankWindow() {}

    ReRenderWindow() {
        # Jump to pos 0x 0y
        # RenderBlankWindow()

    }


}

# New-Variable RendererSingleton ([Renderer]::GetInstance()) -Option Constant
# New-Variable StateDataSingleton ([Renderer]::GetInstance()) -Option Constant
# New-Variable InputHandlerSingleton ([Renderer]::GetInstance()) -Option Constant

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
        $temp = [Dictionary[string, int]]::new()
        $temp.Add("UP", -1) ; $temp.Add("DOWN", 1)
        $DIRECTION = [ReadOnlyDictionary[string, int]]::new($temp)

        $UserInput = $global:Host.UI.RawUI.ReadKey("IncludeKeyDown, NoEcho")
        switch ($UserInput.VirtualKeyCode) {
            $K.BACKSPACE {
                if ([Singletons]::StateData.TypedUserInput) { 
                    [Singletons]::StateData.TypedUserInput = [Singletons]::StateData.TypedUserInput.Substring(0, [Singletons]::StateData.TypedUserInput.Length - 1)
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
                [Singletons]::StateData.TypedUserInput += $UserInput.Character           
            }
        }
    }

}


class MenuCommonInterface {
    $Name
    $Index
    $Desc
    $Tags
    $Meta
    Call() {}
}

class CommandItem : MenuCommonInterface {
    $Command
    Call() {}
}

class MenuItem : MenuCommonInterface {
    $ChildMenus
    $ChildCallables
    Call() {}
}

class ScriptItem : MenuCommonInterface {
    $Path
    Call() {}
}


class DataBase {
    [list[CommandItem]]$Commands
    [list[MenuItem]]$Menus
    [list[ScriptItem]]$Scripts
    [DataBase] $MasterDB

    LoadMenuItems($MenuObject) {
        #! add cmd to clear database
        # take a list of strings, load each one of those [command/script/...] into the db
        foreach ($type in @("commands", "menus", "scripts")) {            
            foreach ($itemString in $MenuObject.$type) {
                $item = $this.MasterDB.$type.$itemString
                $this.$type += $this.GetItemFromMasterDB($item, $type)
            }            
        }
    }

    [object] GetItemFromMasterDB($ItemNameField, $ItemType) {
        # $ItemType += "s"    
        return $this.MasterDB.$ItemType.$ItemNameField
    }

    LoadItemsFromKeyword() {
        $_Input = [Singletons]::StateData.TypedUserInput
        $_Index = 0
        #! add cmd to clear database
        foreach ($type in @("commands", "scripts")) {            
            foreach ($item in $this.MasterDB.$type) {
                if ($item.name -like "*$_Input*") {
                    $item.Index = $_Index
                    $this.MasterDB.$type += $item
                    $_Index++
                }
            }            
        }
    }

    [PSCustomObject] ReadJsonToObject( $Path) {
        $JsonPath = (Split-Path $PSScriptRoot -Parent) + "\exports\_ps.json"
        $Data = Get-Content -Raw -Path $JsonPath | ConvertFrom-Json
        Write-Host $Data.menus.'main menu'.'child callable items'
        return $Data
    }

    ParseJsonToDB() {

    }


}


function Main() {
    $__ = [Singletons]::GetInstance()
    
    while ($true) {
        [Singletons]::InputHandler.HandleUserInput()
        [Singletons]::Renderer.ReRenderWindow()
    }

}

Main