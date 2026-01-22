;; Student Achievement Badges Contract
;; Digital badge system for recognizing student achievements

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u100))
(define-constant err-unauthorized (err u101))
(define-constant err-already-awarded (err u102))