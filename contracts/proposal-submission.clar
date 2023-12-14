
;; title: proposal-submission
;; version:
;; summary:
;; description:

;; traits
(impl-trait .extension-trait.extension-trait)
(use-trait proposal-trait .proposal-trait.proposal-trait)

;; token definitions
;;

;; constants
(define-constant ERR_UNAUTHORIZED (err u3000))
(define-constant ERR_UNKNOWN_PARAMETER (err u3001))
(define-constant ERR_PROPOSAL_SEED_NOT_INCREMENTED (err u3002))

;; data vars
(define-data-var proposal-id uint u1)

;; data maps
(define-map parameters (string-ascii 34) uint)

(map-set parameters "proposal-duration" u1440) ;; ~10 days based on a ~10 minute block time.

;; public functions
(define-public (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender .core) (contract-call? .core is-extension contract-caller)) ERR_UNAUTHORIZED))
)

(define-public (propose (proposal <proposal-trait>) (title (string-ascii 50)) (description (string-utf8 500)) (grant-amount uint) (withdraw-amount uint))
  (let 
     (
      (id (var-get proposal-id))
     ) 
    (begin
      (asserts! (var-set proposal-id (+ id u1)) (err u3002))
      (contract-call? .proposal-voting add-proposal
        proposal
        {
          id: id,
          start-block-height: block-height,
          end-block-height: (+ block-height (try! (get-parameter "proposal-duration"))),
          proposer: tx-sender,
          title: title,
          description: description,
          grant-amount: grant-amount,
          withdraw-amount: u0
        }
      )
    )
  )
)

(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)

;; read only functions
(define-read-only (get-parameter (parameter (string-ascii 34)))
  (ok (unwrap! (map-get? parameters parameter) ERR_UNKNOWN_PARAMETER))
)

;; private functions
;;

