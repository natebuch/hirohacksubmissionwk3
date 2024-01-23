;; title: milestone-disbursement
;; version:
;; summary:
;; description: This contract tracks passed grant proposals and manages the disbursments of funds.
;; funds are di 

;; traits
(impl-trait .extension-trait.extension-trait)

;; constants
(define-constant ERR_UNAUTHORIZED (err u5001))
(define-constant ERR_GRANT_NOT_FOUND (err u5002))
(define-constant ERR_GRANT_INACTIVE (err u5003))
(define-constant ERR_AMOUNT_EXCEEDS_TOTAL_GRANT_AMOUNT (err u5004))

;; data maps
(define-map grants principal
  { 
    proposal-id: uint,
    proposer: principal,
    grant-amount: uint,
    amount-disbursed: uint,
    withdraw-amount: uint,
    active: bool,
  }
)

;; public functions
(define-public (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender .core) (contract-call? .core is-extension contract-caller)) ERR_UNAUTHORIZED))
)

(define-public 
  (add-grant (proposal principal)
    (data 
      {
        proposal-id: uint,
        proposer: principal, 
        grant-amount: uint,
        amount-disbursed: uint,
        withdraw-amount: uint,
        active: bool
      }
    )
  )
  (begin
    (try! (is-dao-or-extension))
    (ok (asserts! (map-insert grants proposal data) (err u5004)))
  )
)

;;disburse function
(define-public (disburse-funds (grant principal) (amount uint))
   (let
    ( 
      (grant-data (unwrap! (map-get? grants grant) ERR_GRANT_NOT_FOUND))
    )
    (begin
      (try! (is-dao-or-extension))
      (asserts! (get active grant-data) ERR_GRANT_INACTIVE)
      (asserts! (<= amount (get grant-amount grant-data)) ERR_AMOUNT_EXCEEDS_TOTAL_GRANT_AMOUNT)
      (map-set grants grant
         (merge grant-data {grant-amount: amount})
      )
      (try! (as-contract (contract-call? .vault vault-transfer-stx amount grant)))
      (ok true)
    )
  )
)

(define-public (deactivate-grant (grant principal))
  (let
    ( 
      (grant-data (unwrap! (map-get? grants grant) ERR_GRANT_NOT_FOUND))
    )
    (begin 
      (asserts! (or (is-eq tx-sender .core) (contract-call? .core is-extension contract-caller)) ERR_UNAUTHORIZED)
      (asserts! (get active grant-data) ERR_GRANT_INACTIVE)
      (map-set grants grant
        (merge grant-data {active: false})
      )
      (ok true)
    )
  ) 
)

(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)

;; read only functions
;;

;; private functions
;;

