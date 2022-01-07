module Template
  module Go
    def self.function(file_name)
      <<~APP
        // Package p contains an HTTP Cloud Function.
        package p

        import (
          "encoding/json"
          "fmt"
          "html"
          "io"
          "log"
          "net/http"
        )

        // HelloWorld prints the JSON encoded "message" field in the body
        // of the request or "Hello, World!" if there isn't one.
        func #{file_name.underscore.camelize}(w http.ResponseWriter, r *http.Request) {
          var d struct {
            Message string `json:"message"`
          }

          if err := json.NewDecoder(r.Body).Decode(&d); err != nil {
            switch err {
            case io.EOF:
              fmt.Fprint(w, "Hello World!")
              return
            default:
              log.Printf("json.NewDecoder: %v", err)
              http.Error(w, http.StatusText(http.StatusBadRequest), http.StatusBadRequest)
              return
            }
          }

          if d.Message == "" {
            fmt.Fprint(w, "Hello World!")
            return
          }
          fmt.Fprint(w, html.EscapeString(d.Message))
        }

      APP
    end
  end
end
