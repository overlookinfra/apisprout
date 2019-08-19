package main

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/getkin/kin-openapi/openapi3"
	"github.com/spf13/viper"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

var localServerTests = []struct {
	name string
	in   []string
	out  []string
}{
	{
		"No servers",
		[]string{},
		[]string{},
	},
	{
		"Same path",
		[]string{
			"https://api.example.com/v1",
			"https://beta.api.example.com/v1",
		},
		[]string{
			"https://api.example.com/v1",
			"https://beta.api.example.com/v1",
			"http://localhost:8000/v1",
		},
	},
	{
		"Includes localhost already",
		[]string{
			"https://api.example.com/v1",
			"http://localhost:8000/v1",
		},
		[]string{
			"https://api.example.com/v1",
			"http://localhost:8000/v1",
		},
	},
	{
		"Invalid URL",
		[]string{
			"http://192.168.0.%31/",
		},
		[]string{},
	},
}

func TestAddLocalServers(t *testing.T) {
	viper.SetDefault("port", 8000)
	for _, tt := range localServerTests {
		t.Run(tt.name, func(t *testing.T) {
			servers := make([]*openapi3.Server, len(tt.in))
			for i, u := range tt.in {
				servers[i] = &openapi3.Server{
					URL: u,
				}
			}

			s := &openapi3.Swagger{
				Servers: servers,
			}

			err := addLocalServers(s)
			if len(tt.in) > 0 && len(tt.out) == 0 {
				assert.Error(t, err)
				return
			}
			assert.NoError(t, err)

			results := make([]string, 0, len(tt.out))
			for _, server := range s.Servers {
				results = append(results, server.URL)
			}

			assert.Equal(t, tt.out, results)
		})
	}
}

func TestMediaTypes(t *testing.T) {
	const schema = `{
		"paths": {
			"/test": {
				"get": {
					"summary": "Test",
					"responses": {
						"200": {
							"content": {
								"%s": {
									"schema": {
										type": "boolean",
										"example": true
									}
								}
							}
						}
					}
				}
			}
		}
	}`

	tests := []struct {
		MediaType  string
		StatusCode int
	}{
		{
			MediaType:  "application/json",
			StatusCode: http.StatusOK,
		},
		{
			MediaType:  "application/vnd.test-api+json",
			StatusCode: http.StatusOK,
		},
		{
			MediaType:  "application/yaml",
			StatusCode: http.StatusOK,
		},
		{
			MediaType:  "application/x-yaml",
			StatusCode: http.StatusOK,
		},
		{
			MediaType:  "application/vnd.test-api+yaml",
			StatusCode: http.StatusOK,
		},
		{
			MediaType:  "text/yaml",
			StatusCode: http.StatusOK,
		},
		{
			MediaType:  "text/x-yaml",
			StatusCode: http.StatusOK,
		},
		{
			MediaType:  "text/vnd.test-api+yaml",
			StatusCode: http.StatusOK,
		},
		{
			MediaType:  "text/vnd.test-api+xml",
			StatusCode: http.StatusInternalServerError,
		},
		{
			MediaType:  "application/json-with-extensions",
			StatusCode: http.StatusInternalServerError,
		},
	}
	for _, test := range tests {
		t.Run(test.MediaType, func(t *testing.T) {
			_, router, err := load("file:///swagger.json", []byte(fmt.Sprintf(schema, test.MediaType)))
			require.NoError(t, err)
			require.NotNil(t, router)

			rr := NewRefreshableRouter()
			rr.Set(router)

			req, err := http.NewRequest("GET", "/test", nil)
			require.NoError(t, err)

			resp := httptest.NewRecorder()
			handler(rr).ServeHTTP(resp, req)

			assert.Equal(t, test.StatusCode, resp.Code)
		})
	}
}
