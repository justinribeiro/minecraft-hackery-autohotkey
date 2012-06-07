; Minecraft Hackery v1.0
; Author:	Justin Ribeiro <justin@justinribeiro.com>
; Website:	http://www.justinribeiro.com/
;
; 	Additional Credits:
;		1) F1/F2 mappings from Desi Quintans' Minecraft Remaps v2.1 (http://www.desiquintans.com)
;		2) autopilot code from jaceguay (http://www.autohotkey.com/forum/topic59506.html)
;		3) autocrouch from avien (http://www.minecraftforum.net/viewtopic.php?f=3&t=60032)
;		4) item id key image from Marvin http://marvk.net/?page_id=184
;		5) initial GUI mocked up with SmartGUI Creator 4.0 (http://www.autohotkey.com/download/)
;		6) AutoHotKey.  Seriously, my desktop would not be useable without you.
;
;	Script Function:
;  		The following will only apply inside the Minecraft window:
;			1) From Desi's Remaps: F1 toggles hold-left-click. Handy for breaking lots of blocks or mining obsidian.
;			2) From Desi's Remaps: F2 toggles hold-W, making you move forward automatically. Use with F1 for automated mining action!
;			3) JDR: F3 toggles hold-s, making you move backward automatically.
;			4) JDR: F4 prompts for itemid, for use as OP in SMP: make sure to set player var
;			5) JDR: Ctrl-R toggles crouching.
;
;	Script Presumes:	
;		The script makes the following assumptions (which you can change if you like in the code)
;			1) Talk is mapped to "t"
;			2) Walk is mapped to "w"
;			3) Backwards Walk is mapped to "s"
;			4) Crouch is mapped to LShift
;
;	Setup:
;		1) Go download the item key image and remember the path where you put it (get image: http://marvk.net/?page_id=184)
;		2) Set the vars for your player name and the item key image in the SetMineCraftDefaults() function
;		3) ???
;		4) Profit
;
;	Things this script is not:
;		1) Profitable (booo, I missed setup point #3)
;		2) Perfect (is anything really every perfect...you got that joke right?)
;

#NoEnv
#InstallKeybdHook
SendMode Input
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 3

; JDR: this function sets the global vars that are needed by the rest of the app
SetMineCraftDefaults()
{
	; JDR: do not remove
	global 
	
	; JDR: set your default user
	dfplayerhandle := "justinribeiro"
	
	; JDR: image used to be in the Minecraft wiki, can get from original source: http://marvk.net/?page_id=184
	dfitemkeyimg := "D:\DropPoint\QuickDocs\downloads\Images\ItemslistV110.png"
	
	dfquantity := 64
	dfloop := 1
}	

#IfWinActive, Minecraft
{
	; The following autopilot code was borrowed from jaceguay at http://www.autohotkey.com/forum/topic59506.html
	F1::Send % "{LButton " ((Cnt := !Cnt) ? "Down}" : "Up}" )
	F2::Send % "{w " ((Cnt2 := !Cnt2) ? "Down}" : "Up}" )
	
	; JDR: walk backwards
	F3::Send % "{s " ((Cnt2 := !Cnt2) ? "Down}" : "Up}" )
	
	; JDR: Ctrl-r for autocrouch from avien at http://www.minecraftforum.net/viewtopic.php?f=3&t=60032
	^r::
	GetKeyState, state, Shift
	if state = D
	   Send {LShift Up}
	else
	   Send {LShift Down}
	return
	
	; JDR: The following is my GUI for giving items to either yourself or other players as an OP in SMP
	F4::Goto, GetSomeItem
	GetSomeItem:
		; JDR: get the globals
		SetMineCraftDefaults()
		
		; JDR: we open a talk command line, otherwise Minecraft trips out
		SendInput t 
		
		; JDR: start building the GUI
		; JDR: initial GUI was mocked up with SmartGUI Creator 4.0
		Gui, +LastFound +AlwaysOnTop +ToolWindow +Border
		Gui, Font, s12, Arial

		; !!!! IMPORTANT !!!!!
		; JDR: make sure you set the correct path to the image file here!
		Gui, Add, Picture, x15 y15 w300 h660 , %dfitemkeyimg%
		
		Gui, Add, GroupBox, x320 y15 w305 h370 , Pick your poison
		Gui, Add, Text, x330 y46 w290 h20 , Please enter item id
		Gui, Add, Edit, x330 y73 w66 h25 vitemid +Number +ToolTip,
		Gui, Add, Text, x330 y112 w290 h20 , Please enter quantity
		Gui, Add, Edit, x330 y137 w65 h25 vsbquantity +Number +ToolTip,
		Gui, Add, Text, x330 y175 w290 h20 , Please enter loop number
		Gui, Add, Edit, x330 y205 w66 h25 vsbloop +Number +ToolTip,
		Gui, Add, Text, x330 y244 w290 h20 , Please enter player (default = you)
		Gui, Add, Edit, x330 y276 w247 h25 vsbplayerhandle +Number +ToolTip,
		Gui, Add, Text, x400 y137 w220 h20 , (default = 64`, max = 64)
		Gui, Add, Text, x400 y204 w220 h20 , (default = 1)
		Gui, Add, Button, x330 y320 w130 h55 , Deliver
		Gui, Add, Button, x470 y320 w130 h55 , Cancel

		Gui, Add, GroupBox, x320 y400 w305 h285 , Help
		Gui, Add, Text, x330 y425 w290 h45 , Item ID = the item you wish to give yourself/someone else
		Gui, Add, Text, x330 y480 w290 h45 , Quantity = amount of item id to give (default = 64`, max = 64)
		Gui, Add, Text, x330 y530 w290 h45 , Loop Number = number of times to run /give command
		Gui, Add, Text, x330 y580 w290 h45 , Player = Set player var in script to your handle`, otherwise enter player handle
		Gui, Show, x100 y100 h700 w650, Set to deliver some goods in Minecraft
		Return

		GuiClose:
			SendInput {Esc}
			Gui, Destroy
		Return		
		
		ButtonCancel:
			SendInput {Esc}
			Gui, Destroy
		Return
		
		ButtonDeliver:
			; JDR: get our vars from the form
			GUI, Submit
			
			; JDR: switch back to the minecraft window
			WinActivate, Minecraft
			
			; JDR: we close the talk screen as a safety
			SendInput {Esc}
			
			; JDR: which user are we targeting
			if (sbplayerhandle)
			{
				player := sbplayerhandle
			}
			else
			{
				player := dfplayerhandle
			}
			
			; JDR: which quantity are we going to use
			if (sbquantity)
			{
				quantity := sbquantity
			}
			else
			{
				quantity := dfquantity
			}
			
			; JDR: how many loops
			; JDR: note, we add +1 because of A_Index in the loop always starts at 1 and not 0
			if (sbloop)
			{
				loopnumber := sbloop + 1
			}
			else
			{
				loopnumber := dfloop + 1
			}
			
			; JDR: we run our loop to give us some stuff
			while A_Index <= loopnumber
			{
				; JDR: we send the commands to the minecraft window
				SendInput t
				SendInput #/give %player% %itemid% %quantity% {Enter}
				
				; JDR: if we don't sleep for a half second, the loop goes way too fast and minecraft trips out
				Sleep, 500
			}

			Gui, Destroy
		Return    	    
	Return
}