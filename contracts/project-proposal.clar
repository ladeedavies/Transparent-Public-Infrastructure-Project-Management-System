;; Project Proposal Contract
;; Manages submission and approval of infrastructure projects

(define-map projects
  { project-id: uint }
  {
    name: (string-ascii 100),
    description: (string-ascii 500),
    budget: uint,
    timeline: uint,
    proposer: principal,
    status: (string-ascii 20),
    proposal-date: uint,
    review-date: (optional uint)
  }
)

(define-data-var project-id-counter uint u0)

(define-constant contract-owner tx-sender)

(define-read-only (get-project (project-id uint))
  (map-get? projects { project-id: project-id })
)

(define-read-only (get-project-count)
  (var-get project-id-counter)
)

(define-public (submit-proposal (name (string-ascii 100)) (description (string-ascii 500)) (budget uint) (timeline uint))
  (let
    (
      (new-project-id (+ (var-get project-id-counter) u1))
    )
    (var-set project-id-counter new-project-id)
    (ok (map-set projects
      { project-id: new-project-id }
      {
        name: name,
        description: description,
        budget: budget,
        timeline: timeline,
        proposer: tx-sender,
        status: "proposed",
        proposal-date: block-height,
        review-date: none
      }
    ))
  )
)

(define-public (review-proposal (project-id uint) (approved bool))
  (let
    (
      (project (unwrap! (get-project project-id) (err u404)))
    )
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (asserts! (is-eq (get status project) "proposed") (err u400))
    (ok (map-set projects
      { project-id: project-id }
      (merge project {
        status: (if approved "approved" "rejected"),
        review-date: (some block-height)
      })
    ))
  )
)

(define-public (mark-project-completed (project-id uint))
  (let
    (
      (project (unwrap! (get-project project-id) (err u404)))
    )
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (asserts! (is-eq (get status project) "approved") (err u400))
    (ok (map-set projects
      { project-id: project-id }
      (merge project {
        status: "completed"
      })
    ))
  )
)
