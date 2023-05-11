; Created by Sam Gleske
; http://www.pages.drexel.edu/~sag47/

; Required to Compile
; Use custom NSIS installer to resolve most plugins - http://www.pages.drexel.edu/~sag47/uharc/NSIS-Installer.zip

; This was also created to help promote the NSIS community growth
; Go to http://nsis.sf.net/

;--------------------------------
; Runtime code

XPStyle on

; Best Compression
SetCompress Auto
SetCompressor /SOLID lzma
SetCompressorDictSize 32
SetDatablockOptimize On

!define INSTALLER_NAME "autorun_gen.exe"
!define PRODUCT_NAME "Autorun Generator"
!define PRODUCT_VERSION "1.0.0.0"
!define PRODUCT_PUBLISHER "By Sam Gleske"
!define PRODUCT_COPYRIGHT "© Sam Gleske"

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
;!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"

; Welcome page
;!insertmacro MUI_PAGE_WELCOME
Page custom GenConfig GeneratorValidation
; License page
;!insertmacro MUI_PAGE_LICENSE "c:\path\to\licence\YourSoftwareLicence.txt"
; Instfiles page
!define MUI_INSTFILESPAGE_FINISHHEADER_TEXT "Source Generated"
!define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT "Check the 'Autorun Source' folder located in the same folder as this generator."
!insertmacro MUI_PAGE_INSTFILES
; Finish page
;!insertmacro MUI_PAGE_FINISH

; Language files
!insertmacro MUI_LANGUAGE "English"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "${INSTALLER_NAME}"
InstallDir "$TEMP"
ShowInstDetails nevershow
BrandingText /TRIMRIGHT "${PRODUCT_NAME}"

; File info
VIProductVersion "${PRODUCT_VERSION}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "${PRODUCT_NAME} ${PRODUCT_VERSION}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "${PRODUCT_PUBLISHER}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "${PRODUCT_NAME}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${PRODUCT_VERSION}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "OriginalFilename" "${INSTALLER_NAME}"

;--------------------------------
; Variables

Var SUPPORT_LINK
Var SUPPORT_TITLE
Var AUTORUN_EXE
Var AUTORUN_HTM
Var OPTION1_NAME
Var OPTION1_COMMAND
Var OPTION2_NAME
Var OPTION2_COMMAND

;--------------------------------
; Macros

!macro MakeDependent CHECKBOX FIELD1 FIELD2
  ReadINIStr $0 "$PLUGINSDIR\generator.ini" "${CHECKBOX}" "State"
  ReadINIStr $1 "$PLUGINSDIR\generator.ini" "${FIELD1}" "HWND"
  EnableWindow $1 $0
  ReadINIStr $1 "$PLUGINSDIR\generator.ini" "${FIELD1}" "HWND2"
  EnableWindow $1 $0
  ReadINIStr $1 "$PLUGINSDIR\generator.ini" "${FIELD2}" "HWND"
  EnableWindow $1 $0
  ReadINIStr $1 "$PLUGINSDIR\generator.ini" "${FIELD2}" "HWND2"
  EnableWindow $1 $0
!macroend

!macro WriteINIStr FIELD ENTRY VALUE FLAGS
; writeinistr field entry value flags
  WriteINIStr "$PLUGINSDIR\generator.ini" "${FIELD}" "${ENTRY}" "${VALUE}"
  WriteINIStr "$PLUGINSDIR\generator.ini" "${FIELD}" "Flags" "${FLAGS}"
  ReadINIStr $1 "$PLUGINSDIR\generator.ini" "${FIELD}" "HWND"
  SendMessage $1 ${WM_SETTEXT} 0 "STR:${VALUE}"
!macroend

!macro WriteToFile STRING FILE
 Push "${STRING}"
 Push "${FILE}"
  Call WriteToFile
!macroend

;--------------------------------
; Installer Sections

Section "Main" SEC01
; here is the sourcecode
  CreateDirectory "$EXEDIR\Autorun Source"
  SetOutPath "$EXEDIR\Autorun Source"
  File "autorun_gen.nsi"
  File "generator.ini"
SectionEnd

;--------------------------------
; Installer Functions

Function .onInit
  BringToFront
