;; Payment Release Contract
;; Manages disbursement of funds based on verified progress

(define-map payments
  { payment-id: uint }
  {
    project-id: uint,
    milestone-id: uint,
    amount: uint,
    recipient: principal,
    status: (string-ascii 20),
    request-date: uint,
    release-date: (optional uint)
  }
)

(define-data-var payment-id-counter uint u0)

(define-constant contract-owner tx-sender)

(define-read-only (get-payment (payment-id uint))
  (map-get? payments { payment-id: payment-id })
)

(define-public (request-payment (project-id uint) (milestone-id uint) (amount uint))
  (let
    (
      (new-payment-id (+ (var-get payment-id-counter) u1))
    )
    (var-set payment-id-counter new-payment-id)
    (ok (map-set payments
      { payment-id: new-payment-id }
      {
        project-id: project-id,
        milestone-id: milestone-id,
        amount: amount,
        recipient: tx-sender,
        status: "requested",
        request-date: block-height,
        release-date: none
      }
    ))
  )
)

(define-public (release-payment (payment-id uint))
  (let
    (
      (payment (unwrap! (get-payment payment-id) (err u404)))
    )
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (asserts! (is-eq (get status payment) "requested") (err u400))

    ;; In a real implementation, we would transfer STX here
    ;; (try! (stx-transfer? (get amount payment) tx-sender (get recipient payment)))

    (ok (map-set payments
      { payment-id: payment-id }
      (merge payment {
        status: "released",
        release-date: (some block-height)
      })
    ))
  )
)

(define-read-only (get-payment-for-milestone (project-id uint) (milestone-id uint))
  (var-get payment-id-counter)
  ;; In a real implementation, we would search for the payment
  ;; This is a simplified version that just returns the counter
)
