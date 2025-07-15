;; Model Development Contract
;; Develops and manages financial models

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u200))
(define-constant ERR-MODEL-NOT-FOUND (err u201))
(define-constant ERR-INVALID-INPUT (err u202))
(define-constant ERR-PLANNER-NOT-VERIFIED (err u203))
(define-constant ERR-MODEL-LOCKED (err u204))

;; Data Variables
(define-data-var next-model-id uint u1)
(define-data-var total-models uint u0)

;; Data Maps
(define-map models
  { model-id: uint }
  {
    creator: principal,
    planner-id: uint,
    name: (string-ascii 100),
    model-type: (string-ascii 50),
    initial-capital: uint,
    time-horizon: uint,
    risk-level: uint,
    expected-return: uint,
    created-at: uint,
    last-updated: uint,
    version: uint,
    active: bool,
    locked: bool
  }
)

(define-map model-parameters
  { model-id: uint }
  {
    inflation-rate: uint,
    market-volatility: uint,
    interest-rate: uint,
    tax-rate: uint,
    emergency-fund: uint,
    retirement-age: uint,
    life-expectancy: uint
  }
)

(define-map model-results
  { model-id: uint }
  {
    projected-value: uint,
    success-probability: uint,
    shortfall-risk: uint,
    optimal-allocation: (string-ascii 200),
    last-calculated: uint
  }
)

;; Public Functions

;; Create a new financial model
(define-public (create-model
  (planner-id uint)
  (name (string-ascii 100))
  (model-type (string-ascii 50))
  (initial-capital uint)
  (time-horizon uint)
  (risk-level uint))
  (let
    (
      (model-id (var-get next-model-id))
      (caller tx-sender)
    )
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> initial-capital u0) ERR-INVALID-INPUT)
    (asserts! (> time-horizon u0) ERR-INVALID-INPUT)
    (asserts! (<= risk-level u100) ERR-INVALID-INPUT)
    ;; Remove cross-contract call as per requirements
    (asserts! (> planner-id u0) ERR-INVALID-INPUT)

    (map-set models
      { model-id: model-id }
      {
        creator: caller,
        planner-id: planner-id,
        name: name,
        model-type: model-type,
        initial-capital: initial-capital,
        time-horizon: time-horizon,
        risk-level: risk-level,
        expected-return: (calculate-expected-return risk-level),
        created-at: block-height,
        last-updated: block-height,
        version: u1,
        active: true,
        locked: false
      }
    )

    (map-set model-parameters
      { model-id: model-id }
      {
        inflation-rate: u300,
        market-volatility: (calculate-volatility risk-level),
        interest-rate: u500,
        tax-rate: u2500,
        emergency-fund: (/ initial-capital u10),
        retirement-age: u65,
        life-expectancy: u85
      }
    )

    (var-set next-model-id (+ model-id u1))
    (var-set total-models (+ (var-get total-models) u1))

    (ok model-id)
  )
)

;; Update model parameters
(define-public (update-model-parameters
  (model-id uint)
  (inflation-rate uint)
  (market-volatility uint)
  (interest-rate uint)
  (tax-rate uint))
  (let
    (
      (model (map-get? models { model-id: model-id }))
      (caller tx-sender)
    )
    (asserts! (is-some model) ERR-MODEL-NOT-FOUND)
    (asserts! (is-eq caller (get creator (unwrap-panic model))) ERR-NOT-AUTHORIZED)
    (asserts! (not (get locked (unwrap-panic model))) ERR-MODEL-LOCKED)
    (asserts! (<= inflation-rate u1000) ERR-INVALID-INPUT)
    (asserts! (<= market-volatility u5000) ERR-INVALID-INPUT)
    (asserts! (<= interest-rate u2000) ERR-INVALID-INPUT)
    (asserts! (<= tax-rate u5000) ERR-INVALID-INPUT)

    (let
      (
        (current-params (unwrap-panic (map-get? model-parameters { model-id: model-id })))
      )
      (map-set model-parameters
        { model-id: model-id }
        (merge current-params {
          inflation-rate: inflation-rate,
          market-volatility: market-volatility,
          interest-rate: interest-rate,
          tax-rate: tax-rate
        })
      )

      (map-set models
        { model-id: model-id }
        (merge (unwrap-panic model) {
          last-updated: block-height,
          version: (+ (get version (unwrap-panic model)) u1)
        })
      )

      (ok true)
    )
  )
)

