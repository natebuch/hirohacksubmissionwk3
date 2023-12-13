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
(define-constant ERR_GRANT_ALREADY_EXISTS (err u5005))
(define-constant ERR_VAULT_FUNDS_INSUFFICIENT (err u5005))


;; data maps
(define-map grants uint
  { 
    proposer: principal,
    milestones: uint,
    grant-amount: uint,
    amount-disbursed: uint,
    active: bool,
  }
)

;; public functions
(define-public (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender .core) (contract-call? .core is-extension contract-caller)) ERR_UNAUTHORIZED))
)

(define-public 
  (add-grant (id uint)
    (data 
      {
        proposer: principal, 
        milestones: uint,
        grant-amount: uint,
        amount-disbursed: uint,
        active: bool
      }
    )
  )
  (begin
    (try! (is-dao-or-extension))
    (ok (asserts! (map-insert grants id data) (err u5004)))
  )
)

;;mint and disburse function
(define-public (disburse-funds (grant principal) (amount uint) (proposal-id uint))
   (let
    ( 
      (grant-data (unwrap! (map-get? grants proposal-id) ERR_GRANT_NOT_FOUND))
      (new-milestones (- (get milestones grant-data) u1))
    )
    (begin
      (try! (is-dao-or-extension))
      (asserts! (get active grant-data) ERR_GRANT_INACTIVE)
      (asserts! (<= amount (get grant-amount grant-data)) ERR_AMOUNT_EXCEEDS_TOTAL_GRANT_AMOUNT)
      (map-set grants proposal-id 
         (merge grant-data {grant-amount: amount, milestones: new-milestones})
      )
      (try! (as-contract (contract-call? .vault vault-transfer-stx amount grant)))
      (ok true)
    )
  )
)

(define-public (deactivate-grant (proposal-id uint))
  (let
    ( 
      (grant-data (unwrap! (map-get? grants proposal-id) ERR_GRANT_NOT_FOUND))
    )
    (begin 
      (asserts! (or (is-eq tx-sender .core) (contract-call? .core is-extension contract-caller)) ERR_UNAUTHORIZED)
      (asserts! (get active grant-data) ERR_GRANT_INACTIVE)
      (map-set grants proposal-id
        (merge grant-data {active: false})
      )
      (ok true)
    )
  ) 
)

(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)
;;view grant details

;; read only functions
;;

;; private functions
;;

