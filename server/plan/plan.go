package plan

import "time"

type Plan interface {
	GetBalance() float32
}

type PlanAction string

const (
	Buy PlanAction = "BUY"
	Sell PlanAction = "SELL"
	Skip PlanAction = "SKIP"
	None PlanAction = "NONE"
)

type Holding struct {
	Symbol string
	LastBalance float64
	LastAction time.Time
	Action PlanAction
}