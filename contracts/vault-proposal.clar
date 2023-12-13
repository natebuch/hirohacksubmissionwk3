;; title: community-vault-proposal
;; summary: If this proposal passes, the vault extension will be activated.
;; A community fund of 1000 membership will be minted and transfered to the vault.

;; traits
(impl-trait .proposal-trait.proposal-trait)

;; token definitions
;;

;; constants
(define-constant initial-vault-fund u1000)

;; public functions
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .core set-extension .vault true))		
		(try! (contract-call? .membership-token mint initial-vault-fund .vault))
        (ok true)
	)
)

