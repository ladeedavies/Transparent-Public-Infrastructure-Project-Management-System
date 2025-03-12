;; Contractor Bidding Contract
;; Handles secure submission and evaluation of bids

(define-map bids
  { bid-id: uint }
  {
    project-id: uint,
    contractor: principal,
    amount: uint,
    proposal: (string-ascii 500),
    status: (string-ascii 20),
    submission-date: uint
  }
)

(define-map project-bids
  { project-id: uint }
  { bid-count: uint, selected-bid: (optional uint) }
)

(define-data-var bid-id-counter uint u0)

(define-constant contract-owner tx-sender)

(define-read-only (get-bid (bid-id uint))
  (map-get? bids { bid-id: bid-id })
)

(define-read-only (get-project-bid-info (project-id uint))
  (default-to
    { bid-count: u0, selected-bid: none }
    (map-get? project-bids { project-id: project-id })
  )
)

(define-public (submit-bid (project-id uint) (amount uint) (proposal (string-ascii 500)))
  (let
    (
      (new-bid-id (+ (var-get bid-id-counter) u1))
      (project-bid-info (get-project-bid-info project-id))
    )
    (var-set bid-id-counter new-bid-id)
    (map-set project-bids
      { project-id: project-id }
      {
        bid-count: (+ (get bid-count project-bid-info) u1),
        selected-bid: (get selected-bid project-bid-info)
      }
    )
    (ok (map-set bids
      { bid-id: new-bid-id }
      {
        project-id: project-id,
        contractor: tx-sender,
        amount: amount,
        proposal: proposal,
        status: "submitted",
        submission-date: block-height
      }
    ))
  )
)

(define-public (select-bid (bid-id uint))
  (let
    (
      (bid (unwrap! (get-bid bid-id) (err u404)))
      (project-id (get project-id bid))
      (project-bid-info (get-project-bid-info project-id))
    )
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (asserts! (is-eq (get status bid) "submitted") (err u401))

    ;; Update the selected bid in project-bids
    (map-set project-bids
      { project-id: project-id }
      (merge project-bid-info { selected-bid: (some bid-id) })
    )

    ;; Update the status of the selected bid
    (ok (map-set bids
      { bid-id: bid-id }
      (merge bid { status: "selected" })
    ))
  )
)