; Check if already running
; If so don't open another but bring to front
  System::Call "kernel32::CreateMutexA(i 0, i 0, t '$(^Name)') i .r0 ?e"
  Pop $0
  StrCmp $0 0 launch
   StrLen $0 "$(^Name)"
   IntOp $0 $0 + 1
  loop:
    FindWindow $1 '#32770' '' 0 $1
    IntCmp $1 0 +4
    System::Call "user32::GetWindowText(i r1, t .r2, i r0) i."
    StrCmp $2 "Autorun Configuration" +2 +1
    StrCmp $2 "$(^Name)" +1 loop
    System::Call "user32::ShowWindow(i r1,i 9) i."         ; If minimized then maximize
    System::Call "user32::SetForegroundWindow(i r1) i."    ; Brint to front
    Abort
  launch:
  
  InitPluginsDir
  File /oname=$PLUGINSDIR\generator.ini "generator.ini"
  StrCpy $SUPPORT_TITLE "&Get Support..."
  StrCpy $SUPPORT_LINK "http://support.mycompany.com/"
  StrCpy $AUTORUN_HTM "index.html"
  StrCpy $OPTION1_NAME "Click Option 1"
  StrCpy $OPTION1_COMMAND "option1.exe"
  StrCpy $OPTION2_NAME "Click Option 2"
  StrCpy $OPTION2_COMMAND "option2.exe"
FunctionEnd

Function GenConfig
  !insertmacro MUI_HEADER_TEXT "Autorun Configuration Page" "Fill out the form below and your autorun will be generated automatically!"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "generator.ini"
FunctionEnd

Function GenerateINF

; Check if Autorun.inf already exists
  IfFileExists "$EXEDIR\Autorun.inf" +1 +4
  MessageBox MB_YESNO|MB_ICONQUESTION|MB_SETFOREGROUND|MB_TOPMOST "Autorun.inf already exists.  Would you like to overwrite?" idYes +2 idNo +1
  Abort
  Delete "$EXEDIR\Autorun.inf"
  
; Check if support.bat already exists
  IfFileExists "$EXEDIR\support.bat" +1 +4
  MessageBox MB_YESNO|MB_ICONQUESTION|MB_SETFOREGROUND|MB_TOPMOST "support.bat already exists.  Would you like to overwrite?" idYes +2 idNo +1
  Abort
  Delete "$EXEDIR\support.bat"
  
  !insertmacro WriteToFile "; Automatically generated by Autorun Generator 1.0$\r$\n" "$EXEDIR\Autorun.inf"
  !insertmacro WriteToFile "; Created by Sam Gleske$\r$\n" "$EXEDIR\Autorun.inf"
  !insertmacro WriteToFile "; http://www.pages.drexel.edu/~sag47/$\r$\n" "$EXEDIR\Autorun.inf"
  !insertmacro WriteToFile "; This is opensource/free software, if you paid for it then get a refund!$\r$\n" "$EXEDIR\Autorun.inf"
  !insertmacro WriteToFile "$\r$\n" "$EXEDIR\Autorun.inf"

; write the open section
  ReadINIStr $0 "$PLUGINSDIR\generator.ini" "Field 3" "State"
  StrCmp $0 1 +1 +5
  ReadINIStr $1 "$PLUGINSDIR\generator.ini" "Field 1" "State"
  StrCmp $1 "" +2
  WriteINIStr "$EXEDIR\Autorun.inf" "autorun" "shellexecute" "$1"
  Goto skipopen
  ReadINIStr $1 "$PLUGINSDIR\generator.ini" "Field 1" "State"
  StrCmp $1 "" +2
  WriteINIStr "$EXEDIR\Autorun.inf" "autorun" "open" "$1"
  skipopen:
  
  WriteINIStr "$EXEDIR\Autorun.inf" "autorun" ";action" "Open Program"
  
; write the icon section
  ReadINIStr $1 "$PLUGINSDIR\generator.ini" "Field 5" "State"
  StrCmp $1 "" +2
  WriteINIStr "$EXEDIR\Autorun.inf" "autorun" "icon" "$1"

; write the label section
  ReadINIStr $1 "$PLUGINSDIR\generator.ini" "Field 8" "State"
  StrCmp $1 "" +2
  WriteINIStr "$EXEDIR\Autorun.inf" "autorun" "label" "$1"

