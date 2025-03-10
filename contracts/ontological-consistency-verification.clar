;; Ontological Consistency Verification Contract
;; Verifies and maintains ontological consistency in reality

(define-map ontological-entities
  { id: uint }
  {
    name: (string-ascii 100),
    category: (string-ascii 50),
    consistency-score: uint,
    last-verified: uint,
    verifier: principal
  }
)

(define-map verification-records
  { entity-id: uint, record-id: uint }
  {
    verifier: principal,
    previous-score: uint,
    new-score: uint,
    timestamp: uint,
    notes: (string-ascii 200)
  }
)

(define-data-var next-entity-id uint u1)
(define-data-var next-record-id uint u1)

(define-public (register-entity (name (string-ascii 100)) (category (string-ascii 50)))
  (let ((entity-id (var-get next-entity-id)))
    (map-set ontological-entities
      { id: entity-id }
      {
        name: name,
        category: category,
        consistency-score: u100,
        last-verified: block-height,
        verifier: tx-sender
      }
    )
    (var-set next-entity-id (+ entity-id u1))
    (ok entity-id)
  )
)

(define-public (verify-consistency (entity-id uint) (new-score uint) (notes (string-ascii 200)))
  (let ((entity (default-to { name: "", category: "", consistency-score: u0, last-verified: u0, verifier: tx-sender }
                           (map-get? ontological-entities { id: entity-id })))
        (record-id (var-get next-record-id)))

    ;; Record verification
    (map-set verification-records
      { entity-id: entity-id, record-id: record-id }
      {
        verifier: tx-sender,
        previous-score: (get consistency-score entity),
        new-score: new-score,
        timestamp: block-height,
        notes: notes
      }
    )

    ;; Update entity
    (map-set ontological-entities
      { id: entity-id }
      {
        name: (get name entity),
        category: (get category entity),
        consistency-score: new-score,
        last-verified: block-height,
        verifier: tx-sender
      }
    )

    (var-set next-record-id (+ record-id u1))
    (ok record-id)
  )
)

(define-read-only (get-entity (entity-id uint))
  (map-get? ontological-entities { id: entity-id })
)

(define-read-only (get-verification-record (entity-id uint) (record-id uint))
  (map-get? verification-records { entity-id: entity-id, record-id: record-id })
)

(define-read-only (is-entity-consistent (entity-id uint))
  (let ((entity (default-to { name: "", category: "", consistency-score: u0, last-verified: u0, verifier: tx-sender }
                           (map-get? ontological-entities { id: entity-id }))))
    (>= (get consistency-score entity) u70)
  )
)

