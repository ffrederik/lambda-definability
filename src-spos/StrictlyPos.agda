{-# OPTIONS --postfix-projections #-}
{-# OPTIONS --rewriting #-}

module StrictlyPos where

open import Library

subst-trans : ∀ {A : Set}{P : A → Set} {x y z : A} →
                (p : x ≡ y) → (q : y ≡ z) → (xs : P x) →
                  subst P (trans p q) xs ≡ subst P q (subst P p xs)
subst-trans refl refl xs = refl

-- _S_trictly _P_ositive functors have a well-behaved support

_→̇_ : {I : Set} (A B : I → Set) → Set
A →̇ B = ∀{i} (u : A i) → B i

record SPos (I : Set) : Set₁ where
  field
    F    : (ρ : I → Set) → Set
    mon  : ∀{ρ ρ'} (ρ→ρ' : ρ →̇ ρ') (x : F ρ) → F ρ'

    Supp : ∀{ρ} (x : F ρ) (i : I) → Set

    mon-Supp : ∀{ρ ρ'} (ρ→ρ' : ρ →̇ ρ') (x : F ρ) → Supp (mon ρ→ρ' x) →̇ Supp x

    necc : ∀{ρ} (x : F ρ) → Supp x →̇ ρ
    suff : ∀{ρ} (x : F ρ) → F (Supp x)

    mon-Supp-suff : ∀{ρ ρ'} (x : F ρ) (supp→ρ' : Supp x →̇ ρ') → Supp (mon supp→ρ' (suff x)) →̇ Supp x


    -- Laws

    mon-id : ∀{ρ}  → mon {ρ} id ≡ id
    mon-comp : ∀ {ρ₁ ρ₂ ρ₃} {ρ₂→ρ₃ : ρ₂ →̇  ρ₃} {ρ₁→ρ₂ : ρ₁ →̇  ρ₂} →
            ∀ x → mon {ρ₂} ρ₂→ρ₃ (mon ρ₁→ρ₂ x) ≡ mon (ρ₂→ρ₃ ∘ ρ₁→ρ₂) x

    mon-Supp-id : ∀{ρ} → mon-Supp {ρ} id ≡ λ x {i} → subst (λ f → Supp (f x) i) (mon-id {ρ})

    -- mon-Supp-id : ∀{ρ} (x : F ρ) →
    --   (λ{i} → mon-Supp {ρ} id x {i}) ≡  λ{i} → subst (λ f → Supp (f x) i) (mon-id {ρ})

    necc-suff : ∀ {ρ} (x : F ρ) →  mon (necc x) (suff x) ≡ x

{-

    mon-Supp-comp : ∀ {x y z} {g : y → z} {f : x → y} →
                 ∀ xs → (p : Supp (mon g (mon f xs)))
                 → mon-Supp f xs (mon-Supp g (mon f xs) p)
                 ≡ mon-Supp (g ∘ f) xs (subst Supp (mon-comp xs) p)


    necc-nat : ∀{ρ ρ' : Set} → (f : ρ → ρ') → ∀ (xs : F ρ) (p : Supp (mon f xs))
               → necc (mon f xs) p ≡ f (necc xs (mon-Supp f xs p))

    suff-nat : ∀{ρ ρ'} → (f : ρ → ρ') → ∀ (xs : F ρ)
               → mon (mon-Supp f xs) (suff (mon f xs)) ≡ suff xs


    suff-necc : ∀ {ρ} {x : F ρ} (p : Supp _)
                → necc (suff x) (mon-Supp (necc x) (suff x) p)
                ≡ subst Supp necc-suff p
-}
open SPos

-- Constructions on SPos

SP = SPos ∘ Fin

-- Variable

δ-diag : ∀{n} (i : Fin n) → δ i i ≡ ⊤
δ-diag zero = refl
δ-diag (suc i) with i ≟ i
δ-diag (suc i) | yes p = refl
δ-diag (suc i) | no ¬p = case ¬p refl of λ()

-- {-# REWRITE δ-diag #-}  -- illegal

-- Type variables (projections)

-- Var could be generalized to decidable I

Var : ∀{n} (i : Fin n) → SP n
Var i .F ρ = ρ i
Var i .mon ρ→ρ' x = ρ→ρ' x
Var i .Supp _ j = δ i j
Var i .mon-Supp ρ→ρ' _ = id
Var i .necc x {j} u with i ≟ j
Var i .necc x {.i} _ | yes refl = x
Var i .necc x {j} () | no _
Var i .suff = _ -- rewrite δ-diag i = _
Var i .mon-Supp-suff x supp→ρ' u = u
Var i .mon-id = refl
Var i .mon-comp x = refl
Var i .mon-Supp-id {ρ} = refl
Var i .necc-suff x = refl

-- Constant types have empty support

Const : ∀ (A : Set) {I} → SPos I
Const A .F _ = A
Const A .mon _ = id
Const A .Supp _ _ = ⊥
Const A .mon-Supp _ _ = id
Const A .necc _ ()
Const A .suff = id
Const A .mon-Supp-suff _ _ = id
Const A .mon-id = refl
Const A .mon-comp x = refl
Const A .mon-Supp-id = refl
Const A .necc-suff x = refl

Empty = Const ⊥
Unit  = Const ⊤

Fun : ∀ (A : Set) {I} (B : SPos I) → SPos I
Fun A B .F ρ                     = A → B .F ρ
Fun A B .mon ρ→ρ' f a            = B .mon ρ→ρ' (f a)
Fun A B .Supp f i                = ∃ λ (a : A) → B .Supp (f a) i
Fun A B .mon-Supp ρ→ρ' f (a , u) = a , B .mon-Supp ρ→ρ' (f a) u
Fun A B .necc f (a , u)          = B .necc (f a) u
Fun A B .suff f a                = B .mon (a ,_) (B .suff (f a))
Fun A B .mon-Supp-suff f supp→ρ' (a , u) = a , B .mon-Supp-suff (f a) (λ{i} u → supp→ρ' (a , u)) {!u!}
Fun A B .mon-id                  = funExt λ f → funExt λ a → cong-app (B .mon-id) (f a)
Fun A B .mon-comp f              = funExt λ a → B .mon-comp (f a)
-- Fun A B .mon-Supp-id {ρ} f = funExtH λ{i} →  funExt λ p → {! aux (B .mon {ρ} id) (B .mon-id {ρ})!}
--   where
--   aux : ∀ {A I} {B : SPos I} {ρ : I → Set} {f : A → B .F ρ} {i : I}
--         {p : ∃ (λ a → B .Supp (B .mon (λ {i₁} → id) (f a)) i)}
--         (w : B .F ρ → B .F ρ) (w₁ : w ≡ (λ x → x)) →
--       (p .proj₁ , B .mon-Supp (λ {i₁} x → x) (f (p .proj₁)) (p .proj₂)) ≡
--       subst (λ f₁ → Σ A (λ a → B .Supp (f₁ f a) i))
--       (funExt (λ f₁ → funExt (λ a → cong-app w₁ (f₁ a)))) p
--   aux = ?
  -- aux : ∀ {A I} {B : SPos I} {ρ : I → Set} {f : A → B .F ρ} {i : I}
  --       {a : A} {u : B .Supp (B .mon (λ {i₁} → id) (f a)) i}
  --       (w : B .F ρ → B .F ρ) (w₁ : w ≡ (λ x → x)) →
  --     (a , B .mon-Supp (λ {i₁} x → x) (f a) u) ≡
  --     subst (λ f₁ → Σ A (λ a₁ → B .Supp (f₁ f a₁) i))
  --     (funExt (λ f₁ → funExt (λ a₁ → cong-app w₁ (f₁ a₁)))) (a , u)
  -- aux = ?
  -- aux : ∀ {i}
  --       {a : A}
  --       (w : B .F ρ → B .F ρ)  {u : B .Supp (w (f a)) i} (w₁ : w ≡ id) →
  --     (a , B .mon-Supp id (f a) u) ≡
  --     subst (λ f₁ → Σ A (λ a₁ → B .Supp (f₁ f a₁) i))
  --     (funExt (λ f₁ → funExt (λ a₁ → cong-app w₁ (f₁ a₁)))) (a , u)
  -- aux = ?
Fun A B .mon-Supp-id {ρ} = funExt λ f → funExtH λ{i} →  funExt λ{ (a , u) → {! aux (B .mon {ρ} id) (B .mon-id {ρ}) (B .mon-Supp {ρ} id) (B .mon-Supp-id {ρ} (f a))!} }
  -- where
  -- aux : ∀ {A I} {B : SPos I} {ρ : I → Set} {f : A → B .F ρ} {i : I}
  --       {a : A} {u : B .Supp (B .mon (λ {i₁} → id) (f a)) i}
  --       (w : B .F ρ → B .F ρ) (w₁ : w ≡ (λ x → x))
  --       (w₂
  --        : (x : B .F ρ) {i : I} → B .Supp (w x) i → B .Supp x i) →
  --     (λ{i₁} → w₂ (f a) {i₁}) ≡ (λ {i₁} → subst (λ f₁ → B .Supp (f₁ (f a)) i₁) w₁) →
  --     (a , w₂ (f a) u) ≡
  --     subst (λ f₁ → Σ A (λ a₁ → B .Supp (f₁ f a₁) i))
  --     (funExt (λ f₁ → funExt (λ a₁ → cong-app w₁ (f₁ a₁)))) (a , u)
  -- aux = ?
-- Fun A B .mon-Supp-id {ρ} f = {! aux (B .mon {ρ} id) (B .mon-id {ρ}) (Fun A B .mon-Supp {ρ} id)!}
-- Fun A B .mon-Supp-id {ρ} f with B .mon {ρ} id | B .mon-id {ρ} | B .mon-Supp {ρ} id
-- ... | z | eq | u = {!eq!}
-- Fun A B .mon-Supp-id {ρ} f rewrite B .mon-id {ρ} = {!!}
Fun A B .necc-suff f = funExt λ a →
  begin
  B .mon (Fun A B .necc f) (B .mon (a ,_) (B .suff (f a)))  ≡⟨ B .mon-comp (B .suff (f a)) ⟩
  B .mon (Fun A B .necc f ∘ (a ,_)) (B .suff (f a))         ≡⟨⟩
  B .mon (B .necc (f a)) (B .suff (f a))                    ≡⟨ B .necc-suff (f a) ⟩
  f a                                                       ∎ where open ≡-Reasoning -- {!B .necc-suff!}

Prod : ∀{I} (A B : SPos I) → SPos I
Prod A B .F ρ                            = A .F ρ × B .F ρ
Prod A B .mon ρ→ρ' (a , b)               = A .mon ρ→ρ' a , B .mon ρ→ρ' b
Prod A B .Supp (a , b) i                 = A .Supp a i ⊎ B .Supp b i
Prod A B .mon-Supp ρ→ρ' (a , b)          = A .mon-Supp ρ→ρ' a +̇ B .mon-Supp ρ→ρ' b
Prod A B .necc (a , b)                   = [ A .necc a , B .necc b ]
Prod A B .suff (a , b)                   = A .mon inj₁ (A .suff a) , B .mon inj₂ (B .suff b)
Prod A B .mon-Supp-suff (a , b) supp→ρ' (inj₁ u) = inj₁ (A .mon-Supp-suff a (λ{i} u' → supp→ρ' (inj₁ u')) {!!})
Prod A B .mon-Supp-suff (a , b) supp→ρ' (inj₂ u) = {!!}
Prod A B .mon-id                         =  cong₂ _×̇_ (A .mon-id) (B .mon-id)
Prod A B .mon-comp (a , b) = cong₂ _,_ (A .mon-comp a) (B .mon-comp b)
Prod A B .mon-Supp-id {ρ} = funExt λ p → funExtH λ{i} → funExt (aux p {i})
  where
  aux : ∀ (p : Prod A B .F ρ) {i} (u : A .Supp (A .mon id (p .proj₁)) i ⊎ B .Supp (B .mon id (p .proj₂)) i) →
      Prod A B .mon-Supp id p u ≡
      subst (λ f → A .Supp (f p .proj₁) i ⊎ B .Supp (f p .proj₂) i)
      (cong₂ _×̇_ (A .mon-id) (B .mon-id)) u
  aux (a , b) (inj₁ u) rewrite A .mon-Supp-id {ρ} | A .mon-id {ρ} | B .mon-id {ρ} = refl
  aux (a , b) (inj₂ u) rewrite B .mon-Supp-id {ρ} | A .mon-id {ρ} | B .mon-id {ρ} = refl
