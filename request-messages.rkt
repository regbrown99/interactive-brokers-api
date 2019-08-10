#lang racket/base

(require racket/class
         racket/contract
         (only-in racket/date
                  date->seconds)
         racket/match
         racket/string
         srfi/19)

(provide contract-details-req%
         executions-req%
         place-order-req%
         req-msg<%>
         start-api-req%)

(define/contract ibkr-msg%
  (class/c (init-field [msg-id integer?]
                       [version integer?]))
  (class object%
    (super-new)
    (init-field msg-id version)))

(define req-msg<%>
  ; method to produce a string where each element, regardless of type, is converted
  ; to a string and is null terminated. these elements converted to null-terminated
  ; strings are then all appended together to form the message string.
  (interface ()
    [->string (->m string?)]))

(define/contract contract-details-req%
  (class/c (inherit-field [msg-id integer?]
                          [version integer?])
           (init-field [request-id integer?]
                       [contract-id integer?]
                       [symbol string?]
                       [security-type (or/c 'stk 'opt 'fut 'cash 'bond 'cfd 'fop 'war 'iopt 'fwd 'bag
                                            'ind 'bill 'fund 'fixed 'slb 'news 'cmdty 'bsk 'icu 'ics #f)]
                       [expiry (or/c date? #f)]
                       [strike rational?]
                       [right (or/c 'call 'put #f)]
                       [multiplier (or/c rational? #f)]
                       [exchange string?]
                       [primary-exchange string?]
                       [currency string?]
                       [local-symbol string?]
                       [trading-class string?]
                       [security-id-type (or/c 'cusip 'sedol 'isin 'ric #f)]
                       [security-id string?]))
  (class* ibkr-msg%
    (req-msg<%>)
    (super-new [msg-id 9]
               [version 8])
    (inherit-field msg-id version)
    (init-field [request-id 0]
                [contract-id 0]
                [symbol ""]
                [security-type #f]
                [expiry #f]
                [strike 0]
                [right #f]
                [multiplier #f]
                [exchange ""]
                [primary-exchange ""]
                [currency ""]
                [local-symbol ""]
                [trading-class ""]
                [include-expired ""]
                [security-id-type #f]
                [security-id ""])
    (define/public (->string)
      (string-append
       (number->string msg-id) "\0"
       (number->string version) "\0"
       (number->string request-id) "\0"
       (number->string contract-id) "\0"
       symbol "\0"
       (if (symbol? security-type) (string-upcase (symbol->string security-type)) "") "\0"
       (if (date? expiry) (date->string expiry "~Y~m~d") "") "\0"
       (real->decimal-string strike 3) "\0"
       (if (symbol? right) (string-upcase (substring (symbol->string right) 0 1)) "") "\0"
       (if (rational? multiplier) (number->string multiplier) "") "\0"
       exchange "\0"
       primary-exchange "\0"
       currency "\0"
       local-symbol "\0"
       trading-class "\0"
       include-expired "\0"
       (if (symbol? security-id-type) (string-upcase (symbol->string security-id-type)) "") "\0"
       security-id "\0"))))

(define/contract executions-req%
  (class/c (inherit-field [msg-id integer?]
                          [version integer?])
           (init-field [request-id integer?]
                       [client-id integer?]
                       [account string?]
                       [timestamp (or/c date? #f)]
                       [symbol string?]
                       [security-type (or/c 'stk 'opt 'fut 'cash 'bond 'cfd 'fop 'war 'iopt 'fwd 'bag
                                            'ind 'bill 'fund 'fixed 'slb 'news 'cmdty 'bsk 'icu 'ics #f)]
                       [exchange string?]
                       [side (or/c 'buy 'sell 'sshort #f)]))
  (class* ibkr-msg%
    (req-msg<%>)
    (super-new [msg-id 7]
               [version 3])
    (inherit-field msg-id version)
    (init-field [request-id 0]
                [client-id 0]
                [account ""]
                [timestamp #f]
                [symbol ""]
                [security-type #f]
                [exchange ""]
                [side #f])
    (define/public (->string)
      (string-append
       (number->string msg-id) "\0"
       (number->string version) "\0"
       (number->string request-id) "\0"
       (number->string client-id) "\0"
       account "\0"
       (if (date? timestamp) (string->date timestamp "~Y~m~d-~H:~M:~S") "") "\0"
       symbol "\0"
       (if (symbol? security-type) (string-upcase (symbol->string security-type)) "") "\0"
       exchange "\0"
       (if (symbol? side) (string-upcase (symbol->string side)) "") "\0"))))

(define/contract place-order-req%
  (class/c (inherit-field [msg-id integer?]
                          [version integer?])
           (init-field [order-id integer?]
                       [contract-id integer?]
                       [symbol string?]
                       [security-type (or/c 'stk 'opt 'fut 'cash 'bond 'cfd 'fop 'war 'iopt 'fwd 'bag
                                            'ind 'bill 'fund 'fixed 'slb 'news 'cmdty 'bsk 'icu 'ics #f)]
                       [expiry (or/c date? #f)]
                       [strike rational?]
                       [right (or/c 'call 'put #f)]
                       [multiplier (or/c rational? #f)]
                       [exchange string?]
                       [primary-exchange string?]
                       [currency string?]
                       [local-symbol string?]
                       [trading-class string?]
                       [security-id-type (or/c 'cusip 'sedol 'isin 'ric #f)]
                       [security-id string?]
                       [action (or/c 'buy 'sell 'sshort)]
                       [total-quantity rational?]
                       [order-type string?]
                       [limit-price (or/c rational? #f)]
                       [aux-price (or/c rational? #f)]
                       [time-in-force (or/c 'day 'gtc 'opg 'ioc 'gtd 'gtt 'auc 'fok 'gtx 'dtc)]
                       [oca-group string?]
                       [account string?]
                       [open-close (or/c 'open 'close)]
                       [origin (or/c 'customer 'firm)]
                       [order-ref string?]
                       [transmit boolean?]
                       [parent-id integer?]
                       [block-order boolean?]
                       [sweep-to-fill boolean?]
                       [display-size integer?]
                       [trigger-method integer?]
                       [outside-rth boolean?]
                       [hidden boolean?]
                       [combo-legs list?]
                       [order-combo-legs (listof rational?)]
                       [smart-combo-routing-params list?]
                       [discretionary-amount (or/c rational? #f)]
                       [good-after-time (or/c date? #f)]
                       [good-till-date (or/c date? #f)]
                       [advisor-group string?]
                       [advisor-method string?]
                       [advisor-percentage string?]
                       [advisor-profile string?]
                       [model-code string?]
                       [short-sale-slot (or/c 0 1 2)]
                       [designated-location string?]
                       [exempt-code integer?]
                       [oca-type integer?]
                       [rule-80-a string?]
                       [settling-firm string?]
                       [all-or-none boolean?]
                       [minimum-quantity (or/c integer? #f)]
                       [percent-offset (or/c rational? #f)]
                       [electronic-trade-only boolean?]
                       [firm-quote-only boolean?]
                       [nbbo-price-cap (or/c rational? #f)]
                       [auction-strategy (or/c 'match 'improvement 'transparent #f)]
                       [starting-price rational?]
                       [stock-ref-price rational?]
                       [delta (or/c rational? #f)]
                       [stock-range-lower rational?]
                       [stock-range-upper rational?]
                       [override-percentage-constraints boolean?]
                       [volatility (or/c rational? #f)]
                       [volatility-type (or/c integer? #f)]
                       [delta-neutral-order-type string?]
                       [delta-neutral-aux-price (or/c rational? #f)]
                       [continuous-update integer?]
                       [reference-price-type (or/c integer? #f)]
                       [trailing-stop-price (or/c rational? #f)]
                       [trailing-percent (or/c rational? #f)]
                       [scale-init-level-size (or/c integer? #f)]
                       [scale-subs-level-size (or/c integer? #f)]
                       [scale-price-increment (or/c rational? #f)]
                       [scale-price-adjust-value (or/c rational? #f)]
                       [scale-price-adjust-interval (or/c integer? #f)]
                       [scale-profit-offset (or/c rational? #f)]
                       [scale-auto-reset boolean?]
                       [scale-init-position (or/c integer? #f)]
                       [scale-init-fill-quantity (or/c integer? #f)]
                       [scale-random-percent boolean?]
                       [scale-table string?]
                       [active-start-time string?]
                       [active-stop-time string?]
                       [hedge-type string?]
                       [hedge-param string?]
                       [opt-out-smart-routing boolean?]
                       [clearing-account string?]
                       [clearing-intent (or/c 'ib 'away 'pta #f)]
                       [not-held boolean?]
                       [delta-neutral-contract-id (or/c integer? #f)]
                       [delta-neutral-delta (or/c rational? #f)]
                       [delta-neutral-price (or/c rational? #f)]
                       [algo-strategy string?]
                       [algo-id string?]
                       [what-if boolean?]
                       [order-misc-options string?]
                       [solicited boolean?]
                       [randomize-size boolean?]
                       [randomize-price boolean?]
                       [reference-contract-id integer?]
                       [is-pegged-change-amount-decrease boolean?]
                       [pegged-change-amount rational?]
                       [reference-change-amount rational?]
                       [reference-exchange-id string?]
                       [conditions list?]
                       [adjusted-order-type (or/c 'mkt 'lmt 'stp 'stp-limit 'rel 'trail 'box-top 'fix-pegged 'lit 'lmt-+-mkt
                                                  'loc 'mit 'mkt-prt 'moc 'mtl 'passv-rel 'peg-bench 'peg-mid 'peg-mkt 'peg-prim
                                                  'peg-stk 'rel-+-lmt 'rel-+-mkt 'snap-mid 'snap-mkt 'snap-prim 'stp-prt
                                                  'trail-limit 'trail-lit 'trail-lmt-+-mkt 'trail-mit 'trail-rel-+-mkt 'vol
                                                  'vwap 'quote 'ppv 'pdv 'pmv 'psv #f)]
                       [trigger-price rational?]
                       [limit-price-offset rational?]
                       [adjusted-stop-price rational?]
                       [adjusted-stop-limit-price rational?]
                       [adjusted-trailing-amount rational?]
                       [adjusted-trailing-unit integer?]
                       [ext-operator string?]
                       [soft-dollar-tier-name string?]
                       [soft-dollar-tier-value string?]))
  (class* ibkr-msg%
    (req-msg<%>)
    (super-new [msg-id 3]
               [version 45])
    (inherit-field msg-id version)
    (init-field [order-id 0]
                [contract-id 0]
                [symbol ""]
                [security-type #f]
                [expiry #f]
                [strike 0]
                [right #f]
                [multiplier #f]
                [exchange ""]
                [primary-exchange ""]
                [currency ""]
                [local-symbol ""]
                [trading-class ""]
                [security-id-type #f]
                [security-id ""]
                ; default from Order
                [action 'buy]
                [total-quantity 0]
                ; default from Order
                [order-type "LMT"]
                [limit-price #f]
                [aux-price #f]
                ; default from Order
                [time-in-force 'day]
                [oca-group ""]
                [account ""]
                ; default from Order
                [open-close 'open]
                [origin 'customer]
                [order-ref ""]
                ; default from Order
                [transmit #t]
                [parent-id 0]
                [block-order #f]
                [sweep-to-fill #f]
                [display-size 0]
                [trigger-method 0]
                [outside-rth #f]
                [hidden #f]
                ; not handled at this moment
                [combo-legs (list)]
                ; not handled at this moment
                [order-combo-legs (list)]
                ; not handled at this moment
                [smart-combo-routing-params (list)]
                [discretionary-amount #f]
                [good-after-time #f]
                [good-till-date #f]
                [advisor-group ""]
                [advisor-method ""]
                [advisor-percentage ""]
                [advisor-profile ""]
                [model-code ""]
                [short-sale-slot 0]
                [designated-location ""]
                [exempt-code -1]
                [oca-type 0]
                [rule-80-a ""]
                [settling-firm ""]
                [all-or-none #f]
                [minimum-quantity #f]
                [percent-offset #f]
                [electronic-trade-only #f]
                [firm-quote-only #f]
                [nbbo-price-cap #f]
                [auction-strategy #f]
                [starting-price 0]
                [stock-ref-price 0]
                [delta #f]
                [stock-range-lower 0]
                [stock-range-upper 0]
                [override-percentage-constraints #f]
                [volatility #f]
                [volatility-type #f]
                [delta-neutral-order-type ""]
                [delta-neutral-aux-price #f]
                [continuous-update 0]
                [reference-price-type #f]
                [trailing-stop-price #f]
                [trailing-percent #f]
                [scale-init-level-size #f]
                [scale-subs-level-size #f]
                [scale-price-increment #f]
                [scale-price-adjust-value #f]
                [scale-price-adjust-interval #f]
                [scale-profit-offset #f]
                [scale-auto-reset #f]
                [scale-init-position #f]
                [scale-init-fill-quantity #f]
                [scale-random-percent #f]
                [scale-table ""]
                [active-start-time ""]
                [active-stop-time ""]
                [hedge-type ""]
                [hedge-param ""]
                [opt-out-smart-routing #f]
                [clearing-account ""]
                [clearing-intent #f]
                [not-held #f]
                [delta-neutral-contract-id #f]
                [delta-neutral-delta #f]
                [delta-neutral-price #f]
                [algo-strategy ""]
                [algo-id ""]
                [what-if #f]
                [order-misc-options ""]
                [solicited #f]
                [randomize-size #f]
                [randomize-price #f]
                [reference-contract-id 0]
                [is-pegged-change-amount-decrease #f]
                [pegged-change-amount 0]
                [reference-change-amount 0]
                [reference-exchange-id ""]
                [conditions (list)]
                [adjusted-order-type #f]
                [trigger-price 0]
                [limit-price-offset 0]
                [adjusted-stop-price 0]
                [adjusted-stop-limit-price 0]
                [adjusted-trailing-amount 0]
                [adjusted-trailing-unit 0]
                [ext-operator ""]
                [soft-dollar-tier-name ""]
                [soft-dollar-tier-value ""])
    (define/public (->string)
      (string-append
       (number->string msg-id) "\0"
       (number->string version) "\0"
       (number->string order-id) "\0"
       (number->string contract-id) "\0"
       symbol "\0"
       (if (symbol? security-type) (string-upcase (symbol->string security-type)) "") "\0"
       (if (date? expiry) (date->string expiry "~Y~m~d") "") "\0"
       (real->decimal-string strike 3) "\0"
       (if (symbol? right) (string-upcase (substring (symbol->string right) 0 1)) "") "\0"
       (if (rational? multiplier) (number->string multiplier) "") "\0"
       exchange "\0"
       primary-exchange "\0"
       currency "\0"
       local-symbol "\0"
       trading-class "\0"
       (if (symbol? security-id-type) (string-upcase (symbol->string security-id-type)) "") "\0"
       security-id "\0"
       (string-upcase (symbol->string action)) "\0"
       (real->decimal-string total-quantity 3) "\0"
       order-type "\0"
       (if (rational? limit-price) (real->decimal-string limit-price 3) "") "\0"
       (if (rational? aux-price) (real->decimal-string aux-price 3) "") "\0"
       (string-upcase (symbol->string time-in-force)) "\0"
       oca-group "\0"
       account "\0"
       (string-upcase (substring (symbol->string open-close) 0 1)) "\0"
       (match origin
         ['customer "0"]
         ['firm "1"])
       "\0"
       order-ref "\0"
       (if transmit "1" "0") "\0"
       (number->string parent-id) "\0"
       (if block-order "1" "0") "\0"
       (if sweep-to-fill "1" "0") "\0"
       (number->string display-size) "\0"
       (number->string trigger-method) "\0"
       (if outside-rth "1" "0") "\0"
       (if hidden "1" "0") "\0"
       ; combo-legs not handled at this moment
       ; order-combo-legs not handled at this moment
       ; smart-combo-routing-params not handled at this moment
       ; deprecated shares-allocation
       "\0"
       (if (rational? discretionary-amount) (real->decimal-string discretionary-amount 3) "") "\0"
       (if (date? good-after-time)
           (string-append (date->string good-after-time "~Y~m~d ~H:~M:~S ")
                          ; convert from date to date* which has time zone name
                          (date*-time-zone-name (seconds->date (date->seconds good-after-time))))
           "")
       "\0"
       (if (date? good-till-date) (date->string good-till-date "~Y~m~d") "") "\0"
       advisor-group "\0"
       advisor-method "\0"
       advisor-percentage "\0"
       advisor-profile "\0"
       model-code "\0"
       (number->string short-sale-slot) "\0"
       designated-location "\0"
       (number->string exempt-code) "\0"
       (number->string oca-type) "\0"
       rule-80-a "\0"
       settling-firm "\0"
       (if all-or-none "1" "0") "\0"
       (if (integer? minimum-quantity) (number->string minimum-quantity) "") "\0"
       (if (rational? percent-offset) (real->decimal-string percent-offset 3) "") "\0"
       (if electronic-trade-only "1" "0") "\0"
       (if firm-quote-only "1" "0") "\0"
       (if (rational? nbbo-price-cap) (real->decimal-string nbbo-price-cap 3) "") "\0"
       (match auction-strategy
         ['match "1"]
         ['improvement "2"]
         ['transparent "3"]
         [_ "0"])
       "\0"
       (real->decimal-string starting-price 3) "\0"
       (real->decimal-string stock-ref-price 3) "\0"
       (if (rational? delta) (real->decimal-string delta 3) "") "\0"
       (real->decimal-string stock-range-lower 3) "\0"
       (real->decimal-string stock-range-upper 3) "\0"
       (if override-percentage-constraints "1" "0") "\0"
       (if (rational? volatility) (real->decimal-string (* 100 volatility) 3) "") "\0"
       (if (integer? volatility-type) (number->string volatility-type) "") "\0"
       ; there is some additional logic surrounding the delta neutral order type but
       ; it is currently unknown how to properly construct it, so we'll send nothing
       "" "\0"
       (if (rational? delta-neutral-aux-price) (real->decimal-string delta-neutral-aux-price 3) "") "\0"
       (number->string continuous-update) "\0"
       (if (integer? reference-price-type) (number->string reference-price-type) "") "\0"
       (if (rational? trailing-stop-price) (real->decimal-string trailing-stop-price 3) "") "\0"
       (if (rational? trailing-percent) (real->decimal-string (* 100 trailing-percent) 3) "") "\0"
       (if (integer? scale-init-level-size) (number->string scale-init-level-size) "") "\0"
       (if (integer? scale-subs-level-size) (number->string scale-subs-level-size) "") "\0"
       (if (rational? scale-price-increment)
           (string-append
            (real->decimal-string scale-price-increment 3) "\0"
            (if (rational? scale-price-adjust-value) (real->decimal-string scale-price-adjust-value 3) "") "\0"
            (if (integer? scale-price-adjust-interval) (number->string scale-price-adjust-interval) "") "\0"
            (if (rational? scale-profit-offset) (real->decimal-string scale-profit-offset 3) "") "\0"
            (if scale-auto-reset "1" "0") "\0"
            (if (integer? scale-init-position) (number->string scale-init-position) "") "\0"
            (if (integer? scale-init-fill-quantity) (number->string scale-init-fill-quantity) "") "\0"
            (if scale-random-percent "1" "0"))
           "\0")
       scale-table "\0"
       active-start-time "\0"
       active-stop-time "\0"
       ; there is some additional logic surrounding hedge type and hedge param but it is
       ; currently unknown which values are acceptable, so we'll send nothing
       "" "\0"
       (if opt-out-smart-routing "1" "0") "\0"
       clearing-account "\0"
       (match clearing-intent
         ['ib "IB"]
         ['away "Away"]
         ['pta "PTA"]
         [_ ""])
       "\0"
       (if not-held "1" "0") "\0"
       (if (and (integer? delta-neutral-contract-id)
                (rational? delta-neutral-delta)
                (rational? delta-neutral-price))
           (string-append
            "1" "\0"
            (number->string delta-neutral-contract-id) "\0"
            (real->decimal-string delta-neutral-delta 3) "\0"
            (real->decimal-string delta-neutral-price 3))
           "0")
       "\0"
       ; there is additional logic with algo strategy that we are not sure of
       ; so we send nothing for now
       "" "\0"
       ; related to algo strategy above, we send nothing for algo id
       "" "\0"
       (if what-if "1" "0") "\0"
       order-misc-options "\0"
       (if solicited "1" "0") "\0"
       (if randomize-size "1" "0") "\0"
       (if randomize-price "1" "0") "\0"
       (if (equal? order-type 'peg-bench)
           (string-append
            (number->string reference-contract-id) "\0"
            (if is-pegged-change-amount-decrease "1" "0") "\0"
            (real->decimal-string pegged-change-amount 3) "\0"
            (real->decimal-string reference-change-amount 3) "\0"
            reference-exchange-id "\0")
           "")
       ; extra logic surrounding conditions we're not sure how to represent
       "0" "\0"
       (if (symbol? adjusted-order-type)
           (string-replace (string-upcase (symbol->string order-type)) "-" " ")
           "")
       "\0"
       (real->decimal-string trigger-price 3) "\0"
       (real->decimal-string limit-price-offset 3) "\0"
       (real->decimal-string adjusted-stop-price 3) "\0"
       (real->decimal-string adjusted-stop-limit-price 3) "\0"
       (real->decimal-string adjusted-trailing-amount 3) "\0"
       (number->string adjusted-trailing-unit) "\0"
       ext-operator "\0"
       soft-dollar-tier-name "\0"
       soft-dollar-tier-value "\0"))))

(define/contract start-api-req%
  (class/c (inherit-field [msg-id integer?]
                          [version integer?])
           (init-field [client-id integer?]))
  (class* ibkr-msg%
    (req-msg<%>)
    (super-new [msg-id 71]
               [version 2])
    (inherit-field msg-id version)
    (init-field [client-id 0])
    (define/public (->string)
      (string-append
       (number->string msg-id) "\0"
       (number->string version) "\0"
       (number->string client-id) "\0"
       ; optional capabilities not used currently
       "\0"))))