;; Progress Tracking Contract
;; Monitors project milestones and completion

(define-map milestones
  { milestone-id: uint }
  {
    project-id: uint,
    description: (string-ascii 200),
    deadline: uint,
    weight: uint,
    status: (string-ascii 20),
    completion-date: (optional uint),
    verified-by: (optional principal)
  }
)

(define-map project-milestones
  { project-id: uint }
  { milestone-count: uint, completed-count: uint }
)

(define-data-var milestone-id-counter uint u0)

(define-constant contract-owner tx-sender)

(define-read-only (get-milestone (milestone-id uint))
  (map-get? milestones { milestone-id: milestone-id })
)

(define-read-only (get-project-milestone-info (project-id uint))
  (default-to
    { milestone-count: u0, completed-count: u0 }
    (map-get? project-milestones { project-id: project-id })
  )
)

(define-public (add-milestone (project-id uint) (description (string-ascii 200)) (deadline uint) (weight uint))
  (let
    (
      (new-milestone-id (+ (var-get milestone-id-counter) u1))
      (project-milestone-info (get-project-milestone-info project-id))
    )
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (var-set milestone-id-counter new-milestone-id)
    (map-set project-milestones
      { project-id: project-id }
      {
        milestone-count: (+ (get milestone-count project-milestone-info) u1),
        completed-count: (get completed-count project-milestone-info)
      }
    )
    (ok (map-set milestones
      { milestone-id: new-milestone-id }
      {
        project-id: project-id,
        description: description,
        deadline: deadline,
        weight: weight,
        status: "pending",
        completion-date: none,
        verified-by: none
      }
    ))
  )
)

(define-public (report-milestone-completion (milestone-id uint))
  (let
    (
      (milestone (unwrap! (get-milestone milestone-id) (err u404)))
    )
    (asserts! (is-eq (get status milestone) "pending") (err u400))
    (ok (map-set milestones
      { milestone-id: milestone-id }
      (merge milestone {
        status: "reported",
        completion-date: (some block-height)
      })
    ))
  )
)

(define-public (verify-milestone (milestone-id uint) (approved bool))
  (let
    (
      (milestone (unwrap! (get-milestone milestone-id) (err u404)))
      (project-id (get project-id milestone))
      (project-milestone-info (get-project-milestone-info project-id))
    )
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (asserts! (is-eq (get status milestone) "reported") (err u400))

    (if approved
      (begin
        (map-set project-milestones
          { project-id: project-id }
          {
            milestone-count: (get milestone-count project-milestone-info),
            completed-count: (+ (get completed-count project-milestone-info) u1)
          }
        )
        (map-set milestones
          { milestone-id: milestone-id }
          (merge milestone {
            status: "completed",
            verified-by: (some tx-sender)
          })
        )
      )
      (map-set milestones
        { milestone-id: milestone-id }
        (merge milestone {
          status: "rejected",
          verified-by: (some tx-sender)
        })
      )
    )
    (ok approved)
  )
)

(define-read-only (get-project-progress (project-id uint))
  (let
    (
      (milestone-info (get-project-milestone-info project-id))
    )
    (if (> (get milestone-count milestone-info) u0)
      (/ (* u100 (get completed-count milestone-info)) (get milestone-count milestone-info))
      u0
    )
  )
)
