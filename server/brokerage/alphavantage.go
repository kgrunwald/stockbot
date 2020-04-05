package brokerage

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
)

type MonthlyResponse struct {
	Data map[string]MonthlyData `json:"Monthly Time Series"`
}

type MonthlyData struct {
	Open string `json:"1. open"`
	Close string `json:"4. close"`
}

func GetLast2YearHigh(symbol string) (float32, error) {
	q := url.Values{}
	q.Add("function", "TIME_SERIES_MONTHLY")
	q.Add("apikey", os.Getenv("ALPHA_API_KEY"))
	q.Add("symbol", symbol)
	url := url.URL{
		Scheme: "https",
		Host: "www.alphavantage.co",
		Path: "/query",
		RawQuery: q.Encode(),
	}
	
	req, err := http.NewRequest("GET", url.String(), nil)
	if err != nil {
		return 0, err
	}

	client := http.DefaultClient
	res, err := client.Do(req)
	if err != nil {
		return 0, err
	}

	defer res.Body.Close()
	b, _ := ioutil.ReadAll(res.Body)
	monthlyResponse := &MonthlyResponse{}
	if err = json.Unmarshal(b, monthlyResponse); err != nil {
		return 0, err
	}
	fmt.Printf("%+v\n", monthlyResponse.Data)
	return 0, nil
}