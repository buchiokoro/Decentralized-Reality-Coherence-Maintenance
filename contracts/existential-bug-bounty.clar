;; Existential Bug Bounty Contract
;; Rewards finding bugs in reality

(define-map reality-bugs
  { id: uint }
  {
    title: (string-ascii 100),
    description: (string-ascii 200),
    severity: uint,
    discoverer: principal,
    status: (string-ascii 20),
    discovery-time: uint,
    affected-entities: (list 10 uint)
  }
)

(define-map bug-rewards
  { bug-id: uint }
  {
    amount: uint,
    rewarded-to: principal,
    reward-time: uint
  }
)

(define-data-var next-bug-id uint u1)

(define-public (report-bug (title (string-ascii 100)) (description (string-ascii 200)) (severity uint) (affected-entities (list 10 uint)))
  (let ((bug-id (var-get next-bug-id)))
    (map-set reality-bugs
      { id: bug-id }
      {
        title: title,
        description: description,
        severity: severity,
        discoverer: tx-sender,
        status: "reported",
        discovery-time: block-height,
        affected-entities: affected-entities
      }
    )
    (var-set next-bug-id (+ bug-id u1))
    (ok bug-id)
  )
)

(define-public (verify-bug (bug-id uint) (new-status (string-ascii 20)))
  (let ((bug (default-to { title: "", description: "", severity: u0, discoverer: tx-sender, status: "", discovery-time: u0, affected-entities: (list) }
                        (map-get? reality-bugs { id: bug-id }))))

    ;; Update bug status
    (map-set reality-bugs
      { id: bug-id }
      (merge bug { status: new-status })
    )

    (ok true)
  )
)

(define-public (reward-bug (bug-id uint) (amount uint))
  (let ((bug (default-to { title: "", description: "", severity: u0, discoverer: tx-sender, status: "", discovery-time: u0, affected-entities: (list) }
                        (map-get? reality-bugs { id: bug-id }))))

    ;; Record reward
    (map-set bug-rewards
      { bug-id: bug-id }
      {
        amount: amount,
        rewarded-to: (get discoverer bug),
        reward-time: block-height
      }
    )

    ;; Update bug status
    (map-set reality-bugs
      { id: bug-id }
      (merge bug { status: "rewarded" })
    )

    (ok true)
  )
)

(define-read-only (get-bug (bug-id uint))
  (map-get? reality-bugs { id: bug-id })
)

(define-read-only (get-reward (bug-id uint))
  (map-get? bug-rewards { bug-id: bug-id })
)

(define-read-only (calculate-reward (severity uint))
  ;; Simple reward calculation based on severity
  (* severity u10)
)

