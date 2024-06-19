package main

import (
	"encoding/csv"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"time"
)

func main() {
	var verbose = *flag.Bool("v", false, "Verbosity")
	flag.Parse()

	lokiHost := os.Getenv("LOKI_HOST") // "172.16.16.13"
	lokiPort := os.Getenv("LOKI_PORT") // "31503"
	query := `{job="fluent-bit"}`
	limit := os.Getenv("LOKI_LIMIT") // 10

	if verbose {
		fmt.Printf("Host: %s:%s\nQuery: %s\nLimit: %s", lokiHost, lokiPort, query, limit)
	}

	now := time.Now()
	start := fmt.Sprintf("%d", now.Add(-time.Minute).UnixNano())
	end := fmt.Sprintf("%d", now.UnixNano())

	baseURL := fmt.Sprintf("http://%s:%s/loki/api/v1/query_range", lokiHost, lokiPort)
	if verbose {
		fmt.Println(baseURL)
	}
	params := url.Values{}
	params.Add("query", query)
	params.Add("start", start)
	params.Add("end", end)
	params.Add("limit", limit)

	requestURL := fmt.Sprintf("%s?%s", baseURL, params.Encode())

	resp, err := http.Get(requestURL)
	if err != nil {
		fmt.Println("Failed to make request", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		fmt.Println("not 200?", resp.StatusCode)
		return
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("Failed to read respbody", err)
		return
	}

	var result map[string]interface{}
	err = json.Unmarshal(body, &result)
	if err != nil {
		fmt.Println("Cant unmarshal", err)
		return
	}

	data, ok := result["data"].(map[string]interface{})
	if !ok {
		fmt.Println("Data key not found")
		return
	}

	res, ok := data["result"].([]interface{})
	if !ok {
		fmt.Println("Result key is missing")
		return
	}

	writer := csv.NewWriter(os.Stdout)
	defer writer.Flush()

	writer.Write([]string{"Container", "Instance", "Job", "Namespace", "Node", "Timestamp", "Log"})

	for _, entry := range res {
		entryMap, ok := entry.(map[string]interface{})
		if !ok {
			continue
		}

		stream, ok := entryMap["stream"].(map[string]interface{})
		if !ok {
			continue
		}

		container := fmt.Sprintf("%v", stream["container"])
		instance := fmt.Sprintf("%v", stream["instance"])
		job := fmt.Sprintf("%v", stream["job"])
		namespace := fmt.Sprintf("%v", stream["namespace"])
		node := fmt.Sprintf("%v", stream["node"])

		values, ok := entryMap["values"].([]interface{})
		if !ok {
			continue
		}

		for _, value := range values {
			valuePair, ok := value.([]interface{})
			if !ok || len(valuePair) != 2 {
				continue
			}

			timestamp := fmt.Sprintf("%v", valuePair[0])
			log := fmt.Sprintf("%v", valuePair[1])

			writer.Write([]string{container, instance, job, namespace, node, timestamp, log})
		}
	}

	writer.Flush()
	if err := writer.Error(); err != nil {
		fmt.Println("Error writing CSV to stdout", err)
	}
}
