;; Student Achievement Badges Contract
;; Digital badge system for recognizing student achievements

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u100))
(define-constant err-unauthorized (err u101))
(define-constant err-already-awarded (err u102))

;; Data Variables
(define-data-var badge-type-nonce uint u0)
(define-data-var badge-award-nonce uint u0)

;; Data Maps
(define-map badge-types
  uint
  {
    name: (string-ascii 100),
    description: (string-ascii 300),
    category: (string-ascii 50),
    creator: principal,
    active: bool
  }
)

(define-map badge-awards
  uint
  {
    badge-type-id: uint,
    recipient: principal,
    awarded-by: principal,
    awarded-at: uint,
    reason: (string-ascii 200)
  }
)

(define-map user-badge-awards
  { recipient: principal, badge-type-id: uint }
  uint
)

(define-map user-badge-count principal uint)

(define-map authorized-issuers principal bool)