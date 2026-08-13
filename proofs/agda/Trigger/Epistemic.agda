{-# OPTIONS --safe --without-K #-}

module Trigger.Epistemic where

open import Data.Product using (Σ; _,_)
open import Data.Sum using (_⊎_; inj₁; inj₂)
open import Relation.Binary.PropositionalEquality using (_≡_; refl)

-- =====================================================================
-- Trigger Epistemic Formalism (Level 3 Proof Needs)
-- =====================================================================

-- Standpoints (Agents making the reports)
postulate Agent : Set
postulate Channel : Set
postulate Policy : Set

-- The abstract concept of a Policy Violation
postulate Violates : Channel → Policy → Set

-- =====================================================================
-- Evidence & Epistemic Tracking
-- =====================================================================

-- 'Evidence a c p' means Agent 'a' holds evidence that Channel 'c' violates Policy 'p'
postulate Evidence : Agent → Channel → Policy → Set

-- A Report is a dependent record. An agent cannot construct a Report
-- without supplying proof of Evidence.
record Report (a : Agent) (c : Channel) (p : Policy) : Set where
  constructor make-report
  field
    -- The epistemic precondition: the agent must 'know' the violation
    evidence : Evidence a c p

-- =====================================================================
-- Sequential Dispatch Fairness
-- =====================================================================

-- Representing the pool of active accounts
data AccountPool : Set where
  empty : AccountPool
  add   : Agent → AccountPool → AccountPool

-- A proof that an Agent is active in the pool
data IsActive (a : Agent) : AccountPool → Set where
  here  : ∀ {pool} → IsActive a (add a pool)
  there : ∀ {pool a'} → IsActive a pool → IsActive a (add a' pool)

-- A dispatch function requires an active agent and their evidence
-- to produce a valid report to transmit.
dispatch : ∀ {a c p pool}
         → IsActive a pool
         → Evidence a c p
         → Report a c p
dispatch _ ev = make-report ev

-- (Future) To prove fairness, we would model the transition function of the 
-- AccountPool and prove that every Agent in `IsActive` eventually reaches the `here` state.
