# object.bqn

`object.bqn` is a library that brings prototype-based object oriented programming to [BQN](https://mlochbaum.github.io/BQN/index.html).

## Examples

For full details on available features, please refer to the doc comments in the [source code](https://github.com/MX-Futhark/object.bqn/blob/master/object.bqn).

* Empty object:
```bqn
⟨Object⟩ ← •Import "object.bqn"

o ← Object@
o.Entries@ # → ⟨⟩
```

* Object with initial properties:
```bqn
⟨Object⟩ ← •Import "object.bqn"

o ← Object ⟨"a"‿1, "b"‿2⟩
o.Entries@ # → ⟨ ⟨ "a" 1 ⟩ ⟨ "b" 2 ⟩ ⟩
```

* `Has`/`Get`/`Set`/`Delete`:
```bqn
⟨Object⟩ ← •Import "object.bqn"

o ← Object@
o.Has "key" # → 0
o.Set "key"‿"value"
o.Get "key" # → "value"
o.Delete "key"
o.Has "key" # → 0
```

* Methods:
```bqn
⟨Object⟩ ← •Import "object.bqn"

milo ← Object ⟨
  "name"‿"Milo"
  "bark"‿{self 𝕊 times:
    (self.Get "name") ∾ " says:" ∾ {𝕩 ∾ " woof"}⍟times ""
  }
⟩

•Out milo.Send⟜"bark" 3 # → "Milo says: woof woof woof"
```

* Prototype inheritance:
```bqn
⟨Object⟩ ← •Import "object.bqn"

dog ← Object ⟨
  "name"‿"Some dog"
  "bark"‿{self 𝕊 times:
    (self.Get "name") ∾ " says:" ∾ {𝕩 ∾ " woof"}⍟times ""
  }
⟩
milo ← Object ⟨"name"‿"Milo"⟩
milo.SetPrototype dog

•Out dog.Send⟜"bark" 3 # → "Some dog says: woof woof woof"
•Out milo.Send⟜"bark" 3 # → "Milo says: woof woof woof"
```

* Simulating classes:
```bqn
⟨Object⟩ ← •Import "object.bqn"

# Static members:
animal ← Object ⟨"class name"‿"animal"⟩
# Class constructor:
animal.SetInitializer {{self 𝕊 name:
  self.Set "name"‿name
}}
# Instance members:
animal.SetInstancePrototype Object ⟨
  "name"‿@
  "cry"‿"**silence**"
  "perform cry"‿{self 𝕊 times:
    (self.Get "name") ∾ " says:" ∾ {𝕩 ∾ " " ∾ self.Get "cry"}⍟times ""
  }
⟩

dog ← Object ⟨"class name"‿"dog"⟩
dog.SetInitializer {{self 𝕊 name:
  self⊸animal.initializer name
}}
# Inheritance:
dog.SetInstancePrototype {𝕩.SetPrototype animal.instancePrototype} Object ⟨
  "cry"‿"woof"
  "perform cry"‿{self 𝕊 times:
    (milo.Send⟜"bark only" times) ∾ ", then growls"
  }
  "bark only"‿{self 𝕊 times:
    self⊸(animal.instancePrototype.Get "perform cry") times
  }
⟩

milo ← dog.New "Milo"

•Out milo.Send⟜"perform cry" 3 # → "Milo says: woof woof woof, then growls"
```
