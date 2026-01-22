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

;; Read-only functions
(define-read-only (get-badge-type (badge-type-id uint))
  (map-get? badge-types badge-type-id)
)

(define-read-only (get-badge-award (award-id uint))
  (map-get? badge-awards award-id)
)

(define-read-only (has-badge (recipient principal) (badge-type-id uint))
  (is-some (map-get? user-badge-awards { recipient: recipient, badge-type-id: badge-type-id }))
)

(define-read-only (get-user-badge-count (user principal))
  (default-to u0 (map-get? user-badge-count user))
)

(define-read-only (is-authorized-issuer (issuer principal))
  (default-to false (map-get? authorized-issuers issuer))
)

(define-read-only (get-badge-type-nonce)
  (var-get badge-type-nonce)
)

(define-read-only (get-badge-award-nonce)
  (var-get badge-award-nonce)
)

;; Public functions
;; #[allow(unchecked_data)]
(define-public (authorize-issuer (issuer principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (map-set authorized-issuers issuer true)
    (ok true)
  )
)

;; #[allow(unchecked_data)]
(define-public (create-badge-type 
  (name (string-ascii 100))
  (description (string-ascii 300))
  (category (string-ascii 50)))
  (let
    (
      (badge-type-id (var-get badge-type-nonce))
    )
    (asserts! (is-authorized-issuer tx-sender) err-unauthorized)
    (map-set badge-types badge-type-id
      {
        name: name,
        description: description,
        category: category,
        creator: tx-sender,
        active: true
  }
)
(var-set badge-type-nonce (+ badge-type-id u1))
(ok badge-type-id)
)
)

;; #[allow(unchecked_data)]
(define-public (award-badge (badge-type-id uint) (recipient principal) (reason (string-ascii 200)))
(let
(
(award-id (var-get badge-award-nonce))
(badge-type (unwrap! (map-get? badge-types badge-type-id) err-not-found))
)
(asserts! (is-authorized-issuer tx-sender) err-unauthorized)
(asserts! (get active badge-type) err-unauthorized)
(asserts! (is-none (map-get? user-badge-awards { recipient: recipient, badge-type-id: badge-type-id })) err-already-awarded)
(map-set badge-awards award-id
{
badge-type-id: badge-type-id,
recipient: recipient,
awarded-by: tx-sender,
awarded-at: stacks-block-height,
reason: reason
}
)
(map-set user-badge-awards
{ recipient: recipient, badge-type-id: badge-type-id }
award-id
)
(map-set user-badge-count recipient (+ (get-user-badge-count recipient) u1))
(var-set badge-award-nonce (+ award-id u1))
(ok award-id)
)
)

(define-public (deactivate-badge-type (badge-type-id uint))
(let
(
(badge-type (unwrap! (map-get? badge-types badge-type-id) err-not-found))
)
(asserts! (is-eq tx-sender (get creator badge-type)) err-unauthorized)
(map-set badge-types badge-type-id (merge badge-type { active: false }))
(ok true)
)
)

(define-public (reactivate-badge-type (badge-type-id uint))
(let
(
(badge-type (unwrap! (map-get? badge-types badge-type-id) err-not-found))
)
(asserts! (is-eq tx-sender (get creator badge-type)) err-unauthorized)
(map-set badge-types badge-type-id (merge badge-type { active: true }))
(ok true)
)
)

;; #[allow(unchecked_data)]
(define-public (revoke-issuer (issuer principal))
(begin
(asserts! (is-eq tx-sender contract-owner) err-unauthorized)
(map-set authorized-issuers issuer false)
(ok true)
)
)

;; #[allow(unchecked_data)]
;; Update badge type description
(define-public (update-badge-description (badge-type-id uint) (new-description (string-ascii 300)))
(let
(
(badge-type (unwrap! (map-get? badge-types badge-type-id) err-not-found))
)
(asserts! (is-eq tx-sender (get creator badge-type)) err-unauthorized)
(map-set badge-types badge-type-id (merge badge-type { description: new-description }))
(ok true)
)
)

;; #[allow(unchecked_data)]
;; Update badge type name
(define-public (update-badge-name (badge-type-id uint) (new-name (string-ascii 100)))
(let
(
(badge-type (unwrap! (map-get? badge-types badge-type-id) err-not-found))
)
(asserts! (is-eq tx-sender (get creator badge-type)) err-unauthorized)
(map-set badge-types badge-type-id (merge badge-type { name: new-name }))
(ok true)
)
)

;; #[allow(unchecked_data)]
;; Update badge type category
(define-public (update-badge-category (badge-type-id uint) (new-category (string-ascii 50)))
(let
(
(badge-type (unwrap! (map-get? badge-types badge-type-id) err-not-found))
)
(asserts! (is-eq tx-sender (get creator badge-type)) err-unauthorized)
(map-set badge-types badge-type-id (merge badge-type { category: new-category }))
(ok true)
)
)

;; Transfer badge creator rights
(define-public (transfer-badge-ownership (badge-type-id uint) (new-owner principal))
(let
(
(badge-type (unwrap! (map-get? badge-types badge-type-id) err-not-found))
)
(asserts! (is-eq tx-sender (get creator badge-type)) err-unauthorized)
(map-set badge-types badge-type-id (merge badge-type { creator: new-owner }))
(ok true)
)
)

;; Get award details by recipient and badge type
(define-read-only (get-user-badge-award (recipient principal) (badge-type-id uint))
(map-get? user-badge-awards { recipient: recipient, badge-type-id: badge-type-id })
)

;; Check if a principal is the contract owner
(define-read-only (is-contract-owner (user principal))
(is-eq user contract-owner)
)

;; Get badge award details with recipient check
(define-read-only (get-award-with-recipient (award-id uint) (expected-recipient principal))
(match (map-get? badge-awards award-id)
award (if (is-eq (get recipient award) expected-recipient)
(some award)
none)
none
)
)

;; Check if badge type is active
(define-read-only (is-badge-active (badge-type-id uint))
(match (map-get? badge-types badge-type-id)
badge-type (get active badge-type)
false
)
)

;; Get badge type creator
(define-read-only (get-badge-creator (badge-type-id uint))
(match (map-get? badge-types badge-type-id)
badge-type (some (get creator badge-type))
none
)
)

;; Get badge type name
(define-read-only (get-badge-name (badge-type-id uint))
(match (map-get? badge-types badge-type-id)
badge-type (some (get name badge-type))
none
)
)

;; Get badge type category
(define-read-only (get-badge-category (badge-type-id uint))
(match (map-get? badge-types badge-type-id)
badge-type (some (get category badge-type))
none
)
)

;; Get badge type description
(define-read-only (get-badge-description (badge-type-id uint))
(match (map-get? badge-types badge-type-id)
badge-type (some (get description badge-type))
none
)
)

;; Get award recipient
(define-read-only (get-award-recipient (award-id uint))
(match (map-get? badge-awards award-id)
award (some (get recipient award))
none
)
)

;; Get award issuer
(define-read-only (get-award-issuer (award-id uint))
(match (map-get? badge-awards award-id)
award (some (get awarded-by award))
none
)
)

;; Get award timestamp
(define-read-only (get-award-timestamp (award-id uint))
(match (map-get? badge-awards award-id)
award (some (get awarded-at award))
none
)
)

;; Get award reason
(define-read-only (get-award-reason (award-id uint))
(match (map-get? badge-awards award-id)
award (some (get reason award))
none
)
)

;; Get the badge type ID from an award
(define-read-only (get-award-badge-type (award-id uint))
(match (map-get? badge-awards award-id)
award (some (get badge-type-id award))
none
)
)

;; Check if two users both have a specific badge
(define-read-only (both-have-badge (user1 principal) (user2 principal) (badge-type-id uint))
(and
(is-some (map-get? user-badge-awards { recipient: user1, badge-type-id: badge-type-id }))
(is-some (map-get? user-badge-awards { recipient: user2, badge-type-id: badge-type-id }))
)
)

;; Check if user has more than N badges
(define-read-only (has-minimum-badges (user principal) (minimum uint))
(>= (get-user-badge-count user) minimum)
)

;; Verify if user has any badges
(define-read-only (has-any-badges (user principal))
(> (get-user-badge-count user) u0)
)

;; Compare badge counts between two users
(define-read-only (compare-badge-counts (user1 principal) (user2 principal))
(let
(
(count1 (get-user-badge-count user1))
(count2 (get-user-badge-count user2))
)
(if (> count1 count2)
u1  ;; user1 has more
(if (< count1 count2)
u2  ;; user2 has more
u0  ;; equal
)
)
)
)

;; Get total badge types created
(define-read-only (get-total-badge-types)
(var-get badge-type-nonce)
)

;; Get total awards issued
(define-read-only (get-total-awards)
(var-get badge-award-nonce)
)