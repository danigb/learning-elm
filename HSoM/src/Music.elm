module Music exposing ( PitchClass(..), Primitive(..), Music(..), Control(..),
  note, rest, tempo, absPitch )

{-|
My attempt to port HSoM to elm

2.1 Preliminaries

Octave, PitchClass, Pitch, Dur

# 2.2 Notes, Music, and Polymorphism

@docs PitchClass, Primitive, Music, Control

# 2.3 Convenient Auxiliary Functions

@docs note, rest, tempo

# 2.4

@docs absPitch

-}


{-- 2.1 Preliminaries --}

type alias Octave = Int

{-| PitchClass -}
type PitchClass =
      Cff| Cf  | C | Dff | Cs | Df | Css | D | Eff | Ds
   |  Ef | Fff | Dss | E | Ff | Es | F | Gff | Ess | Fs
   |  Gf | Fss | G | Aff | Gs | Af | Gss | A | Bff | As
   |  Bf | Ass | B | Bs | Bss

type alias Pitch = (PitchClass, Octave)
type alias Dur = Float

{-- 2.2 Notes, Music, and Polymorphism --}

{-| Primitive -}
type Primitive a =
  Note Dur a
  | Rest Dur

{-| Music -}
type Music a =
  Prim (Primitive a)
  | Seq (Music a) (Music a)
  | Par (Music a) (Music a)
  | Modify Control (Music a)

{-| Control -}
type Control = Tempo Float

{-- 2.3 Convenient Auxiliary Functions --}

{-| note -}
note : Dur -> a -> Music a
note d p =
  Prim (Note d p)

{-| rest -}
rest : Dur -> Music a
rest d =
  Prim (Rest d)

{-| tempo -}
tempo : Dur -> Music a -> Music a
tempo r m =
  Modify (Tempo r) m

{- 2.4 Absolute Pitches -}

{- Treating pitches simply as integers is useful in many settings, so Euterpea
uses a type synonym to define the concept of an “absolute pitch: -}

{- NOTE: I would prefer to use a Float -}

type alias AbsPitch = Int

{-| The absolute pitch of a Pitch -}
absPitch : Pitch -> AbsPitch
absPitch (pc, o) =
  12 * o + pcToInt pc

pcToInt pc  = case pc of
  Cff  -> -2
  Cf  -> -1
  C  -> 0
  Cs  -> 1
  Css  -> 2
  Dff  -> 0
  Df  -> 1
  D  -> 2
  Ds  -> 3
  Dss  -> 4
  Eff  -> 2
  Ef  -> 3
  E  -> 4
  Es  -> 5
  Ess  -> 6
  Fff  -> 3
  Ff  -> 4
  F  -> 5
  Fs  -> 6
  Fss  -> 7
  Gff  -> 5
  Gf  -> 6
  G  -> 7
  Gs  -> 8
  Gss  -> 9
  Aff  -> 7
  Af  -> 8
  A  -> 9
  As  -> 10
  Ass  -> 11
  Bff  -> 9
  Bf  -> 10
  B  -> 11
  Bs  -> 12
  Bss  -> 13