; write the support link
  ReadINIStr $1 "$PLUGINSDIR\generator.ini" "Field 9" "State"
  StrCmp $1 1 +1 skipsupport
  ReadINIStr $1 "$PLUGINSDIR\generator.ini" "Field 10" "State"
  StrCmp $1 "" +1 +3
  MessageBox MB_ICONEXCLAMATION|MB_OK "Support Link Title is blank!"
  Abort
  WriteINIStr "$EXEDIR\Autorun.inf" "autorun" "shell\support" "$1"
  ReadINIStr $1 "$PLUGINSDIR\generator.ini" "Field 11" "State"
  StrCmp $1 "" +1 +3
  MessageBox MB_ICONEXCLAMATION|MB_OK "Support Link URL is blank!"
  Abort
  WriteINIStr "$EXEDIR\Autorun.inf" "autorun" "shell\support\command" "support.bat"
  !insertmacro WriteToFile ":: Automatically generated by Autorun Generator 1.0$\r$\n" "$EXEDIR\support.bat"
  !insertmacro WriteToFile ":: Created by Sam Gleske$\r$\n" "$EXEDIR\support.bat"
  !insertmacro WriteToFile ":: http://www.pages.drexel.edu/~sag47/$\r$\n" "$EXEDIR\support.bat"
  !insertmacro WriteToFile ":: This is opensource/free software, if you paid for it then get a refund!$\r$\n" "$EXEDIR\support.bat"
  !insertmacro WriteToFile "$\r$\n" "$EXEDIR\support.bat"
  !insertmacro WriteToFile "echo off$\r$\n" "$EXEDIR\support.bat"
  !insertmacro WriteToFile "title Launching Support Site$\r$\n" "$EXEDIR\support.bat"
  !insertmacro WriteToFile "cls$\r$\n" "$EXEDIR\support.bat"
  !insertmacro WriteToFile "echo Please Wait...$\r$\n" "$EXEDIR\support.bat"
  !insertmacro WriteToFile "start $1$\r$\n" "$EXEDIR\support.bat"
  skipsupport:
  
; write context menu option1
  ReadINIStr $1 "$PLUGINSDIR\generator.ini" "Field 12" "State"
  StrCmp $1 1 +1 skipoption1
  ReadINIStr $1 "$PLUGINSDIR\generator.ini" "Field 13" "State"
  StrCmp $1 "" +1 +3
  MessageBox MB_ICONEXCLAMATION|MB_OK "Right Click Name is blank!"
  Abort
  WriteINIStr "$EXEDIR\Autorun.inf" "autorun" "shell\option1" "$1"
  ReadINIStr $1 "$PLUGINSDIR\generator.ini" "Field 14" "State"
  StrCmp $1 "" +1 +3
  MessageBox MB_ICONEXCLAMATION|MB_OK "Right Click Executable is blank!"
  Abort
  WriteINIStr "$EXEDIR\Autorun.inf" "autorun" "shell\option1\command" "$1"
  skipoption1:
  
; write context menu option2
  ReadINIStr $1 "$PLUGINSDIR\generator.ini" "Field 15" "State"
  StrCmp $1 1 +1 skipoption2
  ReadINIStr $1 "$PLUGINSDIR\generator.ini" "Field 16" "State"
  StrCmp $1 "" +1 +3
  MessageBox MB_ICONEXCLAMATION|MB_OK "Right Click Name is blank!"
  Abort
  WriteINIStr "$EXEDIR\Autorun.inf" "autorun" "shell\option2" "$1"
  ReadINIStr $1 "$PLUGINSDIR\generator.ini" "Field 17" "State"
  StrCmp $1 "" +1 +3
  MessageBox MB_ICONEXCLAMATION|MB_OK "Right Click Executable is blank!"
  Abort
  WriteINIStr "$EXEDIR\Autorun.inf" "autorun" "shell\option2\command" "$1"
  skipoption2:

  Messagebox MB_OK "Autorun.inf has been generated!"
  ReadINIStr $1 "$PLUGINSDIR\generator.ini" "Field 9" "State"
  StrCmp $1 1 +1 +2
  Messagebox MB_OK "support.bat has been generated!"
FunctionEnd

Function GeneratorValidation
  ReadINIStr $0 "$PLUGINSDIR\generator.ini" "Settings" "State"
  StrCmp $0 0 generatebutton  ; Generate button
  StrCmp $0 3 autoruncheck  ; Autorun checkbox
  StrCmp $0 9 supportcheck  ; Support checkbox
  StrCmp $0 12 context1check ; Context Menu Option1 Checkbox
  StrCmp $0 15 context2check ; Context Menu Option2 Checkbox
  Goto abort ; Return to the page

