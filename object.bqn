minBuckets ← 8
maxBuckets ← 2 ⋆ 16
minLoadFactor ← 0.25
maxLoadFactor ← 0.9

## Creates an object following prototype-based OO conventions.
## Param 𝕩: ⟨string‿any, ...⟩ | @ - Optional list of initial properties as key/value pairs.
## Returns: object
Object ⇐ {𝕊:
  self ← {
    buckets ← minBuckets ⥊ ⟨⟨⟩⟩

    ## Prototype of the object.
    ## Type: object | @
    prototype ⇐ @

    ## Initializer called alongside New.
    ## Type: (self 𝕊 any) => void
    initializer ⇐ {{self 𝕊 arg: @}}

    ## Prototype of objects produced by New.
    ## Type: object | @
    instancePrototype ⇐ @

    ## Tells if the given property can be found in the prototype chain of the object.
    ## Param 𝕩: string
    ## Returns: boolean
    Has ⇐ {𝕊 key:
      item ← RawGetOwn key
      {
        ShouldUsePrototype item ? prototype.Has key ;
        item ≢ ⟨⟩
      }
    }

    ## Tells if the given property is known by the object, not taking its prototype chain into account.
    ## Param 𝕩: string
    ## Returns: boolean
    HasOwn ⇐ {𝕊 key:
      ⟨⟩ ≢ RawGetOwn key
    }

    ## Retrieves the value of a property by its name in the prototype chain.
    ## Param 𝕩: string
    ## Returns: any
    ## Throws: "Unknown key" - The property could not be found in the prototype chain of the object.
    Get ⇐ {𝕊 key:
      item ← RawGetOwn key
      {
        ShouldUsePrototype item ? prototype.Get key ;
        "Unknown key" ! item ≢ ⟨⟩
        1⊑⊑item
      }
    }

    ## Sets or changes a property of the object. Shadows the prototype property of the same name if it exists.
    ## Param 𝕩: string‿any - The name of the property as the first element, the associated value as the second one.
    ## Returns: self
    Set ⇐ {𝕊 key‿value:
      HasOwn◶⊢‿RawDelete key
      RawSet key‿value
      Resize@
      self
    }

    ## Removes a property by its name.
    ## Param 𝕩: string
    ## Returns: self
    ## Throws: "Unknown own key" - The property does not exist, not taking the prototype chain into account.
    Delete ⇐ {𝕊 key:
      item ← RawGetOwn key
      "Unknown own key" ! item ≢ ⟨⟩
      RawDelete key
      Resize@
      self
    }

    ## All key/value pairs in the object in no particular order, not taking its prototype chain into account.
    ## Param 𝕩: @
    ## Returns: ⟨string‿any, ...⟩
    Entries ⇐ {𝕊:
      {𝕨 ∾ 𝕩}´buckets
    }

    ## All property names in the object in no particular order, not taking its prototype chain into account.
    ## Param 𝕩: @
    ## Returns: ⟨string, ...⟩
    Keys ⇐ {𝕊:
      {⊑𝕩}¨Entries@
    }

    ## Sends a message to the object, which will be handled by a method,
    ## i.e. a function property of the form (self 𝕊 any) => any.
    ## `arg o.Send⟜"method"` and `o.Send⟜"method" arg` are sugar for `o⊸(o.Get "method") arg`.
    ## Param 𝕨: arg - Left argument of the method.
    ## Param 𝕩: string - Name of the method.
    ## Returns: (𝕊 any) => any
    Send ⇐ {arg 𝕊 key:
      self⊸(Get key) arg
    }

    ## Creates an instance of the current object type.
    ## Sets the current `instancePrototype` as its `prototype` and calls the current `initializer` with the result.
    ## Param 𝕩: any - Argument to forward to the left argument of the initializer.
    ## Returns: object - The newly created instance.
    New ⇐ {𝕊 arg:
      instance ← Object@
      instance.SetPrototype instancePrototype
      instance⊸Initializer arg
      instance
    }

    ## Tells if the object is an instance of the given object type.
    ## Param 𝕩: object
    ## Returns: boolean
    InstanceOf ⇐ {𝕊 type:
      (prototype ≡ type.instancePrototype) ∨ {
        prototype ≡ @ ? 0 ;
        prototype.InstanceOf type
      }
    }

    ## Changes the prototype of the object.
    ## Param 𝕩: object
    ## Returns: self
    SetPrototype ⇐ {𝕊 newPrototype:
      prototype ↩ newPrototype
      self
    }

    ## Changes the initializer.
    ## Param 𝕩: (self 𝕊 any) => void
    ## Returns: self
    SetInitializer ⇐ {𝕊 newInitializer:
      initializer ↩ newInitializer
      self
    }

    ## Changes the prototype of objects produced by New.
    ## Param 𝕩: object
    ## Returns: self
    SetInstancePrototype ⇐ {𝕊 newInstancePrototype:
      instancePrototype ↩ newInstancePrototype
      self
    }

    RawGetOwn ← {𝕊 key:
      key ≡_filterBucket buckets ⊑˜ BucketIndex key
    }

    RawSet ← {𝕊 key‿value:
      ind ← BucketIndex key
      buckets (⟨key‿value⟩ ∾˜ ind ⊑ buckets)⌾(ind⊸⊑)↩
    }

    RawDelete ← {𝕊 key:
      buckets {key ≢_filterBucket 𝕩}¨↩
    }

    Resize ← {𝕊:
      entriesBackup ← Entries@
      loadFactor ← entriesBackup ÷○≠ buckets
      lengthFactor ← {
        (minBuckets < ≠buckets) ∧ loadFactor ≤ minLoadFactor ? 0.5 ;
        (maxBuckets > ≠buckets) ∧ loadFactor ≥ maxLoadFactor ? 2 ; 1
      }
      lengthFactor ≠ 1 ?
      buckets ↩ lengthFactor × (≠buckets) ⥊ ⟨⟨⟩⟩
      RawSet¨entriesBackup ; @
    }

    ShouldUsePrototype ← {𝕊 item:
      (item ≡ ⟨⟩) ∧ prototype ≢ @
    }

    BucketIndex ← {𝕊 key:
      (≠buckets) | Djb2 key
    }

    _filterBucket ← {key compare _𝕣 bucket:
      {key Compare ⊑𝕩}¨⊸/bucket
    }
  }

  self.Set¨(𝕩 ≡ @) ⊑ ⟨𝕩, ⟨⟩⟩

  self
}

Djb2 ← { 𝕊 str:
  "Cannot hash non-string value" ! str =○•Type ""

  # http://www.cse.yorku.ca/~oz/hash.html
  5381 {maxBuckets | 𝕨 + 𝕩 × 33}´⌽{𝕩 - @}¨str
}
