{-# OPTIONS --safe --without-K #-}

module Trigger.API where

open import Data.Product using (Σ; _,_)
open import Data.Sum using (_⊎_)
open import Relation.Binary.PropositionalEquality using (_≡_; refl)

-- =====================================================================
-- Level 4: API Equivalence & MTProto Well-Formedness
-- =====================================================================

-- The state of an MTProto connection session
data SessionState : Set where
  Unauth       : SessionState
  AuthReq      : SessionState
  AuthAck      : SessionState
  SessionActive : SessionState

-- A session identifier
postulate SessionID : Set

-- Abstract tracking of state per session
postulate stateOf : SessionID → SessionState

-- =====================================================================
-- Well-Formedness Rules
-- =====================================================================

-- Proof that a session is fully active
data IsAuthorized (s : SessionID) : Set where
  authorized : stateOf s ≡ SessionActive → IsAuthorized s

-- Postulate the Idris2 API actions as transitions that preserve or 
-- require these invariants.
postulate Message : Set
postulate Reason : Set
postulate Result : Set

-- You cannot issue a report unless the session is in the SessionActive state.
-- This mirrors the Idris2 dependent type signature.
postulate reportMessage : (s : SessionID) → Message → Reason 
                        → IsAuthorized s 
                        → Result

-- Cryptographic opacity (simplified placeholder for Level 4)
postulate CipherText : Set
postulate isOpaque : CipherText → Set