; Autorun Checkbox
  autoruncheck:
  ReadINIStr $1 "$PLUGINSDIR\generator.ini" "Field 3" "State"
  StrCmp $1 1 autorunchecked autorununchecked
  autorunchecked:
  ReadINIStr $AUTORUN_EXE "$PLUGINSDIR\generator.ini" "Field 1" "State"
  !insertmacro WriteINIStr "Field 1" "State" "$AUTORUN_HTM" ""
  Goto abort
  autorununchecked:
  ReadINIStr $AUTORUN_HTM "$PLUGINSDIR\generator.ini" "Field 1" "State"
  !insertmacro WriteINIStr "Field 1" "State" "$AUTORUN_EXE" ""
  Goto abort

; Support Checkbox
  supportcheck:
  !insertmacro MakeDependent "Field 9" "Field 10" "Field 11"
  StrCmp $0 1 supportchecked supportunchecked
  supportchecked:
    !insertmacro WriteINIStr "Field 10" "State" "$SUPPORT_TITLE" ""
    !insertmacro WriteINIStr "Field 11" "State" "$SUPPORT_LINK" ""
    Goto abort
  supportunchecked:
    ReadINIStr $SUPPORT_TITLE "$PLUGINSDIR\generator.ini" "Field 10" "State"
    ReadINIStr $SUPPORT_LINK "$PLUGINSDIR\generator.ini" "Field 11" "State"
    !insertmacro WriteINIStr "Field 10" "State" "Support Link Title" "DISABLED"
    !insertmacro WriteINIStr "Field 11" "State" "Support Link URL" "DISABLED"
    Goto abort

; Context Option1 Checkbox
  context1check:
  !insertmacro MakeDependent "Field 12" "Field 13" "Field 14"
  StrCmp $0 1 context1checked context1unchecked
  context1checked:
    !insertmacro WriteINIStr "Field 13" "State" "$OPTION1_NAME" ""
    !insertmacro WriteINIStr "Field 14" "State" "$OPTION1_COMMAND" ""
    Goto abort
  context1unchecked:
    ReadINIStr $OPTION1_NAME "$PLUGINSDIR\generator.ini" "Field 13" "State"
    ReadINIStr $OPTION1_COMMAND "$PLUGINSDIR\generator.ini" "Field 14" "State"
    !insertmacro WriteINIStr "Field 13" "State" "Right Click Name" "DISABLED"
    !insertmacro WriteINIStr "Field 14" "State" "Right Click Executable" "DISABLED"
    Goto abort

; Context Option2 Checkbox
  context2check:
  !insertmacro MakeDependent "Field 15" "Field 16" "Field 17"
  StrCmp $0 1 context2checked context2unchecked
  context2checked:
    !insertmacro WriteINIStr "Field 16" "State" "$OPTION2_NAME" ""
    !insertmacro WriteINIStr "Field 17" "State" "$OPTION2_COMMAND" ""
    Goto abort
  context2unchecked:
    ReadINIStr $OPTION2_NAME "$PLUGINSDIR\generator.ini" "Field 16" "State"
    ReadINIStr $OPTION2_COMMAND "$PLUGINSDIR\generator.ini" "Field 17" "State"
    !insertmacro WriteINIStr "Field 16" "State" "Right Click Name" "DISABLED"
    !insertmacro WriteINIStr "Field 17" "State" "Right Click Executable" "DISABLED"
    Goto abort

; Generate Button
  generatebutton:
  ReadINIStr $0 "$PLUGINSDIR\generator.ini" "Field 19" "State"
  StrCmp $0 1 sourcecode
  Call GenerateINF
  abort:
  Abort ; return to page

  sourcecode:
FunctionEnd

Function WriteToFile
 Exch $0 ;file to write to
 Exch
 Exch $1 ;text to write

  FileOpen $0 $0 a #open file
   FileSeek $0 0 END #go to end
   FileWrite $0 $1 #write to file
  FileClose $0

 Pop $1
 Pop $0
FunctionEnd

!echo "Autorun Generator 1.0 - © 2005-2007 Sam Gleske"