!* Duglas Edge Zoom factor manager

TZoomFactorManager            CLASS, TYPE, MODULE('dezoom.clw'), LINK('dezoom.clw')
sFileName                       STRING(FILE:MaxFilePath), PRIVATE
jRootArray                      &cJSON, PRIVATE

Construct                       PROCEDURE()
Destruct                        PROCEDURE(), VIRTUAL
Init                            PROCEDURE(STRING pFileName), BOOL, PROC
Kill                            PROCEDURE()
Reset                           PROCEDURE(), VIRTUAL
Save                            PROCEDURE(), BOOL, PROC
GetZoomFactor                   PROCEDURE(STRING pHost), REAL
SetZoomFactor                   PROCEDURE(STRING pHost, REAL pZoomFactor), BOOL, PROC
                              END
