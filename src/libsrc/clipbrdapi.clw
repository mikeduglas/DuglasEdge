!* Clipboard api support
!* mikeduglas@yandex.ru

                              MEMBER

  INCLUDE('clipbrdapi.inc'), ONCE

  MAP
    MODULE('Clipboard api')
      winapi::OpenClipboard(HWND hWndNewOwner=0),BOOL,PROC,PASCAL,NAME('OpenClipboard')
      winapi::CloseClipboard(),BOOL,PROC,PASCAL,NAME('CloseClipboard')
      winapi::EmptyClipboard(),BOOL,PROC,PASCAL,NAME('EmptyClipboard')
      winapi::SetClipboardData(ULONG uFormat,HANDLE hMem),HANDLE,PROC,PASCAL,NAME('SetClipboardData')
    END

    MODULE('Mem api')
      winapi::GlobalAlloc(LONG uFlags,LONG dwBytes),LONG,PASCAL,NAME('GlobalAlloc')
      winapi::GlobalLock(SIGNED hMem),LONG,PASCAL,PROC,NAME('GlobalLock')
      winapi::GlobalUnlock(SIGNED hMem),BOOL,PASCAL,PROC,NAME('GlobalUnlock')
      winapi::lstrcpy(LONG,LONG),LONG,PROC,PASCAL,RAW,NAME('lstrcpyA')
      winapi::GetLastError(),LONG,PASCAL,NAME('GetLastError')
    END
  
    ent_SubclassProc(HWND hWnd, ULONG wMsg, UNSIGNED wParam, LONG lParam, ULONG subclassId, UNSIGNED dwRefData), LONG, PASCAL, PRIVATE
    AddToClipboard(STRING pData),PRIVATE

    INCLUDE('printf.inc'), ONCE
  END



!!!region Callbacks
ent_SubclassProc              PROCEDURE(HWND hWnd, ULONG wMsg, UNSIGNED wParam, LONG lParam, ULONG subclassId, UNSIGNED dwRefData)
win                             TWnd
ctrl                            &TEntryCLipboardBase
  CODE
  win.SetHandle(hWnd)
  !- get TEntryCLipboardBase instance
  ctrl &= (dwRefData)
  IF ctrl &= NULL
    !- not our window
    RETURN win.DefSubclassProc(wMsg, wParam, lParam)
  END

  CASE wMsg
  OF WM_COPY
    IF ctrl.OnCopy()
      RETURN TRUE
    END
  END
  
  !- call original window proc
  RETURN ctrl.DefSubclassProc(wMsg, wParam, lParam)
!!!endregion
  
!!!region Helper functions
AddToClipboard                PROCEDURE(STRING pData)
szData                          CSTRING(LEN(pData)+1), AUTO
nStrLen                         LONG, AUTO
hMem                            HGDIOBJ, AUTO
szCopyTo                        &CSTRING
  CODE
  nStrLen = LEN(pData)
  szData = pData
  hMem = winapi::GlobalAlloc(GMEM_SHARE, nStrLen + 1)
  IF hMem
    szCopyTo &= winapi::GlobalLock(hMem)
    winapi::lstrcpy(ADDRESS(szCopyTo), ADDRESS(szData))
    winapi::GlobalUnlock(hMem)
    winapi::OpenClipboard()
    winapi::EmptyClipboard()
    winapi::SetClipboardData(CF_TEXT, hMem)
    winapi::CloseClipboard()
  ELSE
    printd('GlobalAlloc(%i) failed, error %i', nStrLen + 1, winapi::GetLastError())
  END
  
!!!endregion

!!!region TEntryCLipboardBase
TEntryCLipboardBase.Construct PROCEDURE()
  CODE
  
TEntryCLipboardBase.Destruct  PROCEDURE()
  CODE
  IF NOT SELF.sData &= NULL
    DISPOSE(SELF.sData)
  END
  
TEntryCLipboardBase.Init      PROCEDURE(SIGNED pFeq)
  CODE
  ASSERT(pFeq{PROP:Type} = CREATE:entry)
  IF pFeq{PROP:Type} <> CREATE:entry
    RETURN
  END
  
  PARENT.Init(pFeq)
  
  !- overwrite default subclass proc
  SELF.SetWindowSubclass(ADDRESS(ent_SubclassProc), 0, ADDRESS(SELF))
  
TEntryCLipboardBase.SetClipboardData  PROCEDURE(STRING pData)
  CODE
  IF NOT SELF.sData &= NULL
    DISPOSE(SELF.sData)
    SELF.sData &= NULL
  END
  IF LEN(pData)
    SELF.sData &= NEW STRING(LEN(pData))
    SELF.sData = pData
  END
  
TEntryCLipboardBase.OnCopy    PROCEDURE()
  CODE
!  printd('Selection %i:%i', SELF.FEQ{PROP:SelStart}, SELF.FEQ{PROP:SelEnd})
  !- ENTRY contents: 1234567890
  !- Possible values of SelStart and SelEnd
  !- Selection by keyboard or mouse from start to end : 1:10
  !- Selection by keyboard or mouse from end to start : 11:0
  
  IF (SELF.FEQ{PROP:SelStart} = 1 AND SELF.FEQ{PROP:SelEnd} = LEN(SELF.FEQ{PROP:ScreenText})) |
    OR (SELF.FEQ{PROP:SelStart} = LEN(SELF.FEQ{PROP:ScreenText})+1 AND SELF.FEQ{PROP:SelEnd} = 0)
    !- all text selected: copy to clipboard custom data
    IF NOT SELF.sData &= NULL
      AddToClipboard(SELF.sData)
      RETURN TRUE
    END
  END
  !- default processing
  RETURN FALSE
!!!endregion