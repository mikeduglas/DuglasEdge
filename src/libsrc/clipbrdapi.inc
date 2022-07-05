!* Clipboard api support
!* mikeduglas@yandex.ru

  INCLUDE('winapi.inc'), ONCE

TEntryCLipboardBase           CLASS(TWnd), TYPE, MODULE('clipbrdapi.clw'), LINK('clipbrdapi.clw')
sData                           &STRING, PROTECTED

Construct                       PROCEDURE()
Destruct                        PROCEDURE(), DERIVED
Init                            PROCEDURE(SIGNED pFeq), DERIVED
SetClipboardData                PROCEDURE(STRING pData), VIRTUAL
OnCopy                          PROCEDURE(), BOOL, VIRTUAL, PROTECTED
                              END
