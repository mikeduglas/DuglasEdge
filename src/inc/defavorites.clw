!* Duglas Edge favorites

  MEMBER

  INCLUDE('defavorites.inc'), ONCE
  INCLUDE('winapi.inc'), ONCE

  MAP
    INCLUDE('printf.inc'), ONCE
  END


TFavorites.Construct          PROCEDURE()
  CODE
  
TFavorites.Destruct           PROCEDURE()
  CODE
  SELF.Reset()
  
TFavorites.Reset              PROCEDURE()
  CODE
  IF NOT SELF.jFavorites &= NULL
    SELF.jFavorites.Delete()
  END

TFavorites.SetFile            PROCEDURE(STRING pFileName)
  CODE
  SELF.sFileName = pFileName
  
TFavorites.Load               PROCEDURE()
  CODE
  SELF.Reset()
  SELF.jFavorites &= SELF.ParseFile(SELF.sFileName)
  IF NOT SELF.jFavorites &= NULL
    !- successfully loaded
    IF SELF.jFavorites.IsArray()
      RETURN TRUE
    ELSE
      RETURN FALSE
    END
  ELSE
    !- create an empty array
    SELF.jFavorites &= json::CreateArray()
    RETURN TRUE
  END
  
TFavorites.Save               PROCEDURE()
df                              TDiskFile
  CODE
  IF NOT SELF.jFavorites &= NULL
    RETURN df.SaveFile(SELF.sFileName, SELF.jFavorites.ToString(TRUE))
  END
  RETURN FALSE

TFavorites.AddSite            PROCEDURE(STRING pUri, STRING pTitle, STRING pfaviconFile)
jItem                           &cJSON
jValue                          &cJSON
i                               LONG, AUTO
favIcon                         &STRING
  CODE
  IF NOT SELF.jFavorites &= NULL
    favIcon &= json::LoadFile(pfaviconFile)
    
    i = SELF.IndexOf(pUri)
    IF i = 0
      !- add new item
      jItem &= json::CreateObject()
      jItem.AddStringToObject('title', pTitle)
      jItem.AddStringToObject('uri', pUri)
      jItem.AddStringToObject('favicon', printf('%v', favIcon))
      SELF.jFavorites.AddItemToArray(jItem)
    ELSE
      !- replace existing
      jItem &= SELF.jFavorites.GetArrayItem(i)
      jValue &= jItem.GetObjectItem('title')
      jValue.SetStringValue(pTitle)
      jValue &= jItem.GetObjectItem('favicon')
      jValue.SetStringValue(printf('%v', favIcon))
    END
    
    DISPOSE(favIcon)
    RETURN TRUE
  END
  RETURN FALSE

TFavorites.AddSite            PROCEDURE(typFavoriteInfo pInfo)
  CODE
  RETURN SELF.AddSite(pInfo.uri, pInfo.title, pInfo.favicon)

TFavorites.RemoveSite         PROCEDURE(STRING pUri)
i                               LONG, AUTO
  CODE
  i = SELF.IndexOf(pUri)
  IF i
    SELF.jFavorites.DeleteItemFromArray(i)
    RETURN TRUE
  END
  RETURN FALSE

TFavorites.IndexOf            PROCEDURE(STRING pUri)
jItem                           &cJSON
i                               LONG, AUTO
  CODE
  IF pUri
    IF NOT SELF.jFavorites &= NULL
      LOOP i=1 TO SELF.jFavorites.GetArraySize()
        jItem &= SELF.jFavorites.GetArrayItem(i)
        IF NOT jItem &= NULL
          IF CLIP(jItem.GetValue('uri')) = pUri
            !- found an item with specified uri
            RETURN i
          END
        END
      END
    END
  END
  RETURN 0

TFavorites.GetByIndex         PROCEDURE(LONG pIndex, *STRING pUri, *STRING pTitle, *STRING pFavicon)
jItem                           &cJSON
  CODE
  IF NOT SELF.jFavorites &= NULL
    jItem &= SELF.jFavorites.GetArrayItem(pIndex)
    IF NOT jItem &= NULL
      pUri = jItem.GetValue('uri')
      pTitle = jItem.GetValue('title')
      pFavicon = jItem.GetValue('favicon')
      RETURN TRUE
    ELSE
      printd('TFavorites.GetByIndex(%i) failed: index out of range.', pIndex)
    END
  END
  RETURN FALSE

TFavorites.GetByIndex         PROCEDURE(LONG pIndex, *typFavoriteInfo pInfo)
  CODE
  RETURN SELF.GetByIndex(pIndex, pInfo.uri, pInfo.title, pInfo.favicon)
  
TFavorites.GetAll             PROCEDURE(*typFavoriteInfos pInfos)
i                               LONG, AUTO
  CODE
  FREE(pInfos)
  IF NOT SELF.jFavorites &= NULL
    LOOP i=1 TO SELF.jFavorites.GetArraySize()
      CLEAR(pInfos)
      IF SELF.GetByIndex(i, pInfos)
        ADD(pInfos)
      END
    END
    RETURN TRUE
  END
  RETURN FALSE
 