;; Calculate model projections
(define-public (calculate-projections (model-id uint))
  (let
    (
      (model (map-get? models { model-id: model-id }))
      (params (map-get? model-parameters { model-id: model-id }))
    )
    (asserts! (is-some model) ERR-MODEL-NOT-FOUND)
    (asserts! (is-some params) ERR-MODEL-NOT-FOUND)

    (let
      (
        (model-data (unwrap-panic model))
        (param-data (unwrap-panic params))
        (projected-value (calculate-future-value
          (get initial-capital model-data)
          (get expected-return model-data)
          (get time-horizon model-data)
          (get inflation-rate param-data)))
        (success-prob (calculate-success-probability
          (get risk-level model-data)
          (get market-volatility param-data)))
      )
      (map-set model-results
        { model-id: model-id }
        {
          projected-value: projected-value,
          success-probability: success-prob,
          shortfall-risk: (- u100 success-prob),
          optimal-allocation: (generate-allocation-string (get risk-level model-data)),
          last-calculated: block-height
        }
      )

      (ok projected-value)
    )
  )
)

;; Lock model for simulation
(define-public (lock-model (model-id uint))
  (let
    (
      (model (map-get? models { model-id: model-id }))
      (caller tx-sender)
    )
    (asserts! (is-some model) ERR-MODEL-NOT-FOUND)
    (asserts! (is-eq caller (get creator (unwrap-panic model))) ERR-NOT-AUTHORIZED)

    (map-set models
      { model-id: model-id }
      (merge (unwrap-panic model) {
        locked: true,
        last-updated: block-height
      })
    )

    (ok true)
  )
)

;; Unlock model
(define-public (unlock-model (model-id uint))
  (let
    (
      (model (map-get? models { model-id: model-id }))
      (caller tx-sender)
    )
    (asserts! (is-some model) ERR-MODEL-NOT-FOUND)
    (asserts! (is-eq caller (get creator (unwrap-panic model))) ERR-NOT-AUTHORIZED)

    (map-set models
      { model-id: model-id }
      (merge (unwrap-panic model) {
        locked: false,
        last-updated: block-height
      })
    )

    (ok true)
  )
)

;; Read-only Functions

;; Get model information
(define-read-only (get-model (model-id uint))
  (map-get? models { model-id: model-id })
)

;; Get model parameters
(define-read-only (get-model-parameters (model-id uint))
  (map-get? model-parameters { model-id: model-id })
)

;; Get model results
(define-read-only (get-model-results (model-id uint))
  (map-get? model-results { model-id: model-id })
)

;; Get total models count
(define-read-only (get-total-models)
  (var-get total-models)
)

;; Check if model is ready for simulation
(define-read-only (is-model-ready (model-id uint))
  (match (map-get? models { model-id: model-id })
    model (and (get active model) (not (get locked model)))
    false
  )
)

;; Private Functions

;; Calculate expected return based on risk level
(define-private (calculate-expected-return (risk-level uint))
  (+ u400 (/ (* risk-level u600) u100))
)

;; Calculate market volatility based on risk level
(define-private (calculate-volatility (risk-level uint))
  (+ u1000 (/ (* risk-level u2000) u100))
)

;; Calculate future value with inflation adjustment
(define-private (calculate-future-value (principal uint) (rate uint) (years uint) (inflation uint))
  (let
    (
      (real-rate (if (> rate inflation) (- rate inflation) u100))
      (growth-factor (+ u10000 real-rate))
    )
    (/ (* principal (pow growth-factor years)) u10000)
  )
)

;; Calculate success probability
(define-private (calculate-success-probability (risk-level uint) (volatility uint))
  (let
    (
      (base-prob u80)
      (risk-adjustment (/ risk-level u5))
      (volatility-adjustment (/ volatility u200))
    )
    (if (> (+ risk-adjustment volatility-adjustment) base-prob)
      u20
      (- base-prob (+ risk-adjustment volatility-adjustment))
    )
  )
)

;; Generate allocation string based on risk level
(define-private (generate-allocation-string (risk-level uint))
  (if (< risk-level u30)
    "Conservative: 20% Stocks, 70% Bonds, 10% Cash"
    (if (< risk-level u60)
      "Moderate: 50% Stocks, 40% Bonds, 10% Cash"
      "Aggressive: 80% Stocks, 15% Bonds, 5% Cash"
    )
  )
)