Prod A B .necc-suff (a , b) = cong₂ _,_
  (trans (A .mon-comp (A .suff a)) (A .necc-suff a))
  (trans (B .mon-comp (B .suff b)) (B .necc-suff b))

{-# TERMINATING #-}
Sum : ∀{I} (A B : SPos I) → SPos I
Sum A B .F ρ                      = A .F ρ ⊎ B .F ρ
Sum A B .mon ρ→ρ'                 = A .mon ρ→ρ' +̇ B .mon ρ→ρ'
Sum A B .Supp {ρ}                 = [ A .Supp {ρ} , B .Supp {ρ} ]
Sum A B .mon-Supp ρ→ρ'            = [ A .mon-Supp ρ→ρ' , B .mon-Supp ρ→ρ' ]
Sum A B .necc {ρ}                 = [ A .necc {ρ} , B .necc {ρ} ]
-- NOT POSSIBLE BECAUSE OF DEPENDENCY: Sum A B .suff {ρ} = A .suff {ρ} +̇ B .suff {ρ}
Sum A B .suff (inj₁ a)            = inj₁ (A .suff a)
Sum A B .suff (inj₂ b)            = inj₂ (B .suff b)
Sum A B .mon-Supp-suff (inj₁ a) supp→ρ' u = A .mon-Supp-suff a supp→ρ' u
Sum A B .mon-Supp-suff (inj₂ b) supp→ρ' u = B .mon-Supp-suff b supp→ρ' u
Sum A B .mon-id                   =  funExt λ
  { (inj₁ a) → cong (λ f → inj₁ (f a)) (A .mon-id)
  ; (inj₂ b) → cong (λ f → inj₂ (f b)) (B .mon-id)
  }
-- Sum A B .mon-id (inj₁ a)          = {! cong inj₁ (A .mon-id a) !}
-- Sum A B .mon-id (inj₂ b)          = {! cong inj₂ (B .mon-id b) !}
Sum A B .mon-comp (inj₁ a) = cong inj₁ (A .mon-comp a)
Sum A B .mon-comp (inj₂ b) = cong inj₂ (B .mon-comp b)
Sum A B .mon-Supp-id {ρ} = funExt λ
  { (inj₁ a) → funExtH λ{i} → funExt λ u → {!aux a i u!}
  ; (inj₂ b) → funExtH λ{i} → funExt λ u → {!!}
  }
  where
  aux : ∀ (a : A .F ρ) i (u : A .Supp (A .mon id a) i) →
      A .mon-Supp id a u ≡
      subst (λ f → Sum A B .Supp (f (inj₁ a)) i) (Sum A B .mon-id) u
  aux a i u rewrite A .mon-Supp-id {ρ} = {!c!} -- | A .mon-id {ρ} = ? -- | B .mon-id {ρ} = {!!}
  -- aux : ∀ (x : A .F ρ ⊎ B .F ρ) i →
  --     Sum A B .mon-Supp id x ≡
  --     subst (λ f → Sum A B .Supp (f x) i) (Sum A B .mon-id)
  -- aux (inj₁ a) i rewrite A .mon-Supp-id {ρ} = {!!}
  -- aux (inj₂ b) i = {!!}

-- Sum A B .mon-Supp-id {ρ} = funExt λ x → funExtH λ{i} → {!aux x i!}
--   where
--   aux : ∀ (x : A .F ρ ⊎ B .F ρ) i →
--       Sum A B .mon-Supp id x ≡
--       subst (λ f → Sum A B .Supp (f x) i) (Sum A B .mon-id)
--   aux (inj₁ a) i rewrite A .mon-Supp-id {ρ} = {!!}
--   aux (inj₂ b) i = {!!}
-- with A .mon {ρ} id | A .mon-id {ρ} | A .mon-Supp id a | A .mon-Supp-id {ρ} a
-- ... | x | y | z | v = {!!}
-- Sum A B .mon-Supp-id {ρ} (inj₁ a) rewrite A .mon-id {ρ} | A .mon-Supp-id {ρ} a = {!!}
Sum A B .necc-suff (inj₁ a) = cong inj₁ (A .necc-suff a)
Sum A B .necc-suff (inj₂ b) = cong inj₂ (B .necc-suff b)

ext : ∀{ℓ} {A : Set ℓ} {n} (ρ : Fin n → A) (x : A) (i : Fin (suc n)) → A
ext ρ x zero = x
ext ρ x (suc i) = ρ i

ext-⊤-mon : ∀{n}{ρ ρ' : Fin n → Set} (ρ→ρ' : ρ →̇ ρ') → ext ρ ⊤ →̇ ext ρ' ⊤
ext-⊤-mon ρ→ρ' {zero} = _
ext-⊤-mon ρ→ρ' {suc i} = ρ→ρ'

-- ext-⊤-mon-id : ∀{n} {ρ : Fin n → Set} → _≡_ {A = ext ρ ⊤ →̇ ext ρ ⊤} (λ{i} → ext-⊤-mon {n} {ρ} id {i}) id
ext-⊤-mon-id : ∀{n} {ρ : Fin n → Set} → (λ{i} → ext-⊤-mon {n} {ρ} id {i}) ≡ id
ext-⊤-mon-id = funExtH λ{ {zero} → refl ; {suc i} → refl }

{-# REWRITE ext-⊤-mon-id #-}

{-# TERMINATING #-}
Mu : ∀{n} (A : SP (suc n)) → SP n
Mu A .F ρ  = 𝕎 (A .F (ext ρ ⊤)) λ x → A .Supp x zero
Mu A .mon {ρ}{ρ'} ρ→ρ' = 𝕎-map (A .mon λ{i} → ext-⊤-mon ρ→ρ' {i})
                                (λ x → A .mon-Supp (λ{i} → ext-⊤-mon ρ→ρ' {i}) x)
Mu A .mon-id {ρ} = {!A .mon-Supp-id!}
Mu A .mon-id {ρ} with A .mon {ext ρ ⊤} id | A .mon-id {ext ρ ⊤} | A .mon-Supp {ext ρ ⊤} id | A .mon-Supp-id {ext ρ ⊤}
Mu A .mon-id {ρ} | .id | refl | v | p = {!!} -- with A .mon-id x
-- Mu A .mon-id {ρ} (sup x f) with A .mon {ext ρ ⊤} id | A .mon-id {ext ρ ⊤} | A .mon-Supp {ext ρ ⊤} id
-- ... | t | u | v = {!!} -- with A .mon-id x
-- = hcong₂ sup (A .mon-id x) {!!} -- rewrite A .mon-id x = {!hcong₂ sup ? ?!}
Mu A .Supp w i = EF𝕎 (λ x → A .Supp x (suc i)) w
Mu A .mon-Supp {ρ} ρ→ρ' = loop
  where
  loop : (x : Mu A .F ρ) → Mu A .Supp (Mu A .mon ρ→ρ' x) →̇ Mu A .Supp x
  loop (sup x f) (here p)    = here (A .mon-Supp (λ{i} → ext-⊤-mon ρ→ρ' {i}) x p)
  loop (sup x f) (there i u) = there v (loop (f v) u)
    where
    v : A .Supp x zero
    v = A .mon-Supp (λ {j} → ext-⊤-mon ρ→ρ' {j}) x i
Mu A .necc {ρ} = loop
  where
  loop : (x : Mu A .F ρ) → Mu A .Supp x →̇ ρ
  loop (sup x f) (here p)    = A .necc x p
  loop (sup x f) (there i u) = loop (f i) u
Mu A .suff {ρ} (sup x f) = sup (A .mon ζ (A .suff x)) λ p →
  let
    r : 𝕎 (A .F (ext ρ ⊤)) (λ y → A .Supp y zero)
    r = f (A .mon-Supp-suff x ζ p)
  in
      𝕎-map (A .mon (λ {i} → α p i))
        (β {p}) (Mu A .suff r)
  where
  ζ : A .Supp x →̇ ext (Mu A .Supp (sup x f)) ⊤
  ζ {zero} = _
  ζ {suc i} = here

  -- agda was not happy about i being implicit when applying alpha
  α : ∀ p → ∀ i
      → ext (Mu A .Supp (f (A .mon-Supp-suff x ζ p))) ⊤ i
      → ext (Mu A .Supp (sup x f))                    ⊤ i
  α p i = ext-⊤-mon (there (A .mon-Supp-suff x ζ p)) {i}


  β : ∀ {p : A .Supp (A .mon ζ (A .suff x)) zero}
        (s : A .F (ext (Mu A .Supp (f (A .mon-Supp-suff x ζ p))) ⊤))
      → A .Supp (A .mon (λ {i} → α p i) s) zero
      → A .Supp s                          zero
  β {p} s q = A .mon-Supp-suff s _
    (subst (λ s → A .Supp s zero) (A .mon-comp (A .suff s))
      (subst (λ s → A .Supp (A .mon ((λ {i} → α p i)) s) zero) (sym (A .necc-suff s)) q))
  -- β {p} s q = A .mon-Supp-suff s _ q''
  --   where
  --     q' = subst (λ s → A .Supp (A .mon ((λ {i} → α p i)) s) zero) (sym (A .necc-suff)) q
  --     q'' = subst (λ s → A .Supp s zero) (A .mon-comp (A .suff s)) q'

  -- Inlined for the sake of termination:
  -- x' : A .F (ext (Mu A .Supp (sup x f)) ⊤)
  -- x' = A .mon ζ (A .suff x)

{-
-- containers
record Cont : Set₁ where
  constructor _,_
  field
    S : Set
    P : S → Set

open Cont

⟦_⟧ : Cont → Set → Set
⟦ S , P ⟧ X = Σ S λ s → P s → X

-- Every container is strictly positive
tosp : Cont → SPos
tosp C .F = ⟦ C ⟧
tosp C .mon f (s , t) = s , λ p → f (t p)
tosp C .Supp (s , t) = C .P s
tosp C .mon-Supp f (s , t) p = p
tosp C .necc (s , t) p = t p
tosp C .suff (s , t) = s , λ x → x
{-
tosp C .necc-suff = refl
tosp C .suff-necc p = refl
tosp C .suff-nat f xs = refl
tosp C .necc-nat f xs p = refl
tosp C .mon-comp xs = refl
tosp C .mon-Supp-comp = λ xs p → refl
-}

-- A stricly positive functor is isomorphic to a container
module M  (sp : SPos) where

  cont : Cont
  cont = sp .F ⊤ , sp .Supp

  G = ⟦ cont ⟧

  fwd : ∀ {X} → sp .F X → G X
  fwd fx = sp .mon _ fx  , λ p → sp .necc fx (sp .mon-Supp _ fx p)

  bwd : ∀ {X} → G X → sp .F X
  bwd (s , t) = sp .mon t (sp .suff s)

{-
  iso1 : ∀ {X} (xs : sp .F X) → bwd (fwd xs) ≡ xs
  iso1 xs = trans
            (trans (sym (sp .mon-comp (sp .suff (sp .mon _ xs))))
                   (cong (sp .mon (sp .necc xs)) (sp .suff-nat _ xs)))
                   (sp .necc-suff)

  iso2₁ : ∀ {X} (xs : G X) → (fwd (bwd xs)) .proj₁ ≡ xs .proj₁
  iso2₁ (s , t) = trans (sp .mon-comp (sp .suff s)) (sp .necc-suff)


  iso2₂ : ∀ {X} (xs : G X) {p : _} →
            (fwd (bwd xs)) .proj₂ p ≡ xs .proj₂ (subst (sp .Supp) (iso2₁ xs) p)
  iso2₂ (s , t) {p} = trans (sp .necc-nat  t (sp .suff s) _)
                  (cong t (trans
                          (cong (sp .necc (sp .suff s)) (sp .mon-Supp-comp (sp .suff s) _))
                                (trans (sp .suff-necc _)
                                       (sym (subst-trans ((sp .mon-comp (sp .suff s)))
                                                         (sp .necc-suff) p) ))))
-- -}
-- -}
-- -}
-- -}
-- -}
-- -}
-- -}
-- -}