;; title: vault
;; version:
;; summary:
;; description:

;; traits
(impl-trait .extension-trait.extension-trait)

;; constants
(define-constant ERR_UNAUTHORIZED (err u4001))
(define-constant ERR_VAULT_STACKS_BALANCE_INSUFFICIENT (err u4002))

;; data vars
;;

;; data maps
;;

;; public functions
(define-public (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender .core) (contract-call? .core is-extension contract-caller)) ERR_UNAUTHORIZED))
)

(define-public (vault-transfer-membership-token (amount uint) (recipient principal))
  (begin 
    (try! (is-dao-or-extension))
    (as-contract (contract-call? .membership-token transfer amount tx-sender recipient))
  )
)

(define-public (vault-transfer-stx (amount uint) (recipient principal))
  (begin 
    (try! (is-dao-or-extension))
    (asserts! (<= (vault-get-stx-balance) amount) ERR_VAULT_STACKS_BALANCE_INSUFFICIENT)
    (as-contract (stx-transfer? amount tx-sender recipient))
  )
)

(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)

;; read only functions
(define-read-only (vault-get-membership-token-balance)
  (as-contract (contract-call? .membership-token get-balance tx-sender))
)

(define-read-only (vault-get-stx-balance)
  (as-contract (stx-get-balance tx-sender))
)


