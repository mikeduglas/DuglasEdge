!* Duglas Edge favorites

  INCLUDE('cjson.inc'), ONCE

typFavoriteInfo               GROUP, TYPE
uri                             STRING(1024)
title                           STRING(256)
favicon                         STRING(4096)
                              END
typFavoriteInfos              QUEUE(typFavoriteInfo), TYPE.

TFavorites                    CLASS(cJSONFactory), TYPE, MODULE('defavorites.clw'), LINK('defavorites.clw')
sFileName                       STRING(256), PROTECTED
jFavorites                      &cJSON, PROTECTED

Construct                       PROCEDURE()
Destruct                        PROCEDURE(), VIRTUAL
Reset                           PROCEDURE(), VIRTUAL
SetFile                         PROCEDURE(STRING pFileName)
Load                            PROCEDURE(), BOOL, PROC
Save                            PROCEDURE(), BOOL, PROC
AddSite                         PROCEDURE(STRING pUri, STRING pTitle, STRING pfaviconFile), BOOL, PROC
AddSite                         PROCEDURE(typFavoriteInfo pInfo), BOOL, PROC
RemoveSite                      PROCEDURE(STRING pUri), BOOL, PROC
IndexOf                         PROCEDURE(STRING pUri), LONG
GetByIndex                      PROCEDURE(LONG pIndex, *STRING pUri, *STRING pTitle, *STRING pFavicon), BOOL
GetByIndex                      PROCEDURE(LONG pIndex, *typFavoriteInfo pInfo), BOOL
GetAll                          PROCEDURE(*typFavoriteInfos pInfos), BOOL, PROC
                              END
