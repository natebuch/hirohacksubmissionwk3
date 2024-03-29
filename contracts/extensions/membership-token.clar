
;; title: membership-token
;; version:
;; summary:
;; description:

;; traits
(impl-trait .extension-trait.extension-trait)

;; token definitions
(define-fungible-token sGrant)

;; constants
(define-constant ERR_UNAUTHORIZED (err u2000))
(define-constant ERR_NOT_TOKEN_OWNER (err u2001))
(define-constant ERR_MEMBERSHIP_LIMIT_REACHED (err u2002))

;; data vars
(define-data-var tokenName (string-ascii 32) "sGrant")
(define-data-var tokenSymbol (string-ascii 10) "SGT")
(define-data-var tokenUri (optional (string-utf8 256)) none)
(define-data-var tokenDecimals uint u6)

;; data maps
;;

;; public functions
(define-public (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender .core) (contract-call? .core is-extension contract-caller)) ERR_UNAUTHORIZED))
)

(define-public (mint (amount uint) (recipient principal))
  (begin
    (try! (is-dao-or-extension))
    (ft-mint? sGrant amount recipient)
  )
)

(define-public (mint-many (recipients (list 200 {amount: uint, recipient: principal})))
	(begin
		(try! (is-dao-or-extension))
		(ok (map mint-many-iter recipients))
	)
)

(define-public (burn (amount uint) (owner principal))
  (begin
    (try! (is-dao-or-extension))
    (ft-burn? sGrant amount owner)
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (ft-transfer? sGrant amount sender recipient)
)

;; read only functions
(define-read-only (get-name)
  (ok (var-get tokenName))
)

(define-read-only (get-symbol)
  (ok (var-get tokenSymbol))
)

(define-read-only (get-decimals)
  (ok (var-get tokenDecimals))
)

(define-read-only (get-balance (who principal))
  (ok (ft-get-balance sGrant who))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply sGrant))
)

(define-read-only (get-token-uri)
  (ok (var-get tokenUri))
)

(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)
;; private functions
(define-private (mint-many-iter (item {amount: uint, recipient: principal}))
	(ft-mint? sGrant (get amount item) (get recipient item))
)

