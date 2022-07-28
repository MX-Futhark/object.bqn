⟨Object⟩ ← •Import "object.bqn"

{𝕊 testName‿testCase:
  •Out testName
  TestCase@
  •Out "  OK"
}¨⟨
  "create object"‿{𝕊:
    ! {Object@ ⋄ 1}
    ! {Object ⟨"foo"‿0, "bar"‿1⟩ ⋄ 1}
  }

  "set prototype"‿{𝕊:
    o ← Object@
    proto ← Object ⟨"foo"‿0, "bar"‿1⟩

    result ← o.SetPrototype proto

    ! o.prototype ≡ proto
    ! result ≡ o
  }

  "set instance prototype"‿{𝕊:
    o ← Object@
    instanceProto ← Object ⟨"foo"‿0, "bar"‿1⟩

    result ← o.SetInstancePrototype instanceProto

    ! o.instancePrototype ≡ instanceProto
    ! result ≡ o
  }

  "set initializer"‿{𝕊:
    o ← Object ⟨"foo"‿0, "bar"‿1⟩
    called ← @

    result ← o.SetInitializer {{self 𝕊 arg:
      called ↩ self‿arg
    }}
    o⊸o.initializer "a"

    ! called ≡ o‿"a"
    ! result ≡ o
  }

  "entries"‿{𝕊:
    entries ← ((Object ⟨"foo"‿0, "bar"‿1⟩).SetPrototype Object ⟨"baz"‿2⟩).Entries@

    ! (≠entries) = 2
    ! (≠entries) > ⊑(entries ⊐ ⟨"foo"‿0⟩)
    ! (≠entries) > ⊑(entries ⊐ ⟨"bar"‿1⟩)
  }

  "keys"‿{𝕊:
    keys ← ((Object ⟨"foo"‿0, "bar"‿1⟩).SetPrototype Object ⟨"baz"‿2⟩).Keys@

    ! (≠keys) = 2
    ! (≠keys) > ⊑(keys ⊐ ⟨"foo"⟩)
    ! (≠keys) > ⊑(keys ⊐ ⟨"bar"⟩)
  }

  "has own"‿{𝕊:
    ! ¬(Object@).HasOwn "foo"
    ! (Object ⟨"foo"‿0⟩).HasOwn "foo"
    ! ¬((Object@).SetPrototype Object ⟨"foo"‿0⟩).HasOwn "foo"
  }

  "has"‿{𝕊:
    ! ¬(Object@).Has "foo"
    ! (Object ⟨"foo"‿0⟩).Has "foo"
    ! ((Object@).SetPrototype Object ⟨"foo"‿0⟩).Has "foo"
  }

  "get"‿{𝕊:
    ! {𝕊: (Object@).Get "foo" ⋄ 0}⎊{𝕊: 1}@
    ! 0 = (Object ⟨"foo"‿0⟩).Get "foo"
    ! 0 = ((Object@).SetPrototype Object ⟨"foo"‿0⟩).Get "foo"
    ! 0 = ((Object ⟨"foo"‿0⟩).SetPrototype Object ⟨"foo"‿1⟩).Get "foo"
  }

  "set"‿{𝕊:
    proto ← Object ⟨"a"‿¯1⟩
    o ← (Object@).SetPrototype proto

    # Set more than 8 properties to trigger a resize
    o.Set¨⟨"a"‿0, "b"‿1, "c"‿2, "d"‿3, "e"‿4, "f"‿5, "g"‿6, "h"‿7, "i"‿8⟩
    o.Set "i"‿88

    ! 0‿1‿2‿3‿4‿5‿6‿7‿88 ≡ o.Get¨"a"‿"b"‿"c"‿"d"‿"e"‿"f"‿"g"‿"h"‿"i"
    ! ¯1 = proto.Get "a"
    ! {𝕊: o.Set 0‿"bad key" ⋄ 0}⎊{𝕊: 1}@
  }

  "delete"‿{𝕊:
    proto ← Object ⟨"foo"‿0⟩
    o ← (Object ⟨"foo"‿1⟩).SetPrototype proto

    o.Delete "foo"

    ! ¬o.HasOwn "foo"
    ! proto.HasOwn "foo"
    ! {𝕊: o.Delete "foo" ⋄ 0}⎊{𝕊: 1}@
  }

  "send"‿{𝕊:
    called ← ⟨⟩
    MakeMethodEntry ← {𝕊 name:
      name‿{self 𝕊 arg:
        called ↩ called ∾ ⟨name‿self‿arg⟩
      }
    }
    proto ← Object ⟨MakeMethodEntry "bar"⟩
    o ← (Object ⟨MakeMethodEntry "foo"⟩).SetPrototype proto

    o.Send⟜"foo" 0
    o.Send⟜"bar" 1

    ! called ≡ ⟨"foo"‿o‿0, "bar"‿o‿1⟩
  }

  "new"‿{𝕊:
    called ← @
    class ← Object@
    class.SetInstancePrototype ⟨"foo"‿0⟩
    class.SetInitializer {{self 𝕊 name:
      called ↩ self‿name
    }}

    result ← class.New "bar"

    ! called ≡ result‿"bar"
    ! result.prototype ≡ class.instancePrototype
  }

  "instance of"‿{𝕊:
    GetClass ← {𝕊:
      class ← Object@
      class.SetInstancePrototype Object@
    }
    parent ← GetClass@
    child ← GetClass@
    child.instancePrototype.SetPrototype parent.instancePrototype
    unrelated ← GetClass@
    result ← child.New@

    ! result.InstanceOf child
    ! result.InstanceOf parent
    ! ¬result.InstanceOf unrelated
  }
⟩
•Out "All tests passed"
