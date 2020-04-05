package plan

type nineSig struct {

}

const (
	nineSigStockETF = "TQQQ"
	nineSigBondETF = "AGG"
)

// NewNineSig returns a new instance of a 9Sig plan
func NewNineSig() Plan {
	return &nineSig{}
}

func (n *nineSig) GetBalance(symbol string) float64 {
	return 123.45
}

func (n *nineSig) GetCashBalance() float64 {
	return 123.45
}

func (n *nineSig) GetNextAction(prev *Holding) (*Holding, error) {
	target := prev.LastBalance * 1.09
	current := n.GetBalance(nineSigStockETF)
	if current < target {
		// We are below our target for the period. Sell bond and buy index to make up the difference
		amt := target - current
		n.DoTrade(nineSigBondETF, nineSigStockETF, amt)
	} else if current > target {
		// We are above our target for the period. Sell index and move excess to bond
		amt := target - current
		n.DoTrade(nineSigStockETF, nineSigBondETF, amt)
	}
}

func (n *nineSig) DoTrade(from, to string, amt float64) {
	n.Sell(from, amt)
	n.Buy(to, n.GetCashBalance())
}

func (n *nineSig) Buy(symbol string, amt float64) {

}

func (n *nineSig) Sell(symbol string, amt float64) {
	
}