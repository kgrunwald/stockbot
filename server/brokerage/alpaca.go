package brokerage

import (
	"fmt"
	"os"
	"time"

	"github.com/alpacahq/alpaca-trade-api-go/alpaca"
	"github.com/alpacahq/alpaca-trade-api-go/common"
	"github.com/alpacahq/alpaca-trade-api-go/polygon"
	"github.com/shopspring/decimal"
)

type alpacaApi struct {
	client *alpaca.Client
	polygon *polygon.Client
}

func newAlpacaApi() Brokerage {
	k := common.APIKey{ID: os.Getenv("POLYGON_API_KEY")}
	return &alpacaApi{
		client: alpaca.NewClient(common.Credentials()),
		polygon: polygon.NewClient(&k),
	}
}

func (a *alpacaApi) GetAccountBalance() (decimal.Decimal, error) {
	acct, err := a.client.GetAccount()
	if err != nil {
		return decimal.Decimal{}, err
	}

	return acct.PortfolioValue, nil
}

func (a *alpacaApi) GetPreviousValue(symbol string) (float32, error) {
	a.shouldSkip(symbol)
	// res, err := a.getQuarterBars(time.Now().Add(-1 * time.Hour * 24 * 265 * 2), time.Now(), symbol)
	// if err != nil {
	// 	return 0, err
	// }
	// for _, tick := range res {
	// 	fmt.Printf("Tick: %s  Close $%f\n", time.Unix(tick.EpochMilliseconds / 1000, 0).Format(time.RFC3339), tick.High)
	// }
	return 0, nil
}

func (a *alpacaApi) getQuarterBars(start, end time.Time, symbol string) ([]polygon.AggTick, error) {
	var q polygon.AggType = "day"
	res, err := a.polygon.GetHistoricAggregatesV2(symbol, 1, q, &start, &end, nil)
	if err != nil {
		return []polygon.AggTick{}, err
	}

	// for _, tick := range res.Ticks {
	// 	fmt.Printf("Tick: %s  Close $%f\n", time.Unix(tick.EpochMilliseconds / 1000, 0).Format(time.RFC3339), tick.High)
	// }

	return res.Ticks, nil
}

func (a *alpacaApi) getPreviousClose(symbol string, date time.Time) (float64, error) {
	start := date.AddDate(0, 0, -5)
	res, err := a.polygon.GetHistoricAggregatesV2(symbol, 1, polygon.Day, &start, &date, nil)
	if err != nil {
		return 0, err
	}

	tick := res.Ticks[res.ResultsCount - 1]
	day := time.Unix(tick.EpochMilliseconds / 1000, 0)
	dayStr := day.Format("2006-01-02")
	fmt.Printf("[%s] Close: %f.\n", dayStr, tick.Close)
	return tick.Close, nil
}

func (a *alpacaApi) shouldSkip(symbol string) (error) {
	// Are we in 30 down?
		// If a Q closes down 30% from high in the last 2 years, skip 1 sell, up to 2 years

		// 1 Count # of 30 down events
		// for each Q going back 2 years
		count := 0
		for i := 0; i < 8; i++ {
			isDown, err := a.isQuarter30Down(time.Now().AddDate(0, -3 * i, 0), symbol)
			if err != nil {
				return err
			}
			if isDown {
				count++
			}
		}

		return nil
			// Did Q close down 30% from prev 2 years?
		
		// Count # of Sell signals going back 2 years.
		// for each Q going back 2 years
			// Did Q close up > 9% from prev Q?

		// if # sell events < # 30 down events, skip next sell event.
}

func (a *alpacaApi) isQuarter30Down(quarter time.Time, symbol string) (bool, error) {
	ticks, err := a.getQuarterBars(quarter.AddDate(-2, 0, 0), quarter, symbol)
	if err != nil {
		return false, err
	}

	high := float64(0)
	for _, tick := range ticks {
		if tick.High > high {
			high = tick.High
		}
	}

	quarterStr := quarter.Format("2006-01-02")
	fmt.Printf("[%s] 2 year high: %f.\n", quarterStr, high)

	prevClose, err := a.getPreviousClose(symbol, quarter)
	if err != nil {
		return false, err
	}

	prevQuarterClose, err := a.getPreviousClose(symbol, quarter.AddDate(0, -3, 0))
	if err != nil {
		return false, err
	}

	growthRatio := (prevClose / (prevQuarterClose * 1.09))
	growthPercetage := 0.
	action := "SELL"
	if growthRatio < 1.09 {
		action = "BUY"
	}
	if growthRatio >= 1 {
		growthPercetage = (growthRatio - 1.) * 100.
	} else {
		growthPercetage = (1. - growthRatio) * -100.
	}

	fmt.Printf("[%s] Growth: %f [%s]\n", quarterStr, growthPercetage, action)
	thirtyDown := prevClose <= high * 0.7
	fmt.Printf("[%s] 30 Down: %t.\n\n\n", quarterStr, thirtyDown)
	return thirtyDown, nil
}