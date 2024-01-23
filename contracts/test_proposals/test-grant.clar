
;; title: Build grant milestone program
;; summary: If this proposal passes, the proposed grant amount will be transferred to the specified address.
;; description: Proposal to build a grant milestone program that will allow grants to be paid out incrementally
;; as opposed to being paid in full when proposal passes.

;; traits
(impl-trait .proposal-trait.proposal-trait)

;; token definitions
;;

;; constants
(define-constant grant-amount u1000)

;; public functions
(define-public (execute (sender principal))
	(begin	
		(try! (contract-call? .vault vault-transfer-stx grant-amount (as-contract tx-sender)))
        (ok true)
	)
)

