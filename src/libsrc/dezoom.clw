!* Duglas Edge Zoom factor manager

  MEMBER

  INCLUDE('dezoom.inc'), ONCE
  INCLUDE('cjson.inc'), ONCE
  INCLUDE('cjsonpath.inc'), ONCE

  MAP
    FindItemByHost(cJSON jArray, STRING pHost), *cJSON, PRIVATE
    INCLUDE('printf.inc'), ONCE
  END

FindItemByHost                PROCEDURE(cJSON jArray, STRING pHost)
jItem                           &cJSON, AUTO
jpResult                        TCJsonPathResultAccumulator
  CODE
  IF jArray.FindPathContext(printf('$[?(@.host = %S)]', pHost), jpResult) > 0
    jItem &= jpResult.GetObject(1)
  ELSE
    jItem &= NULL
  END
  RETURN jItem

TZoomFactorManager.Construct  PROCEDURE()
  CODE
  
TZoomFactorManager.Destruct   PROCEDURE()
  CODE
  SELF.Kill()
  
TZoomFactorManager.Init       PROCEDURE(STRING pFileName)
jParser                         cJSONFactory
  CODE
  SELF.Reset()
  SELF.sFileName = pFileName
  SELF.jRootArray &= jParser.ParseFile(SELF.sFileName)
  IF NOT SELF.jRootArray &= NULL
    !- successfully loaded
    IF SELF.jRootArray.IsArray()
      RETURN TRUE
    ELSE
      RETURN FALSE
    END
  ELSE
    !- create an empty array
    SELF.jRootArray &= json::CreateArray()
    RETURN TRUE
  END
    
TZoomFactorManager.Kill       PROCEDURE()
  CODE
  SELF.Save()
  SELF.Reset()

TZoomFactorManager.Reset      PROCEDURE()
  CODE
  IF NOT SELF.jRootArray &= NULL
    SELF.jRootArray.Delete()
  END

TZoomFactorManager.Save       PROCEDURE()
  CODE
  IF SELF.sFileName AND NOT SELF.jRootArray &= NULL
    RETURN json::SaveFile(SELF.sFileName, SELF.jRootArray.ToString(TRUE))
  END
  RETURN FALSE

TZoomFactorManager.GetZoomFactor  PROCEDURE(STRING pHost)
jItem                               &cJSON, AUTO
jZoomFactor                         &cJSON, AUTO
  CODE
  IF NOT pHost OR SELF.jRootArray &= NULL
    RETURN 0
  END
  
  jItem &= SELF.jRootArray.FindItemByHost(pHost)
  IF NOT jItem &= NULL
    jZoomFactor &= jItem.GetObjectItem('zoomfactor')
    IF NOT jZoomFactor &= NULL
      RETURN jZoomFactor.GetNumberValue()
    END
  END
  RETURN 0
  
TZoomFactorManager.SetZoomFactor  PROCEDURE(STRING pHost, REAL pZoomFactor)
jItem                               &cJSON, AUTO
jZoomFactor                         &cJSON, AUTO
  CODE
  IF NOT pHost OR SELF.jRootArray &= NULL
    RETURN FALSE
  END
  
  jItem &= SELF.jRootArray.FindItemByHost(pHost)
  IF NOT jItem &= NULL
    !- host found, add or replace zoom factor.
    jZoomFactor &= jItem.GetObjectItem('zoomfactor')
    IF NOT jZoomFactor &= NULL
      jZoomFactor.SetNumberValue(pZoomFactor)
    ELSE
      jItem.AddNumberToObject('zoomFactor', pZoomFactor)
    END
  ELSE
    !- host not found, let's create it.
    jItem &= json::CreateObject()
    jItem.AddStringToObject('host', pHost)
    jItem.AddNumberToObject('zoomFactor', pZoomFactor)
    SELF.jRootArray.AddItemToArray(jItem)
  END

  RETURN TRUE
